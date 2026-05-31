import Foundation

@MainActor
protocol AccessControlProviding: AnyObject {
    func canAccess(feature: AppFeature, tier: AccessTier) -> Bool
}

extension AccessManager: AccessControlProviding {}
