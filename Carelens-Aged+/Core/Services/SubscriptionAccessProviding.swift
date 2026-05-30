import Foundation

@MainActor
protocol SubscriptionAccessProviding: AnyObject {
    func canAccess(feature: AppFeature, tier: SubscriptionTier) -> Bool
}

extension SubscriptionManager: SubscriptionAccessProviding {}
