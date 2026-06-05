import Testing
import Foundation
@testable import CarelensAged

// MARK: - Authentication Service Tests

struct AuthenticationTests {

    @Test @MainActor func adminLoginSucceeds() async throws {
        let auth = AuthenticationService.makeForTesting()
        let result = await auth.login(email: "admin@carelens.health", password: "CareLens2026!")
        #expect(result == true)
        #expect(auth.isAuthenticated == true)
        #expect(auth.currentUser?.role == .admin)
        #expect(auth.currentUser?.accessTier == .enterprise)
    }

    @Test @MainActor func adminLoginWrongPasswordFails() async throws {
        let auth = AuthenticationService.makeForTesting()
        let result = await auth.login(email: "admin@carelens.health", password: "wrong")
        #expect(result == false)
        #expect(auth.isAuthenticated == false)
    }

    @Test @MainActor func clinicianLoginSucceeds() async throws {
        let auth = AuthenticationService.makeForTesting()
        let result = await auth.login(email: "clinician@carelens.health", password: "password123")
        #expect(result == true)
        #expect(auth.currentUser?.role == .clinician)
        #expect(auth.currentUser?.accessTier == .professional)
    }

    @Test @MainActor func emptyEmailFails() async throws {
        let auth = AuthenticationService.makeForTesting()
        let result = await auth.login(email: "", password: "password123")
        #expect(result == false)
    }

    @Test @MainActor func shortPasswordFails() async throws {
        let auth = AuthenticationService.makeForTesting()
        let result = await auth.login(email: "test@test.com", password: "12345")
        #expect(result == false)
    }

    @Test @MainActor func emailWithoutAtSignFails() async throws {
        let auth = AuthenticationService.makeForTesting()
        let result = await auth.login(email: "testuser", password: "password123")
        #expect(result == false)
    }

    @Test @MainActor func logoutClearsState() async throws {
        let auth = AuthenticationService.makeForTesting()
        _ = await auth.login(email: "admin@carelens.health", password: "CareLens2026!")
        auth.logout()
        #expect(auth.isAuthenticated == false)
        #expect(auth.currentUser == nil)
    }

    @Test @MainActor func isAdminReturnsTrueForAdmin() async throws {
        let auth = AuthenticationService.makeForTesting()
        _ = await auth.login(email: "admin@carelens.health", password: "CareLens2026!")
        #expect(auth.isAdmin() == true)
    }

    @Test @MainActor func isAdminReturnsFalseForClinician() async throws {
        let auth = AuthenticationService.makeForTesting()
        _ = await auth.login(email: "clinician@carelens.health", password: "password123")
        #expect(auth.isAdmin() == false)
    }

    @Test @MainActor func hasAccessChecksAccessTier() async throws {
        let auth = AuthenticationService.makeForTesting()
        _ = await auth.login(email: "clinician@carelens.health", password: "password123")
        #expect(auth.hasAccess(to: .aiInsights) == true)
        #expect(auth.hasAccess(to: .adminPanel) == false)
    }
}

// MARK: - Access Manager Tests

struct AccessManagerTests {

    @Test @MainActor func freeAccessLimited() {
        let manager = AccessManager()
        #expect(manager.canAccess(feature: .aiInsights, tier: .free) == false)
        #expect(manager.canAccess(feature: .dashboard, tier: .free) == true)
    }

    @Test @MainActor func starterAccessMiddleTier() {
        let manager = AccessManager()
        #expect(manager.canAccess(feature: .neuroWatch, tier: .starter) == true)
        #expect(manager.canAccess(feature: .aiInsights, tier: .starter) == false)
    }

    @Test @MainActor func professionalAccessBroad() {
        let manager = AccessManager()
        #expect(manager.canAccess(feature: .aiInsights, tier: .professional) == true)
        #expect(manager.canAccess(feature: .monitoring, tier: .professional) == true)
        #expect(manager.canAccess(feature: .adminPanel, tier: .professional) == false)
    }

    @Test @MainActor func enterpriseAccessAll() {
        let manager = AccessManager()
        for feature in AppFeature.allCases {
            #expect(manager.canAccess(feature: feature, tier: .enterprise) == true, "Enterprise should access \(feature.rawValue)")
        }
    }

    @Test func tierMaxClients() {
        #expect(AccessTier.free.maxClients == 3)
        #expect(AccessTier.starter.maxClients == 15)
        #expect(AccessTier.professional.maxClients == 100)
        #expect(AccessTier.enterprise.maxClients == Int.max)
    }

    @Test @MainActor func setAccessTier() {
        let manager = AccessManager()
        manager.setAccessTier(for: "u2", to: .professional)
        let user = manager.managedUsers.first(where: { $0.id == "u2" })
        #expect(user?.accessTier == .professional)
    }

    @Test @MainActor func toggleUserActive() {
        let manager = AccessManager()
        let wasActive = manager.managedUsers.first(where: { $0.id == "u4" })?.isActive ?? true
        manager.toggleUserActive("u4")
        let isActive = manager.managedUsers.first(where: { $0.id == "u4" })?.isActive ?? false
        #expect(isActive != wasActive)
    }

