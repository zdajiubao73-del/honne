import AVFoundation
import SwiftUI

struct WarpTransitionView: View {
    @EnvironmentObject var appState: AppState
    let situation: Situation

    @State private var animationStartTime: Date = .distantPast
    @State private var warpSpeed: Double = 0
    @State private var warpLineOpacity: Double = 0
    @State private var bloomOpacity: Double = 0
    @State private var bloomScale: Double = 0.01
    @State private var backgroundOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textScale: Double = 0.88
    @State private var thumbnailImage: UIImage?
    @State private var thumbnailOpacity: Double = 0

    var body: some View {
        ZStack {
            // 1. Destination gradient — reveals at breakthrough
            LinearGradient(
                gradient: Gradient(colors: situation.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(backgroundOpacity)

            // 2. Black void base
            Color.black.ignoresSafeArea()
                .opacity(max(0, 1 - backgroundOpacity * 2))

            // 3. Warp tunnel — TimelineView drives 60fps Canvas animation
            TimelineView(.animation) { timeline in
                let elapsed = timeline.date.timeIntervalSince(animationStartTime)
                Canvas { ctx, size in
                    drawWarpTunnel(&ctx, size: size, elapsed: elapsed, speed: warpSpeed)
                }
                .ignoresSafeArea()
            }
            .opacity(warpLineOpacity)

            // 4. Energy bloom portal (no white flash — expands outward instead)
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(i == 0 ? 1.0 : 0.5 - Double(i) * 0.15),
                                    Color.cyan.opacity(0.7 - Double(i) * 0.15),
                                    (situation.gradientColors.first ?? .blue).opacity(0.4),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100 + CGFloat(i) * 70
                            )
                        )
                        .frame(width: 200 + CGFloat(i) * 140,
                               height: 200 + CGFloat(i) * 140)
                        .scaleEffect(bloomScale * (1.0 + Double(i) * 0.35))
                        .opacity(bloomOpacity * max(0, 1.0 - Double(i) * 0.22))
                }
            }
            .blendMode(.screen)

            // 5. Situation text reveal
            VStack(spacing: 20) {
                // シチュエーション写真（ビデオサムネイル）
                Group {
                    if let thumbnailImage {
                        Image(uiImage: thumbnailImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.55),
                                                (situation.gradientColors.first ?? .blue).opacity(0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(
                                color: (situation.gradientColors.first ?? .blue).opacity(0.75),
                                radius: 28, x: 0, y: 8
                            )
                            .shadow(color: .white.opacity(0.25), radius: 12, x: 0, y: -2)
                            .opacity(thumbnailOpacity)
                    } else {
                        // フォールバック: 絵文字
                        Text(situation.emoji)
                            .font(.system(size: 64))
                            .shadow(color: .white.opacity(0.9), radius: 20)
                            .shadow(
                                color: (situation.gradientColors.first ?? .blue).opacity(0.7),
                                radius: 40
                            )
                    }
                }

                Text(situation.name)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .white.opacity(0.6), radius: 12)

                Text(situation.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(textOpacity)
            .scaleEffect(textScale)
        }
        .onAppear {
            animationStartTime = Date()
            loadThumbnail()
            runWarpSequence()
        }
    }

    // MARK: - Thumbnail Loading

