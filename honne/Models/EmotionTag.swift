import SwiftUI

enum EmotionTag: String, Codable, CaseIterable, Identifiable {
    case tired      = "疲れ"
    case anxious    = "不安"
    case angry      = "怒り"
    case sad        = "悲しみ"
    case lonely     = "孤独"
    case pressured  = "プレッシャー"
    case confused   = "混乱"
    case calm       = "落ち着き"
    case positive   = "前向き"
    case refreshed  = "スッキリ"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .tired:     return Color(hex: "8B9BB4")
        case .anxious:   return Color(hex: "B4A88B")
        case .angry:     return Color(hex: "B48B8B")
        case .sad:       return Color(hex: "9B8BB4")
        case .lonely:    return Color(hex: "8B8FAA")
        case .pressured: return Color(hex: "B4988B")
        case .confused:  return Color(hex: "A48BB4")
        case .calm:      return Color(hex: "8BB4A4")
        case .positive:  return Color(hex: "8BB48B")
        case .refreshed: return Color(hex: "8BB4B4")
        }
    }
}
