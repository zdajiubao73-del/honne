import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userState: UserState

    var body: some View {
        Group {
            if userState.hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: userState.hasCompletedOnboarding)
        .preferredColorScheme(.light)   // ライトテーマ固定 → ステータスバーが黒アイコンに
    }
}
