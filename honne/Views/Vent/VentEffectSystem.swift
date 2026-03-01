import SwiftUI

// MARK: - Effect Type

enum VentEffectType: CaseIterable {
    case explode, shatter, firework, fire, blizzard, confetti
}

// MARK: - Particle

struct VentParticle: Identifiable {
    let id = UUID()
    var x, y: CGFloat
    var vx, vy: CGFloat
    var gravity, drag: CGFloat
    var life, decay: Double
    var size: CGFloat          // initial size; rendered as size * life for decay
    var color: Color
    var rotation, rotationSpeed: Double
    var isRect: Bool = false
    var glow: Bool = false     // draws a soft halo in addition to the core
}

// MARK: - Shockwave Ring

struct ShockwaveRing: Identifiable {
    let id = UUID()
    var x, y: CGFloat
    var radius: CGFloat        // current radius, grows each frame
    var expandSpeed: CGFloat
    var maxRadius: CGFloat
    var life, decay: Double
    var color: Color
    var lineWidth: CGFloat
}

// MARK: - Effect System

@MainActor
class VentEffectSystem: ObservableObject {
    @Published var particles: [VentParticle] = []
    @Published var rings: [ShockwaveRing] = []
    @Published var flashColor: Color = .clear
    @Published var flashOpacity: Double = 0
    @Published var contentScale: CGFloat = 1.0

    private var timer: Timer?

    // MARK: - Public API

    func trigger(_ type: VentEffectType, in size: CGSize) {
        stopLoop()
        particles.removeAll()
        rings.removeAll()
        spawnParticles(type: type, size: size)
        spawnRings(type: type, size: size)
        triggerFlash(color: flashColorFor(type))
        triggerScalePulse(for: type)
        startLoop()
    }

    /// Returns shake keyframe offsets for the caller to animate
    func shakeKeyframes(for type: VentEffectType) -> [CGFloat] {
        switch type {
        case .explode: return [-18, 18, -13, 13, -8, 8, -3, 3, 0]
        case .shatter: return [-12, 12, -8, 8, -4, 4, 0]
        case .fire:    return [-6, 6, -3, 3, 0]
        default:       return []
        }
    }

    // MARK: - Scale Pulse

