import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(SubscriptionManager.self) var subscriptionManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasAcceptedDataConsent") private var hasAcceptedDataConsent = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Black base prevents white flash during any view transition
            Color.black.ignoresSafeArea()

            if !hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if !hasAcceptedDataConsent {
                DataConsentView()
                    .transition(.opacity)
            } else if appState.showChat, let situation = appState.selectedSituation {
                ChatView(situation: situation)
                    .transition(.opacity)
            } else if appState.isTransitioning, let situation = appState.selectedSituation {
                WarpTransitionView(situation: situation)
                    .transition(.opacity)
            } else if appState.showReflection, let situation = appState.selectedSituation {
                ReflectionView(messages: appState.lastMessages, situation: situation)
                    .transition(.opacity)
            } else {
                SituationSelectionView(showSettings: $showSettings)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.3), value: appState.showChat)
        .animation(.easeInOut(duration: 0.25), value: appState.isTransitioning)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environment(subscriptionManager)
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showPaywall = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("ttsEnabled") private var ttsEnabled = false
    @AppStorage("ttsVoice") private var ttsVoice = "shimmer"

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Premium section
                        if !subscriptionManager.isPremium {
                            premiumBanner
                                .padding(.horizontal, 20)
                                .padding(.bottom, 28)
                        } else {
                            premiumActiveBadge
                                .padding(.horizontal, 20)
                                .padding(.bottom, 28)
                        }

                        // Voice section
                        settingsSectionHeader("AIの声")

                        VStack(spacing: 0) {
                            // Toggle
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "ff80c0").opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "waveform")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "ff80c0"))
                                }
                                Text("音声読み上げ")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: $ttsEnabled)
                                    .labelsHidden()
                                    .tint(Color(hex: "a0a0ff"))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 52)

                            // Voice picker（常に表示）
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hex: "80c0ff").opacity(0.15))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: ttsVoice == "male" ? "person.fill" : "person")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "80c0ff"))
                                }
                                Text("声の種類")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Picker("声の種類", selection: $ttsVoice) {
                                    Text("女性").tag("female")
                                    Text("男性").tag("male")
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 110)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                        .animation(.easeInOut(duration: 0.2), value: ttsEnabled)

                        // About section
                        settingsSectionHeader("アプリ情報")

                        VStack(spacing: 0) {
                            settingsRow(
                                icon: "lock.shield.fill",
                                iconColor: Color(hex: "60c0ff"),
                                title: "プライバシーポリシー"
                            ) {
                                showPrivacyPolicy = true
                            }

                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 52)

                            settingsRow(
                                icon: "doc.text.fill",
                                iconColor: Color(hex: "a0ffa0"),
                                title: "利用規約"
                            ) {
                                showTermsOfService = true
                            }

                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 52)

                            settingsRow(
                                icon: "app.badge",
                                iconColor: Color(hex: "ffd060"),
                                title: "バージョン"
                            ) {}
                            .overlay(
                                HStack {
                                    Spacer()
                                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 20)
                                }
                            )
                        }
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)

                        // Onboarding reset
                        settingsSectionHeader("その他")

                        Button(action: {
                            hasCompletedOnboarding = false
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.subheadline)
                                Text("オンボーディングをやり直す")
                                    .font(.subheadline)
                            }
                            .foregroundColor(Color(hex: "a0a0ff"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "a0a0ff").opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environment(subscriptionManager)
        }
    }

    // MARK: - Premium Banner

    private var premiumBanner: some View {
        Button(action: { showPaywall = true }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "a0a0ff").opacity(0.2))
                        .frame(width: 40, height: 40)
                    Text("✨")
                        .font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Honne Premium")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("全機能を解放する")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("アップグレード")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "a0a0ff"), Color(hex: "c080ff")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "a0a0ff").opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "a0a0ff").opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var premiumActiveBadge: some View {
        HStack(spacing: 12) {
            Text("✨")
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text("Premium 有効")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("すべての機能が使えます")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(Color(hex: "a0a0ff"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    @ViewBuilder
    private func settingsSectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .tracking(1)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
