import AVFoundation
import Combine

class TTSService: NSObject, ObservableObject {
    static let shared = TTSService()

    @Published var isSpeaking = false

    private let ttsEndpoint    = "https://eknsaizgeonuundwrifm.supabase.co/functions/v1/tts"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbnNhaXpnZW9udXVuZHdyaWZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyNTEyMjIsImV4cCI6MjA4NzgyNzIyMn0.ccc-ai1IcblBWGHe8e7VRo3uIzFIp1nX93C6pnLhI8s"

    // AVAudioEngine でギャップなしのシームレス再生
    private let audioEngine = AVAudioEngine()
    private let playerNode  = AVAudioPlayerNode()
    private var currentTask: Task<Void, Never>?
    private var finishContinuation: CheckedContinuation<Void, Never>?

    private override init() {
        super.init()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: nil)
    }

    // MARK: - Voice Types

    enum VoiceType: String, CaseIterable {
        /// 落ち着いた男性声
        case male = "male"
        /// やわらかい女性声
        case female = "female"

        var displayName: String {
            switch self {
            case .male:   return "男性（落ち着き）"
            case .female: return "女性（やわらか）"
            }
        }

        var icon: String {
            switch self {
            case .male:   return "person.fill"
            case .female: return "person"
            }
        }

    }

    // MARK: - Persistent Preferences (UserDefaults)

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "ttsEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "ttsEnabled")
            DispatchQueue.main.async { self.objectWillChange.send() }
            if !newValue { stop() }
        }
    }

    var selectedVoice: VoiceType {
        get { VoiceType(rawValue: UserDefaults.standard.string(forKey: "ttsVoice") ?? "") ?? .female }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "ttsVoice")
            DispatchQueue.main.async { self.objectWillChange.send() }
        }
    }

    // MARK: - Public API

    func speak(_ text: String) {
        guard isEnabled else { return }
        currentTask?.cancel()
        stopEngine()
        let cleaned = cleanText(text)
        let voice = selectedVoice
        currentTask = Task { [weak self] in
            guard let self, !Task.isCancelled else { return }
            // 前処理はサーバーサイド（GPT-4o）で実施するため、クリーニング済みテキストをそのまま送信
            guard let data = await self.fetchAudio(text: cleaned, voice: voice) else { return }
            guard !Task.isCancelled else { return }
            await self.play(data)
        }
    }

    func stop() {
        currentTask?.cancel()
        stopEngine()
    }

    // MARK: - Playback

    /// 音声データを1バッファで再生する
    private func play(_ data: Data) async {
        guard let buffer = makeBuffer(from: data) else { return }

        await MainActor.run {
            AudioManager.shared.duckBGM()
            isSpeaking = true
        }

        // playerNode の接続フォーマットをバッファに合わせて設定
        audioEngine.disconnectNodeOutput(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: buffer.format)

        do { try audioEngine.start() } catch {
            print("AudioEngine start error: \(error)")
            return
        }

        await withCheckedContinuation { [weak self] (cont: CheckedContinuation<Void, Never>) in
            guard let self else { cont.resume(); return }
            self.finishContinuation = cont
            self.playerNode.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) { [weak self] _ in
                self?.onPlaybackComplete()
            }
            self.playerNode.play()
        }
    }

    private func onPlaybackComplete() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isSpeaking = false
            AudioManager.shared.unduckBGM()
            let cont = self.finishContinuation
            self.finishContinuation = nil
            cont?.resume()
        }
    }

    private func stopEngine() {
        playerNode.stop()
        if audioEngine.isRunning { audioEngine.stop() }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isSpeaking = false
            AudioManager.shared.unduckBGM()
            let cont = self.finishContinuation
            self.finishContinuation = nil
            cont?.resume()
        }
    }

    /// MP3 Data → AVAudioPCMBuffer（一時ファイル経由でデコード）
    private func makeBuffer(from data: Data) -> AVAudioPCMBuffer? {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mp3")
        do {
            try data.write(to: tmp)
            defer { try? FileManager.default.removeItem(at: tmp) }
            let file = try AVAudioFile(forReading: tmp)
            guard let buf = AVAudioPCMBuffer(
                pcmFormat: file.processingFormat,
                frameCapacity: AVAudioFrameCount(file.length)
            ) else { return nil }
            try file.read(into: buf)
            return buf
        } catch {
            print("makeBuffer error: \(error)")
            return nil
        }
    }

    // MARK: - Network

    private func fetchAudio(text: String, voice: VoiceType) async -> Data? {
        guard let url = URL(string: ttsEndpoint) else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        req.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "text": text,
            "voice": voice.rawValue
        ])
        guard let (data, res) = try? await URLSession.shared.data(for: req),
              (res as? HTTPURLResponse)?.statusCode == 200 else { return nil }
        return data
    }


    // MARK: - Preprocessing

    /// 記号などを整理するだけのシンプルなクリーニング（ひらがな変換はサーバーサイドで実施）
    private func cleanText(_ text: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: "...", with: "、")
        result = result.replacingOccurrences(of: "…", with: "、")
        result = result.replacingOccurrences(of: "、、", with: "、")
        result = result.replacingOccurrences(of: "**", with: "")
        result = result.replacingOccurrences(of: "*", with: "")
        return result
    }


}
