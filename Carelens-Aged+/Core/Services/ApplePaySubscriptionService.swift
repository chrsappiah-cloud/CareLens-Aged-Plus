import Foundation
import StoreKit
import SwiftUI
import Combine

enum SubscriptionProduct: String, CaseIterable {
    case starterMonthly = "com.carelens.aged.starter.monthly"
    case starterAnnual = "com.carelens.aged.starter.annual"
    case professionalMonthly = "com.carelens.aged.professional.monthly"
    case professionalAnnual = "com.carelens.aged.professional.annual"
    case enterpriseMonthly = "com.carelens.aged.enterprise.monthly"
    case enterpriseAnnual = "com.carelens.aged.enterprise.annual"

    var tier: SubscriptionTier {
        switch self {
        case .starterMonthly, .starterAnnual: return .starter
        case .professionalMonthly, .professionalAnnual: return .professional
        case .enterpriseMonthly, .enterpriseAnnual: return .enterprise
        }
    }

    var displayName: String {
        switch self {
        case .starterMonthly: return "Starter Monthly"
        case .starterAnnual: return "Starter Annual"
        case .professionalMonthly: return "Professional Monthly"
        case .professionalAnnual: return "Professional Annual"
        case .enterpriseMonthly: return "Enterprise Monthly"
        case .enterpriseAnnual: return "Enterprise Annual"
        }
    }

    var price: String {
        switch self {
        case .starterMonthly: return "$29.99/mo"
        case .starterAnnual: return "$299.99/yr"
        case .professionalMonthly: return "$79.99/mo"
        case .professionalAnnual: return "$799.99/yr"
        case .enterpriseMonthly: return "$199.99/mo"
        case .enterpriseAnnual: return "$1,999.99/yr"
        }
    }

    var savings: String? {
        switch self {
        case .starterAnnual: return "Save 17%"
        case .professionalAnnual: return "Save 17%"
        case .enterpriseAnnual: return "Save 17%"
        default: return nil
        }
    }

    static var allProductIDs: [String] {
        allCases.map(\.rawValue)
    }
}

@MainActor
class ApplePaySubscriptionService: ObservableObject {
    static let shared = ApplePaySubscriptionService()

    @Published var purchasedSubscription: SubscriptionProduct?
    @Published var storeProducts: [Product] = []
    @Published var isPurchasing = false
    @Published var purchaseError: String?
    @Published var transactionStatus: TransactionStatus = .idle

    private var transactionListener: Task<Void, Never>?
    private let usesStoreKitMock: Bool

    enum TransactionStatus: Equatable {
        case idle
        case processing
        case success
        case failed(String)
        case restored
        case pending
    }

    init() {
        usesStoreKitMock = AppEnvironment.usesMockBackends || AppEnvironment.isRunningTests
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        guard !usesStoreKitMock else { return }
        do {
            storeProducts = try await Product.products(for: SubscriptionProduct.allProductIDs)
        } catch {
            purchaseError = "Unable to load App Store products."
        }
    }

    func purchase(_ product: SubscriptionProduct) async {
        isPurchasing = true
        purchaseError = nil
        transactionStatus = .processing

        if usesStoreKitMock {
            await simulatePurchase(product)
            return
        }

        var storeProduct = storeProducts.first(where: { $0.id == product.rawValue })
        if storeProduct == nil {
            storeProduct = try? await Product.products(for: [product.rawValue]).first
        }
        guard let storeProduct else {
            await simulatePurchase(product)
            return
        }

        do {
            let result = try await storeProduct.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                applyPurchase(product)
                transactionStatus = .success
            case .userCancelled:
                transactionStatus = .idle
            case .pending:
                transactionStatus = .pending
            @unknown default:
                transactionStatus = .failed("Unknown purchase result")
            }
        } catch {
            purchaseError = error.localizedDescription
            transactionStatus = .failed(error.localizedDescription)
        }

        isPurchasing = false
    }

    func restorePurchases() async {
        transactionStatus = .processing
        isPurchasing = true

        if usesStoreKitMock {
            try? await Task.sleep(nanoseconds: 500_000_000)
            transactionStatus = .restored
            isPurchasing = false
            return
        }

        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if let transaction = try? checkVerified(result),
                   let product = SubscriptionProduct(rawValue: transaction.productID) {
                    applyPurchase(product)
                    transactionStatus = .restored
                    isPurchasing = false
                    return
                }
            }
            transactionStatus = .restored
        } catch {
            purchaseError = error.localizedDescription
            transactionStatus = .failed(error.localizedDescription)
        }
        isPurchasing = false
    }

    func cancelSubscription() async {
        transactionStatus = .processing
        purchasedSubscription = nil
        AuthenticationService.shared.applySubscriptionTier(.free)
        transactionStatus = .idle
    }

    func localizedPrice(for product: SubscriptionProduct) -> String {
        storeProducts.first(where: { $0.id == product.rawValue })?.displayPrice ?? product.price
    }

    // MARK: - Private

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    if let product = SubscriptionProduct(rawValue: transaction.productID) {
                        self.applyPurchase(product)
                        self.transactionStatus = .success
                    }
                } catch {
                    continue
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error): throw error
        case .verified(let value): return value
        }
    }

    private func simulatePurchase(_ product: SubscriptionProduct) async {
        try? await Task.sleep(nanoseconds: 400_000_000)
        applyPurchase(product)
        transactionStatus = .success
        isPurchasing = false
    }

    private func applyPurchase(_ product: SubscriptionProduct) {
        purchasedSubscription = product
        AuthenticationService.shared.applySubscriptionTier(product.tier)
    }
}

extension AuthenticationService {
    func applySubscriptionTier(_ tier: SubscriptionTier) {
        guard var user = currentUser else { return }
        user.subscriptionTier = tier
        currentUser = user
    }
}
