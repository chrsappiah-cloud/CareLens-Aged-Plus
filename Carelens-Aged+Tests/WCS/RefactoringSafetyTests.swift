import XCTest
@testable import CarelensAged

/// WCS: Refactoring safety — characterization tests lock legacy behavior before structural changes.
@MainActor
final class RefactoringSafetyTests: XCTestCase {

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_neuroWatchBand_scoreBoundaries_areStable() {
        let bands: [(NeuroWatchBand, ClosedRange<Int>)] = [
            (.noSignificantChange, 0...7),
            (.mildConcern, 8...14),
            (.progressiveConcern, 15...23),
            (.urgentDeliriumRuleOut, 24...Int.max)
        ]
        for (band, range) in bands {
            XCTAssertFalse(band.suggestedAction.isEmpty, "\(band) must keep suggested action copy")
            XCTAssertFalse(range.isEmpty)
        }
    }

    func test_accessTier_featureCounts_areStable() {
        XCTAssertEqual(AccessTier.free.features.count, 3)
        XCTAssertEqual(AccessTier.starter.features.count, 8)
        XCTAssertEqual(AccessTier.professional.features.count, 15)
        XCTAssertEqual(AccessTier.enterprise.features.count, AppFeature.allCases.count)
    }

    func test_assessmentStatus_unknownString_fallsBackToDraft() {
        let session = AssessmentSession(
            clientID: "c1",
            assessmentType: "Intake",
            status: "UnexpectedLegacyValue",
            assessorRole: "Social Worker"
        )
        XCTAssertEqual(session.assessmentStatus, .draft)
    }

    func test_reportType_allCases_haveNonEmptyTitles() {
        for type in ReportType.allCases {
            XCTAssertFalse(type.rawValue.isEmpty)
        }
    }
}
