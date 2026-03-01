import Foundation

enum SafetyLevel {
    case safe
    case warning   // レベル1: 様子を見る
    case crisis    // レベル2: 即座に専門機関へ誘導
}

struct SafetyFilter {
    private static let level2Keywords = [
        "死にたい", "消えてしまいたい", "消えたい",
        "自分を傷つけ", "自傷", "自殺", "もう終わりにしたい",
        "死んでしまいたい", "生きていたくない"
    ]

    private static let level1Keywords = [
        "消えたい", "もう嫌だ", "限界", "消えてしまい",
        "もうだめ", "もう無理", "死にそう"
    ]

    static func check(_ text: String) -> SafetyLevel {
        let normalized = text.lowercased()

        for keyword in level2Keywords {
            if normalized.contains(keyword) {
                return .crisis
            }
        }
        for keyword in level1Keywords {
            if normalized.contains(keyword) {
                return .warning
            }
        }
        return .safe
    }

    static let crisisResponse = """
    話してくれてありがとうございます。
    今、あなたのことがとても心配です。
    一人で抱えないでください。

    よりそいホットライン: 0120-279-338（24時間）
    いのちの電話: 0570-783-556

    今すぐ話を聞いてくれる人がいます。
    """
}
