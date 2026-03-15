import Foundation

struct ConversationSummary: Codable {
    let situationName: String
    let date: Date
    let summary: String
}

class ConversationMemoryService {
    static let shared = ConversationMemoryService()
    private let userDefaultsKey = "conversationSummaries"

    private init() {}

    func save(_ summary: ConversationSummary) {
        var summaries = loadAll()
        summaries.insert(summary, at: 0)
        if summaries.count > 5 {
            summaries = Array(summaries.prefix(5))
        }
        if let data = try? JSONEncoder().encode(summaries) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func loadAll() -> [ConversationSummary] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let summaries = try? JSONDecoder().decode([ConversationSummary].self, from: data) else {
            return []
        }
        return summaries
    }

    func buildMemoryContext() -> String? {
        let summaries = loadAll()
        guard !summaries.isEmpty else { return nil }

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.unitsStyle = .full

        let entries = summaries.map { summary in
            let relativeDate = formatter.localizedString(for: summary.date, relativeTo: Date())
            return "- \(relativeDate)（\(summary.situationName)）: \(summary.summary)"
        }.joined(separator: "\n")

        return """


## 過去の会話の記録（参考情報）
この人とは以前にも話したことがあります：
\(entries)
自然なタイミングで参照しても良いですが、無理に話題にする必要はありません。
"""
    }
}
