import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    let situation: Situation
    @StateObject private var viewModel: ChatViewModel
    @State private var inputText = ""
    @State private var showExitConfirm = false
    @FocusState private var isInputFocused: Bool
    @State private var appearAnimation = false

    init(situation: Situation) {
        self.situation = situation
        _viewModel = StateObject(wrappedValue: ChatViewModel(situation: situation))
    }

    var body: some View {
        ZStack {
            // Immersive background
            ParticleBackgroundView(situation: situation)
                .ignoresSafeArea()

            // Darkened overlay for readability
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Messages
                messagesView

                // Input bar
                inputBar
            }
        }
        .onAppear {
            viewModel.openAIKey = appState.openAIKey
            AudioManager.shared.play(bgm: situation.bgmFileName)

            withAnimation(.easeOut(duration: 0.8)) {
                appearAnimation = true
            }

            // Send initial greeting
            viewModel.sendInitialGreeting()
        }
        .onDisappear {
            AudioManager.shared.stop()
        }
        .alert("この場所を離れますか？", isPresented: $showExitConfirm) {
            Button("離れる", role: .destructive) {
                exitChat()
            }
            Button("もう少しいる", role: .cancel) {}
        } message: {
            Text("会話の内容は失われます")
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: { showExitConfirm = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                    Text("戻る")
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial.opacity(0.5))
                .cornerRadius(20)
            }

            Spacer()

            // Situation indicator
            VStack(spacing: 2) {
                Text(situation.emoji + " " + situation.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // BGM toggle
            Button(action: {
                AudioManager.shared.toggleMute()
            }) {
                Image(systemName: AudioManager.shared.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(10)
                    .background(.ultraThinMaterial.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Messages

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message, situation: situation)
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    if viewModel.isTyping {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation(.spring(response: 0.3)) {
                    if viewModel.isTyping {
                        proxy.scrollTo("typing", anchor: .bottom)
                    } else if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.isTyping) { _ in
                withAnimation(.spring(response: 0.3)) {
                    if viewModel.isTyping {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("本音を話してみよう...", text: $inputText, axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial.opacity(0.3))
                .cornerRadius(24)
                .focused($isInputFocused)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.white.opacity(0.3)
                        : Color.white
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isTyping)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.2))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Actions

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        inputText = ""
        viewModel.send(text)

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    private func exitChat() {
        withAnimation(.easeInOut(duration: 0.3)) {
            appState.showChat = false
            appState.selectedSituation = nil
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    let situation: Situation
    @State private var appeared = false

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser
                        ? AnyShapeStyle(.ultraThinMaterial)
                        : AnyShapeStyle(Color.white.opacity(0.08))
                    )
                    .cornerRadius(20)
                    .cornerRadius(message.isUser ? 20 : 4, corners: message.isUser ? [.bottomRight] : [.bottomLeft])

                Text(timeString(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.3))
            }

            if !message.isUser { Spacer(minLength: 60) }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Custom corner radius helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotAnimations = [false, false, false]

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .offset(y: dotAnimations[index] ? -5 : 0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.08))
            .cornerRadius(20)

            Spacer()
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.15)
                ) {
                    dotAnimations[i] = true
                }
            }
        }
    }
}
