import SwiftUI

@main
struct honneApp: App {
    @StateObject private var userState = UserState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userState)
                .preferredColorScheme(.light)
                .task {
                    // 起動時に匿名認証（既存セッションがあれば自動復元）
                    await AuthService.shared.signInAnonymously()
                }
        }
    }
}
