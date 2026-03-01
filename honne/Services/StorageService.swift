import Foundation

@MainActor
class StorageService {
    static let shared = StorageService()
    private let sessionsKey = "honne_sessions"

    private init() {}

    func saveSessions(_ sessions: [Session]) {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }

    func loadSessions() -> [Session] {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey),
              let sessions = try? JSONDecoder().decode([Session].self, from: data) else {
            return []
        }
        return sessions.sorted { $0.date > $1.date }
    }

    func addSession(_ session: Session) {
        var sessions = loadSessions()
        sessions.insert(session, at: 0)
        saveSessions(sessions)
    }

    func sessionsThisWeek() -> [Session] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return loadSessions().filter { $0.date >= startOfWeek }
    }

    func emotionFrequencyThisWeek() -> [EmotionTag: Int] {
        var freq: [EmotionTag: Int] = [:]
        for session in sessionsThisWeek() {
            for tag in session.emotionTags {
                freq[tag, default: 0] += 1
            }
        }
        return freq
    }
}
