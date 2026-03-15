import Foundation
import Observation
import RevenueCat

@Observable
class SubscriptionManager {
    static let shared = SubscriptionManager()

    var isPremium = false
    var monthlyPackage: Package?
    var yearlyPackage: Package?
    var isPurchasing = false
    var isRestoring = false
    var isLoadingProducts = false
    var productsLoadFailed = false

    init() {
        Task {
            await loadOfferings()
            await updateSubscriptionStatus()
        }
    }

    // MARK: - Load Offerings

    func loadOfferings() async {
        isLoadingProducts = true
        productsLoadFailed = false
        defer { isLoadingProducts = false }
        do {
            let offerings = try await Purchases.shared.offerings()
            let current = offerings.current

            // まず標準の convenience property を試す
            monthlyPackage = current?.monthly
            yearlyPackage  = current?.annual

            // 見つからない場合は availablePackages から product ID で検索
            if let packages = current?.availablePackages {
                if monthlyPackage == nil {
                    monthlyPackage = packages.first { $0.storeProduct.productIdentifier.contains("monthly") }
                }
                if yearlyPackage == nil {
                    yearlyPackage = packages.first {
                        $0.storeProduct.productIdentifier.contains("yearly") ||
                        $0.storeProduct.productIdentifier.contains("annual")
                    }
                }
            }

            productsLoadFailed = (monthlyPackage == nil && yearlyPackage == nil)
            if let pkgs = current?.availablePackages {
                print("[RC] available packages: \(pkgs.map { $0.storeProduct.productIdentifier })")
            }
        } catch {
            print("[RC] loadOfferings failed: \(error)")
            productsLoadFailed = true
        }
    }

    // MARK: - Purchase

    func purchase(_ package: Package) async throws -> Bool {
        isPurchasing = true
        defer { isPurchasing = false }
        let result = try await Purchases.shared.purchase(package: package)
        if !result.userCancelled {
            isPremium = result.customerInfo.entitlements["premium"]?.isActive == true
            return isPremium
        }
        return false
    }

    // MARK: - Restore

    func restore() async {
        isRestoring = true
        defer { isRestoring = false }
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            print("[RC] restore failed: \(error)")
        }
    }

    // MARK: - Status Check

    func updateSubscriptionStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            isPremium = info.entitlements["premium"]?.isActive == true
        } catch {
            print("[RC] customerInfo failed: \(error)")
        }
    }

#if DEBUG
    func debugSetPremium(_ value: Bool) {
        isPremium = value
    }
#endif
}
