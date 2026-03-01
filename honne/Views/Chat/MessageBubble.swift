import SwiftUI

struct MessageBubble: View {
    let message: Message

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(isUser ? .white : Constants.textPrimary)
                    .lineSpacing(6)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(bubbleBackground)
                    .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

                // 危機対応メッセージのとき: 電話番号をタップ可能リンクとして表示
                if !crisisPhoneNumbers.isEmpty {
                    ForEach(crisisPhoneNumbers, id: \.name) { item in
                        Link(destination: URL(string: "tel://\(item.rawNumber)")!) {
                            Label(item.name, systemImage: "phone.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color(hex: "EF4444")))
                        }
                    }
                }
            }

            if !isUser { Spacer(minLength: 60) }
        }
        .transition(.opacity.combined(with: .offset(y: 6)))
    }

    // MARK: - Bubble Background

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            // ユーザー: sky グラデーション + 右上だけ 4px の吹き出し角丸
            UnevenRoundedRectangle(
                topLeadingRadius: 18,
                bottomLeadingRadius: 18,
                bottomTrailingRadius: 18,
                topTrailingRadius: 4
            )
            .fill(Constants.accentGradient)
        } else {
            // AI: 白 + sky-200 ボーダー + 左上だけ 4px
            UnevenRoundedRectangle(
                topLeadingRadius: 4,
                bottomLeadingRadius: 18,
                bottomTrailingRadius: 18,
                topTrailingRadius: 18
            )
            .fill(Color.white)
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 4,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 18,
                    topTrailingRadius: 18
                )
                .stroke(Constants.borderLight, lineWidth: 1)
            )
        }
    }

    // MARK: - Crisis Phone Numbers

    private struct PhoneItem: Identifiable {
        let id = UUID()
        let name: String
        let rawNumber: String   // tel:// に渡すハイフンなし
    }

    private var crisisPhoneNumbers: [PhoneItem] {
        guard message.content.contains("0120-279-338") else { return [] }
        return [
            PhoneItem(name: "よりそいホットライン（0120-279-338）", rawNumber: "0120279338"),
            PhoneItem(name: "いのちの電話（0570-783-556）",         rawNumber: "0570783556"),
        ]
    }
}
