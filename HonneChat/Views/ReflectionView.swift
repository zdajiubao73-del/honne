import SwiftUI

// MARK: - Emotion Tag Model

struct EmotionTag: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
}

// MARK: - Conversation Rank

enum ConversationRank: Int, CaseIterable {
    case seed   = 1  // < 100 chars
    case spark  = 2  // 100-299
    case bloom  = 3  // 300-599
    case star   = 4  // 600-999
    case deep   = 5  // 1000+

    static func from(userCharCount: Int) -> ConversationRank {
        switch userCharCount {
        case ..<100:   return .seed
        case ..<300:   return .spark
        case ..<600:   return .bloom
        case ..<1000:  return .star
        default:       return .deep
        }
    }

    var icon: String {
        switch self {
        case .seed:  return "leaf.fill"
        case .spark: return "flame.fill"
        case .bloom: return "heart.fill"
        case .star:  return "star.fill"
        case .deep:  return "moon.stars.fill"
        }
    }

    var label: String {
        switch self {
        case .seed:  return "はじまり"
        case .spark: return "うちあけ"
        case .bloom: return "こころひらく"
        case .star:  return "本音"
        case .deep:  return "深い対話"
        }
    }

    /// オーブの色（ランクが上がるほどより鮮やか）
    var orbColors: [Color] {
        switch self {
        case .seed:  return [Color(hex: "4ade80"), Color(hex: "16a34a")]
        case .spark: return [Color(hex: "fb923c"), Color(hex: "ea580c")]
        case .bloom: return [Color(hex: "f472b6"), Color(hex: "db2777")]
        case .star:  return [Color(hex: "facc15"), Color(hex: "ca8a04")]
        case .deep:  return [Color(hex: "a78bfa"), Color(hex: "7c3aed")]
        }
    }

    /// ランクの星表示
    var stars: String { String(repeating: "★", count: rawValue) }
}

// MARK: - Reflection View

struct ReflectionView: View {
    @EnvironmentObject var appState: AppState
    let messages: [ChatMessage]
    let situation: Situation

    @State private var appear = false
    @State private var rankAppear = false

    private var detectedEmotions: [EmotionTag] {
        detectEmotions(from: messages)
    }

    private var insight: String {
        generateInsight(situation: situation, emotions: detectedEmotions)
    }

    private var conversationRank: ConversationRank {
        let total = messages.filter { $0.isUser }.map { $0.content.count }.reduce(0, +)
        return ConversationRank.from(userCharCount: total)
    }

