import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "0a0a0f").ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "60c0ff").opacity(0.15))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "60c0ff"))
                            }
                            Text("最終更新日: 2026年3月")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.top, 12)

                        ppSection(title: "1. 収集する情報", content: """
                            HonneChatアプリ（以下「本アプリ」）は、以下の情報を収集します。

                            【デバイス内に保存する情報】
                            • 会話の記録（プレミアム機能：メモリ）は端末内にのみ保存されます

                            【第三者サービスへ送信する情報】
                            • お客様が入力したメッセージはAI処理のためサーバーへ送信されます
                            • サブスクリプション管理のため、購入情報はRevenueCatへ送信されます

                            本アプリは、お客様の個人を特定できる情報（氏名、メールアドレス等）を収集しません。
                            """)

                        ppSection(title: "2. 情報の利用目的", content: """
                            収集した情報は以下の目的で利用します。

                            • AIとの会話機能の提供
                            • アプリの正常な動作の維持
                            • サービス品質の向上

                            収集した情報を広告目的や第三者への販売には一切使用しません。
                            """)

                        ppSection(title: "3. データの保存とセキュリティ", content: """
                            • チャット履歴はデバイスのメモリにのみ保持されます
                            • プレミアム機能のメモリはデバイス内にのみ保存されます
                            • 当社はお客様のチャット内容をサーバーに保存しません
                            """)

                        ppSection(title: "4. 第三者サービスの利用", content: """
                            本アプリはOpenAI APIを利用しています。入力された会話はOpenAIのサーバーで処理されます。OpenAIのプライバシーポリシー（platform.openai.com）をご確認ください。

                            本アプリ自体は分析ツール、広告SDK、その他のトラッキングサービスを使用しません。
                            """)

                        ppSection(title: "5. 子どものプライバシー", content: """
                            本アプリは13歳未満の子どもを対象としていません。13歳未満の方から意図せずデータを収集した場合は、速やかに削除します。
                            """)

                        ppSection(title: "6. プライバシーポリシーの変更", content: """
                            本プライバシーポリシーは予告なく変更されることがあります。変更はアプリのアップデートとともに反映されます。重要な変更がある場合はアプリ内でお知らせします。
                            """)

                        ppSection(title: "7. お問い合わせ", content: """
                            プライバシーに関するご質問・ご要望は、App Storeのレビュー機能またはサポートページよりお問い合わせください。
                            """)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("プライバシーポリシー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(Color(hex: "a0a0ff"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func ppSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)

            Text(content)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "c0c0c0"))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