    private func triggerScalePulse(for type: VentEffectType) {
        let target: CGFloat
        switch type {
        case .explode:  target = 1.06
        case .shatter:  target = 0.94
        case .firework: target = 1.04
        case .fire:     target = 1.04
        case .blizzard: target = 0.97
        case .confetti: target = 1.05
        }
        withAnimation(.spring(response: 0.10, dampingFraction: 0.28)) {
            contentScale = target
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
                self.contentScale = 1.0
            }
        }
    }

    // MARK: - Flash

    private func flashColorFor(_ type: VentEffectType) -> Color {
        switch type {
        case .explode:  return .orange
        case .shatter:  return .blue
        case .firework: return .yellow
        case .fire:     return .red
        case .blizzard: return .cyan
        case .confetti: return .pink
        }
    }

    private func triggerFlash(color: Color) {
        flashColor = color
        withAnimation(.easeIn(duration: 0.055)) { flashOpacity = 0.50 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.055) {
            withAnimation(.easeOut(duration: 0.30)) { self.flashOpacity = 0 }
        }
    }

    // MARK: - Spawn Rings

    /// originY: message area (lower portion of screen)
    private func spawnRings(type: VentEffectType, size: CGSize) {
        let cx = size.width / 2
        let oy = size.height * 0.70   // emit from message area

        switch type {
        case .explode:
            let colors: [Color] = [.orange, .red, .yellow]
            for i in 0..<3 {
                rings.append(ShockwaveRing(
                    x: cx, y: oy,
                    radius: 28 + CGFloat(i) * 14,
                    expandSpeed: 12 - CGFloat(i) * 1.5,
                    maxRadius: size.width * 1.1,
                    life: 1.0, decay: 0.017 - Double(i) * 0.001,
                    color: colors[i],
                    lineWidth: 4.0 - CGFloat(i) * 0.8
                ))
            }

        case .shatter:
            rings.append(ShockwaveRing(x: cx, y: oy, radius: 22,  expandSpeed: 13, maxRadius: size.width, life: 1.0, decay: 0.015, color: .blue,              lineWidth: 3.5))
            rings.append(ShockwaveRing(x: cx, y: oy, radius: 10,  expandSpeed: 9,  maxRadius: size.width * 0.65, life: 0.9, decay: 0.020, color: .purple, lineWidth: 2.5))
            rings.append(ShockwaveRing(x: cx, y: oy, radius: 5,   expandSpeed: 16, maxRadius: size.width * 0.8, life: 1.0, decay: 0.022, color: Color(hex: "818CF8"), lineWidth: 1.5))

        case .firework:
            let bursts: [(CGFloat, CGFloat, Color)] = [
                (size.width * 0.28, size.height * 0.28, Color(hue: 0.02, saturation: 1, brightness: 1)),
                (size.width * 0.72, size.height * 0.23, Color(hue: 0.15, saturation: 1, brightness: 1)),
                (size.width * 0.50, size.height * 0.13, Color(hue: 0.55, saturation: 1, brightness: 1)),
                (size.width * 0.18, size.height * 0.44, Color(hue: 0.75, saturation: 1, brightness: 1)),
                (size.width * 0.82, size.height * 0.38, Color(hue: 0.33, saturation: 1, brightness: 1)),
            ]
            for (bx, by, c) in bursts {
                rings.append(ShockwaveRing(x: bx, y: by, radius: 8, expandSpeed: 7, maxRadius: 140, life: 1.0, decay: 0.024, color: c, lineWidth: 2.0))
            }

        case .fire:
            rings.append(ShockwaveRing(x: cx, y: size.height * 0.83, radius: 18, expandSpeed: 10, maxRadius: size.width * 0.60, life: 1.0, decay: 0.028, color: .orange, lineWidth: 3.0))

        case .blizzard:
            rings.append(ShockwaveRing(x: cx, y: size.height * 0.08, radius: 22, expandSpeed: 11, maxRadius: size.width * 0.75, life: 1.0, decay: 0.021, color: .cyan, lineWidth: 2.5))

        case .confetti:
            rings.append(ShockwaveRing(x: cx, y: size.height * 0.38, radius: 12, expandSpeed: 9,  maxRadius: size.width * 0.68, life: 1.0, decay: 0.017, color: .pink,   lineWidth: 2.5))
            rings.append(ShockwaveRing(x: cx, y: size.height * 0.38, radius: 22, expandSpeed: 6,  maxRadius: size.width * 0.48, life: 0.85, decay: 0.023, color: .yellow, lineWidth: 2.0))
        }
    }

    // MARK: - Spawn Particles

    private func spawnParticles(type: VentEffectType, size: CGSize) {
        let cx = size.width / 2
        let oy = size.height * 0.70   // origin near message bubbles

        switch type {

        // ── EXPLODE ───────────────────────────────────────────────
        case .explode:
            // Main radial burst
            for _ in 0..<140 {
                let angle = Double.random(in: 0..<2 * .pi)
                let speed = CGFloat.random(in: 5...22)
                particles.append(VentParticle(
                    x: cx + CGFloat.random(in: -20...20),
                    y: oy + CGFloat.random(in: -15...15),
                    vx: cos(angle) * speed,
                    vy: sin(angle) * speed - 3,
                    gravity: 0.42, drag: 0.955,
                    life: 1.0, decay: Double.random(in: 0.009...0.018),
                    size: CGFloat.random(in: 4...14),
                    color: [Color.red, Color.orange, Color(hex: "FF6B00"), Color.yellow].randomElement()!,
                    rotation: Double.random(in: 0..<360),
                    rotationSpeed: Double.random(in: -14...14),
                    glow: true
                ))
            }
            // White hot core sparks
            for _ in 0..<60 {
                let angle = Double.random(in: 0..<2 * .pi)
                let speed = CGFloat.random(in: 12...28)
                particles.append(VentParticle(
                    x: cx, y: oy,
                    vx: cos(angle) * speed,
                    vy: sin(angle) * speed,
                    gravity: 0.52, drag: 0.94,
                    life: 1.0, decay: Double.random(in: 0.016...0.028),
                    size: CGFloat.random(in: 2...6),
                    color: .white,
                    rotation: 0, rotationSpeed: 0,
                    glow: true
                ))
            }

        // ── SHATTER ───────────────────────────────────────────────
        case .shatter:
            // Even ring of shards
            for i in 0..<100 {
                let angle = (Double(i) / 100.0) * 2 * .pi + Double.random(in: -0.08...0.08)
                let speed = CGFloat.random(in: 3...15)
                particles.append(VentParticle(
                    x: cx, y: oy,
                    vx: cos(angle) * speed,
                    vy: sin(angle) * speed - 1,
                    gravity: 0.14, drag: 0.972,
                    life: 1.0, decay: Double.random(in: 0.007...0.014),
                    size: CGFloat.random(in: 3...11),
                    color: [Color.blue, Color.purple, Color.cyan, Color(hex: "818CF8"), Color(hex: "6EE7F0")].randomElement()!,
                    rotation: Double.random(in: 0..<360),
                    rotationSpeed: Double.random(in: -10...10),
                    glow: true
                ))
            }
            // White glass shards
            for _ in 0..<45 {
                let angle = Double.random(in: 0..<2 * .pi)
                let speed = CGFloat.random(in: 7...20)
                particles.append(VentParticle(
                    x: cx + CGFloat.random(in: -35...35),
                    y: oy + CGFloat.random(in: -25...25),
                    vx: cos(angle) * speed,
                    vy: sin(angle) * speed,
                    gravity: 0.20, drag: 0.96,
                    life: 1.0, decay: Double.random(in: 0.013...0.024),
                    size: CGFloat.random(in: 1.5...5),
                    color: .white,
                    rotation: 0, rotationSpeed: 0,
                    glow: true
                ))
            }

        // ── FIREWORK ──────────────────────────────────────────────
        case .firework:
            let burstDefs: [(x: CGFloat, y: CGFloat, hue: Double)] = [
                (size.width * 0.28, size.height * 0.28, 0.02),
                (size.width * 0.72, size.height * 0.23, 0.15),
                (size.width * 0.50, size.height * 0.13, 0.55),
                (size.width * 0.18, size.height * 0.44, 0.75),
                (size.width * 0.82, size.height * 0.38, 0.33),
            ]
            for burst in burstDefs {
                // Spoke particles
                for i in 0..<50 {
                    let angle = (Double(i) / 50.0) * 2 * .pi + Double.random(in: -0.04...0.04)
                    let speed = CGFloat.random(in: 4...12)
                    particles.append(VentParticle(
                        x: burst.x, y: burst.y,
                        vx: cos(angle) * speed,
                        vy: sin(angle) * speed,
                        gravity: 0.06, drag: 0.978,
                        life: 1.0, decay: Double.random(in: 0.005...0.011),
                        size: CGFloat.random(in: 3...9),
                        color: Color(hue: burst.hue + Double.random(in: -0.04...0.04), saturation: 1.0, brightness: 1.0),
                        rotation: 0, rotationSpeed: 0,
                        glow: true
                    ))
                }
                // White core flash
                for _ in 0..<14 {
                    let angle = Double.random(in: 0..<2 * .pi)
                    let speed = CGFloat.random(in: 8...16)
                    particles.append(VentParticle(
                        x: burst.x, y: burst.y,
                        vx: cos(angle) * speed,
                        vy: sin(angle) * speed,
                        gravity: 0.08, drag: 0.96,
                        life: 1.0, decay: Double.random(in: 0.014...0.026),
                        size: CGFloat.random(in: 2...5),
                        color: .white,
                        rotation: 0, rotationSpeed: 0,
                        glow: true
                    ))
                }
            }

        // ── FIRE ──────────────────────────────────────────────────
        case .fire:
            let startY = size.height * 0.85
            for _ in 0..<170 {
                let startX = CGFloat.random(in: size.width * 0.08...size.width * 0.92)
                let hue = Double.random(in: 0.00...0.09)
                particles.append(VentParticle(
                    x: startX,
                    y: startY + CGFloat.random(in: -30...0),
                    vx: CGFloat.random(in: -3.5...3.5),
                    vy: CGFloat.random(in: -11 ... -3),
                    gravity: -0.045, drag: 0.984,
                    life: 1.0, decay: Double.random(in: 0.008...0.017),
                    size: CGFloat.random(in: 7...22),
                    color: Color(hue: hue, saturation: 1.0, brightness: 1.0),
                    rotation: 0, rotationSpeed: 0,
                    glow: true
                ))
            }
            // Embers
            for _ in 0..<50 {
                let startX = CGFloat.random(in: size.width * 0.15...size.width * 0.85)
                particles.append(VentParticle(
                    x: startX,
                    y: startY - CGFloat.random(in: 0...80),
                    vx: CGFloat.random(in: -1.5...1.5),
                    vy: CGFloat.random(in: -7 ... -2),
                    gravity: 0.025, drag: 0.99,
                    life: 1.0, decay: Double.random(in: 0.005...0.011),
                    size: CGFloat.random(in: 1.5...3.5),
                    color: Color(hex: "FFA500"),
                    rotation: 0, rotationSpeed: 0,
                    glow: true
                ))
            }

        // ── BLIZZARD ──────────────────────────────────────────────
        case .blizzard:
            for _ in 0..<190 {
                let startX = CGFloat.random(in: -40...size.width + 40)
                particles.append(VentParticle(
                    x: startX,
                    y: CGFloat.random(in: -50 ... -5),
                    vx: CGFloat.random(in: -3...3),
                    vy: CGFloat.random(in: 3...8),
                    gravity: 0.025, drag: 0.993,
                    life: 1.0, decay: Double.random(in: 0.004...0.008),
                    size: CGFloat.random(in: 3...14),
                    color: [Color.white, Color.cyan, Color(hex: "BAE6FD"), Color(hex: "E0F2FE")].randomElement()!,
                    rotation: Double.random(in: 0..<360),
                    rotationSpeed: Double.random(in: -6...6),
                    glow: false
                ))
            }

        // ── CONFETTI ─────────────────────────────────────────────
        case .confetti:
            for _ in 0..<210 {
                let startX = CGFloat.random(in: -40...size.width + 40)
                let hue = Double.random(in: 0...1)
                particles.append(VentParticle(
                    x: startX,
                    y: CGFloat.random(in: -70 ... -5),
                    vx: CGFloat.random(in: -4...4),
                    vy: CGFloat.random(in: 3...11),
                    gravity: 0.09, drag: 0.993,
                    life: 1.0, decay: Double.random(in: 0.003...0.008),
                    size: CGFloat.random(in: 8...18),
                    color: Color(hue: hue, saturation: 0.92, brightness: 1.0),
                    rotation: Double.random(in: 0..<360),
                    rotationSpeed: Double.random(in: -16...16),
                    isRect: true, glow: false
                ))
            }
        }
    }

    // MARK: - Loop

    private func startLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
    }

    private func stopLoop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        particles = particles.compactMap { p in
            var p = p
            p.x  += p.vx
            p.y  += p.vy
            p.vy += p.gravity
            p.vx *= p.drag
            p.vy *= p.drag
            p.life -= p.decay
            p.rotation += p.rotationSpeed
            return p.life > 0 ? p : nil
        }
        rings = rings.compactMap { r in
            var r = r
            r.radius += r.expandSpeed
            r.life   -= r.decay
            return (r.life > 0 && r.radius < r.maxRadius) ? r : nil
        }
        if particles.isEmpty && rings.isEmpty { stopLoop() }
    }
}

