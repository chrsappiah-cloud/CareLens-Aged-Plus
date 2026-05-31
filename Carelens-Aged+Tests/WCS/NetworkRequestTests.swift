import XCTest
@testable import CarelensAged

/// WCS: Network requests — endpoint paths and feature gating before requests fire.
@MainActor
final class NetworkRequestTests: XCTestCase {

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_assessmentInsightEndpoint_hasExpectedPath() {
        let endpoint = APIEndpoint.assessmentInsight(
            type: "NeuroWatch",
            scores: ["cognition": 12],
            age: 82,
            concerns: "Memory"
        )
        XCTAssertEqual(endpoint.path, "/api/v1/insights/assessment")
    }

    func test_freeTierRequest_isBlockedBeforeNetworkCall() async {
        let spy = AccessControlSpy()
        spy.allowedFeatures = []
        let auth = WCSArrange.authenticationService(accessControl: spy)
        _ = await WCSAct.login(auth, email: "clinician@carelens.health", password: "password123")

        XCTAssertFalse(auth.hasAccess(to: .aiInsights))
        XCTAssertTrue(spy.requestedFeatures.contains(.aiInsights))
    }

    func test_starterTier_cannotRequestAdvancedReports() async {
        let middleware = NetworkMiddleware()
        do {
            _ = try await middleware.generateReportNarrative(
                type: "Clinical",
                clientName: "Jane Doe",
                data: [:],
                userTier: .starter
            )
            XCTFail("Expected gating error")
        } catch {
            XCTAssertEqual(
                error.localizedDescription,
                NetworkMiddleware.MiddlewareError.featureNotAvailable.localizedDescription
            )
        }
    }
}
