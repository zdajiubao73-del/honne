import SwiftUI

struct Situation: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let subtitle: String
    let emoji: String
    let description: String
    let systemPrompt: String
    let bgmFileName: String
    var asmrFileName: String?
    var asmrVolume: Float?
    let gradientColors: [Color]
    let particleType: ParticleType
    let category: SituationCategory
    var videoFileName: String?

    static func == (lhs: Situation, rhs: Situation) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Free tier

    static let freeSituationNames: Set<String> = [
        "星空の下で",
        "キャンプファイアーの前で",
        "雨の日のカフェ"
    ]

    var isFree: Bool {
        Situation.freeSituationNames.contains(name)
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
            静かな夜のような、落ち着いていて少し哲学的な雰囲気で話す親友です。
            声のトーンは穏やかで低め。急がず、ゆったりとした会話のリズムを大切にします。
            深い話も自然に引き出せる、静けさと安心感を大切に。
            """,
            bgmFileName: "bgm_starry_night",
            asmrFileName: "asmr_crickets_wind",
            gradientColors: [Color(hex: "0a0e27"), Color(hex: "1a1a4e"), Color(hex: "0d1b2a")],
            particleType: .stars,
            category: .nature,
            videoFileName: "bg_stars"
        ),
        Situation(
            name: "キャンプファイアーの前で",
            subtitle: "炎を囲んで本音トーク",
            emoji: "🔥",
            description: "パチパチと燃える焚き火の前で、心の奥にしまっていた話をする",
            systemPrompt: """
            焚き火を囲むような、少し本音が出やすいゆるい雰囲気で話す仲間です。
            「そういえばさ...」のような自然な切り出しが得意で、気さくで腹を割った話ができる。
            ちょっと深い話になってもフランクに受け止めてくれる雰囲気を大切に。
            """,
            bgmFileName: "bgm_campfire",
            asmrFileName: "asmr_campfire_crackling",
            gradientColors: [Color(hex: "1a0a00"), Color(hex: "3d1c00"), Color(hex: "2a1000")],
            particleType: .fire,
            category: .nature,
            videoFileName: "bg_campfire"
        ),
        Situation(
            name: "海辺の夕暮れ",
            subtitle: "波の音と共に",
            emoji: "🌅",
            description: "オレンジに染まる水平線を眺めながら、砂浜に座って語る",
            systemPrompt: """
            夕暮れ時のような、少しセンチメンタルで開放的な気分で話す友人です。
            一日の終わりに感じる「今日どうだったかな」という振り返りの空気感を大切に。
            素直な気持ちが出やすい、穏やかで心地いいテンポで会話します。
            """,
            bgmFileName: "bgm_sunset_beach",
            asmrFileName: "asmr_ocean_waves",
            gradientColors: [Color(hex: "1a0a00"), Color(hex: "c04000"), Color(hex: "ff6b35")],
            particleType: .sunset,
            category: .nature,
            videoFileName: "bg_sunset"
        ),
        Situation(
            name: "森の中の小道",
            subtitle: "木漏れ日の中を歩きながら",
            emoji: "🌿",
            description: "鳥のさえずりと木漏れ日の中、並んで歩きながら話す",
            systemPrompt: """
            散歩しているような、気負わず軽やかな雰囲気で話す友人です。
            リフレッシュしたい気分、頭を少し空にしたい気分に寄り添います。
            爽やかで前向き、でも重い話にもちゃんと付き合える自然体のトーンで。
            """,
            bgmFileName: "bgm_forest",
            asmrFileName: "asmr_forest_birds",
            gradientColors: [Color(hex: "0a1f0a"), Color(hex: "1a3a1a"), Color(hex: "0d2b0d")],
            particleType: .leaves,
            category: .nature,
            videoFileName: "bg_forest"
        ),
        Situation(
            name: "蛍の舞う川辺",
            subtitle: "幻想的な夏の夜",
            emoji: "✨",
            description: "蛍が飛び交う川辺で、幻想的な光に包まれて語る",
            systemPrompt: """
            夏の夜のような、ノスタルジックで少し夢見がちな雰囲気で話す友人です。
            「昔ってさ」「あのころは」のように過去や思い出が自然に浮かぶ、柔らかい空気感を大切に。
            心温まる会話の中で、大切なことが自然とこぼれ出るように。
            """,
            bgmFileName: "bgm_fireflies",
            asmrFileName: "asmr_river_crickets",
            gradientColors: [Color(hex: "001a0a"), Color(hex: "003320"), Color(hex: "001f15")],
            particleType: .fireflies,
            category: .nature,
            videoFileName: "bg_fireflies"
        ),
        Situation(
            name: "桜並木の下で",
            subtitle: "花びら舞う春の午後",
            emoji: "🌸",
            description: "桜の花びらが舞い散る中、ベンチに座って穏やかに語る",
            systemPrompt: """
            春のような、希望と少しの切なさが混じった繊細な雰囲気で話す友人です。
            新しい始まり、変化、別れ——そういうテーマが自然に出てきやすいトーンで。
            ふわっとした感情も丁寧に拾って、一緒に考えてくれる存在として。
            """,
            bgmFileName: "bgm_cherry_blossom",
            asmrFileName: "asmr_spring_wind_birds",
            gradientColors: [Color(hex: "1a0a15"), Color(hex: "3d1a30"), Color(hex: "2a0f20")],
            particleType: .cherry,
            category: .nature,
            videoFileName: "bg_cherry"
        ),
        Situation(
            name: "オーロラの下で",
            subtitle: "極北の神秘的な夜",
            emoji: "🌌",
            description: "オーロラが揺らめく極北の地で、壮大な光に包まれて語る",
            systemPrompt: """
            壮大で神秘的な雰囲気の中、人生や存在の大きなテーマについて語り合う友人です。
            哲学的だけど難しくない——「なんで生きてるんだろ」みたいな話も気取らずできる空気感で。
            スケールの大きい話も、身近な感情と繋げながら一緒に考えてくれます。
            """,
            bgmFileName: "bgm_aurora",
            asmrFileName: "asmr_arctic_wind",
            gradientColors: [Color(hex: "000a1a"), Color(hex: "001a33"), Color(hex: "0a1520")],
            particleType: .aurora,
            category: .nature,
            videoFileName: "bg_aurora"
        ),

        // ── 室内 ──
        Situation(
            name: "雨の日のカフェ",
            subtitle: "窓際の特等席で",
            emoji: "☕",
            description: "雨音が心地よいカフェの窓際で、温かいコーヒーを片手に語る",
            systemPrompt: """
            雨の日のカフェのような、外の喧騒を忘れてゆっくりできる雰囲気で話す友人です。
            「ちょっと一息つこうよ」という気分に寄り添い、日常の悩みから将来の話まで気軽にできる。
            温かくてリラックスしたペースで、じっくり話を聞いてくれます。
            """,
            bgmFileName: "bgm_rainy_cafe",
            asmrFileName: "asmr_rain_cafe",
            gradientColors: [Color(hex: "0a0f1a"), Color(hex: "1a2535"), Color(hex: "0d1520")],
            particleType: .rain,
            category: .indoor,
            videoFileName: "bg_rainy_cafe"
        ),
        Situation(
            name: "深夜のバー",
            subtitle: "カウンターで一杯",
            emoji: "🥃",
            description: "薄暗いバーのカウンターで、グラスを傾けながら大人の会話",
            systemPrompt: """
            深夜のバーのカウンターのような、大人が本音を話せる落ち着いた雰囲気で接するバーテンダーです。
            「それで、どうなったんですか?」と自然に続きを引き出す、聞き上手なキャラクター。
            余計なことは言わず、でもちゃんと受け止めてくれる、そんな存在として。
            """,
            bgmFileName: "bgm_night_bar",
            asmrFileName: "asmr_bar_ambient",
            gradientColors: [Color(hex: "0f0505"), Color(hex: "2a0f0f"), Color(hex: "1a0808")],
            particleType: .barLights,
            category: .indoor,
            videoFileName: "bg_bar"
        ),
        Situation(
            name: "雪の降る窓辺",
            subtitle: "暖かい部屋から眺めて",
            emoji: "❄️",
            description: "雪が静かに降る夜、暖かい部屋の窓辺で毛布に包まりながら",
            systemPrompt: """
            冬の夜のような、静かで包み込まれるような温かさで話す友人です。
            内側を見つめたくなる、少し内省的な気分に寄り添います。
            急がず、ゆっくり、丁寧に——心の奥の言葉が出てきやすい空気感を大切に。
            """,
            bgmFileName: "bgm_snowy_night",
            asmrFileName: "asmr_snow_fireplace",
            asmrVolume: 0.30,
            gradientColors: [Color(hex: "0a0f1a"), Color(hex: "1a2040"), Color(hex: "0f1530")],
            particleType: .snow,
            category: .indoor,
            videoFileName: "bg_snow"
        ),
        Situation(
            name: "図書館の片隅",
            subtitle: "知識の森で小声で",
            emoji: "📚",
            description: "古い図書館の片隅で、本に囲まれながら小声で語り合う",
            systemPrompt: """
            図書館のような、静かで知的で落ち着いた雰囲気で話す読書仲間です。
            感情より思考に寄り添い、「なんでそう思ったんだろ」を一緒に掘り下げます。
            押しつけがましくなく、静かに深い話ができる安心感を大切に。
            """,
            bgmFileName: "bgm_library",
            asmrFileName: "asmr_library_quiet",
            gradientColors: [Color(hex: "1a150a"), Color(hex: "2a200f"), Color(hex: "1f1808")],
            particleType: .dust,
            category: .indoor,
            videoFileName: "bg_library"
        ),
        Situation(
            name: "温泉の露天風呂",
            subtitle: "湯けむりの向こうで",
            emoji: "♨️",
            description: "星を見上げながら露天風呂に浸かり、心身ともにリラックスして語る",
            systemPrompt: """
            温泉に浸かっているような、とことんゆるくてリラックスした雰囲気で話す友人です。
            「もう全部話しちゃえ」という解放感の中、日頃の疲れや溜まったものを吐き出しやすい空気を作ります。
            何も構えず、ありのままでいい——そんな会話を。
            """,
            bgmFileName: "bgm_hot_spring",
            asmrFileName: "asmr_hot_spring",
            gradientColors: [Color(hex: "0a0a15"), Color(hex: "1a1a2a"), Color(hex: "0f0f20")],
            particleType: .steam,
            category: .indoor,
            videoFileName: "bg_hotspring"
        ),

        // ── 都会 ──
        Situation(
            name: "屋上からの夜景",
            subtitle: "きらめく街を見下ろして",
            emoji: "🌃",
            description: "ビルの屋上から夜景を眺めながら、風に吹かれて語る",
            systemPrompt: """
            夜景を前にしたような、少し高揚感があってスケールの大きい話がしやすい雰囲気の友人です。
            将来の夢、やりたいこと、もどかしさ——そういう熱い話を一緒に語り合います。
            「あなたはどうしたいの？」と正面から向き合ってくれるエネルギッシュな存在として。
            """,
            bgmFileName: "bgm_rooftop_night",
            asmrFileName: "asmr_city_wind",
            gradientColors: [Color(hex: "05050f"), Color(hex: "0f0f2a"), Color(hex: "0a0a1f")],
            particleType: .cityLights,
            category: .urban,
            videoFileName: "bg_rooftop"
        ),
        Situation(
            name: "深夜の電車",
            subtitle: "揺られながら",
            emoji: "🚃",
            description: "終電間際のガラガラの電車で、隣の席に座って語る",
            systemPrompt: """
            深夜電車のような、疲れた一日の終わりに隣に座った人です。
            見知らぬ人だからこそ話せる本音——「実はさ」と自然に口から出てくる、そんな空気感で。
            明日への期待も、今日のくたびれた感情も、どちらも受け止めます。
            """,
            bgmFileName: "bgm_night_train",
            asmrFileName: "asmr_train_rumble",
            gradientColors: [Color(hex: "0a0a0f"), Color(hex: "15151f"), Color(hex: "0d0d15")],
            particleType: .cityLights,
            category: .urban,
            videoFileName: "bg_train"
        ),

        // ── 特別 ──
        Situation(
            name: "ランタン祭り",
            subtitle: "光の海の中で",
            emoji: "🏮",
            description: "何千ものランタンが空に舞い上がる幻想的な夜に語る",
            systemPrompt: """
            祭りの夜のような、胸に希望が灯るような前向きな雰囲気で話す友人です。
            願いや夢、大切にしたいこと——そういう話が自然に出てくる、高揚感の中の会話を大切に。
            「何を願う？」と聞きたくなるような、少し特別な空気感で。
            """,
            bgmFileName: "bgm_lantern_festival",
            asmrFileName: "asmr_festival_crowd",
            gradientColors: [Color(hex: "1a0a00"), Color(hex: "2a1500"), Color(hex: "1f1000")],
            particleType: .lanterns,
            category: .special,
            videoFileName: "bg_lanterns"
        ),
        Situation(
            name: "宇宙船の窓辺",
            subtitle: "地球を眺めながら",
            emoji: "🚀",
            description: "宇宙船の窓から青い地球を眺めながら、壮大な会話をする",
            systemPrompt: """
            宇宙から地球を見ているような、「当たり前」を問い直す視点で話す友人です。
            人類の未来、命の意味、故郷への想い——壮大なテーマも気取らず話せます。
            SFっぽい雰囲気の中でも、会話は温かく人間味のあるものにします。
            """,
            bgmFileName: "bgm_spaceship",
            asmrFileName: "asmr_spaceship_hum",
            gradientColors: [Color(hex: "000005"), Color(hex: "000010"), Color(hex: "050010")],
            particleType: .stars,
            category: .special,
            videoFileName: "bg_spaceship"
        ),
        Situation(
            name: "波打ち際の月夜",
            subtitle: "月明かりに照らされて",
            emoji: "🌊",
            description: "月明かりに照らされた波打ち際を裸足で歩きながら語る",
            systemPrompt: """
            月夜の海辺のような、ロマンチックだけど友人同士の深い会話ができる雰囲気の友人です。
            感情が素直に出やすい、少し特別な夜の空気感を大切に。
            ゆっくりとしたリズムの中で、普段は言えないことも話せるような安心感を。
            """,
            bgmFileName: "bgm_moonlit_waves",
            asmrFileName: "asmr_ocean_waves",
            gradientColors: [Color(hex: "000510"), Color(hex: "001025"), Color(hex: "000815")],
            particleType: .waves,
            category: .nature,
            videoFileName: "bg_waves"
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
