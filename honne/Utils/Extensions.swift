import SwiftUI

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8)  / 255.0
        let b = Double(rgbValue & 0x0000FF)          / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Liquid Glass Background

/// 写真のような「厚みのあるフロストガラス」効果を作るビュー
/// 3層構造: 半透明ベース + 上部ハイライトグラデ + エッジボーダーグラデ
struct LiquidGlassShape: View {
    var cornerRadius: CGFloat = 20
    var tint: Color = .clear           // optional tint (e.g. orange for vent button)

    var body: some View {
        ZStack {
            // Layer 1: Frosted base
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)

            // Layer 2: White sheen
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white.opacity(0.50))

            // Layer 3: Optional tint
            if tint != .clear {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(tint.opacity(0.08))
            }

            // Layer 4: Top specular highlight
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.90), location: 0.00),
                            .init(color: Color.white.opacity(0.30), location: 0.30),
                            .init(color: Color.white.opacity(0.05), location: 0.60),
                            .init(color: Color.clear,               location: 1.00),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Layer 5: Edge border (bright top → dim bottom)
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.15),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: .black.opacity(0.07), radius: 20, x: 0, y: 10)
        .shadow(color: .black.opacity(0.04), radius:  5, x: 0, y:  3)
    }
}

/// Capsule 版（入力フィールド・丸ボタン用）
struct LiquidGlassCapsule: View {
    var tint: Color = .clear

    var body: some View {
        ZStack {
            Capsule().fill(.ultraThinMaterial)
            Capsule().fill(Color.white.opacity(0.50))
            if tint != .clear {
                Capsule().fill(tint.opacity(0.08))
            }
            Capsule().fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.90), location: 0.00),
                        .init(color: Color.white.opacity(0.20), location: 0.40),
                        .init(color: Color.clear,               location: 0.70),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            Capsule().stroke(
                LinearGradient(
                    colors: [Color.white.opacity(0.95), Color.white.opacity(0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.5
            )
        }
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .shadow(color: .black.opacity(0.03), radius:  3, x: 0, y: 1)
    }
}

// MARK: - View Modifiers
extension View {
    /// フロストガラスカード（写真のような立体的な透明感）
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        self.background(LiquidGlassShape(cornerRadius: cornerRadius))
    }

    func honneBackground() -> some View {
        self.background(Constants.bgPrimary.ignoresSafeArea())
    }

    /// CTAボタン用グラデーション背景
    func accentGradientBackground(cornerRadius: CGFloat = 16) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Constants.accentGradient)
        )
    }
}

// MARK: - Date helpers
extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
}
