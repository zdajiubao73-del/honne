import AVFoundation
import SwiftUI

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @Published var isMuted = false

    private var audioPlayer: AVAudioPlayer?
    private var currentBGM: String?
    private var fadeTimer: Timer?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    func play(bgm fileName: String) {
        guard currentBGM != fileName else { return }
        currentBGM = fileName

        // Fade out current
        if audioPlayer?.isPlaying == true {
            fadeOut { [weak self] in
                self?.startPlayback(fileName: fileName)
            }
        } else {
            startPlayback(fileName: fileName)
        }
    }

    private func startPlayback(fileName: String) {
        // Try to find the audio file in the bundle
        // Supports .mp3 and .m4a formats
        let extensions = ["mp3", "m4a", "wav", "aac"]
        var url: URL?

        for ext in extensions {
            if let bundleURL = Bundle.main.url(forResource: fileName, withExtension: ext) {
                url = bundleURL
                break
            }
        }

        guard let audioURL = url else {
            print("BGM file not found: \(fileName) (add \(fileName).mp3 to your project)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.numberOfLoops = -1 // Loop forever
            audioPlayer?.volume = isMuted ? 0 : 0.4
            audioPlayer?.prepareToPlay()

            // Fade in
            audioPlayer?.volume = 0
            audioPlayer?.play()
            fadeIn()
        } catch {
            print("Failed to play BGM: \(error)")
        }
    }

    func stop() {
        fadeOut { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
            self?.currentBGM = nil
        }
    }

    func toggleMute() {
        isMuted.toggle()

        if isMuted {
            fadeOut(toZero: true)
        } else {
            fadeIn()
        }
    }

    private func fadeIn(duration: TimeInterval = 1.0) {
        fadeTimer?.invalidate()
        let targetVolume: Float = 0.4
        let steps = 20
        let interval = duration / Double(steps)
        var currentStep = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            currentStep += 1
            let progress = Float(currentStep) / Float(steps)
            self?.audioPlayer?.volume = targetVolume * progress

            if currentStep >= steps {
                timer.invalidate()
            }
        }
    }

    private func fadeOut(toZero: Bool = false, duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()
        let startVolume = audioPlayer?.volume ?? 0
        let steps = 10
        let interval = duration / Double(steps)
        var currentStep = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            currentStep += 1
            let progress = Float(currentStep) / Float(steps)
            self?.audioPlayer?.volume = startVolume * (1 - progress)

            if currentStep >= steps {
                timer.invalidate()
                if !toZero {
                    completion?()
                }
            }
        }
    }
}