    private func loadThumbnail() {
        guard let videoFileName = situation.videoFileName,
              let url = Bundle.main.url(forResource: videoFileName, withExtension: "mp4") else { return }

        Task.detached(priority: .userInitiated) {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 480, height: 360)

            let time = CMTime(seconds: 2.0, preferredTimescale: 600)
            guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else { return }
            let image = UIImage(cgImage: cgImage)

            await MainActor.run {
                thumbnailImage = image
                withAnimation(.easeIn(duration: 0.4)) {
                    thumbnailOpacity = 1.0
                }
            }
        }
    }

    // MARK: - Warp Tunnel Rendering

    private func drawWarpTunnel(_ ctx: inout GraphicsContext,
                                size: CGSize,
                                elapsed: Double,
                                speed: Double) {
        guard speed > 0.01 else { return }

        let cx = size.width / 2
        let cy = size.height / 2
        let maxR = max(size.width, size.height) * 0.8
        let accent = situation.gradientColors.first ?? Color.blue

        // Three rings of lines — outer ring is brightest, creates depth illusion
        let configs: [(count: Int, trail: Double, width: CGFloat, colors: [Color])] = [
            (80, 0.22, 2.0, [.clear, Color.cyan.opacity(0.85), .white]),
            (50, 0.18, 1.4, [.clear, accent.opacity(0.65), Color.cyan.opacity(0.75)]),
            (35, 0.14, 0.9, [.clear, Color(red: 0.65, green: 0.65, blue: 1.0).opacity(0.55),
                             accent.opacity(0.55)])
        ]

        for (ci, cfg) in configs.enumerated() {
            let phaseShift = Double(ci) * 0.33

            for i in 0..<cfg.count {
                let angle = (Double(i) / Double(cfg.count)) * 2 * .pi
                let lineOffset = Double(i) / Double(cfg.count)

                // Continuous stream: t loops 0→1, each line is at a different offset
                let rawT = fmod(elapsed * speed * 0.45 + lineOffset + phaseShift, 1.0)
                let t = rawT * rawT  // Quadratic ease → acceleration feel

                let trailLen = min(cfg.trail * speed / 1.5, 0.35)
                let tailT = max(0.0, t - trailLen)

                let startR = tailT * maxR
                let endR = min(t * maxR, maxR * 1.4)
                guard endR > startR + 3 else { continue }

                let s = CGPoint(x: cx + cos(angle) * startR,
                                y: cy + sin(angle) * startR)
                let e = CGPoint(x: cx + cos(angle) * endR,
                                y: cy + sin(angle) * endR)

                var path = Path()
                path.move(to: s)
                path.addLine(to: e)

                ctx.opacity = sin(t * .pi) * 0.85
                ctx.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: cfg.colors),
                        startPoint: s,
                        endPoint: e
                    ),
                    lineWidth: cfg.width * CGFloat(0.4 + t * 0.7)
                )
            }
        }
    }

    // MARK: - Animation Sequence

    private func runWarpSequence() {
        let med = UIImpactFeedbackGenerator(style: .medium)
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        med.prepare()
        heavy.prepare()

        // Phase 1: Build-up (0.0 – 0.6s)
        withAnimation(.easeIn(duration: 0.6)) {
            warpSpeed = 1.2
            warpLineOpacity = 0.8
            bloomScale = 0.18
            bloomOpacity = 0.55
        }

        // Phase 2: Full warp (0.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            med.impactOccurred()
            withAnimation(.easeIn(duration: 0.5)) {
                warpSpeed = 3.5
                warpLineOpacity = 1.0
                bloomScale = 0.55
                bloomOpacity = 0.9
            }
        }

        // Phase 3: Breakthrough — bloom explodes outward, destination reveals (1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            heavy.impactOccurred()

            withAnimation(.spring(response: 0.38, dampingFraction: 0.58)) {
                bloomScale = 5.0
                bloomOpacity = 0.0
            }
            withAnimation(.easeOut(duration: 0.12)) {
                warpLineOpacity = 0
            }
            withAnimation(.easeIn(duration: 0.55).delay(0.08)) {
                backgroundOpacity = 1.0
            }
        }

        // Phase 4: Arrival — text appears (1.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.78)) {
                textOpacity = 1.0
                textScale = 1.0
            }
        }

        // Phase 5: Exit to chat (3.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
            withAnimation(.easeInOut(duration: 0.35)) {
                textOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                appState.isTransitioning = false
                appState.showChat = true
            }
        }
    }
}
