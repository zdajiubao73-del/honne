import SwiftUI

// MARK: - Universal Particle Background System

struct ParticleBackgroundView: View {
    let situation: Situation
    @State private var time: Double = 0
    let timer = Timer.publish(every: 1/30, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: situation.gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Particle layer
            particleLayer
                .ignoresSafeArea()

            // Atmospheric overlay
            atmosphericOverlay
                .ignoresSafeArea()
        }
        .onReceive(timer) { _ in
            time += 1/30
        }
    }

    @ViewBuilder
    private var particleLayer: some View {
        switch situation.particleType {
        case .stars:
            StarryNightCanvas(time: time)
        case .fire:
            CampfireCanvas(time: time)
        case .rain:
            RainCanvas(time: time)
        case .sunset:
            SunsetCanvas(time: time)
        case .barLights:
            BarLightsCanvas(time: time)
        case .leaves:
            LeavesCanvas(time: time)
        case .snow:
            SnowCanvas(time: time)
        case .cityLights:
            CityLightsCanvas(time: time)
        case .steam:
            SteamCanvas(time: time)
        case .dust:
            DustCanvas(time: time)
        case .cherry:
            CherryBlossomCanvas(time: time)
        case .waves:
            WavesCanvas(time: time)
        case .fireflies:
            FirefliesCanvas(time: time)
        case .aurora:
            AuroraCanvas(time: time)
        case .lanterns:
            LanternsCanvas(time: time)
        }
    }

    @ViewBuilder
    private var atmosphericOverlay: some View {
        // Vignette effect for all situations
        RadialGradient(
            gradient: Gradient(colors: [.clear, .black.opacity(0.4)]),
            center: .center,
            startRadius: 200,
            endRadius: 500
        )
    }
}

// MARK: - ★ Starry Night

struct StarryNightCanvas: View {
    let time: Double
    @State private var stars: [StarParticle] = (0..<120).map { _ in StarParticle() }
    @State private var shootingStars: [ShootingStar] = []

    var body: some View {
        Canvas { context, size in
            // Stars
            for star in stars {
                let twinkle = sin(time * star.twinkleSpeed + star.twinkleOffset)
                let alpha = star.baseAlpha + twinkle * 0.3
                let center = CGPoint(
                    x: star.x * size.width,
                    y: star.y * size.height
                )
                let currentSize = star.size * (1 + twinkle * 0.2)

                // Glow
                context.opacity = alpha * 0.3
                context.fill(
                    Circle().path(in: CGRect(
                        x: center.x - currentSize * 2,
                        y: center.y - currentSize * 2,
                        width: currentSize * 4,
                        height: currentSize * 4
                    )),
                    with: .color(.white)
                )
                // Core
                context.opacity = alpha
                context.fill(
                    Circle().path(in: CGRect(
                        x: center.x - currentSize / 2,
                        y: center.y - currentSize / 2,
                        width: currentSize,
                        height: currentSize
                    )),
                    with: .color(.white)
                )
            }

            // Shooting stars
            for star in shootingStars {
                let progress = star.progress
                let tailLength: CGFloat = 80
                let headX = star.startX * size.width + progress * star.dx * size.width
                let headY = star.startY * size.height + progress * star.dy * size.height
                let tailX = headX - star.dx * tailLength
                let tailY = headY - star.dy * tailLength

                var path = Path()
                path.move(to: CGPoint(x: tailX, y: tailY))
                path.addLine(to: CGPoint(x: headX, y: headY))

                context.opacity = (1 - progress) * 0.8
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [.clear, .white]),
                        startPoint: CGPoint(x: tailX, y: tailY),
                        endPoint: CGPoint(x: headX, y: headY)
                    ),
                    lineWidth: 2
                )
            }
        }
        .onAppear {
            // Trigger shooting stars periodically
            Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                if Double.random(in: 0...1) > 0.3 {
                    addShootingStar()
                }
            }
        }
    }

    private func addShootingStar() {
        var star = ShootingStar()
        star.startX = Double.random(in: 0.1...0.9)
        star.startY = Double.random(in: 0...0.3)
        star.dx = Double.random(in: 0.3...0.6)
        star.dy = Double.random(in: 0.1...0.3)
        shootingStars.append(star)

        withAnimation(.linear(duration: 1.5)) {
            if let idx = shootingStars.indices.last {
                shootingStars[idx].progress = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            shootingStars.removeFirst()
        }
    }
}