    @Test @MainActor func addAndRemoveUser() {
        let manager = AccessManager()
        let newUser = AppUser(
            id: "test_user",
            email: "test@test.com",
            displayName: "Test User",
            role: .clinician,
            accessTier: .starter,
            isActive: true,
            facilityID: nil,
            createdAt: .now,
            lastLoginAt: nil
        )
        manager.addUser(newUser)
        #expect(manager.managedUsers.contains(where: { $0.id == "test_user" }))

        manager.removeUser("test_user")
        #expect(!manager.managedUsers.contains(where: { $0.id == "test_user" }))
    }
}

// MARK: - User Role Tests

struct UserRoleTests {

    @Test func accessLevelHierarchy() {
        #expect(UserRole.admin.accessLevel > UserRole.clinician.accessLevel)
        #expect(UserRole.clinician.accessLevel > UserRole.facilityManager.accessLevel)
        #expect(UserRole.facilityManager.accessLevel > UserRole.familyMember.accessLevel)
        #expect(UserRole.familyMember.accessLevel > UserRole.carer.accessLevel)
        #expect(UserRole.carer.accessLevel > UserRole.externalClinician.accessLevel)
    }

    @Test func allRolesHaveNames() {
        for role in UserRole.allCases {
            #expect(!role.rawValue.isEmpty)
        }
    }
}

// MARK: - Health API Service Tests

struct HealthAPIServiceTests {

    @Test func generateClinicalInsightReturnsResult() async throws {
        let service = HealthAPIService()
        let insight = try await service.generateClinicalInsight(
            assessmentType: "NeuroWatch",
            scores: ["totalScore": 12.0, "orientationScore": 3.0],
            clientAge: 82,
            concerns: "Memory lapses, word-finding difficulty"
        )
        #expect(!insight.summary.isEmpty)
        #expect(insight.category == "NeuroWatch")
        #expect(insight.confidence > 0)
    }

    @Test func generateDifferentialAnalysis() async throws {
        let service = HealthAPIService()
        let insight = try await service.generateDifferentialAnalysis(
            symptoms: ["mood": "low", "onset": "acute", "fluctuation": "yes"]
        )
        #expect(!insight.summary.isEmpty)
        #expect(insight.category == "Differential Analysis")
    }

    @Test func generateCarePlanSuggestions() async throws {
        let service = HealthAPIService()
        let insight = try await service.generateCarePlanSuggestions(
            strengths: ["Strong family support", "Motivated"],
            problems: ["Falls risk", "Isolation"],
            assessmentScores: ["adl": 7.0, "cognition": 4.0]
        )
        #expect(!insight.summary.isEmpty)
        #expect(insight.category == "Care Plan AI Suggestions")
    }

    @Test func generateReportNarrative() async throws {
        let service = HealthAPIService()
        let narrative = try await service.generateReportNarrative(
            reportType: "Clinical Summary",
            clientName: "Mrs. Kingson",
            assessmentData: ["cognition": "Mild concern", "mood": "Low"]
        )
        #expect(!narrative.isEmpty)
    }
}

// MARK: - Network Middleware Tests

struct NetworkMiddlewareTests {

    @Test @MainActor func featureGatingBlocksUnauthorized() async {
        let middleware = NetworkMiddleware.shared
        do {
            _ = try await middleware.requestInsight(
                for: .assessmentInsight(type: "Test", scores: [:], age: 80, concerns: ""),
                requiredFeature: .aiInsights,
                userTier: .free
            )
            #expect(Bool(false), "Should have thrown")
        } catch {
            // Expected: feature not available
        }
    }

    @Test @MainActor func featureGatingAllowsAuthorized() async throws {
        let middleware = NetworkMiddleware.shared
        let result = try await middleware.requestInsight(
            for: .assessmentInsight(type: "NeuroWatch", scores: ["total": 10.0], age: 75, concerns: "Memory"),
            requiredFeature: .aiInsights,
            userTier: .professional
        )
        #expect(result != nil)
    }

    @Test @MainActor func reportNarrativeGating() async {
        let middleware = NetworkMiddleware.shared
        do {
            _ = try await middleware.generateReportNarrative(
                type: "Clinical",
                clientName: "Test",
                data: [:],
                userTier: .starter
            )
            #expect(Bool(false), "Should have thrown for starter tier")
        } catch {
            // Expected: feature not available for starter
        }
    }
}

// MARK: - App Feature Tests

struct AppFeatureTests {

    @Test func allFeaturesHaveIcons() {
        for feature in AppFeature.allCases {
            #expect(!feature.icon.isEmpty, "\(feature.rawValue) should have an icon")
        }
    }

    @Test func allFeaturesHaveNames() {
        for feature in AppFeature.allCases {
            #expect(!feature.rawValue.isEmpty)
        }
    }

    @Test func featureCountPerTier() {
        #expect(AccessTier.free.features.count == 3)
        #expect(AccessTier.starter.features.count == 8)
        #expect(AccessTier.professional.features.count == 15)
        #expect(AccessTier.enterprise.features.count == AppFeature.allCases.count)
    }

