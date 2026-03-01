import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var selectedTopic: String?

    let totalPages = 3

    var canAdvance: Bool {
        if currentPage == totalPages - 1 {
            return selectedTopic != nil
        }
        return true
    }

    func advance() {
        guard currentPage < totalPages - 1 else { return }
        currentPage += 1
    }

    func selectTopic(_ topic: String) {
        selectedTopic = topic
    }
}
