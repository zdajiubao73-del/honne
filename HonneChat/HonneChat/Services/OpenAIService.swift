import Foundation

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let max_tokens: Int
    let presence_penalty: Double
    let frequency_penalty: Double
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

class OpenAIService {
    private let endpoint = "https://api.openai.com/v1/chat/completions"

    func sendMessage(
        messages: [OpenAIMessage],
        systemPrompt: String,
        apiKey: String
    ) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.noAPIKey
        }

        var allMessages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: systemPrompt)
        ]
        allMessages.append(contentsOf: messages)

        let request = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: allMessages,
            temperature: 0.9,
            max_tokens: 300,
            presence_penalty: 0.6,
            frequency_penalty: 0.3
        )

        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30

        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        let decoder = JSONDecoder()
        let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)

        guard let content = openAIResponse.choices.first?.message.content else {
            throw OpenAIError.noContent
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum OpenAIError: LocalizedError {
    case noAPIKey
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case noContent

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "APIキーが設定されていません"
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "サーバーからの応答が無効です"
        case .apiError(let code, let msg):
            return "APIエラー (\(code)): \(msg)"
        case .noContent:
            return "応答にコンテンツがありません"
        }
    }
}