struct StarParticle {
    var x = Double.random(in: 0...1)
    var y = Double.random(in: 0...0.7)
    var size = Double.random(in: 1...4)
    var baseAlpha = Double.random(in: 0.3...0.9)
    var twinkleSpeed = Double.random(in: 1...4)
    var twinkleOffset = Double.random(in: 0...(2 * .pi))
}

struct ShootingStar {
    var startX: Double = 0.5
    var startY: Double = 0.1
    var dx: Double = 0.5
    var dy: Double = 0.2
    var progress: Double = 0
}

// MARK: - 🔥 Campfire

struct CampfireCanvas: View {
    let time: Double
    @State private var flames: [FlameParticle] = (0..<60).map { _ in FlameParticle() }
    @State private var embers: [EmberParticle] = (0..<25).map { _ in EmberParticle() }

    var body: some View {
        Canvas { context, size in
            let firebaseY = size.height * 0.85
            let firebaseX = size.width * 0.5

            // Fire glow
            context.opacity = 0.15 + sin(time * 3) * 0.05
            context.fill(
                Circle().path(in: CGRect(
                    x: firebaseX - 150,
                    y: firebaseY - 200,
                    width: 300,
                    height: 300
                )),
                with: .color(Color(hex: "ff6600"))
            )

            // Flames
            for flame in flames {
                let age = (time * flame.speed).truncatingRemainder(dividingBy: 1.0)
                let x = firebaseX + flame.offsetX * 40 + sin(time * flame.wobble) * 15
                let y = firebaseY - age * 150
                let alpha = (1 - age) * flame.maxAlpha
                let currentSize = flame.size * (1 - age * 0.5)

                let color: Color = age < 0.3 ? Color(hex: "ffee00") :
                                   age < 0.6 ? Color(hex: "ff8800") :
                                   Color(hex: "ff3300")

                context.opacity = alpha
                context.fill(
                    Ellipse().path(in: CGRect(
                        x: x - currentSize / 2,
                        y: y - currentSize,
                        width: currentSize,
                        height: currentSize * 1.5
                    )),
                    with: .color(color)
                )
            }

            // Embers floating up
            for ember in embers {
                let age = (time * ember.speed + ember.offset).truncatingRemainder(dividingBy: 1.0)
                let x = firebaseX + ember.offsetX * 60 + sin(time * 2 + ember.offset) * 30
                let y = firebaseY - age * size.height * 0.5
                let alpha = (1 - age) * 0.8

                context.opacity = alpha
                context.fill(
                    Circle().path(in: CGRect(x: x - 2, y: y - 2, width: 4, height: 4)),
                    with: .color(Color(hex: "ffaa00"))
                )
            }
        }
    }
}

struct FlameParticle {
    var offsetX = Double.random(in: -1...1)
    var speed = Double.random(in: 0.5...1.5)
    var wobble = Double.random(in: 2...5)
    var size = Double.random(in: 8...25)
    var maxAlpha = Double.random(in: 0.4...0.8)
}

struct EmberParticle {
    var offsetX = Double.random(in: -1.5...1.5)
    var speed = Double.random(in: 0.2...0.5)
    var offset = Double.random(in: 0...1)
}

// MARK: - 🌧 Rain

struct RainCanvas: View {
    let time: Double
    @State private var drops: [RainDrop] = (0..<100).map { _ in RainDrop() }

