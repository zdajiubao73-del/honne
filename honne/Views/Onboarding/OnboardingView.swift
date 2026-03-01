import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userState: UserState
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            Constants.bgPrimary.ignoresSafeArea()

            TabView(selection: $vm.currentPage) {
                OnboardingPage1View()
                    .tag(0)
                OnboardingPage2View()
                    .tag(1)
                TopicSelectorView(selectedTopic: $vm.selectedTopic)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: vm.currentPage)

            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<vm.totalPages, id: \.self) { i in
                        Capsule()
                            .fill(i == vm.currentPage ? Constants.accent : Constants.borderLight)
                            .frame(width: i == vm.currentPage ? 20 : 6, height: 6)
                            .animation(.spring(), value: vm.currentPage)
                    }
                }
                .padding(.bottom, 16)

                Button(action: handleNext) {
                    Text(vm.currentPage < vm.totalPages - 1 ? "次へ" : "はじめる")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .accentGradientBackground(cornerRadius: 16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .disabled(!vm.canAdvance)
                .opacity(vm.canAdvance ? 1 : 0.4)
                .animation(.easeInOut(duration: 0.2), value: vm.canAdvance)
            }
        }
    }

    private func handleNext() {
        if vm.currentPage < vm.totalPages - 1 {
            withAnimation { vm.advance() }
        } else {
            userState.completeOnboarding()
        }
    }
}

struct OnboardingPage1View: View {
    @State private var showHint = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("夜、誰かに話を聞いてほしく\nなることはありますか。")
                .font(.system(size: 26, weight: .regular))
                .foregroundColor(Constants.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()

            Text("tap anywhere to continue")
                .font(.system(size: 13))
                .foregroundColor(Constants.textMuted.opacity(0.5))
                .opacity(showHint ? 1 : 0)
                .animation(.easeIn(duration: 0.8), value: showHint)
                .padding(.bottom, 120)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                showHint = true
            }
        }
    }
}

struct OnboardingPage2View: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("honneは\nただ聞きます。")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(Constants.textPrimary)
                .lineSpacing(10)

            Spacer().frame(height: 40)

            VStack(alignment: .leading, spacing: 24) {
                SafetyItem(icon: "lock.fill", text: "名前もメアドも不要です")
                SafetyItem(icon: "lock.fill", text: "会話は端末に暗号化して保存されます")
                SafetyItem(icon: "lock.fill", text: "AIはあなたを批判しません")
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

private struct SafetyItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.accent)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Constants.accent.opacity(0.12))
                )
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Constants.textPrimary)
        }
    }
}
