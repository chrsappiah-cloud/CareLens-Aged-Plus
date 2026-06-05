import XCTest
@testable import CarelensAged

/// WCS: Network responses — async success and failure handling.
@MainActor
final class NetworkResponseTests: XCTestCase {

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_healthAPIService_successReturnsNonEmptyInsight() async throws {
        let service = HealthAPIService()
        let insight = try await service.generateClinicalInsight(
            assessmentType: "NeuroWatch",
            scores: ["cognition": 10],
            clientAge: 80,
            concerns: "Wandering"
        )
        XCTAssertFalse(insight.summary.isEmpty)
        XCTAssertGreaterThan(insight.confidence, 0)
    }

    func test_networkMiddleware_syncFailure_surfacesServerError() async {
        let middleware = NetworkMiddleware()
        do {
            try await middleware.syncData(
                clients: [],
                assessments: [],
                plans: [],
                userTier: .free
            )
            XCTFail("Expected sync to be gated for free tier")
        } catch let error as NetworkMiddleware.MiddlewareError {
            if case .featureNotAvailable = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Unexpected middleware error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_networkMiddleware_starterSync_succeedsAgainstMockBackend() async throws {
        let middleware = NetworkMiddleware()
        let client = TestFixtures.client()
        try await middleware.syncData(
            clients: [client],
            assessments: [],
            plans: [],
            userTier: .starter
        )
        XCTAssertEqual(middleware.lastSyncPipeline?.primarySucceeded, true)
    }
}
