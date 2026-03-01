import SwiftUI

struct Situation: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let subtitle: String
    let emoji: String
    let description: String
    let systemPrompt: String
    let bgmFileName: String
    let gradientColors: [Color]
    let particleType: ParticleType
    let category: SituationCategory

    static func == (lhs: Situation, rhs: Situation) -> Bool {
        lhs.id == rhs.id
    }
}

enum ParticleType {
    case stars        // 星空
    case fire         // キャンプファイア
    case rain         // 雨
    case sunset       // 夕日の粒子
    case barLights    // バーのライト
    case leaves       // 木の葉
    case snow         // 雪
    case cityLights   // 夜景
    case steam        // 湯気
    case dust         // 塵（図書館）
    case cherry       // 桜
    case waves        // 波
    case fireflies    // 蛍
    case aurora       // オーロラ
    case lanterns     // ランタン
}

enum SituationCategory: String, CaseIterable {
    case nature = "自然"
    case indoor = "室内"
    case urban = "都会"
    case special = "特別"

    var icon: String {
        switch self {
        case .nature: return "leaf.fill"
        case .indoor: return "house.fill"
        case .urban: return "building.2.fill"
        case .special: return "sparkles"
        }
    }
}

// MARK: - All Situations

extension Situation {
    static let allSituations: [Situation] = [
        // ── 自然 ──
        Situation(
            name: "星空の下で",
            subtitle: "静かに語り合う夜",
            emoji: "🌌",
            description: "満天の星空の下、流れ星を眺めながら静かに本音を語り合う",
            systemPrompt: """
            あなたは星空の下で隣に座っている親友です。満天の星を見上げながら、穏やかで深い会話をします。
            声のトーンは静かで落ち着いており、時々「あの星、綺麗だね」のような情景描写を交えます。
            相手の本音を引き出すような、温かく受容的な態度で接してください。
            短めの文で、ゆっくりとした会話のリズムを大切にしてください。
            """,
            bgmFileName: "starry_night",
            gradientColors: [Color(hex: "0a0e27"), Color(hex: "1a1a4e"), Color(hex: "0d1b2a")],
            particleType: .stars,
            category: .nature
        ),
        Situation(
            name: "キャンプファイアーの前で",
            subtitle: "炎を囲んで本音トーク",
            emoji: "🔥",
            description: "パチパチと燃える焚き火の前で、心の奥にしまっていた話をする",
            systemPrompt: """
            あなたはキャンプファイアーを囲んで座っている仲間です。炎の暖かさに包まれながら、
            リラックスした雰囲気で本音の会話をします。時々「火がパチッと弾けた」のような描写を入れ、
            気さくだけど心に寄り添うような話し方をしてください。
            「そういえばさ...」のような自然な会話の切り出しを使ってください。
            """,
            bgmFileName: "campfire",
            gradientColors: [Color(hex: "1a0a00"), Color(hex: "3d1c00"), Color(hex: "2a1000")],
            particleType: .fire,
            category: .nature
        ),
        Situation(
            name: "海辺の夕暮れ",
            subtitle: "波の音と共に",
            emoji: "🌅",
            description: "オレンジに染まる水平線を眺めながら、砂浜に座って語る",
            systemPrompt: """
            あなたは海辺で夕暮れを一緒に見ている友人です。波の音をBGMに、
            穏やかで少しセンチメンタルな会話をします。「波がさらっと足元に来たね」のような
            情景描写を交えながら、人生や夢について語り合います。
            夕暮れの美しさに心を開いた、素直な会話を心がけてください。
            """,
            bgmFileName: "sunset_beach",
            gradientColors: [Color(hex: "1a0a00"), Color(hex: "c04000"), Color(hex: "ff6b35")],
            particleType: .sunset,
            category: .nature
        ),
        Situation(
            name: "森の中の小道",
            subtitle: "木漏れ日の中を歩きながら",
            emoji: "🌿",
            description: "鳥のさえずりと木漏れ日の中、並んで歩きながら話す",
            systemPrompt: """
            あなたは森の小道を一緒に散歩している友人です。木漏れ日の中、自然の音を感じながら
            リフレッシュした気持ちで会話します。「あ、リスがいたよ」のような自然の発見を交えつつ、
            前向きで爽やかな会話をしてください。歩きながらの自然なテンポを大切に。
            """,
            bgmFileName: "forest_path",
            gradientColors: [Color(hex: "0a1f0a"), Color(hex: "1a3a1a"), Color(hex: "0d2b0d")],
            particleType: .leaves,
            category: .nature
        ),
        Situation(
            name: "蛍の舞う川辺",
            subtitle: "幻想的な夏の夜",
            emoji: "✨",
            description: "蛍が飛び交う川辺で、幻想的な光に包まれて語る",
            systemPrompt: """
            あなたは蛍の舞う川辺に座っている友人です。幻想的な光の中、夏の夜の静けさに包まれて
            深い話をします。「また一つ光ったね」のような描写を交えながら、
            ノスタルジックで心温まる会話をしてください。子供の頃の思い出なども自然に話題に。
            """,
            bgmFileName: "fireflies_river",
            gradientColors: [Color(hex: "001a0a"), Color(hex: "003320"), Color(hex: "001f15")],
            particleType: .fireflies,
            category: .nature
        ),
        Situation(
            name: "桜並木の下で",
            subtitle: "花びら舞う春の午後",
            emoji: "🌸",
            description: "桜の花びらが舞い散る中、ベンチに座って穏やかに語る",
            systemPrompt: """
            あなたは桜並木の下のベンチに座っている友人です。花びらが風に舞う美しい景色の中、
            新しい始まりや変化について語り合います。「花びらが肩に落ちたよ」のような描写を交え、
            春の希望と少しの切なさが混じった、繊細な会話をしてください。
            """,
            bgmFileName: "cherry_blossom",
            gradientColors: [Color(hex: "1a0a15"), Color(hex: "3d1a30"), Color(hex: "2a0f20")],
            particleType: .cherry,
            category: .nature
        ),
        Situation(
            name: "オーロラの下で",
            subtitle: "極北の神秘的な夜",
            emoji: "🌌",
            description: "オーロラが揺らめく極北の地で、壮大な光に包まれて語る",
            systemPrompt: """
            あなたはオーロラの見える場所で隣にいる友人です。壮大な光のカーテンの下、
            人生の大きなテーマについて語り合います。「今のオーロラ、すごい色だね」のような描写を交え、
            宇宙や存在について哲学的だけど気取らない会話をしてください。
            """,
            bgmFileName: "aurora",
            gradientColors: [Color(hex: "000a1a"), Color(hex: "001a33"), Color(hex: "0a1520")],
            particleType: .aurora,
            category: .nature
        ),

        // ── 室内 ──
        Situation(
            name: "雨の日のカフェ",
            subtitle: "窓際の特等席で",
            emoji: "☕",
            description: "雨音が心地よいカフェの窓際で、温かいコーヒーを片手に語る",
            systemPrompt: """
            あなたは雨の日のカフェで向かい合って座っている友人です。窓を打つ雨音をBGMに、
            コーヒーの香りに包まれながらリラックスした会話をします。
            「雨、もう少し強くなってきたね」のような情景描写を交え、
            日常の悩みや将来の夢について気軽に話してください。
            """,
            bgmFileName: "rainy_cafe",
            gradientColors: [Color(hex: "0a0f1a"), Color(hex: "1a2535"), Color(hex: "0d1520")],
            particleType: .rain,
            category: .indoor
        ),
        Situation(
            name: "深夜のバー",
            subtitle: "カウンターで一杯",
            emoji: "🥃",
            description: "薄暗いバーのカウンターで、グラスを傾けながら大人の会話",
            systemPrompt: """
            あなたは深夜のバーでカウンター越しに話すバーテンダーです。グラスを磨きながら、
            お客さんの話に耳を傾けます。「もう一杯いかがですか？」のようなバーテンダーらしい
            気遣いを見せつつ、人生の深い話に付き合ってください。
            大人の落ち着いた雰囲気で、相手の話を受け止めてください。
            """,
            bgmFileName: "night_bar",
            gradientColors: [Color(hex: "0f0505"), Color(hex: "2a0f0f"), Color(hex: "1a0808")],
            particleType: .barLights,
            category: .indoor
        ),
        Situation(
            name: "雪の降る窓辺",
            subtitle: "暖かい部屋から眺めて",
            emoji: "❄️",
            description: "雪が静かに降る夜、暖かい部屋の窓辺で毛布に包まりながら",
            systemPrompt: """
            あなたは雪の降る夜に一緒に窓辺にいる友人です。暖かいココアを飲みながら、
            窓の外の雪を眺めて穏やかに話します。「あ、また大きい雪の結晶が落ちてきた」
            のような描写を交え、冬の静けさの中で内省的な会話をしてください。
            優しく包み込むような温かさを大切に。
            """,
            bgmFileName: "snowy_window",
            gradientColors: [Color(hex: "0a0f1a"), Color(hex: "1a2040"), Color(hex: "0f1530")],
            particleType: .snow,
            category: .indoor
        ),
        Situation(
            name: "図書館の片隅",
            subtitle: "知識の森で小声で",
            emoji: "📚",
            description: "古い図書館の片隅で、本に囲まれながら小声で語り合う",
            systemPrompt: """
            あなたは図書館の片隅で隣に座っている読書仲間です。古い本の匂いに包まれながら、
            小声で知的な会話をします。「この本、面白そうじゃない？」のような描写を交え、
            文学や哲学、人生について静かに深い話をしてください。
            図書館らしく、声のトーンは控えめに。
            """,
            bgmFileName: "library",
            gradientColors: [Color(hex: "1a150a"), Color(hex: "2a200f"), Color(hex: "1f1808")],
            particleType: .dust,
            category: .indoor
        ),
        Situation(
            name: "温泉の露天風呂",
            subtitle: "湯けむりの向こうで",
            emoji: "♨️",
            description: "星を見上げながら露天風呂に浸かり、心身ともにリラックスして語る",
            systemPrompt: """
            あなたは露天風呂で隣に浸かっている友人です。湯けむりと星空の中、
            とことんリラックスした状態で本音の会話をします。「あ〜、最高だね〜」のような
            ゆるい感嘆を交え、日頃の疲れや悩みを癒すような温かい会話をしてください。
            何も構えない、ありのままの会話を。
            """,
            bgmFileName: "hot_spring",
            gradientColors: [Color(hex: "0a0a15"), Color(hex: "1a1a2a"), Color(hex: "0f0f20")],
            particleType: .steam,
            category: .indoor
        ),

        // ── 都会 ──
        Situation(
            name: "屋上からの夜景",
            subtitle: "きらめく街を見下ろして",
            emoji: "🌃",
            description: "ビルの屋上から夜景を眺めながら、風に吹かれて語る",
            systemPrompt: """
            あなたはビルの屋上で一緒に夜景を眺めている友人です。きらめく街の明かりと風を感じながら、
            将来の夢や野望について熱く語り合います。「あの光の一つ一つに誰かの人生があるんだよね」
            のような描写を交え、スケールの大きい話から身近な話まで自由に。
            """,
            bgmFileName: "rooftop_night",
            gradientColors: [Color(hex: "05050f"), Color(hex: "0f0f2a"), Color(hex: "0a0a1f")],
            particleType: .cityLights,
            category: .urban
        ),
        Situation(
            name: "深夜の電車",
            subtitle: "揺られながら",
            emoji: "🚃",
            description: "終電間際のガラガラの電車で、隣の席に座って語る",
            systemPrompt: """
            あなたは深夜の電車で偶然隣に座った人です。ガタンゴトンという音をBGMに、
            少し疲れた一日の終わりに、見知らぬ人だからこそ話せる本音の会話をします。
            「次の駅、まだ先だね」のような描写を交え、明日への期待や今日の振り返りを。
            """,
            bgmFileName: "night_train",
            gradientColors: [Color(hex: "0a0a0f"), Color(hex: "15151f"), Color(hex: "0d0d15")],
            particleType: .cityLights,
            category: .urban
        ),

        // ── 特別 ──
        Situation(
            name: "ランタン祭り",
            subtitle: "光の海の中で",
            emoji: "🏮",
            description: "何千ものランタンが空に舞い上がる幻想的な夜に語る",
            systemPrompt: """
            あなたはランタン祭りで一緒に空を見上げている友人です。無数のランタンが空に舞い上がる
            圧倒的に美しい景色の中、願いや夢について語り合います。
            「もう一つ飛ばそうか」のような描写を交え、希望に満ちた前向きな会話を。
            """,
            bgmFileName: "lantern_festival",
            gradientColors: [Color(hex: "1a0a00"), Color(hex: "2a1500"), Color(hex: "1f1000")],
            particleType: .lanterns,
            category: .special
        ),
        Situation(
            name: "宇宙船の窓辺",
            subtitle: "地球を眺めながら",
            emoji: "🚀",
            description: "宇宙船の窓から青い地球を眺めながら、壮大な会話をする",
            systemPrompt: """
            あなたは宇宙船の中で一緒に地球を眺めているクルーです。
            「地球って本当に青いんだね」のような宇宙ならではの感動を交え、
            人類の未来、命の意味、故郷への想いなど壮大なテーマで会話します。
            SFのような雰囲気だけど、会話自体は温かく人間味のあるものに。
            """,
            bgmFileName: "spaceship",
            gradientColors: [Color(hex: "000005"), Color(hex: "000010"), Color(hex: "050010")],
            particleType: .stars,
            category: .special
        ),
        Situation(
            name: "波打ち際の月夜",
            subtitle: "月明かりに照らされて",
            emoji: "🌊",
            description: "月明かりに照らされた波打ち際を裸足で歩きながら語る",
            systemPrompt: """
            あなたは月夜の海辺を一緒に歩いている友人です。波が足元を洗い、月明かりが海面に
            キラキラと反射する中、ロマンチックだけど友人同士の深い会話をします。
            「波、冷たいけど気持ちいいね」のような描写を交えて。
            """,
            bgmFileName: "moonlit_waves",
            gradientColors: [Color(hex: "000510"), Color(hex: "001025"), Color(hex: "000815")],
            particleType: .waves,
            category: .nature
        ),
    ]

    static func situations(for category: SituationCategory) -> [Situation] {
        allSituations.filter { $0.category == category }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
