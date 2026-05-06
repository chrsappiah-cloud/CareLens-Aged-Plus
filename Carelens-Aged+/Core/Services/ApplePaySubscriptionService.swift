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
}

@MainActor
class ApplePaySubscriptionService: ObservableObject {
    static let shared = ApplePaySubscriptionService()

    @Published var purchasedSubscription: SubscriptionProduct?
    @Published var isPurchasing = false
    @Published var purchaseError: String?
    @Published var transactionStatus: TransactionStatus = .idle

    enum TransactionStatus {
        case idle, processing, success, failed(String), restored
    }

    func purchase(_ product: SubscriptionProduct) async {
        isPurchasing = true
        purchaseError = nil
        transactionStatus = .processing

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        purchasedSubscription = product
        transactionStatus = .success
        isPurchasing = false
    }

    func restorePurchases() async {
        transactionStatus = .processing
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        transactionStatus = .restored
    }

    func cancelSubscription() async {
        transactionStatus = .processing
        try? await Task.sleep(nanoseconds: 800_000_000)
        purchasedSubscription = nil
        transactionStatus = .idle
    }
}