    var body: some View {
        Canvas { context, size in
            // Rain drops
            for drop in drops {
                let y = ((drop.y + time * drop.speed).truncatingRemainder(dividingBy: 1.2)) - 0.1
                let x = drop.x + sin(time * 0.5) * 0.02

                let startPoint = CGPoint(x: x * size.width, y: y * size.height)
                let endPoint = CGPoint(
                    x: startPoint.x + 2,
                    y: startPoint.y + drop.length
                )

                var path = Path()
                path.move(to: startPoint)
                path.addLine(to: endPoint)

                context.opacity = drop.opacity
                context.stroke(
                    path,
                    with: .color(.white.opacity(0.4)),
                    lineWidth: drop.width
                )
            }

            // Window condensation effect (subtle)
            for i in 0..<5 {
                let x = Double(i) * 0.2 + 0.1
                let streakY = (time * 0.1).truncatingRemainder(dividingBy: 1.0)
                context.opacity = 0.03
                context.fill(
                    Ellipse().path(in: CGRect(
                        x: x * size.width - 10,
                        y: streakY * size.height,
                        width: 20,
                        height: 60
                    )),
                    with: .color(.white)
                )
            }
        }
    }
}

struct RainDrop {
    var x = Double.random(in: 0...1)
    var y = Double.random(in: -0.1...1.1)
    var speed = Double.random(in: 0.3...0.8)
    var length = Double.random(in: 10...30)
    var width = Double.random(in: 0.5...1.5)
    var opacity = Double.random(in: 0.2...0.6)
}

// MARK: - 🌅 Sunset

struct SunsetCanvas: View {
    let time: Double

    var body: some View {
        Canvas { context, size in
            // Sun
            let sunY = size.height * 0.55 + sin(time * 0.1) * 5
            let sunX = size.width * 0.5

            // Sun glow
            context.opacity = 0.3
            context.fill(
                Circle().path(in: CGRect(
                    x: sunX - 100, y: sunY - 100, width: 200, height: 200
                )),
                with: .radialGradient(
                    Gradient(colors: [Color(hex: "ff6600"), .clear]),
                    center: CGPoint(x: sunX, y: sunY),
                    startRadius: 30,
                    endRadius: 100
                )
            )

            // Sun core
            context.opacity = 0.8
            context.fill(
                Circle().path(in: CGRect(
                    x: sunX - 35, y: sunY - 35, width: 70, height: 70
                )),
                with: .color(Color(hex: "ff8844"))
            )

            // Light particles
            for i in 0..<30 {
                let angle = Double(i) * (2 * .pi / 30) + time * 0.2
                let dist = 60 + sin(time * 2 + Double(i)) * 20
                let px = sunX + cos(angle) * dist
                let py = sunY + sin(angle) * dist * 0.5
                let alpha = 0.2 + sin(time * 3 + Double(i) * 0.5) * 0.1

                context.opacity = alpha
                context.fill(
                    Circle().path(in: CGRect(x: px - 2, y: py - 2, width: 4, height: 4)),
                    with: .color(Color(hex: "ffcc66"))
                )
            }

            // Wave reflections at bottom
            for i in 0..<8 {
                let waveY = size.height * 0.75 + Double(i) * 15
                let waveOffset = sin(time * 1.5 + Double(i) * 0.5) * 20

                var path = Path()
                path.move(to: CGPoint(x: 0, y: waveY))
                for x in stride(from: 0, to: size.width, by: 5) {
                    let y = waveY + sin(x / 40 + time * 2 + Double(i)) * 3
                    path.addLine(to: CGPoint(x: x + waveOffset, y: y))
                }

                context.opacity = 0.1 - Double(i) * 0.01
                context.stroke(path, with: .color(Color(hex: "ffaa44")), lineWidth: 1)
            }
        }
    }
}

// MARK: - 🥃 Bar Lights

struct BarLightsCanvas: View {
    let time: Double

