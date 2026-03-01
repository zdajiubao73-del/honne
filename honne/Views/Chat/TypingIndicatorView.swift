import SwiftUI

struct TypingIndicatorView: View {
    @State private var phases: [Bool] = [false, false, false]

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Constants.accent.opacity(phases[i] ? 1.0 : 0.4))
                        .frame(width: 8, height: 8)
                        .scaleEffect(phases[i] ? 1.4 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                            value: phases[i]
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 4,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 18,
                    topTrailingRadius: 18
                )
                .fill(Color.white)
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 4,
                        bottomLeadingRadius: 18,
                        bottomTrailingRadius: 18,
                        topTrailingRadius: 18
                    )
                    .stroke(Constants.borderLight, lineWidth: 1)
                )
            )

            Spacer(minLength: 60)
        }
        .onAppear {
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                    phases[i] = true
                }
            }
        }
    }
}