    var body: some View {
        ZStack {
            Color(hex: "0f0e1a").ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        titleSection
                        emotionsSection
                        insightSection
                        actionButtons
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appear = true
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.5)) {
                rankAppear = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "4030e8").opacity(0.4), Color(hex: "2617cf").opacity(0.18)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "9893c8").opacity(0.25), lineWidth: 1)
                        )
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "c4c0e8"), Color(hex: "6860c4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .font(.system(size: 14))
                }
                Text("honne")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            Button(action: goHome) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Title Section

    private var rankOrbColors: [Color] { conversationRank.orbColors }

    private var titleSection: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    // 外側のグロー
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [rankOrbColors[0].opacity(0.5), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 14)

                    // グラデーションオーブ
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: rankOrbColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 82, height: 82)
                        .shadow(color: rankOrbColors[0].opacity(0.6), radius: 22, x: 0, y: 10)
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.28), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 82, height: 82)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )

                    // ランクアイコン
                    Image(systemName: conversationRank.icon)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appear)

                // ランクレベルバッジ（右上）
                Text("Lv.\(conversationRank.rawValue)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(rankOrbColors[0])
                            .shadow(color: rankOrbColors[0].opacity(0.6), radius: 6)
                    )
                    .offset(x: 4, y: -4)
                    .scaleEffect(rankAppear ? 1 : 0.3)
                    .opacity(rankAppear ? 1 : 0)
            }

            // ランク名バッジ
            HStack(spacing: 6) {
                Text(conversationRank.stars)
                    .font(.system(size: 9))
                    .foregroundColor(rankOrbColors[0])
                Text(conversationRank.label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                Text(conversationRank.stars)
                    .font(.system(size: 9))
                    .foregroundColor(rankOrbColors[0])
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(rankOrbColors[0].opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(rankOrbColors[0].opacity(0.35), lineWidth: 1)
                    )
            )
            .scaleEffect(rankAppear ? 1 : 0.7)
            .opacity(rankAppear ? 1 : 0)

            Text("振り返り")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: appear)

            Text("\(situation.name)での会話")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.4))
                .opacity(appear ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: appear)
        }
    }

    // MARK: - Emotions Section

    private var emotionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日の気持ち")
                .font(.footnote.weight(.semibold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(detectedEmotions.enumerated()), id: \.element.id) { index, emotion in
                        EmotionChip(emotion: emotion)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 16)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.8)
                                .delay(Double(index) * 0.08 + 0.3),
                                value: appear
                            )
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: appear)
    }

    // MARK: - AI Insight Section

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "9893c8").opacity(0.35), Color(hex: "2617cf").opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 22, height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(hex: "9893c8").opacity(0.3), lineWidth: 0.5)
                        )
                    Image(systemName: "sparkles")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 10, weight: .semibold))
                }
                Text("AIからのメッセージ")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)
                    .tracking(1)
            }

            Text(insight)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "2617cf").opacity(0.15), Color(hex: "1a0f9a").opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "2617cf").opacity(0.25), lineWidth: 1)
                )
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: appear)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button(action: goHome) {
                Text("ホームに戻る")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "2617cf"))
                    )
            }

            Text("話してくれてありがとう")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.7))
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.55), value: appear)
    }

    // MARK: - Helpers

    private func goHome() {
        withAnimation(.easeInOut(duration: 0.4)) {
            appState.showReflection = false
            appState.selectedSituation = nil
            appState.lastMessages = []
        }
    }

    private func detectEmotions(from messages: [ChatMessage]) -> [EmotionTag] {
        let userText = messages.filter { $0.isUser }.map { $0.content }.joined(separator: " ")

        var found: [EmotionTag] = []

        let emotionMap: [(keywords: [String], tag: EmotionTag)] = [
            (["疲れ", "しんどい", "くたくた", "ぐったり", "つかれ"], EmotionTag(name: "お疲れさま", emoji: "😮‍💨")),
            (["不安", "こわい", "怖い", "心配", "ドキドキ", "緊張"], EmotionTag(name: "不安", emoji: "😟")),
            (["寂しい", "さびしい", "孤独", "ひとり", "独り"], EmotionTag(name: "さびしい", emoji: "🫂")),
            (["悲しい", "かなしい", "辛い", "つらい", "泣"], EmotionTag(name: "かなしい", emoji: "😢")),
            (["怒", "むかつく", "腹立", "イライラ", "ムカ"], EmotionTag(name: "むしゃくしゃ", emoji: "😤")),
            (["嬉しい", "うれしい", "楽しい", "たのしい", "最高", "よかった"], EmotionTag(name: "うれしい", emoji: "😊")),
            (["頑張", "がんばる", "やる気", "前向き", "挑戦"], EmotionTag(name: "前向き", emoji: "💪")),
            (["ありがとう", "感謝", "助かった"], EmotionTag(name: "感謝", emoji: "🙏")),
            (["後悔", "失敗", "ミス", "ごめん", "申し訳"], EmotionTag(name: "後悔", emoji: "😔")),
            (["迷い", "どうしよう", "わからない", "悩"], EmotionTag(name: "迷い中", emoji: "🤔")),
        ]

        for item in emotionMap {
            if item.keywords.contains(where: { userText.contains($0) }) {
                found.append(item.tag)
            }
        }

        // Default emotions if nothing detected
        if found.isEmpty {
            switch situation.category {
            case .nature:
                found = [EmotionTag(name: "穏やか", emoji: "🌿"), EmotionTag(name: "リフレッシュ", emoji: "✨")]
            case .indoor:
                found = [EmotionTag(name: "ほっこり", emoji: "☕"), EmotionTag(name: "あったか", emoji: "🕯️")]
            case .urban:
                found = [EmotionTag(name: "考え中", emoji: "💭"), EmotionTag(name: "前向き", emoji: "💪")]
            case .special:
                found = [EmotionTag(name: "特別な気分", emoji: "✨"), EmotionTag(name: "感動", emoji: "🥹")]
            }
        }

        return Array(found.prefix(4))
    }

    private func generateInsight(situation: Situation, emotions: [EmotionTag]) -> String {
        let emotionNames = emotions.map { $0.name }.joined(separator: "、")

        let insights: [SituationCategory: [String]] = [
            .nature: [
                "\(emotionNames)、自然の中で話せてよかった。言葉にできたこと自体が、前に進む力になっているよ。",
                "今日の\(emotionNames)という気持ち、ちゃんと受け取った。自然の中で本音を話せた時間は、心の栄養になる。",
            ],
            .indoor: [
                "温かい場所で\(emotionNames)という気持ちを話せたこと、すごく意味があると思う。その感情、大切にしていこう。",
                "\(emotionNames)を感じながらも話してくれた。安心できる場所で本音を出せたこと、一歩前に進んでいるよ。",
            ],
            .urban: [
                "賑やかな都会の中でも、自分と向き合う時間が持てたね。\(emotionNames)を感じながらも、前に進んでいけるよ。",
            ],
            .special: [
                "特別な場所で、特別な時間だったね。\(emotionNames)という気持ちと一緒に、この夜を覚えていてほしい。",
            ],
        ]

        let options = insights[situation.category] ?? ["話してくれてありがとう。\(emotionNames)という気持ちを忘れないでね。"]
        return options.randomElement()!
    }
}

// MARK: - Emotion Chip

struct EmotionChip: View {
    let emotion: EmotionTag

    var body: some View {
        HStack(spacing: 8) {
            Text(emotion.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}
