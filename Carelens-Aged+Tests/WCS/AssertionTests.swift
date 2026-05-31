import XCTest
@testable import CarelensAged

/// WCS: Assertion discipline — right assertion for the behavior under test.
@MainActor
final class AssertionTests: XCTestCase {

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_equalityAssertion_forComputedState() {
        let client = TestFixtures.client(firstName: "Ada", lastName: "Lovelace")
        XCTAssertEqual(client.fullName, "Ada Lovelace")
    }

    func test_booleanAssertion_forAccessCondition() {
        let manager = AccessManager()
        XCTAssertTrue(manager.canAccess(feature: .dashboard, tier: .free))
        XCTAssertFalse(manager.canAccess(feature: .aiInsights, tier: .free))
    }

    func test_nilAssertion_forOptionalRelationship() {
        let assessment = AssessmentSession(
            clientID: "c1",
            assessmentType: "NeuroWatch",
            status: "Draft",
            assessorRole: "Clinician"
        )
        XCTAssertNil(assessment.client)
    }

    func test_throwsAssertion_forGatedNetworkCall() async {
        let middleware = await MainActor.run { NetworkMiddleware() }
        do {
            _ = try await middleware.requestInsight(
                for: .assessmentInsight(type: "NW", scores: [:], age: 80, concerns: ""),
                requiredFeature: .aiInsights,
                userTier: .free
            )
            XCTFail("Expected featureNotAvailable")
        } catch {
            XCTAssertEqual(
                error.localizedDescription,
                NetworkMiddleware.MiddlewareError.featureNotAvailable.localizedDescription
            )
        }
    }
}
