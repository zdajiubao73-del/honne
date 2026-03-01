import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var userState: UserState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Constants.bgSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(Constants.borderLight)
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                Spacer()

                VStack(spacing: 0) {
                    Text("もっと話を続けますか？")
                        .font(.system(size: 14))
                        .foregroundColor(Constants.textMuted)

                    Spacer().frame(height: 16)

                    Text("毎晩、話せる場所。")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Constants.textPrimary)
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: 10)

                    Text("¥980 / 月")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Constants.accent)
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 24)

                Rectangle()
                    .fill(Constants.borderLight)
                    .frame(height: 1)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 20)

                VStack(spacing: 16) {
                    FeatureRow(text: "無制限チャット")
                    FeatureRow(text: "週次レポート（感情パターン分析）")
                    FeatureRow(text: "感情カレンダー（全期間）")
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 14) {
                    Button(action: handleSubscribe) {
                        Text("7日間無料で試す")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .accentGradientBackground(cornerRadius: 16)
                    }
                    .buttonStyle(.plain)

                    Text("いつでも解約できます（1タップ）")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.textMuted.opacity(0.6))

                    Button(action: { dismiss() }) {
                        Text("あとで（無料のまま続ける）")
                            .font(.system(size: 13))
                            .foregroundColor(Constants.textMuted)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func handleSubscribe() {
        // TODO: RevenueCat で実装
        userState.isPro = true
        dismiss()
    }
}

private struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(
                    Circle()
                        .fill(Constants.accentGradient)
                )
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Constants.textPrimary)
            Spacer()
        }
    }
}
