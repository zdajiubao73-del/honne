import SwiftUI

struct DataConsentView: View {
    @AppStorage("hasAcceptedDataConsent") private var hasAcceptedDataConsent = false
    @State private var showPrivacyPolicy = false
    @State private var animateIn = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "0a0a0f"),
                    Color(hex: "0f0a1a"),
                    Color(hex: "0a0a0f")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            AmbientParticlesView()

            VStack(spacing: 0) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "60c0ff").opacity(0.15))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "60c0ff").opacity(0.4), lineWidth: 1.5)
                        )
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "60c0ff"))
                }
                .padding(.bottom, 32)
                .scaleEffect(animateIn ? 1.0 : 0.7)
                .opacity(animateIn ? 1.0 : 0.0)

                // Title
                VStack(spacing: 8) {
                    Text("データの取り扱いについて")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("アプリを始める前にご確認ください")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 32)
                .opacity(animateIn ? 1.0 : 0.0)

                // Consent items
                VStack(spacing: 12) {
                    consentItem(
                        icon: "arrow.up.forward.app.fill",
                        iconColor: Color(hex: "ff9060"),
                        title: "送信されるデータ",
                        body: "あなたが入力した会話メッセージ"
                    )

                    consentItem(
                        icon: "building.2.fill",
                        iconColor: Color(hex: "a0a0ff"),
                        title: "送信先",
                        body: "OpenAI, Inc.（openai.com）\nAIの応答生成のために使用されます"
                    )

                    consentItem(
                        icon: "externaldrive.fill",
                        iconColor: Color(hex: "60e0a0"),
                        title: "当アプリのサーバーへの保存",
                        body: "なし。会話はお使いのデバイス内のみで保持されます"
                    )
                }
                .padding(.horizontal, 24)
                .opacity(animateIn ? 1.0 : 0.0)

                Spacer()

                // Privacy policy link
                Button(action: { showPrivacyPolicy = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.caption)
                        Text("プライバシーポリシーを読む")
                            .font(.subheadline)
                    }
                    .foregroundColor(Color(hex: "60c0ff"))
                }
                .padding(.bottom, 16)
                .opacity(animateIn ? 1.0 : 0.0)

                // Consent button
                Button(action: acceptConsent) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                        Text("内容を確認し、同意してはじめる")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.white, Color(hex: "e0e0ff")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 12)
                .opacity(animateIn ? 1.0 : 0.0)

                Text("同意しない場合、本アプリはご利用いただけません")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 48)
                    .opacity(animateIn ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }

    private func acceptConsent() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        withAnimation(.easeInOut(duration: 0.4)) {
            hasAcceptedDataConsent = true
        }
    }

    @ViewBuilder
    private func consentItem(icon: String, iconColor: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(body)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "c0c0c0"))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
