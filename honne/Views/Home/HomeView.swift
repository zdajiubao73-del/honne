import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userState: UserState
    @StateObject private var vm = HomeViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showChat = false
    @State private var showVentMode = false
    @State private var selectedTopic: String?
    @State private var emojiFloat = false

    var body: some View {
        NavigationStack {
            ZStack {
                ambientBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerSection
                        heroSection
                        actionSection
                        topicSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                vm.load()
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    emojiFloat = true
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active { vm.load() }
            }
            .fullScreenCover(isPresented: $showChat) {
                ChatView(topic: selectedTopic)
                    .environmentObject(userState)
                    .onDisappear { vm.load() }
            }
            .fullScreenCover(isPresented: $showVentMode) {
                VentView().environmentObject(userState)
            }
        }
    }

    // MARK: - Ambient Background

    private var ambientBackground: some View {
        ZStack {
            Color(hex: "F8FBFF").ignoresSafeArea()

            // 左上: スカイブルー
            Circle()
                .fill(Color(hex: "BAE6FD").opacity(0.55))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: -110, y: -210)

            // 右上: ラベンダー
            Circle()
                .fill(Color(hex: "DDD6FE").opacity(0.42))
                .frame(width: 280, height: 280)
                .blur(radius: 75)
                .offset(x: 150, y: -90)

            // 中央右: ウォームピーチ
            Circle()
                .fill(Color(hex: "FED7AA").opacity(0.28))
                .frame(width: 220, height: 220)
                .blur(radius: 65)
                .offset(x: 80, y: 220)

            // 左下: スカイ
            Circle()
                .fill(Color(hex: "7DD3FC").opacity(0.22))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: -100, y: 440)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("honne")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Constants.textPrimary)
            Spacer()
            if !userState.isPro {
                Text("FREE \(userState.remainingFreeMessages)回")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Constants.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(Constants.accent.opacity(0.10))
                            .overlay(Capsule().stroke(Constants.accent.opacity(0.30), lineWidth: 1))
                    )
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack {
            // ベースグラデ
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.88), Color(hex: "EFF6FF").opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // 上部ハイライト
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.85), location: 0.0),
                            .init(color: Color.white.opacity(0.15), location: 0.45),
                            .init(color: Color.clear,               location: 0.75),
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            // エッジボーダー
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.95), Color.white.opacity(0.20)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )

            // コンテンツ
            VStack(spacing: 16) {
                // 浮遊アニメーション付き絵文字
                Text(greetingEmoji)
                    .font(.system(size: 64))
                    .offset(y: emojiFloat ? -10 : 0)
                    .shadow(color: accentGlowColor.opacity(0.60), radius: 18, x: 0, y: 6)

                VStack(spacing: 6) {
                    Text(greetingTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Constants.textPrimary)

                    Text("今日も、ここにいる。")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Constants.accent)
                }

                // 区切り線
                Rectangle()
                    .fill(Constants.borderLight.opacity(0.6))
                    .frame(height: 1)
                    .padding(.horizontal, 32)

                Text("話すだけで、少し楽になれる。\nあなたのペースでいい。")
                    .font(.system(size: 13))
                    .foregroundColor(Constants.textMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
            .padding(.vertical, 44)
            .padding(.horizontal, 28)
        }
        .shadow(color: .black.opacity(0.07), radius: 28, x: 0, y: 14)
        .shadow(color: .black.opacity(0.03), radius:  6, x: 0, y:  3)
    }

    private var accentGlowColor: Color {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return Color(hex: "BAE6FD")   // 朝: スカイ
        case 12..<17: return Color(hex: "FDE68A")   // 昼: イエロー
        case 17..<21: return Color(hex: "FCA5A5")   // 夕: コーラル
        default:      return Color(hex: "C4B5FD")   // 夜: ラベンダー
        }
    }

    // MARK: - Actions

    private var actionSection: some View {
        VStack(spacing: 10) {
            primaryCTAButton
            ventButton
        }
    }

    private var primaryCTAButton: some View {
        let isFreeExhausted = !userState.isPro && userState.remainingFreeMessages == 0

        return Button(action: {
            selectedTopic = nil
            showChat = true
        }) {
            HStack(spacing: 10) {
                Image(systemName: isFreeExhausted ? "arrow.up.circle.fill" : "bubble.left.fill")
                    .font(.system(size: 15, weight: .semibold))
                if isFreeExhausted {
                    VStack(spacing: 2) {
                        Text("残り0回")
                            .font(.system(size: 12, weight: .medium))
                            .opacity(0.85)
                        Text("Proにアップグレード")
                            .font(.system(size: 15, weight: .semibold))
                    }
                } else {
                    Text(vm.sessionCompletedToday ? "もう一度話す" : "今日も話す")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isFreeExhausted
                          ? LinearGradient(colors: [Color(hex: "6366F1"), Color(hex: "818CF8")],
                                           startPoint: .leading, endPoint: .trailing)
                          : Constants.accentGradient)
            )
            .shadow(color: (isFreeExhausted ? Color(hex: "6366F1") : Constants.accent).opacity(0.38),
                    radius: 14, x: 0, y: 7)
        }
        .buttonStyle(.plain)
    }

    private var ventButton: some View {
        Button { showVentMode = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text("発散する")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(hex: "F97316"), Color(hex: "EF4444")],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(LiquidGlassShape(cornerRadius: 16, tint: .orange))
            .shadow(color: Color.orange.opacity(0.20), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Topics

    private var topicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("話すテーマを選ぶ")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Constants.textMuted)
                .padding(.horizontal, 4)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(Constants.topicStarters, id: \.label) { item in
                    topicCard(item)
                }
            }
        }
    }

    private func topicCard(_ item: (icon: String, label: String, prompt: String)) -> some View {
        Button(action: {
            selectedTopic = item.prompt
            showChat = true
        }) {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Constants.accent)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Constants.accent.opacity(0.10)))

                Text(item.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(LiquidGlassShape(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Greeting Helpers

    private var greetingEmoji: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "🌤"
        case 12..<17: return "☀️"
        case 17..<21: return "🌆"
        default:      return "🌙"
        }
    }

    private var greetingTitle: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:  return "おはようございます"
        case 12..<17: return "こんにちは"
        case 17..<21: return "こんばんは"
        default:      return "お疲れさまです"
        }
    }
}
