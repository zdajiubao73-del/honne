import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false

    var body: some View {
        ZStack {
            if appState.showChat, let situation = appState.selectedSituation {
                ChatView(situation: situation)
                    .transition(.opacity)
            } else if appState.isTransitioning, let situation = appState.selectedSituation {
                WarpTransitionView(situation: situation)
            } else {
                SituationSelectionView(showSettings: $showSettings)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.showChat)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var apiKey: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("OpenAI API Key", systemImage: "key.fill")
                            .foregroundColor(.white)
                            .font(.headline)

                        SecureField("sk-...", text: $apiKey)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)

                        Text("AIとの会話にOpenAIのAPIキーが必要です")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()

                    Spacer()
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        appState.saveAPIKey(apiKey)
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.bold)
                }
            }
        }
        .onAppear {
            apiKey = appState.openAIKey
        }
    }
}
