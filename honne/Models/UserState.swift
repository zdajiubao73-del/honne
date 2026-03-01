import Foundation
import Combine

class UserState: ObservableObject {
    @Published var isPro: Bool {
        didSet { UserDefaults.standard.set(isPro, forKey: "isPro") }
    }
    @Published var streak: Int {
        didSet { UserDefaults.standard.set(streak, forKey: "streak") }
    }
    @Published var lastSessionDate: Date? {
        didSet { UserDefaults.standard.set(lastSessionDate, forKey: "lastSessionDate") }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    @Published var dailyMessageCount: Int {
        didSet { UserDefaults.standard.set(dailyMessageCount, forKey: "dailyMessageCount") }
    }
    @Published var lastMessageDate: Date? {
        didSet { UserDefaults.standard.set(lastMessageDate, forKey: "lastMessageDate") }
    }

    let freeMessageLimit = 5

    var canSendMessage: Bool {
        isPro || dailyMessageCount < freeMessageLimit
    }

    var remainingFreeMessages: Int {
        max(0, freeMessageLimit - dailyMessageCount)
    }

    init() {
        self.isPro = UserDefaults.standard.bool(forKey: "isPro")
        self.streak = UserDefaults.standard.integer(forKey: "streak")
        self.lastSessionDate = UserDefaults.standard.object(forKey: "lastSessionDate") as? Date
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.dailyMessageCount = UserDefaults.standard.integer(forKey: "dailyMessageCount")
        self.lastMessageDate = UserDefaults.standard.object(forKey: "lastMessageDate") as? Date
        resetDailyCountIfNeeded()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func recordSession() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastSessionDate, Calendar.current.isDate(last, inSameDayAs: today) {
            return
        }
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        if let last = lastSessionDate, Calendar.current.isDate(last, inSameDayAs: yesterday) {
            streak += 1
        } else {
            streak = 1
        }
        lastSessionDate = today
    }

    func incrementMessageCount() {
        dailyMessageCount += 1
        lastMessageDate = Date()
    }

    private func resetDailyCountIfNeeded() {
        guard let lastDate = lastMessageDate else { return }
        if !Calendar.current.isDateInToday(lastDate) {
            dailyMessageCount = 0
        }
    }
}
