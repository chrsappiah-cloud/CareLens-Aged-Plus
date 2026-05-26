import XCTest
import Foundation
import SwiftUI
@testable import CarelensAged

// MARK: - Report Service Unit Tests

final class ReportServiceTests: XCTestCase {
    func testClinicalReport() {
        let svc = ReportService()
        let c = ClientProfile(firstName: "Jane", lastName: "Doe", dateOfBirth: Calendar.current.date(byAdding: .year, value: -80, to: .now)!)
        let a = AssessmentSession(clientID: c.id, assessmentType: "NeuroWatch", status: "Completed", assessorRole: "Clinician")
        a.cognitionScore = 4.0
        a.moodScore = 3.0
        let r = svc.generateReport(type: .clinical, client: c, assessment: a, carePlan: nil)
        XCTAssertTrue(r.contains("CLINICAL ASSESSMENT REPORT"))
        XCTAssertTrue(r.contains("Jane Doe"))
        XCTAssertTrue(r.contains("Cognition"))
        XCTAssertTrue(r.contains("Mood"))
    }
    func testFamilySummary() {
        let svc = ReportService()
        let c = ClientProfile(firstName: "John", lastName: "Smith", dateOfBirth: .now)
        let p = CarePlan(clientID: c.id, strengths: ["Family support"], priorityProblems: ["Falls risk"])
        let r = svc.generateReport(type: .family, client: c, assessment: nil, carePlan: p)
        XCTAssertTrue(r.contains("FAMILY SUMMARY"))
        XCTAssertTrue(r.contains("John"))
        XCTAssertTrue(r.contains("Family support"))
        XCTAssertTrue(r.contains("Falls risk"))
    }
    func testFacilityHandover() {
        let svc = ReportService()
        let c = ClientProfile(firstName: "M", lastName: "K", dateOfBirth: .now, safetyFlags: ["Wandering"])
        let r = svc.generateReport(type: .facilityHandover, client: c, assessment: nil, carePlan: nil)
        XCTAssertTrue(r.contains("FACILITY HANDOVER"))
        XCTAssertTrue(r.contains("Wandering"))
    }
    func testACPSummary() {
        let svc = ReportService()
        let c = ClientProfile(firstName: "A", lastName: "B", dateOfBirth: .now, nominatedDecisionMaker: "Daughter")
        let r = svc.generateReport(type: .acpSpiritual, client: c, assessment: nil, carePlan: nil)
        XCTAssertTrue(r.contains("ADVANCE CARE PLANNING"))
        XCTAssertTrue(r.contains("Daughter"))
    }
    func testAllReportTypes() {
        let svc = ReportService()
        let c = ClientProfile(firstName: "T", lastName: "U", dateOfBirth: .now)
        for type in ReportType.allCases {
            let r = svc.generateReport(type: type, client: c, assessment: nil, carePlan: nil)
            XCTAssertFalse(r.isEmpty, "\(type.rawValue) should produce content")
        }
    }
    func testRenderPDF() {
        let svc = ReportService()
        let content = "TEST PDF CONTENT\nLine 2\nLine 3"
        guard let pdf = svc.renderPDF(content: content) else {
            XCTFail("PDF rendering failed"); return
        }
        XCTAssertGreaterThan(pdf.count, 100)
        // Verify PDF header
        let header = pdf.prefix(8)
        XCTAssertEqual(header.prefix(5), Data([0x25, 0x50, 0x44, 0x46, 0x2D])) // %PDF-
    }
}

final class AppEnvironmentTests: XCTestCase {
    func testConstants() {
        XCTAssertFalse(AppEnvironment.cloudKitContainerID.isEmpty)
        XCTAssertTrue(AppEnvironment.cloudKitContainerID.contains("iCloud"))
    }
}

final class RepositoriesProtocolTests: XCTestCase {
    func testProtocolExistence() {
        // Verify all repository protocols are reachable
        let _: any ClientRepository
        let _: any AssessmentRepository
        let _: any CarePlanRepository
        let _: any MonitoringRepository
        let _: any ReportRepository
        let _: any SyncCoordinator
    }
}

final class ThemeUnitTests: XCTestCase {
    func testCareLensColors() {
        let colors = [CareLensTheme.Colors.backgroundTop, CareLensTheme.Colors.accentMint, CareLensTheme.Colors.goldPrimary, CareLensTheme.Colors.emeraldGreen, CareLensTheme.Colors.riskRed, CareLensTheme.Colors.safeGreen]
        for c in colors { XCTAssertNotNil(c) }
    }
    func testGradients() {
        let g = [CareLensTheme.Gradients.background, CareLensTheme.Gradients.primaryButton, CareLensTheme.Gradients.diamondGold]
        for gr in g { XCTAssertNotNil(gr) }
    }
    func testConstants() {
        XCTAssertEqual(CareLensTheme.cardCornerRadius, 22)
        XCTAssertEqual(CareLensTheme.minTouchTarget, 44)
        XCTAssertEqual(CareLensTheme.spacing, 16)
        XCTAssertEqual(CareLensTheme.sectionSpacing, 24)
    }
}
