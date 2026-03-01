import SwiftUI

struct WarpTransitionView: View {
    @EnvironmentObject var appState: AppState
    let situation: Situation
    @State private var phase: WarpPhase = .idle
    @State private var warpLines: [WarpLine] = []
    @State private var circleScale: CGFloat = 0.01
    @State private var circleOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var blurAmount: CGFloat = 0
    @State private var whiteFlash: Double = 0

    enum WarpPhase {
        case idle, gathering, warping, arriving, complete
    }

    var body: some View {
        ZStack {
            // Base background
            Color.black.ignoresSafeArea()

            // Destination gradient (reveals at end)
            LinearGradient(
                gradient: Gradient(colors: situation.gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .opacity(phase == .arriving || phase == .complete ? 1 : 0)

            // Warp speed lines
            Canvas { context, size in
                for line in warpLines {
                    let centerX = size.width / 2
                    let centerY = size.height / 2
                    let angle = line.angle
                    let startDist = line.startDistance * max(size.width, size.height)
                    let endDist = line.endDistance * max(size.width, size.height)

                    let startPoint = CGPoint(
                        x: centerX + cos(angle) * startDist,
                        y: centerY + sin(angle) * startDist
                    )
                    let endPoint = CGPoint(
                        x: centerX + cos(angle) * endDist,
                        y: centerY + sin(angle) * endDist
                    )

                    var path = Path()
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)

                    context.opacity = line.opacity
                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [
                                .clear,
                                line.color.opacity(0.8),
                                .white
                            ]),
                            startPoint: startPoint,
                            endPoint: endPoint
                        ),
                        lineWidth: line.width
                    )
                }
            }
            .ignoresSafeArea()

            // Center gathering circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .white,
                            situation.gradientColors.last ?? .blue,
                            .clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .scaleEffect(circleScale)
                .opacity(circleOpacity)

            // White flash overlay
            Color.white
                .ignoresSafeArea()
                .opacity(whiteFlash)

            // Situation name reveal
            VStack(spacing: 12) {
                Text(situation.emoji)
                    .font(.system(size: 60))
                Text(situation.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(situation.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .opacity(textOpacity)
            .scaleEffect(textOpacity > 0 ? 1 : 0.8)
        }
        .blur(radius: blurAmount)
        .onAppear {
            startWarpSequence()
        }
    }

    private func startWarpSequence() {
        // Generate warp lines
        warpLines = (0..<80).map { _ in
            WarpLine(
                angle: Double.random(in: 0...(2 * .pi)),
                startDistance: 0,
                endDistance: 0,
                width: CGFloat.random(in: 1...3),
                opacity: 0,
                color: [Color.white, Color.cyan, Color(hex: "a0a0ff"), situation.gradientColors.first ?? .blue].randomElement()!
            )
        }

        // Phase 1: Gathering (0.0 - 0.8s)
        phase = .gathering
        withAnimation(.easeIn(duration: 0.8)) {
            circleScale = 0.15
            circleOpacity = 0.6
        }

        // Start animating warp lines
        for i in warpLines.indices {
            let delay = Double.random(in: 0...0.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: 0.6)) {
                    warpLines[i].startDistance = 0
                    warpLines[i].endDistance = 0.1
                    warpLines[i].opacity = 0.5
                }
            }
        }

        // Phase 2: Warp (0.8 - 1.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            phase = .warping
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()

            withAnimation(.easeIn(duration: 0.6)) {
                circleScale = 3.0
                circleOpacity = 1.0
            }

            for i in warpLines.indices {
                withAnimation(.easeIn(duration: 0.5)) {
                    warpLines[i].endDistance = 1.2
                    warpLines[i].opacity = 1.0
                    warpLines[i].width = CGFloat.random(in: 2...5)
                }
            }
        }

        // Phase 3: White flash (1.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeIn(duration: 0.15)) {
                whiteFlash = 1.0
            }
        }

        // Phase 4: Arriving (1.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            phase = .arriving
            warpLines = []

            withAnimation(.easeOut(duration: 0.5)) {
                whiteFlash = 0
                circleOpacity = 0
            }

            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                textOpacity = 1.0
            }
        }

        // Phase 5: Complete - transition to chat (3.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                textOpacity = 0
                blurAmount = 10
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                appState.isTransitioning = false
                appState.showChat = true
            }
        }
    }
}

struct WarpLine {
    var angle: Double
    var startDistance: Double
    var endDistance: Double
    var width: CGFloat
    var opacity: Double
    var color: Color
}