    var body: some View {
        Canvas { context, size in
            // Warm ambient lights
            let lights: [(x: Double, y: Double, color: String)] = [
                (0.2, 0.15, "ff8844"),
                (0.5, 0.1, "ffaa66"),
                (0.8, 0.2, "ff6633"),
                (0.35, 0.3, "cc6644"),
                (0.65, 0.25, "ffbb77"),
            ]

            for (i, light) in lights.enumerated() {
                let pulse = sin(time * 1.5 + Double(i) * 1.2) * 0.1
                let x = light.x * size.width
                let y = light.y * size.height
                let radius: CGFloat = 80 + CGFloat(pulse * 20)

                context.opacity = 0.08 + pulse
                context.fill(
                    Circle().path(in: CGRect(
                        x: x - radius, y: y - radius,
                        width: radius * 2, height: radius * 2
                    )),
                    with: .color(Color(hex: light.color))
                )
            }

            // Bokeh effects
            for i in 0..<15 {
                let x = (Double(i) * 0.07 + 0.02).truncatingRemainder(dividingBy: 1.0)
                let y = Double.random(in: 0.1...0.4)
                let pulse = sin(time * 2 + Double(i) * 0.8) * 0.5 + 0.5
                let bSize: CGFloat = CGFloat(10 + pulse * 8)

                context.opacity = 0.05 + pulse * 0.03
                context.fill(
                    Circle().path(in: CGRect(
                        x: x * size.width - bSize / 2,
                        y: y * size.height - bSize / 2,
                        width: bSize, height: bSize
                    )),
                    with: .color(Color(hex: "ffcc88"))
                )
            }
        }
    }
}

// MARK: - 🌿 Leaves

struct LeavesCanvas: View {
    let time: Double
    @State private var leaves: [LeafParticle] = (0..<20).map { _ in LeafParticle() }

    var body: some View {
        Canvas { context, size in
            // Sunbeams
            for i in 0..<5 {
                let angle = Double(i) * 0.3 - 0.3
                let startX = size.width * (0.3 + Double(i) * 0.1)

                var path = Path()
                path.move(to: CGPoint(x: startX, y: 0))
                path.addLine(to: CGPoint(x: startX + angle * size.height, y: size.height))
                path.addLine(to: CGPoint(x: startX + angle * size.height + 40, y: size.height))
                path.addLine(to: CGPoint(x: startX + 40, y: 0))
                path.closeSubpath()

                let pulse = sin(time * 0.5 + Double(i)) * 0.01
                context.opacity = 0.03 + pulse
                context.fill(path, with: .color(Color(hex: "88cc44")))
            }

            // Falling leaves
            for leaf in leaves {
                let age = (time * leaf.speed + leaf.offset).truncatingRemainder(dividingBy: 1.0)
                let x = leaf.x * size.width + sin(time * leaf.wobble + leaf.offset) * 40
                let y = age * size.height * 1.2 - size.height * 0.1
                let rotation = time * leaf.rotationSpeed

                context.opacity = 0.6
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: x, y: y)
                transform = transform.rotated(by: rotation)
                context.transform = transform

                context.fill(
                    Ellipse().path(in: CGRect(x: -5, y: -3, width: 10, height: 6)),
                    with: .color(Color(hex: leaf.color))
                )
                context.transform = .identity
            }
        }
    }
}

struct LeafParticle {
    var x = Double.random(in: 0...1)
    var speed = Double.random(in: 0.05...0.15)
    var wobble = Double.random(in: 1...3)
    var offset = Double.random(in: 0...1)
    var rotationSpeed = Double.random(in: 0.5...2)
    var color = ["44aa33", "66bb44", "88cc55", "aadd66", "338822"].randomElement()!
}

// MARK: - ❄️ Snow

struct SnowCanvas: View {
    let time: Double
    @State private var flakes: [SnowFlake] = (0..<80).map { _ in SnowFlake() }

    var body: some View {
        Canvas { context, size in
            for flake in flakes {
                let age = (time * flake.speed + flake.offset).truncatingRemainder(dividingBy: 1.0)
                let x = flake.x * size.width + sin(time * flake.wobble + flake.offset) * 30
                let y = age * size.height * 1.2 - size.height * 0.1
                let currentSize = flake.size * (0.8 + sin(time * 2 + flake.offset) * 0.2)

                // Glow
                context.opacity = flake.opacity * 0.3
                context.fill(
                    Circle().path(in: CGRect(
                        x: x - currentSize * 1.5, y: y - currentSize * 1.5,
                        width: currentSize * 3, height: currentSize * 3
                    )),
                    with: .color(.white)
                )
                // Core
                context.opacity = flake.opacity
                context.fill(
                    Circle().path(in: CGRect(
                        x: x - currentSize / 2, y: y - currentSize / 2,
                        width: currentSize, height: currentSize
                    )),
                    with: .color(.white)
                )
            }
        }
    }
}

