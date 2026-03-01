import Foundation

@MainActor
final class VentViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping = false
    @Published var showPaywall = false
    @Published var errorMessage: String?
    @Published var pendingEffectType: VentEffectType?

    private let openAI = OpenAIService()
    private var systemMessages: [Message] = []

    init() {
        setupSystemPrompt()
        let greeting = Message(role: .assistant, content: "何でも吐き出してOK。全部受け止めるよ。")
        messages.append(greeting)
    }

    func send(_ text: String, userState: UserState) async {
        guard userState.canSendMessage else {
            showPaywall = true
            return
        }

        let safety = SafetyFilter.check(text)
        if safety == .crisis {
            let crisisMsg = Message(
                role: .assistant,
                content: "話してくれてありがとう。今すぐ話を聞いてくれる場所があります。\nよりそいホットライン: 0120-279-338（24時間）"
            )
            messages.append(Message(role: .user, content: text))
            messages.append(crisisMsg)
            return
        }

        messages.append(Message(role: .user, content: text))
        userState.incrementMessageCount()

        pendingEffectType = pickEffect()

        isTyping = true
        errorMessage = nil

        do {
            let apiMessages = buildAPIMessages()
            let reply = try await openAI.sendMessage(messages: apiMessages)
            isTyping = false
            messages.append(Message(role: .assistant, content: reply))
        } catch {
            isTyping = false
            errorMessage = "送信に失敗しました。もう一度試してください。"
        }
    }

    // MARK: - Private

    private func setupSystemPrompt() {
        systemMessages = [Message(role: .system, content: Constants.ventModeSystemPrompt)]
    }

    private func buildAPIMessages() -> [Message] {
        let conversation = messages.filter { $0.role != .system }.suffix(20)
        return systemMessages + Array(conversation)
    }

    private func pickEffect() -> VentEffectType {
        VentEffectType.allCases.randomElement() ?? .explode
    }

    var displayMessages: [Message] {
        messages.filter { $0.role != .system }
    }
}
