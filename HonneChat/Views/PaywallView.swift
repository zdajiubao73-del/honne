import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @State private var selectedPlan: String = "com.honnechat.app.premium.yearly"
    @State private var showError = false
    @State private var errorMessage = ""

    private let features: [(icon: String, color: String, title: String, description: String)] = [
        ("infinity",       "a0a0ff", "無制限チャット",       "1日何通でも自由に話せる"),
        ("lock.open.fill", "ffd060", "全シチュエーション解放", "15種類すべての場所で話せる"),
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "0a0a1a"), Color(hex: "0f0a20"), Color(hex: "0a0a1a")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(Color(hex: "a0a0ff").opacity(0.08))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: -100)

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Title
                        VStack(spacing: 8) {
                            Text("✨")
                                .font(.system(size: 44))
                            Text("Honne Premium")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color(hex: "a0a0ff")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("本音をもっと深く、もっと自由に")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)

                        // Feature list
                        VStack(spacing: 12) {
                            ForEach(features, id: \.title) { feature in
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: feature.color).opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: feature.icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: feature.color))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(feature.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Text(feature.description)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: "60d080"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal, 20)

                        // Plan selection
                        VStack(spacing: 10) {
                            planCard(
                                productID: "com.honnechat.app.premium.yearly",
                                title: "年額プラン",
                                badge: "一番お得",
                                price: subscriptionManager.yearlyPackage?.storeProduct.localizedPriceString ?? "¥3,800",
                                perMonth: "月あたり約¥317",
                                isRecommended: true
                            )
                            planCard(
                                productID: "com.honnechat.app.premium.monthly",
                                title: "月額プラン",
                                badge: nil,
                                price: subscriptionManager.monthlyPackage?.storeProduct.localizedPriceString ?? "¥480",
                                perMonth: "毎月更新",
                                isRecommended: false
                            )
                        }
                        .padding(.horizontal, 20)

                        // Purchase button
                        purchaseButton

                        // Products reload retry
                        if subscriptionManager.productsLoadFailed || (subscriptionManager.monthlyPackage == nil && subscriptionManager.yearlyPackage == nil && !subscriptionManager.isLoadingProducts) {
                            Button(action: {
                                Task { await subscriptionManager.loadOfferings() }
                            }) {
                                HStack(spacing: 6) {
                                    if subscriptionManager.isLoadingProducts {
                                        ProgressView().scaleEffect(0.7).tint(.gray)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                    }
                                    Text("商品情報を再読み込み")
                                }
                                .font(.footnote)
                                .foregroundColor(Color(hex: "a0a0ff"))
                            }
                            .disabled(subscriptionManager.isLoadingProducts)
                        }

#if targetEnvironment(simulator)
                        Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 20)
                        VStack(spacing: 8) {
                            Text("🛠 シミュレーター用テスト")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Button(action: {
                                subscriptionManager.debugSetPremium(true)
                            }) {
                                Text("デバッグ購入（プレミアム有効化）")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
#endif

                        // Restore + Legal
                        VStack(spacing: 8) {
                            Button(action: { Task { await subscriptionManager.restore() } }) {
                                HStack(spacing: 6) {
                                    if subscriptionManager.isRestoring {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .scaleEffect(0.7)
                                            .tint(.gray)
                                    }
                                    Text("購入を復元する")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            .disabled(subscriptionManager.isRestoring)

                            Text("サブスクリプションはApple IDに請求されます。現在の期間終了の24時間前までに自動更新をオフにしない限り、自動的に更新されます。購入後はiOS設定 > Apple ID > サブスクリプションから管理・解約できます。")
                                .font(.caption2)
                                .foregroundColor(Color.white.opacity(0.3))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .alert("エラー", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .onChange(of: subscriptionManager.isPremium) {
            if subscriptionManager.isPremium { dismiss() }
        }
        .onAppear {
            if subscriptionManager.monthlyPackage == nil && subscriptionManager.yearlyPackage == nil && !subscriptionManager.isLoadingProducts {
                Task { await subscriptionManager.loadOfferings() }
            }
        }
    }

    // MARK: - Plan Card

    @ViewBuilder
    private func planCard(
        productID: String,
        title: String,
        badge: String?,
        price: String,
        perMonth: String,
        isRecommended: Bool
    ) -> some View {
        let isSelected = selectedPlan == productID

        let ringColor: Color = isSelected ? Color(hex: "a0a0ff") : Color.white.opacity(0.3)
        let fillColor: Color = isSelected ? Color(hex: "a0a0ff").opacity(0.12) : Color.white.opacity(0.05)
        let strokeColor: Color = isSelected ? Color(hex: "a0a0ff").opacity(0.5) : Color.white.opacity(0.1)

        Button(action: { selectedPlan = productID }) {
            HStack(spacing: 12) {
                // Radio button
                ZStack {
                    Circle()
                        .stroke(ringColor, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "a0a0ff"))
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        if let badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: "ffd060"))
                                .cornerRadius(4)
                        }
                    }
                    Text(perMonth)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(price)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(fillColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(strokeColor, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button(action: handlePurchase) {
            ZStack {
                if subscriptionManager.isPurchasing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.black)
                } else {
                    HStack(spacing: 8) {
                        Text("プレミアムを始める")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                            .font(.subheadline)
                    }
                    .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [Color(hex: "a0a0ff"), Color(hex: "c080ff")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(subscriptionManager.isPurchasing)
        .padding(.horizontal, 20)
    }

    // MARK: - Actions

    private func handlePurchase() {
#if targetEnvironment(simulator)
        // シミュレーターで offerings が取得できない場合はデバッグバイパス
        if subscriptionManager.monthlyPackage == nil && subscriptionManager.yearlyPackage == nil {
            subscriptionManager.debugSetPremium(true)
            return
        }
#endif
        let package: Package?
        if selectedPlan.contains("yearly") {
            package = subscriptionManager.yearlyPackage
        } else {
            package = subscriptionManager.monthlyPackage
        }

        guard let package else {
            errorMessage = "商品情報の読み込みに失敗しました。しばらくしてからお試しください。"
            showError = true
            return
        }

        Task {
            do {
                _ = try await subscriptionManager.purchase(package)
            } catch {
                errorMessage = "購入に失敗しました: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}