struct SnowFlake {
    var x = Double.random(in: 0...1)
    var speed = Double.random(in: 0.03...0.1)
    var wobble = Double.random(in: 0.5...2)
    var offset = Double.random(in: 0...1)
    var size = Double.random(in: 2...7)
    var opacity = Double.random(in: 0.4...0.9)
}

// MARK: - 🌃 City Lights

struct CityLightsCanvas: View {
    let time: Double

    var body: some View {
        Canvas { context, size in
            // City skyline silhouette at bottom
            var skyline = Path()
            skyline.move(to: CGPoint(x: 0, y: size.height))
            let buildings: [(x: Double, w: Double, h: Double)] = [
                (0.05, 0.08, 0.3), (0.15, 0.06, 0.25), (0.22, 0.1, 0.4),
                (0.35, 0.05, 0.2), (0.42, 0.12, 0.5), (0.56, 0.07, 0.35),
                (0.65, 0.09, 0.45), (0.76, 0.06, 0.28), (0.84, 0.1, 0.38),
                (0.95, 0.05, 0.22)
            ]

            for b in buildings {
                let bx = b.x * size.width
                let bw = b.w * size.width
                let bh = b.h * size.height * 0.4
                let by = size.height - bh

                skyline.addLine(to: CGPoint(x: bx, y: size.height))
                skyline.addLine(to: CGPoint(x: bx, y: by))
                skyline.addLine(to: CGPoint(x: bx + bw, y: by))
                skyline.addLine(to: CGPoint(x: bx + bw, y: size.height))
            }
            skyline.addLine(to: CGPoint(x: size.width, y: size.height))
            skyline.closeSubpath()

            context.opacity = 0.3
            context.fill(skyline, with: .color(Color(hex: "0a0a15")))

            // Building windows (twinkling)
            for b in buildings {
                let bx = b.x * size.width
                let bw = b.w * size.width
                let bh = b.h * size.height * 0.4
                let by = size.height - bh

                for row in stride(from: by + 8, to: size.height - 5, by: 12) {
                    for col in stride(from: bx + 4, to: bx + bw - 4, by: 8) {
                        let isLit = sin(time * 0.5 + col + row * 0.1) > -0.3
                        if isLit {
                            context.opacity = 0.3 + sin(time * 2 + col * 0.5 + row) * 0.1
                            context.fill(
                                Rectangle().path(in: CGRect(x: col, y: row, width: 4, height: 6)),
                                with: .color(Color(hex: "ffcc66"))
                            )
                        }
                    }
                }
            }

            // Floating city light particles
            for i in 0..<20 {
                let x = (Double(i) / 20 + sin(time * 0.3 + Double(i)) * 0.05)
                    .truncatingRemainder(dividingBy: 1.0) * size.width
                let y = size.height * 0.3 + sin(time * 0.5 + Double(i) * 0.7) * size.height * 0.1
                let pulse = sin(time * 1.5 + Double(i) * 1.2) * 0.5 + 0.5

                context.opacity = 0.03 + pulse * 0.02
                context.fill(
                    Circle().path(in: CGRect(x: x - 15, y: y - 15, width: 30, height: 30)),
                    with: .color(Color(hex: "ffaa55"))
                )
            }
        }
    }
}

// MARK: - ♨️ Steam

struct SteamCanvas: View {
    let time: Double
    @State private var steamPuffs: [SteamPuff] = (0..<30).map { _ in SteamPuff() }

