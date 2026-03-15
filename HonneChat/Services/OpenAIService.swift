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
    private let endpoint = "https://eknsaizgeonuundwrifm.supabase.co/functions/v1/super-task"
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVrbnNhaXpnZW9udXVuZHdyaWZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyNTEyMjIsImV4cCI6MjA4NzgyNzIyMn0.ccc-ai1IcblBWGHe8e7VRo3uIzFIp1nX93C6pnLhI8s"

    func sendMessage(
        messages: [OpenAIMessage],
        systemPrompt: String
    ) async throws -> String {
        var allMessages: [OpenAIMessage] = [
            OpenAIMessage(role: "system", content: systemPrompt)
        ]
        allMessages.append(contentsOf: messages)

        let request = OpenAIRequest(
            model: "gpt-4o",
            messages: allMessages,
            temperature: 0.85,
            max_tokens: 200,
            presence_penalty: 0.4,
            frequency_penalty: 0.5
        )

        guard let url = URL(string: endpoint) else {
            throw OpenAIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30

        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = openAIResponse.choices.first?.message.content else {
            throw OpenAIError.noContent
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum OpenAIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case noContent

    var errorDescription: String? {
        switch self {
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
