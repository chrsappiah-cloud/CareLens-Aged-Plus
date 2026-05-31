import XCTest
@testable import CarelensAged

/// WCS: Coverage discipline — boundary tests for branches and sequential logic.
final class CoverageTests: XCTestCase {

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_neuroWatchEngine_boundaryAtScore7_isNoSignificantChange() {
        let input = NeuroWatchInput(
            orientationErrors: 1,
            delayedRecallScore: 4,
            clockTaskScore: 4,
            categoryFluencyCount: 12,
            medicationErrors: 0,
            attentionFluctuation: false,
            familyConcernLevel: 0,
            functionalDeclineLevel: 0,
            acuteMedicalTrigger: false
        )
        let result = NeuroWatchEngine.evaluate(input)
        XCTAssertLessThanOrEqual(result.totalScore, 7)
        XCTAssertEqual(result.band, .noSignificantChange)
    }

    func test_neuroWatchEngine_boundaryAtScore8_isMildConcern() {
        let input = NeuroWatchInput(
            orientationErrors: 2,
            delayedRecallScore: 3,
            clockTaskScore: 3,
            categoryFluencyCount: 10,
            medicationErrors: 0,
            attentionFluctuation: false,
            familyConcernLevel: 0,
            functionalDeclineLevel: 0,
            acuteMedicalTrigger: false
        )
        let result = NeuroWatchEngine.evaluate(input)
        XCTAssertGreaterThanOrEqual(result.totalScore, 8)
        XCTAssertEqual(result.band, .mildConcern)
    }

    func test_userRole_accessLevel_ordering() {
        XCTAssertGreaterThan(UserRole.admin.accessLevel, UserRole.clinician.accessLevel)
        XCTAssertGreaterThan(UserRole.clinician.accessLevel, UserRole.carer.accessLevel)
    }
}
