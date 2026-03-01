import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false
    var openAIKey: String = ""

    private let situation: Situation
    private let openAIService = OpenAIService()

    init(situation: Situation) {
        self.situation = situation
    }

    func sendInitialGreeting() {
        isTyping = true

        Task {
            // Small delay for immersion
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            if openAIKey.isEmpty {
                // Fallback greeting when no API key
                let greeting = generateFallbackGreeting()
                let message = ChatMessage(content: greeting, isUser: false)
                messages.append(message)
                isTyping = false
            } else {
                // Use OpenAI for greeting
                let systemMessage = situation.systemPrompt + "\n\n最初の挨拶として、このシチュエーションに合った短い一言を言ってください。自然な感じで。"
                do {
                    let response = try await openAIService.sendMessage(
                        messages: [],
                        systemPrompt: systemMessage,
                        apiKey: openAIKey
                    )
                    let message = ChatMessage(content: response, isUser: false)
                    messages.append(message)
                } catch {
                    let fallback = generateFallbackGreeting()
                    let message = ChatMessage(content: fallback, isUser: false)
                    messages.append(message)
                }
                isTyping = false
            }
        }
    }

    func send(_ text: String) {
        let userMessage = ChatMessage(content: text, isUser: true)
        messages.append(userMessage)

        isTyping = true

        Task {
            if openAIKey.isEmpty {
                // Fallback response
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                let response = ChatMessage(
                    content: "（APIキーが設定されていません。設定画面からOpenAI APIキーを入力してください）",
                    isUser: false
                )
                messages.append(response)
                isTyping = false
            } else {
                do {
                    // Build conversation history for OpenAI
                    let conversationHistory = messages.map { msg in
                        OpenAIMessage(
                            role: msg.isUser ? "user" : "assistant",
                            content: msg.content
                        )
                    }

                    let response = try await openAIService.sendMessage(
                        messages: conversationHistory,
                        systemPrompt: situation.systemPrompt,
                        apiKey: openAIKey
                    )

                    let aiMessage = ChatMessage(content: response, isUser: false)
                    messages.append(aiMessage)
                } catch {
                    let errorMessage = ChatMessage(
                        content: "...ちょっと言葉が出てこなかった。もう一回言ってもらえる？（通信エラー: \(error.localizedDescription)）",
                        isUser: false
                    )
                    messages.append(errorMessage)
                }
                isTyping = false
            }
        }
    }

    private func generateFallbackGreeting() -> String {
        let greetings: [ParticleType: [String]] = [
            .stars: ["...星、きれいだね。今夜は特に見える気がする。", "流れ星、見えた？ 今日は話したいこと、ある？"],
            .fire: ["火、いい感じに燃えてきたね。...なんか話す？", "パチパチって音、落ち着くよね。何考えてた？"],
            .rain: ["雨、止まないね。...コーヒー、もう一杯飲む？", "窓の雨粒、見てた。こういう日は色々考えちゃうよね。"],
            .sunset: ["夕日、きれいだね...。今日はどんな一日だった？", "この時間が一番好きかも。何か話したいことある？"],
            .barLights: ["...いらっしゃい。今日は何にしますか？", "お一人ですか？ゆっくりしていってください。"],
            .leaves: ["あ、この道いい匂いするね。散歩日和だ。", "木漏れ日、気持ちいいね。最近どう？"],
            .snow: ["雪、積もってきたね。あったかいもの飲む？", "静かだね...。こういう夜は何を考える？"],
            .cityLights: ["きれいだね、この景色。...何か話したいことある？", "風、気持ちいいね。夜の街って不思議と落ち着く。"],
            .steam: ["あ〜、最高...。お湯加減どう？", "いい湯だね〜。最近、疲れてない？"],
            .dust: ["ねえ、この本見て...面白そうじゃない？", "静かだね。こういう場所、落ち着くよね。"],
            .cherry: ["花びら、肩に落ちたよ。...春だねぇ。", "桜、今年もきれいだね。何か新しいこと始めた？"],
            .waves: ["月がきれい...波の音、聞こえる？", "砂、冷たくなってきたね。でももう少しここにいたい。"],
            .fireflies: ["あ、光った...きれいだね。子供の頃を思い出す。", "蛍って不思議だよね。何か話したいことある？"],
            .aurora: ["すごい...オーロラってこんなに動くんだね。", "こんな景色見たら、色々考えちゃうよね。"],
            .lanterns: ["きれいだね...一つ飛ばしてみる？願い事は？", "ランタン、まだ見えるかな。何をお願いした？"],
        ]

        let options = greetings[situation.particleType] ?? ["...やあ。話そうか。"]
        return options.randomElement()!
    }
}
