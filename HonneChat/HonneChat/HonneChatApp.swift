import SwiftUI

@main
struct HonneChatApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

class AppState: ObservableObject {
    @Published var selectedSituation: Situation?
    @Published var isTransitioning = false
    @Published var showChat = false
    @Published var openAIKey: String = ""

    init() {
        // Load API key from UserDefaults
        self.openAIKey = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }

    func saveAPIKey(_ key: String) {
        self.openAIKey = key
        UserDefaults.standard.set(key, forKey: "openai_api_key")
    }
}
