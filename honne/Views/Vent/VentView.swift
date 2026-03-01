import SwiftUI

struct VentView: View {
    @EnvironmentObject var userState: UserState
    @StateObject private var vm = VentViewModel()
    @StateObject private var effectSystem = VentEffectSystem()
    @State private var inputText = ""
    @State private var shakeOffset: CGFloat = 0
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 発散モード専用: 白〜水色グラデーション背景
                LinearGradient(
                    colors: [Color(hex: "F0F9FF"), Color(hex: "E0F2FE")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    ventNavBar
                    messageList
                    if let err = vm.errorMessage { errorBanner(err) }
                    inputBar
                }
                .scaleEffect(effectSystem.contentScale)
                .offset(x: shakeOffset)

                // パーティクル + リングオーバーレイ
                VentParticleCanvas(system: effectSystem)

                // フラッシュオーバーレイ（透明感を保つため opacity を抑える）
                effectSystem.flashColor
                    .opacity(effectSystem.flashOpacity * 0.65)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .onChange(of: vm.pendingEffectType) { _, newType in
                guard let newType else { return }
                effectSystem.trigger(newType, in: geo.size)
                animateShake(effectSystem.shakeKeyframes(for: newType))
                vm.pendingEffectType = nil
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isInputFocused = true
            }
        }
        .sheet(isPresented: $vm.showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Nav Bar

    private var ventNavBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.textMuted)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Text("発散モード")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Constants.textPrimary)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .background(
            Color(hex: "F0F9FF").opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Constants.borderLight.opacity(0.8))
                .frame(height: 0.5)
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vm.displayMessages) { msg in
                        MessageBubble(message: msg)
                            .id(msg.id)
                            .transition(
                                msg.role == .user
                                    ? .scale(scale: 0.72, anchor: .bottomTrailing).combined(with: .opacity)
                                    : .scale(scale: 0.85, anchor: .bottomLeading).combined(with: .opacity)
                            )
                    }
                    if vm.isTyping {
                        TypingIndicatorView()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .animation(.spring(response: 0.40, dampingFraction: 0.62), value: vm.displayMessages.count)
            }
            .onChange(of: vm.displayMessages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: vm.isTyping) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField(
                "",
                text: $inputText,
                prompt: Text("全部吐き出して…")
                    .foregroundColor(Constants.textMuted.opacity(0.6)),
                axis: .vertical
            )
            .font(.system(size: 16))
            .foregroundColor(Constants.textPrimary)
            .lineLimit(1...4)
            .focused($isInputFocused)
            .onSubmit { sendMessage() }
            .submitLabel(.send)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(LiquidGlassCapsule())

            Button(action: sendMessage) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill(
                            inputText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? AnyShapeStyle(Constants.borderLight)
                            : AnyShapeStyle(
                                LinearGradient(
                                    colors: [Color.orange, Color(hex: "F97316")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isTyping)
            .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(hex: "F0F9FF")
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Constants.borderLight.opacity(0.8))
                        .frame(height: 0.5)
                }
        )
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 13))
            .foregroundColor(.red.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
    }

    // MARK: - Helpers

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        Task { await vm.send(text, userState: userState) }
    }

    private func animateShake(_ keyframes: [CGFloat]) {
        guard !keyframes.isEmpty else { return }
        var delay: Double = 0
        let interval: Double = 0.055
        for offset in keyframes {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: interval)) {
                    shakeOffset = offset
                }
            }
            delay += interval
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if vm.isTyping {
                withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
            } else if let last = vm.displayMessages.last {
                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
            }
        }
    }
}