    var body: some View {
        Canvas { context, size in
            // Water surface
            let waterY = size.height * 0.7

            // Gentle water ripples
            for i in 0..<6 {
                let rippleY = waterY + Double(i) * 8
                var path = Path()
                path.move(to: CGPoint(x: 0, y: rippleY))
                for x in stride(from: 0.0, to: size.width, by: 3) {
                    let y = rippleY + sin(x / 30 + time * 1.5 + Double(i) * 0.5) * 2
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                context.opacity = 0.05
                context.stroke(path, with: .color(.white), lineWidth: 1)
            }

            // Steam rising
            for puff in steamPuffs {
                let age = (time * puff.speed + puff.offset).truncatingRemainder(dividingBy: 1.0)
                let x = puff.x * size.width + sin(time * puff.wobble + puff.offset) * 25
                let y = waterY - age * size.height * 0.6
                let currentSize = puff.size * (0.5 + age * 1.5)
                let alpha = (1 - age) * 0.15

                context.opacity = alpha
                context.fill(
                    Ellipse().path(in: CGRect(
                        x: x - currentSize, y: y - currentSize * 0.6,
                        width: currentSize * 2, height: currentSize * 1.2
                    )),
                    with: .color(.white)
                )
            }
        }
    }
}

struct SteamPuff {
    var x = Double.random(in: 0.1...0.9)
    var speed = Double.random(in: 0.1...0.3)
    var wobble = Double.random(in: 0.5...1.5)
    var offset = Double.random(in: 0...1)
    var size = Double.random(in: 20...50)
}

// MARK: - 📚 Dust (Library)

struct DustCanvas: View {
    let time: Double
    @State private var motes: [DustMote] = (0..<40).map { _ in DustMote() }

    var body: some View {
        Canvas { context, size in
            // Warm light beam from window
            var beam = Path()
            beam.move(to: CGPoint(x: size.width * 0.7, y: 0))
            beam.addLine(to: CGPoint(x: size.width * 0.3, y: size.height))
            beam.addLine(to: CGPoint(x: size.width * 0.8, y: size.height))
            beam.addLine(to: CGPoint(x: size.width * 0.9, y: 0))
            beam.closeSubpath()

            context.opacity = 0.04
            context.fill(beam, with: .color(Color(hex: "ffcc88")))

            // Floating dust motes
            for mote in motes {
                let x = mote.x * size.width + sin(time * mote.driftSpeed + mote.offset) * 30
                let y = mote.y * size.height + cos(time * mote.driftSpeed * 0.7 + mote.offset) * 20
                let alpha = 0.2 + sin(time * 2 + mote.offset) * 0.1

                // Check if in light beam area (approximate)
                let inBeam = x > size.width * 0.35 && x < size.width * 0.85
                let brightness = inBeam ? 1.5 : 0.5

                context.opacity = alpha * brightness
                context.fill(
                    Circle().path(in: CGRect(
                        x: x - mote.size / 2, y: y - mote.size / 2,
                        width: mote.size, height: mote.size
                    )),
                    with: .color(Color(hex: "ffddaa"))
                )
            }
        }
    }
}

struct DustMote {
    var x = Double.random(in: 0...1)
    var y = Double.random(in: 0...1)
    var size = Double.random(in: 1.5...4)
    var driftSpeed = Double.random(in: 0.2...0.8)
    var offset = Double.random(in: 0...(2 * .pi))
}

// MARK: - 🌸 Cherry Blossom

struct CherryBlossomCanvas: View {
    let time: Double
    @State private var petals: [CherryPetal] = (0..<35).map { _ in CherryPetal() }

    var body: some View {
        Canvas { context, size in
            // Soft pink ambient glow
            context.opacity = 0.05
            context.fill(
                Ellipse().path(in: CGRect(
                    x: size.width * 0.2, y: -50,
                    width: size.width * 0.6, height: 300
                )),
                with: .color(Color(hex: "ff88aa"))
            )

            // Falling petals
            for petal in petals {
                let age = (time * petal.speed + petal.offset).truncatingRemainder(dividingBy: 1.0)
                let x = petal.x * size.width + sin(time * petal.wobble + petal.offset) * 50
                let y = age * size.height * 1.3 - size.height * 0.15
                let rotation = time * petal.rotationSpeed + petal.offset

                let petalWidth = petal.size
                let petalHeight = petal.size * 0.6

                context.opacity = 0.5 + sin(time + petal.offset) * 0.2

                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: x, y: y)
                transform = transform.rotated(by: rotation)
                context.transform = transform

                context.fill(
                    Ellipse().path(in: CGRect(
                        x: -petalWidth / 2, y: -petalHeight / 2,
                        width: petalWidth, height: petalHeight
                    )),
                    with: .color(Color(hex: petal.color))
                )
                context.transform = .identity
            }
        }
    }
}

