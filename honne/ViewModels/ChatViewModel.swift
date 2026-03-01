import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping: Bool = false
    @Published var showPaywall: Bool = false
    @Published var errorMessage: String?
    @Published var sessionEnded: Bool = false
    @Published var showTopicSelector: Bool = false
    @Published var canRetry: Bool = false

    private let openAI = OpenAIService()
    private var currentSession = Session()
    var onSessionComplete: ((Session) -> Void)?

    init(topic: String? = nil) {
        setupSystemPrompt()
        if let topic = topic {
            Task { await sendInitialGreeting(for: topic) }
        } else {
            addGreeting()
            let hasSeen = UserDefaults.standard.bool(forKey: "honne_hasSeenTopicSelector")
            showTopicSelector = !hasSeen
        }
    }

    // MARK: - Public

    func send(_ text: String, userState: UserState) async {
        guard userState.canSendMessage else {
            showPaywall = true
            return
        }

        let safety = SafetyFilter.check(text)
        if safety == .crisis {
            appendMessage(role: .assistant, content: SafetyFilter.crisisResponse)
            return
        }

        let userMsg = Message(role: .user, content: text)
        messages.append(userMsg)
        currentSession.messages.append(userMsg)
        userState.incrementMessageCount()

        isTyping = true
        errorMessage = nil
        canRetry = false

        do {
            let reply = try await openAI.sendMessage(messages: buildAPIMessages())
            isTyping = false
            appendMessage(role: .assistant, content: reply)
            if messages.filter({ $0.role == .user }).count >= 10 {
                await endSession(userState: userState)
            }
        } catch {
            isTyping = false
            errorMessage = "送信に失敗しました。もう一度試してください。"
            canRetry = true
        }
    }

    /// 初回チャットのインライントピック選択
    func selectInlineTopic(_ prompt: String, userState: UserState) {
        withAnimation(.easeOut(duration: 0.25)) {
            showTopicSelector = false
        }
        UserDefaults.standard.set(true, forKey: "honne_hasSeenTopicSelector")
        Task { await send(prompt, userState: userState) }
    }

    /// ネットワークエラー後のリトライ（ユーザーメッセージは再送しない）
    func retry(userState: UserState) async {
        guard canRetry else { return }
        canRetry = false
        errorMessage = nil
        isTyping = true

        do {
            let reply = try await openAI.sendMessage(messages: buildAPIMessages())
            isTyping = false
            appendMessage(role: .assistant, content: reply)
            if messages.filter({ $0.role == .user }).count >= 10 {
                await endSession(userState: userState)
            }
        } catch {
            isTyping = false
            errorMessage = "送信に失敗しました。もう一度試してください。"
            canRetry = true
        }
    }

    func endSession(userState: UserState) async {
        guard !sessionEnded else { return }
        sessionEnded = true

        userState.recordSession()

        do {
            let (tags, summary) = try await openAI.extractTagsAndSummary(from: currentSession.messages)
            currentSession.emotionTags = tags
            currentSession.summary = summary
        } catch {
            // タグ付けに失敗しても続行
        }

        StorageService.shared.addSession(currentSession)
        onSessionComplete?(currentSession)
    }

    var displayMessages: [Message] {
        messages.filter { $0.role != .system }
    }

    // MARK: - Private

    private func setupSystemPrompt() {
        let systemMsg = Message(role: .system, content: Constants.systemPrompt)
        messages.append(systemMsg)
        currentSession.messages.append(systemMsg)
    }

    private func addGreeting() {
        let greeting = Message(role: .assistant, content: "今日、どんな気持ちですか？")
        messages.append(greeting)
        currentSession.messages.append(greeting)
    }

    private func sendInitialGreeting(for topic: String) async {
        let greeting = Message(role: .assistant, content: "\(topic)について、話してみてください。")
        messages.append(greeting)
        currentSession.messages.append(greeting)
    }

    private func appendMessage(role: MessageRole, content: String) {
        let msg = Message(role: role, content: content)
        messages.append(msg)
        currentSession.messages.append(msg)
        if role == .assistant {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func buildAPIMessages() -> [Message] {
        let system = messages.filter { $0.role == .system }
        let conversation = messages.filter { $0.role != .system }.suffix(20)
        return system + Array(conversation)
    }
}
