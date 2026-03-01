import SwiftUI

struct ChatView: View {
    @EnvironmentObject var userState: UserState
    @StateObject private var vm: ChatViewModel
    @State private var inputText: String = ""
    @State private var showEndAlert = false
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(topic: String? = nil) {
        _vm = StateObject(wrappedValue: ChatViewModel(topic: topic))
    }

    var body: some View {
        ZStack {
            Constants.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(vm.displayMessages.enumerated()), id: \.element.id) { index, msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)

                                // 初回セッション: 最初のAIメッセージ直下にトピック選択チップを表示
                                if index == 0 && vm.showTopicSelector {
                                    inlineTopicSelector
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                        .id("topicSelector")
                                }
                            }
                            if vm.isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                    .onChange(of: vm.displayMessages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: vm.isTyping) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onAppear {
                        scrollToBottom(proxy: proxy)
                    }
                }

                // エラー + リトライ
                if let error = vm.errorMessage {
                    HStack(spacing: 12) {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red.opacity(0.8))
                        if vm.canRetry {
                            Button("再試行") {
                                Task { await vm.retry(userState: userState) }
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Constants.accent)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                }

                inputBar
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isInputFocused = true
            }
        }
        .sheet(isPresented: $vm.showPaywall) {
            PaywallView()
        }
        .onChange(of: vm.sessionEnded) { ended in
            if ended {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
        .alert("今日はここまでにしますか？", isPresented: $showEndAlert) {
            Button("終わる", role: .destructive) {
                Task { await vm.endSession(userState: userState) }
            }
            Button("続ける", role: .cancel) {}
        } message: {
            Text("続きはいつでも話せます")
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Constants.textMuted)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Text("honne")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Constants.textPrimary)
            Spacer()
            Button(action: { showEndAlert = true }) {
                Text("終わる")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.textMuted)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .background(
            Constants.bgPrimary.opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Constants.borderLight.opacity(0.6))
                .frame(height: 0.5)
        }
    }

    // MARK: - Inline Topic Selector

    private var inlineTopicSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("話したいテーマを選ぶ（任意）")
                .font(.system(size: 12))
                .foregroundColor(Constants.textMuted)
                .padding(.leading, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Constants.topicStarters, id: \.label) { item in
                        Button(action: {
                            vm.selectInlineTopic(item.prompt, userState: userState)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 12, weight: .medium))
                                Text(item.label)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(Constants.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(LiquidGlassShape(cornerRadius: 20))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField(
                "",
                text: $inputText,
                prompt: Text("話してみてください…")
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
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill(
                            inputText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? AnyShapeStyle(Constants.borderLight)
                            : AnyShapeStyle(Constants.accentGradient)
                        )
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || vm.isTyping)
            .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Constants.bgPrimary
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Constants.borderLight.opacity(0.6))
                        .frame(height: 0.5)
                }
        )
    }

    // MARK: - Helpers

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        Task { await vm.send(text, userState: userState) }
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
