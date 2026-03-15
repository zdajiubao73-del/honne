import SwiftUI

struct TermsOfServiceView: View {
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
                                    .fill(Color(hex: "a0ffa0").opacity(0.15))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "a0ffa0"))
                            }
                            Text("最終更新日: 2026年3月")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.top, 12)

                        tosSection(title: "1. 同意について", content: """
                            本アプリをご利用いただくことで、本利用規約に同意したものとみなします。同意いただけない場合は、本アプリのご利用をお控えください。
                            """)

                        tosSection(title: "2. サービスの説明", content: """
                            Honneは、AIとの没入感のある会話体験を提供するアプリです。ユーザーはシチュエーションを選択し、AIと会話することができます。

                            一部機能はサブスクリプション（Honne Premium）によって提供されます。
                            """)

                        tosSection(title: "3. 利用資格", content: """
                            • 本アプリは17歳以上の方を対象としています
                            • 本規約に同意できる法的能力を有する方

                            17歳未満の方は本アプリを利用できません。
                            """)

                        tosSection(title: "4. 禁止事項", content: """
                            以下の行為を禁止します。

                            • 違法行為または違法行為を助長する目的での利用
                            • 他者への嫌がらせ、差別的発言の生成
                            • アプリのリバースエンジニアリングまたは改ざん
                            • 本アプリを商業目的で無断転用
                            • OpenAIの利用規約に違反する利用
                            • 青少年に有害なコンテンツの意図的な生成
                            """)

                        tosSection(title: "5. AIコンテンツについての免責", content: """
                            本アプリで生成されるAIの回答は、OpenAI GPTモデルによって生成されます。

                            • AI回答の正確性・完全性を保証しません
                            • AI回答は専門的アドバイス（医療・法律・金融等）の代替ではありません
                            • AI生成コンテンツに対する一切の責任を負いません
                            • ユーザーはAI回答を参考情報として利用してください
                            """)

                        tosSection(title: "6. 知的財産権", content: """
                            本アプリのデザイン、コード、グラフィック、音楽、映像コンテンツに関する知的財産権は当方に帰属します。ユーザーが入力した会話テキストの権利はユーザーに帰属します。
                            """)

                        tosSection(title: "7. サービスの変更・終了", content: """
                            当方は予告なく本サービスの内容を変更、または提供を終了する場合があります。これによってユーザーに生じた損害について責任を負いません。
                            """)

                        tosSection(title: "8. 免責事項", content: """
                            本アプリは「現状のまま」提供されます。当方は以下について保証しません。

                            • サービスの継続的な提供
                            • AIの回答内容の正確性
                            • 特定の目的への適合性
                            • 不具合・エラーのないこと

                            法律の許す限り、いかなる損害についても責任を負いません。
                            """)

                        tosSection(title: "9. 準拠法・管轄", content: """
                            本規約は日本法に準拠します。本規約に関する紛争は、日本の裁判所を専属合意管轄裁判所とします。
                            """)

                        tosSection(title: "10. お問い合わせ", content: """
                            本規約に関するご質問は、App Storeのサポートページよりお問い合わせください。
                            """)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("利用規約")
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

    private func tosSection(title: String, content: String) -> some View {
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
