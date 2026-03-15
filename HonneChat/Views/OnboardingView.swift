import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var animateIn = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "bubble.left.and.bubble.right.fill",
            iconColors: [Color(hex: "a0a0ff"), Color(hex: "6060dd")],
            title: "Honneへようこそ",
            subtitle: "本音で話せる場所",
            description: "日常では言えない本音や悩み、夢を、\nリラックスできる空間でAIと話してみよう。"
        ),
        OnboardingPage(
            icon: "photo.on.rectangle.angled",
            iconColors: [Color(hex: "ff9060"), Color(hex: "ff5030")],
            title: "シチュエーションを選ぶ",
            subtitle: "17種類の没入空間",
            description: "星空の下、雨カフェ、深夜バー——\nその場所の空気ごと体験できる\nバックグラウンドと音楽が流れる。"
        ),
        OnboardingPage(
            icon: "waveform.and.mic",
            iconColors: [Color(hex: "60e0a0"), Color(hex: "20b060")],
            title: "AIと本音トーク",
            subtitle: "あなたの言葉を受け止める",
            description: "それぞれの場所に合ったキャラクターが\n自然に会話に応じる。\n話せなかったことを、話してみよう。"
        ),
    ]

    var body: some View {
        ZStack {
            // Background
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

            // Ambient particles
            AmbientParticlesView()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)

                // Bottom area
                VStack(spacing: 20) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.4), value: currentPage)
                        }
                    }

                    // Action button
                    Button(action: handleNextTap) {
                        HStack(spacing: 8) {
                            Text(currentPage == pages.count - 1 ? "はじめる" : "次へ")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: currentPage == pages.count - 1 ? "sparkles" : "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
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
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
        }
    }

    private func handleNextTap() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        if currentPage < pages.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.4)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let iconColors: [Color]
    let title: String
    let subtitle: String
    let description: String
}

// MARK: - Single Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.iconColors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: page.iconColors.map { $0.opacity(0.5) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                Image(systemName: page.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)

            // Text content
            VStack(spacing: 12) {
                Text(page.subtitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(page.iconColors.first ?? .purple)
                    .tracking(2)
                    .textCase(.uppercase)

                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 16)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
        }
        .onDisappear {
            iconScale = 0.5
            iconOpacity = 0
        }
    }
}