struct CherryPetal {
    var x = Double.random(in: 0...1)
    var speed = Double.random(in: 0.03...0.08)
    var wobble = Double.random(in: 0.5...1.5)
    var offset = Double.random(in: 0...1)
    var size = Double.random(in: 6...12)
    var rotationSpeed = Double.random(in: 0.3...1.5)
    var color = ["ffb3c6", "ff8faa", "ffc8d7", "ffa0b8"].randomElement()!
}

// MARK: - 🌊 Waves

struct WavesCanvas: View {
    let time: Double

    var body: some View {
        Canvas { context, size in
            // Moon
            let moonX = size.width * 0.7
            let moonY = size.height * 0.15

            context.opacity = 0.1
            context.fill(
                Circle().path(in: CGRect(x: moonX - 80, y: moonY - 80, width: 160, height: 160)),
                with: .color(.white)
            )
            context.opacity = 0.8
            context.fill(
                Circle().path(in: CGRect(x: moonX - 25, y: moonY - 25, width: 50, height: 50)),
                with: .color(Color(hex: "eeeeff"))
            )

            // Moon reflection on water
            let waterY = size.height * 0.55
            for i in 0..<10 {
                let refY = waterY + Double(i) * 15
                let width = 40 - Double(i) * 3
                let shimmer = sin(time * 3 + Double(i) * 0.5) * 5
                context.opacity = 0.1 - Double(i) * 0.008
                context.fill(
                    Ellipse().path(in: CGRect(
                        x: moonX - width / 2 + shimmer, y: refY,
                        width: width, height: 4
                    )),
                    with: .color(.white)
                )
            }

            // Waves
            for layer in 0..<6 {
                let baseY = waterY + Double(layer) * size.height * 0.08
                var path = Path()
                path.move(to: CGPoint(x: 0, y: baseY))

                for x in stride(from: 0.0, to: size.width + 5, by: 3) {
                    let wave1 = sin(x / 60 + time * 1.2 + Double(layer) * 0.5) * 8
                    let wave2 = sin(x / 30 + time * 2.0 + Double(layer)) * 4
                    let y = baseY + wave1 + wave2
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.addLine(to: CGPoint(x: 0, y: size.height))
                path.closeSubpath()

                let alpha = 0.05 + Double(layer) * 0.02
                context.opacity = alpha
                context.fill(path, with: .color(Color(hex: "1a3355")))
            }
        }
    }
}

// MARK: - ✨ Fireflies

struct FirefliesCanvas: View {
    let time: Double
    @State private var fireflies: [Firefly] = (0..<25).map { _ in Firefly() }

    var body: some View {
        Canvas { context, size in
            for ff in fireflies {
                let x = ff.x * size.width + sin(time * ff.moveSpeedX + ff.offset) * 40
                let y = ff.y * size.height + cos(time * ff.moveSpeedY + ff.offset) * 30
                let glow = (sin(time * ff.glowSpeed + ff.offset) + 1) / 2

                if glow > 0.3 {
                    // Outer glow
                    context.opacity = glow * 0.15
                    context.fill(
                        Circle().path(in: CGRect(x: x - 15, y: y - 15, width: 30, height: 30)),
                        with: .color(Color(hex: "ccff66"))
                    )
                    // Inner glow
                    context.opacity = glow * 0.5
                    context.fill(
                        Circle().path(in: CGRect(x: x - 4, y: y - 4, width: 8, height: 8)),
                        with: .color(Color(hex: "eeff88"))
                    )
                    // Core
                    context.opacity = glow * 0.9
                    context.fill(
                        Circle().path(in: CGRect(x: x - 2, y: y - 2, width: 4, height: 4)),
                        with: .color(.white)
                    )
                }
            }
        }
    }
}

struct Firefly {
    var x = Double.random(in: 0.05...0.95)
    var y = Double.random(in: 0.2...0.8)
    var moveSpeedX = Double.random(in: 0.2...0.6)
    var moveSpeedY = Double.random(in: 0.15...0.5)
    var glowSpeed = Double.random(in: 1...3)
    var offset = Double.random(in: 0...(2 * .pi))
}

// MARK: - 🌌 Aurora

struct AuroraCanvas: View {
    let time: Double

