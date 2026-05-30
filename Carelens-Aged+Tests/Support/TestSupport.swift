import Foundation
@testable import CarelensAged

@MainActor
final class MockSubscriptionAccess: SubscriptionAccessProviding {
    var allowedFeatures: Set<AppFeature> = Set(AppFeature.allCases)

    func canAccess(feature: AppFeature, tier: SubscriptionTier) -> Bool {
        allowedFeatures.contains(feature)
    }
}

enum TestFixtures {
    static func client(
        firstName: String = "Jane",
        lastName: String = "Doe",
        yearsOld: Int = 80
    ) -> ClientProfile {
        let dob = Calendar.current.date(byAdding: .year, value: -yearsOld, to: .now)!
        return ClientProfile(firstName: firstName, lastName: lastName, dateOfBirth: dob)
    }

    static func appUser(
        id: String = "test-user",
        email: String = "clinician@carelens.health",
        role: UserRole = .clinician,
        tier: SubscriptionTier = .professional
    ) -> AppUser {
        AppUser(
            id: id,
            email: email,
            displayName: "Test Clinician",
            role: role,
            subscriptionTier: tier,
            isActive: true,
            facilityID: "facility_001",
            createdAt: .now,
            lastLoginAt: .now
        )
    }

    static func neuroWatchInput(
        orientationErrors: Int = 0,
        delayedRecallScore: Int = 5,
        acuteMedicalTrigger: Bool = false
    ) -> NeuroWatchInput {
        NeuroWatchInput(
            orientationErrors: orientationErrors,
            delayedRecallScore: delayedRecallScore,
            clockTaskScore: 5,
            categoryFluencyCount: 15,
            medicationErrors: 0,
            attentionFluctuation: false,
            familyConcernLevel: 0,
            functionalDeclineLevel: 0,
            acuteMedicalTrigger: acuteMedicalTrigger
        )
    }
}
