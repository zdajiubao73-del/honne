import SwiftUI
import Combine
import RevenueCat

@main
struct HonneChatApp: App {
    @StateObject private var appState = AppState()
    @State private var subscriptionManager = SubscriptionManager.shared

    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .error
        #endif
        Purchases.configure(withAPIKey: "appl_kkkKERpQKYrVNdWtWVHlPOcnIVT")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(subscriptionManager)
                .preferredColorScheme(.dark)
        }
    }
}

class AppState: ObservableObject {
    @Published var selectedSituation: Situation?
    @Published var isTransitioning = false
    @Published var showChat = false
    @Published var showReflection = false
    @Published var lastMessages: [ChatMessage] = []
}
