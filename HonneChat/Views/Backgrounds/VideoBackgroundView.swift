import AVFoundation
import SwiftUI
import UIKit

struct VideoBackgroundView: UIViewRepresentable {
    let videoFileName: String

    func makeUIView(context: Context) -> VideoPlayerUIView {
        VideoPlayerUIView(videoFileName: videoFileName)
    }

    func updateUIView(_ uiView: VideoPlayerUIView, context: Context) {}
}

final class VideoPlayerUIView: UIView {

    // 2つのコンテナ（UIView）にそれぞれAVPlayerLayerを載せる
    private let containerA = UIView()
    private let containerB = UIView()
    private var playerA: AVPlayer?
    private var playerB: AVPlayer?
    private var layerA: AVPlayerLayer?
    private var layerB: AVPlayerLayer?

    private var videoURL: URL?
    private var videoDuration: Double = 0
    private var activeIsA = true

    private var timeObserver: Any?
    private var observedPlayer: AVPlayer?
    private var foregroundObserver: NSObjectProtocol?
    private var backgroundObserver: NSObjectProtocol?

    private let crossfadeDuration: TimeInterval = 1.2
    private let gradientMaskLayer = CAGradientLayer()

    init(videoFileName: String) {
        super.init(frame: .zero)
        setupContainers()
        setupGradientMask()
        setupPlayers(videoFileName: videoFileName)
        setupLifecycleObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupGradientMask() {
        // Fade bottom ~20% to transparent — naturally hides any watermark
        gradientMaskLayer.colors = [
            UIColor.black.cgColor,
            UIColor.black.cgColor,
            UIColor.clear.cgColor
        ]
        gradientMaskLayer.locations = [0, 0.75, 1.0]
        gradientMaskLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientMaskLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.mask = gradientMaskLayer
    }

    private func setupContainers() {
        containerA.alpha = 1
        containerB.alpha = 0
        addSubview(containerA)
        addSubview(containerB)
    }

    private func setupPlayers(videoFileName: String) {
        guard let url = Bundle.main.url(forResource: videoFileName, withExtension: "mp4") else {
            return
        }
        videoURL = url

        let pA = AVPlayer(playerItem: AVPlayerItem(asset: AVURLAsset(url: url)))
        pA.isMuted = true
        let lA = AVPlayerLayer(player: pA)
        lA.videoGravity = .resizeAspectFill
        containerA.layer.addSublayer(lA)

        let pB = AVPlayer(playerItem: AVPlayerItem(asset: AVURLAsset(url: url)))
        pB.isMuted = true
        let lB = AVPlayerLayer(player: pB)
        lB.videoGravity = .resizeAspectFill
        containerB.layer.addSublayer(lB)

        playerA = pA
        playerB = pB
        layerA = lA
        layerB = lB

        pA.play()

        // 動画の長さを取得してタイムオブザーバーを設定
        Task {
            let asset = AVURLAsset(url: url)
            guard let duration = try? await asset.load(.duration) else { return }
            await MainActor.run {
                videoDuration = duration.seconds
                resetTimeObserver(for: pA)
            }
        }
    }

    // MARK: - Crossfade

    private func resetTimeObserver(for player: AVPlayer?) {
        // 古いオブザーバーを削除
        if let timeObserver, let observedPlayer {
            observedPlayer.removeTimeObserver(timeObserver)
            self.timeObserver = nil
            self.observedPlayer = nil
        }

        guard let player, videoDuration > crossfadeDuration * 2 else { return }

        let triggerTime = CMTime(
            seconds: videoDuration - crossfadeDuration,
            preferredTimescale: 600
        )

        timeObserver = player.addBoundaryTimeObserver(
            forTimes: [NSValue(time: triggerTime)],
            queue: .main
        ) { [weak self] in
            self?.crossfade()
        }
        observedPlayer = player
    }

    private func crossfade() {
        // 次のプレイヤーを先頭から再生開始
        let nextPlayer = activeIsA ? playerB : playerA
        let nextContainer = activeIsA ? containerB : containerA
        let currentContainer = activeIsA ? containerA : containerB

        nextPlayer?.seek(to: .zero)
        nextPlayer?.play()

        // 映像を直接クロスフェード（黒にならない）
        UIView.animate(withDuration: crossfadeDuration, delay: 0, options: .curveEaseInOut) {
            nextContainer.alpha = 1
            currentContainer.alpha = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            self.activeIsA.toggle()
            // 新しいアクティブプレイヤーにタイムオブザーバーを移す
            self.resetTimeObserver(for: nextPlayer)
        }
    }

    // MARK: - Lifecycle

    private func setupLifecycleObservers() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.playerA?.pause()
            self?.playerB?.pause()
        }

        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            (self.activeIsA ? self.playerA : self.playerB)?.play()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerA.frame = bounds
        containerB.frame = bounds
        layerA?.frame = containerA.bounds
        layerB?.frame = containerB.bounds
        gradientMaskLayer.frame = bounds
    }

    deinit {
        if let timeObserver, let observedPlayer {
            observedPlayer.removeTimeObserver(timeObserver)
        }
        playerA?.pause()
        playerB?.pause()
        if let foregroundObserver { NotificationCenter.default.removeObserver(foregroundObserver) }
        if let backgroundObserver { NotificationCenter.default.removeObserver(backgroundObserver) }
    }
}
