import Foundation

/// Swift 6: 可変状態なし → Sendable 準拠
final class OpenAIService: Sendable {
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    func sendMessage(messages: [Message]) async throws -> String {
        let apiMessages = messages.map { msg -> [String: String] in
            ["role": msg.role.rawValue, "content": msg.content]
        }

        let body: [String: Any] = [
            "model": Constants.openAIModel,
            "messages": apiMessages,
            "max_tokens": 200,
            "temperature": 0.7
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Constants.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        // デバッグ用ログ（本番では削除）
        print("[OpenAI] Status: \(http.statusCode)")
        if http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "no body"
            print("[OpenAI] Error body: \(body)")
            throw OpenAIError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded.choices.first?.message.content ?? ""
    }

    func extractTagsAndSummary(from conversation: [Message]) async throws -> (tags: [EmotionTag], summary: String) {
        let tagRequest = Message(
            role: .user,
            content: "この会話に感情タグ（最大3つ）とサマリーをJSON形式でつけてください。タグは[\"疲れ\",\"不安\",\"怒り\",\"悲しみ\",\"孤独\",\"プレッシャー\",\"混乱\",\"落ち着き\",\"前向き\",\"スッキリ\"]から選んでください。形式: {\"tags\":[...],\"summary\":\"...\"}"
        )

        var allMessages = conversation
        allMessages.append(tagRequest)

        let raw = try await sendMessage(messages: allMessages)

        guard let data = raw.data(using: .utf8),
              let json = try? JSONDecoder().decode(TagResponse.self, from: data) else {
            return ([], "")
        }

        let tags = json.tags.compactMap { tagString in
            EmotionTag.allCases.first { $0.rawValue == tagString }
        }
        return (tags, json.summary)
    }
}

// MARK: - Response Models
private struct OpenAIResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: MessageContent
    }

    struct MessageContent: Decodable {
        let content: String
    }
}

private struct TagResponse: Decodable {
    let tags: [String]
    let summary: String
}

enum OpenAIError: LocalizedError {
    case invalidResponse
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "サーバーとの通信に失敗しました"
        case .networkError:    return "ネットワークエラーが発生しました"
        }
    }
}
