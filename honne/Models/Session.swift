import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    let date: Date
    var messages: [Message]
    var emotionTags: [EmotionTag]
    var summary: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        messages: [Message] = [],
        emotionTags: [EmotionTag] = [],
        summary: String = ""
    ) {
        self.id = id
        self.date = date
        self.messages = messages
        self.emotionTags = emotionTags
        self.summary = summary
    }

    var userMessages: [Message] {
        messages.filter { $0.role == .user }
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