    var body: some View {
        Canvas { context, size in
            // Stars in background
            for i in 0..<60 {
                let x = (Double(i) * 0.0167).truncatingRemainder(dividingBy: 1.0) * size.width
                let y = Double(i * 7 % 100) / 100 * size.height * 0.6
                let twinkle = sin(time * 2 + Double(i)) * 0.5 + 0.5

                context.opacity = twinkle * 0.5
                context.fill(
                    Circle().path(in: CGRect(x: x - 1, y: y - 1, width: 2, height: 2)),
                    with: .color(.white)
                )
            }

            // Aurora bands
            let auroraColors: [(color: String, offsetY: Double)] = [
                ("00ff88", 0.2),
                ("00cc66", 0.25),
                ("0088ff", 0.3),
                ("8844ff", 0.35),
                ("00ffaa", 0.22),
            ]

            for (i, aurora) in auroraColors.enumerated() {
                let baseY = aurora.offsetY * size.height

                var path = Path()
                path.move(to: CGPoint(x: 0, y: baseY))

                for x in stride(from: 0.0, to: size.width + 5, by: 3) {
                    let wave1 = sin(x / 80 + time * 0.5 + Double(i) * 0.8) * 30
                    let wave2 = sin(x / 40 + time * 0.8 + Double(i) * 1.2) * 15
                    let y = baseY + wave1 + wave2
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                for x in stride(from: size.width, through: 0, by: -3) {
                    let wave1 = sin(x / 80 + time * 0.5 + Double(i) * 0.8) * 30
                    let wave2 = sin(x / 40 + time * 0.8 + Double(i) * 1.2) * 15
                    let y = baseY + wave1 + wave2 + 50
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                path.closeSubpath()

                let pulse = sin(time * 0.3 + Double(i) * 0.5) * 0.03
                context.opacity = 0.08 + pulse
                context.fill(path, with: .color(Color(hex: aurora.color)))
            }
        }
    }
}

// MARK: - 🏮 Lanterns

struct LanternsCanvas: View {
    let time: Double
    @State private var lanterns: [Lantern] = (0..<20).map { _ in Lantern() }

    var body: some View {
        Canvas { context, size in
            for lantern in lanterns {
                let age = (time * lantern.speed + lantern.offset).truncatingRemainder(dividingBy: 1.0)
                let x = lantern.x * size.width + sin(time * lantern.wobble + lantern.offset) * 20
                let y = (1 - age) * size.height * 1.2 - size.height * 0.1
                let alpha = age < 0.1 ? age * 10 : (age > 0.9 ? (1 - age) * 10 : 1.0)

                let lSize = lantern.size

                // Outer glow
                context.opacity = alpha * 0.15
                context.fill(
                    Circle().path(in: CGRect(
                        x: x - lSize * 2, y: y - lSize * 2,
                        width: lSize * 4, height: lSize * 4
                    )),
                    with: .color(Color(hex: "ff8844"))
                )

                // Lantern body
                context.opacity = alpha * 0.6
                context.fill(
                    Ellipse().path(in: CGRect(
                        x: x - lSize / 2, y: y - lSize * 0.6,
                        width: lSize, height: lSize * 1.2
                    )),
                    with: .color(Color(hex: lantern.color))
                )

                // Inner light
                context.opacity = alpha * 0.9
                context.fill(
                    Ellipse().path(in: CGRect(
                        x: x - lSize * 0.3, y: y - lSize * 0.3,
                        width: lSize * 0.6, height: lSize * 0.6
                    )),
                    with: .color(Color(hex: "ffdd88"))
                )
            }
        }
    }
}

struct Lantern {
    var x = Double.random(in: 0.05...0.95)
    var speed = Double.random(in: 0.02...0.06)
    var wobble = Double.random(in: 0.3...1.0)
    var offset = Double.random(in: 0...1)
    var size = Double.random(in: 15...30)
    var color = ["ff6644", "ff8855", "ffaa66", "ff7744", "ee5533"].randomElement()!
}
