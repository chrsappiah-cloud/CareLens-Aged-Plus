import XCTest
@testable import CarelensAged

/// WCS Testing Kit — Foundations: behavior-first, narrow unit tests with injected seams.
@MainActor
final class FoundationsTests: XCTestCase {

    // MARK: - Domain models (CareLens equivalents of courses/cohorts/progress)

    func test_clientProfile_fullNameReflectsFirstAndLastName() {
        let client = TestFixtures.client(firstName: "Margaret", lastName: "Kingson")

        XCTAssertEqual(client.fullName, "Margaret Kingson")
    }

    func test_clientProfile_ageUsesDateOfBirth() {
        let client = TestFixtures.client(yearsOld: 82)

        XCTAssertEqual(client.age, 82)
    }

    func test_assessmentSession_mapsStatusStringToEnum() {
        let assessment = AssessmentSession(
            clientID: "c1",
            assessmentType: "NeuroWatch",
            status: "Completed",
            assessorRole: "Clinician"
        )

        XCTAssertEqual(assessment.assessmentStatus, .completed)
    }

    // MARK: - Rules engine (enrollment, access windows, completion logic)

    func test_neuroWatchEngine_lowRiskInput_returnsNoSignificantChangeBand() {
        let result = NeuroWatchEngine.evaluate(TestFixtures.neuroWatchInput())

        XCTAssertEqual(result.band, .noSignificantChange)
        XCTAssertLessThan(result.totalScore, 8)
    }

    func test_neuroWatchEngine_deliriumTrigger_returnsUrgentBand() {
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

        XCTAssertEqual(result.band, .urgentDeliriumRuleOut)
        XCTAssertGreaterThanOrEqual(result.totalScore, 24)
    }

    func test_subscriptionManager_freeTier_blocksAIInsights() {
        let manager = SubscriptionManager()

        XCTAssertFalse(manager.canAccess(feature: .aiInsights, tier: .free))
        XCTAssertTrue(manager.canAccess(feature: .dashboard, tier: .free))
    }

    func test_subscriptionManager_enterpriseTier_grantsAllFeatures() {
        let manager = SubscriptionManager()

        for feature in AppFeature.allCases {
            XCTAssertTrue(
                manager.canAccess(feature: feature, tier: .enterprise),
                "Enterprise should access \(feature.rawValue)"
            )
        }
    }

    // MARK: - Formatting & CTA visibility (status labels, access gating)

    func test_reportService_clinicalReport_includesClientNameAndScores() {
        let client = TestFixtures.client()
        let assessment = AssessmentSession(
            clientID: client.id,
            assessmentType: "NeuroWatch",
            status: "Completed",
            assessorRole: "Clinician"
        )
        assessment.cognitionScore = 4.0
        assessment.moodScore = 3.0

        let report = ReportService().generateReport(
            type: .clinical,
            client: client,
            assessment: assessment,
            carePlan: nil
        )

        XCTAssertTrue(report.contains("Jane Doe"))
        XCTAssertTrue(report.contains("Cognition"))
        XCTAssertTrue(report.contains("Mood"))
    }

    func test_authenticationService_hasAccess_usesInjectedSubscriptionBoundary() async {
        let subscriptionAccess = MockSubscriptionAccess()
        subscriptionAccess.allowedFeatures = [.dashboard]
        let auth = AuthenticationService.makeForTesting(subscriptionAccess: subscriptionAccess)
        _ = await auth.login(email: "clinician@carelens.health", password: "password123")

        XCTAssertTrue(auth.hasAccess(to: .dashboard))
        XCTAssertFalse(auth.hasAccess(to: .aiInsights))
    }

    // MARK: - TDD habits: one rule per test, descriptive naming

    func test_login_withValidAdminCredentials_setsAuthenticatedAdminUser() async {
        let auth = AuthenticationService.makeForTesting()

        let succeeded = await auth.login(email: "admin@carelens.health", password: "CareLens2026!")

        XCTAssertTrue(succeeded)
        XCTAssertTrue(auth.isAuthenticated)
        XCTAssertEqual(auth.currentUser?.role, .admin)
        XCTAssertEqual(auth.currentUser?.subscriptionTier, .enterprise)
    }

    func test_login_withInvalidPassword_setsErrorAndKeepsLoggedOut() async {
        let auth = AuthenticationService.makeForTesting()

        let succeeded = await auth.login(email: "admin@carelens.health", password: "wrong")

        XCTAssertFalse(succeeded)
        XCTAssertFalse(auth.isAuthenticated)
        XCTAssertEqual(auth.errorMessage, "Invalid credentials. Please try again.")
    }

    func test_login_withClinicianEmail_formatsDisplayNameFromLocalPart() async {
        let auth = AuthenticationService.makeForTesting()

        _ = await auth.login(email: "jane.smith@carelens.health", password: "password123")

        XCTAssertEqual(auth.currentUser?.displayName, "Jane Smith")
        XCTAssertEqual(auth.currentUser?.role, .clinician)
    }

    func test_logout_clearsSessionState() async {
        let auth = AuthenticationService.makeForTesting()
        _ = await auth.login(email: "admin@carelens.health", password: "CareLens2026!")

        auth.logout()

        XCTAssertFalse(auth.isAuthenticated)
        XCTAssertNil(auth.currentUser)
    }
}