// MARK: - Canvas Renderer

struct VentParticleCanvas: View {
    @ObservedObject var system: VentEffectSystem

    var body: some View {
        Canvas { context, _ in

            // ── Pass 1: soft glow halos (glow particles only) ──────
            for p in system.particles where p.glow {
                var ctx = context
                let life = CGFloat(max(0, p.life))
                let haloSize = p.size * life * 4.0
                ctx.opacity = Double(life) * 0.20
                let path = Path(ellipseIn: CGRect(
                    x: p.x - haloSize / 2, y: p.y - haloSize / 2,
                    width: haloSize, height: haloSize
                ))
                ctx.fill(path, with: .color(p.color))
            }

            // ── Pass 2: particle cores (all particles) ─────────────
            for p in system.particles {
                var ctx = context
                let life = CGFloat(max(0, p.life))
                ctx.opacity = Double(life)
                let coreSize = p.size * life          // shrinks with life
                let transform = CGAffineTransform.identity
                    .translatedBy(x: p.x, y: p.y)
                    .rotated(by: p.rotation)
                let path: Path
                if p.isRect {
                    path = Path(CGRect(
                        x: -coreSize / 2, y: -coreSize * 0.35,
                        width: coreSize, height: coreSize * 0.70
                    )).applying(transform)
                } else {
                    path = Path(ellipseIn: CGRect(
                        x: -coreSize / 2, y: -coreSize / 2,
                        width: coreSize, height: coreSize
                    )).applying(transform)
                }
                ctx.fill(path, with: .color(p.color))
            }

            // ── Pass 3: shockwave rings ────────────────────────────
            for ring in system.rings {
                var ctx = context
                let life = CGFloat(max(0, ring.life))
                ctx.opacity = Double(life)
                // Line thins as it expands
                let lw = ring.lineWidth * life * 1.6 + 0.4
                let path = Path(ellipseIn: CGRect(
                    x: ring.x - ring.radius, y: ring.y - ring.radius,
                    width: ring.radius * 2, height: ring.radius * 2
                ))
                ctx.stroke(path, with: .color(ring.color), lineWidth: lw)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
