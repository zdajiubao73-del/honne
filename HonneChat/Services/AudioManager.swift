import AVFoundation
import Combine
import SwiftUI

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published var isMuted = false

    // BGM: current player + next player for crossfade loop
    private var bgmPlayer: AVAudioPlayer?
    private var bgmNextPlayer: AVAudioPlayer?
    private var currentBGM: String?
    private var currentBGMURL: URL?
    private var crossfadeScheduleTimer: Timer?   // triggers crossfade at end of track
    private var crossfadeProgressTimer: Timer?   // animates the volume transition
    private let crossfadeDuration: TimeInterval = 4.0

    // ASMR: ambient environmental sounds (volume ~0.55)
    private var asmrPlayer: AVAudioPlayer?
    private var currentASMR: String?
    private var currentASMRVolume: Float = 0.55

    private var bgmFadeTimer: Timer?
    private var asmrFadeTimer: Timer?
    private var duckTimer: Timer?
    private var isDucked = false
    private let duckedBGMVolume: Float  = 0.04
    private let duckedASMRVolume: Float = 0.03

    private let bgmVolume: Float  = 0.25
    private let asmrVolume: Float = 0.40

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    // MARK: - Public API

    func play(bgm bgmFileName: String, asmr asmrFileName: String? = nil, asmrVolume: Float? = nil) {
        playBGM(bgmFileName)
        if let asmr = asmrFileName {
            currentASMRVolume = asmrVolume ?? self.asmrVolume
            playASMR(asmr)
        }
    }

    func stop() {
        stopBGM()
        stopASMR()
    }

    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            fadeBGMOut(toZero: true)
            fadeASMROut(toZero: true)
            bgmNextPlayer?.volume = 0
        } else {
            fadeBGMIn()
            fadeASMRIn()
        }
    }

    // MARK: - BGM

    private func playBGM(_ fileName: String) {
        guard currentBGM != fileName else { return }
        currentBGM = fileName

        if bgmPlayer?.isPlaying == true {
            fadeBGMOut { [weak self] in
                self?.startBGMPlayback(fileName: fileName)
            }
        } else {
            startBGMPlayback(fileName: fileName)
        }
    }

    private func startBGMPlayback(fileName: String) {
        guard let url = findAudioURL(fileName) else {
            print("BGM file not found: \(fileName).{mp3,m4a,wav,aac}")
            return
        }
        currentBGMURL = url
        crossfadeScheduleTimer?.invalidate()
        crossfadeProgressTimer?.invalidate()
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.volume = 0
            bgmPlayer?.prepareToPlay()
            bgmPlayer?.play()
            if !isMuted { fadeBGMIn() }
            scheduleCrossfade()
        } catch {
            print("Failed to play BGM: \(error)")
        }
    }

    /// 曲終了の `crossfadeDuration` 秒前にクロスフェードを予約する
    private func scheduleCrossfade() {
        crossfadeScheduleTimer?.invalidate()
        guard let player = bgmPlayer,
              let url = currentBGMURL,
              player.duration > crossfadeDuration * 2 else {
            // 短すぎる曲はそのままループ
            bgmPlayer?.numberOfLoops = -1
            return
        }
        let delay = player.duration - crossfadeDuration
        crossfadeScheduleTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.performCrossfade(url: url)
        }
    }

    /// 現在の再生を徐々にフェードアウトしながら、次のループをフェードイン
    private func performCrossfade(url: URL) {
        guard let currentPlayer = bgmPlayer else { return }
        do {
            let nextPlayer = try AVAudioPlayer(contentsOf: url)
            nextPlayer.volume = 0
            nextPlayer.prepareToPlay()
            nextPlayer.play()
            bgmNextPlayer = nextPlayer

            let steps = 40
            let interval = crossfadeDuration / Double(steps)
            let target = bgmVolume
            var step = 0

            crossfadeProgressTimer?.invalidate()
            crossfadeProgressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
                guard let self else { timer.invalidate(); return }
                step += 1
                let progress = Float(step) / Float(steps)
                if !self.isMuted {
                    nextPlayer.volume = target * progress
                    currentPlayer.volume = target * (1 - progress)
                }
                if step >= steps {
                    timer.invalidate()
                    self.crossfadeProgressTimer = nil
                    currentPlayer.stop()
                    self.bgmPlayer = nextPlayer
                    self.bgmNextPlayer = nil
                    self.scheduleCrossfade()
                }
            }
        } catch {
            print("Crossfade failed, falling back to loop: \(error)")
            bgmPlayer?.numberOfLoops = -1
        }
    }

    private func stopBGM() {
        crossfadeScheduleTimer?.invalidate()
        crossfadeScheduleTimer = nil
        crossfadeProgressTimer?.invalidate()
        crossfadeProgressTimer = nil
        currentBGMURL = nil
        fadeBGMOut { [weak self] in
            self?.bgmPlayer?.stop()
            self?.bgmPlayer = nil
            self?.bgmNextPlayer?.stop()
            self?.bgmNextPlayer = nil
            self?.currentBGM = nil
        }
    }

    private func fadeBGMIn(duration: TimeInterval = 1.5) {
        bgmFadeTimer?.invalidate()
        let target = bgmVolume
        let steps = 30
        let interval = duration / Double(steps)
        var step = 0
        bgmFadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            step += 1
            self?.bgmPlayer?.volume = target * Float(step) / Float(steps)
            if step >= steps { timer.invalidate() }
        }
    }

    private func fadeBGMOut(toZero: Bool = false, duration: TimeInterval = 0.8, completion: (() -> Void)? = nil) {
        bgmFadeTimer?.invalidate()
        let start = bgmPlayer?.volume ?? 0
        let steps = 16
        let interval = duration / Double(steps)
        var step = 0
        bgmFadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            step += 1
            self?.bgmPlayer?.volume = start * (1 - Float(step) / Float(steps))
            if step >= steps {
                timer.invalidate()
                if !toZero { completion?() }
            }
        }
    }

    // MARK: - ASMR

    private func playASMR(_ fileName: String) {
        guard currentASMR != fileName else { return }
        currentASMR = fileName

        if asmrPlayer?.isPlaying == true {
            fadeASMROut { [weak self] in
                self?.startASMRPlayback(fileName: fileName)
            }
        } else {
            startASMRPlayback(fileName: fileName)
        }
    }

    private func startASMRPlayback(fileName: String) {
        guard let url = findAudioURL(fileName) else {
            print("ASMR file not found: \(fileName).{mp3,m4a,wav,aac}")
            return
        }
        do {
            asmrPlayer = try AVAudioPlayer(contentsOf: url)
            asmrPlayer?.numberOfLoops = -1
            asmrPlayer?.volume = 0
            asmrPlayer?.prepareToPlay()
            asmrPlayer?.play()
            if !isMuted { fadeASMRIn() }
        } catch {
            print("Failed to play ASMR: \(error)")
        }
    }

    private func stopASMR() {
        fadeASMROut { [weak self] in
            self?.asmrPlayer?.stop()
            self?.asmrPlayer = nil
            self?.currentASMR = nil
        }
    }

    private func fadeASMRIn(duration: TimeInterval = 2.0) {
        asmrFadeTimer?.invalidate()
        let target = currentASMRVolume
        let steps = 40
        let interval = duration / Double(steps)
        var step = 0
        asmrFadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            step += 1
            self?.asmrPlayer?.volume = target * Float(step) / Float(steps)
            if step >= steps { timer.invalidate() }
        }
    }

    private func fadeASMROut(toZero: Bool = false, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        asmrFadeTimer?.invalidate()
        let start = asmrPlayer?.volume ?? 0
        let steps = 20
        let interval = duration / Double(steps)
        var step = 0
        asmrFadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            step += 1
            self?.asmrPlayer?.volume = start * (1 - Float(step) / Float(steps))
            if step >= steps {
                timer.invalidate()
                if !toZero { completion?() }
            }
        }
    }

    // MARK: - BGM Ducking (TTS用)

    func duckBGM() {
        guard !isDucked else { return }
        isDucked = true
        duckTimer?.invalidate()
        let steps = 10
        let interval = 0.3 / Double(steps)
        let bgmStart  = bgmPlayer?.volume  ?? bgmVolume
        let asmrStart = asmrPlayer?.volume ?? currentASMRVolume
        let bgmTarget  = duckedBGMVolume
        let asmrTarget = duckedASMRVolume
        var step = 0
        duckTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            step += 1
            let progress = Float(step) / Float(steps)
            if !self.isMuted {
                self.bgmPlayer?.volume  = bgmStart  + (bgmTarget  - bgmStart)  * progress
                self.asmrPlayer?.volume = asmrStart + (asmrTarget - asmrStart) * progress
            }
            if step >= steps { timer.invalidate() }
        }
    }

    func unduckBGM() {
        guard isDucked else { return }
        isDucked = false
        duckTimer?.invalidate()
        guard !isMuted else { return }
        let steps = 15
        let interval = 0.6 / Double(steps)
        let bgmStart  = bgmPlayer?.volume  ?? duckedBGMVolume
        let asmrStart = asmrPlayer?.volume ?? duckedASMRVolume
        let bgmTarget  = bgmVolume
        let asmrTarget = currentASMRVolume
        var step = 0
        duckTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            step += 1
            let progress = Float(step) / Float(steps)
            self.bgmPlayer?.volume  = bgmStart  + (bgmTarget  - bgmStart)  * progress
            self.asmrPlayer?.volume = asmrStart + (asmrTarget - asmrStart) * progress
            if step >= steps { timer.invalidate() }
        }
    }

    // MARK: - Helpers

    private func findAudioURL(_ fileName: String) -> URL? {
        let extensions = ["mp3", "m4a", "wav", "aac"]
        return extensions.compactMap {
            Bundle.main.url(forResource: fileName, withExtension: $0)
        }.first
    }
}