    @Test func higherTiersContainLowerTierFeatures() {
        let freeFeatures = Set(AccessTier.free.features)
        let starterFeatures = Set(AccessTier.starter.features)
        let proFeatures = Set(AccessTier.professional.features)
        let enterpriseFeatures = Set(AccessTier.enterprise.features)

        #expect(freeFeatures.isSubset(of: starterFeatures))
        #expect(starterFeatures.isSubset(of: proFeatures))
        #expect(proFeatures.isSubset(of: enterpriseFeatures))
    }
}

// MARK: - NeuroWatch Engine Tests

struct NeuroWatchEngineTests {

    @Test func evaluateReturnsValidResult() {
        let input = NeuroWatchInput(
            orientationErrors: 2,
            delayedRecallScore: 3,
            clockTaskScore: 3,
            categoryFluencyCount: 10,
            medicationErrors: 1,
            attentionFluctuation: false,
            familyConcernLevel: 1,
            functionalDeclineLevel: 1,
            acuteMedicalTrigger: false
        )
        let result = NeuroWatchEngine.evaluate(input)
        #expect(result.totalScore >= 0)
        #expect(!result.band.rawValue.isEmpty)
        #expect(!result.recommendations.isEmpty)
    }

    @Test func lowRiskInput() {
        let input = NeuroWatchInput(
            orientationErrors: 0,
            delayedRecallScore: 5,
            clockTaskScore: 5,
            categoryFluencyCount: 15,
            medicationErrors: 0,
            attentionFluctuation: false,
            familyConcernLevel: 0,
            functionalDeclineLevel: 0,
            acuteMedicalTrigger: false
        )
        let result = NeuroWatchEngine.evaluate(input)
        #expect(result.totalScore < 8)
        #expect(result.band == .noSignificantChange)
    }

    @Test func mildConcernRange() {
        let input = NeuroWatchInput(
            orientationErrors: 2,
            delayedRecallScore: 3,
            clockTaskScore: 4,
            categoryFluencyCount: 10,
            medicationErrors: 1,
            attentionFluctuation: false,
            familyConcernLevel: 1,
            functionalDeclineLevel: 0,
            acuteMedicalTrigger: false
        )
        let result = NeuroWatchEngine.evaluate(input)
        #expect(result.band == .mildConcern || result.band == .noSignificantChange)
    }

    @Test func highRiskWithDeliriumTrigger() {
        let input = NeuroWatchInput(
            orientationErrors: 3,
            delayedRecallScore: 1,
            clockTaskScore: 1,
            categoryFluencyCount: 5,
            medicationErrors: 3,
            attentionFluctuation: true,
            familyConcernLevel: 3,
            functionalDeclineLevel: 3,
            acuteMedicalTrigger: true
        )
        let result = NeuroWatchEngine.evaluate(input)
        #expect(result.totalScore >= 24)
        #expect(result.band == .urgentDeliriumRuleOut)
    }

    @Test func bandSuggestedActions() {
        #expect(!NeuroWatchBand.noSignificantChange.suggestedAction.isEmpty)
        #expect(!NeuroWatchBand.mildConcern.suggestedAction.isEmpty)
        #expect(!NeuroWatchBand.progressiveConcern.suggestedAction.isEmpty)
        #expect(!NeuroWatchBand.urgentDeliriumRuleOut.suggestedAction.isEmpty)
    }
}

// MARK: - Theme Tests

struct ThemeTests {

    @Test func colorsAreDefined() {
        _ = CareLensTheme.Colors.backgroundTop
        _ = CareLensTheme.Colors.backgroundBottom
        _ = CareLensTheme.Colors.accentMint
        _ = CareLensTheme.Colors.accentMagenta
        _ = CareLensTheme.Colors.accentAmber
        _ = CareLensTheme.Colors.goldPrimary
        _ = CareLensTheme.Colors.goldLight
        _ = CareLensTheme.Colors.goldDeep
        _ = CareLensTheme.Colors.emeraldGreen
        _ = CareLensTheme.Colors.deepForest
        _ = CareLensTheme.Colors.textPrimary
        _ = CareLensTheme.Colors.textSecondary
        _ = CareLensTheme.Colors.textTertiary
        _ = CareLensTheme.Colors.riskRed
        _ = CareLensTheme.Colors.safeGreen
    }

    @Test func gradientsAreDefined() {
        _ = CareLensTheme.Gradients.background
        _ = CareLensTheme.Gradients.primaryButton
        _ = CareLensTheme.Gradients.diamondGold
        _ = CareLensTheme.Gradients.goldGreen
        _ = CareLensTheme.Gradients.emeraldShine
        _ = CareLensTheme.Gradients.statusSafe
        _ = CareLensTheme.Gradients.statusWarning
        _ = CareLensTheme.Gradients.statusRisk
    }

    @Test func spacingConstants() {
        #expect(CareLensTheme.cardCornerRadius == 22)
        #expect(CareLensTheme.minTouchTarget == 44)
        #expect(CareLensTheme.spacing == 16)
        #expect(CareLensTheme.sectionSpacing == 24)
    }
}
