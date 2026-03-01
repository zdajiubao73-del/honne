import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recentSessions: [Session] = []
    @Published var weeklyEmotions: [EmotionTag: Int] = [:]

    func load() {
        recentSessions = StorageService.shared.loadSessions()
        weeklyEmotions = StorageService.shared.emotionFrequencyThisWeek()
    }

    var topEmotions: [EmotionTag] {
        weeklyEmotions
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    /// 今日すでにセッションを完了したか
    var sessionCompletedToday: Bool {
        guard let latest = recentSessions.first else { return false }
        return Calendar.current.isDateInToday(latest.date)
    }
}
