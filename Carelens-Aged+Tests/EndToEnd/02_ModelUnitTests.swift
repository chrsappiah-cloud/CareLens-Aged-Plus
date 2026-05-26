import XCTest
import Foundation
@testable import CarelensAged

// MARK: - Model Units (Frontend Data Layer)

final class ClientProfileTests: XCTestCase {
    func testClientCreation() {
        let dob = Calendar.current.date(byAdding: .year, value: -80, to: .now)!
        let c = ClientProfile(firstName: "Jane", lastName: "Doe", dateOfBirth: dob)
        XCTAssertEqual(c.fullName, "Jane Doe")
        XCTAssertEqual(c.age, 80)
        XCTAssertEqual(c.preferredLanguage, "English")
    }
    func testAgeCalc() {
        let dob = Calendar.current.date(byAdding: .year, value: -65, to: .now)!
        let c = ClientProfile(firstName: "A", lastName: "B", dateOfBirth: dob)
        XCTAssertEqual(c.age, 65)
    }
    func testDefaults() {
        let c = ClientProfile(firstName: "X", lastName: "Y", dateOfBirth: .now)
        XCTAssertEqual(c.consentStatus, "Pending")
        XCTAssertEqual(c.gender, "")
        XCTAssertFalse(c.interpreterNeeded)
        XCTAssertTrue(c.safetyFlags.isEmpty)
    }
}

final class AssessmentSessionTests: XCTestCase {
    func testCreation() {
        let a = AssessmentSession(clientID: "c1", type: "NeuroWatch", status: "Draft", assessorRole: "Clinician")
        XCTAssertEqual(a.clientID, "c1")
        XCTAssertEqual(a.assessmentStatus, .draft)
        XCTAssertNil(a.cognitionScore)
    }
    func testStatusMapping() {
        let a = AssessmentSession(clientID: "c1", type: "T", status: "Completed", assessorRole: "SW")
        XCTAssertEqual(a.assessmentStatus, .completed)
        let b = AssessmentSession(clientID: "c2", type: "T", status: "Urgent", assessorRole: "SW")
        XCTAssertEqual(b.assessmentStatus, .urgent)
        let c = AssessmentSession(clientID: "c3", type: "T", status: "Invalid", assessorRole: "SW")
        XCTAssertEqual(c.assessmentStatus, .draft)
    }
    func testScoresDefaultNil() {
        let a = AssessmentSession(clientID: "c1", type: "T", status: "Draft", assessorRole: "Dr")
        XCTAssertNil(a.moodScore)
        XCTAssertNil(a.anxietyScore)
        XCTAssertNil(a.adlScore)
        XCTAssertNil(a.iadlScore)
        XCTAssertNil(a.deliriumRiskScore)
    }
}

final class AssessmentSectionTests: XCTestCase {
    func testSectionCreation() {
        let s = AssessmentSection(assessmentID: "a1", domain: "Cognition", notes: "Normal")
        XCTAssertEqual(s.assessmentID, "a1")
        XCTAssertEqual(s.domain, "Cognition")
        XCTAssertNil(s.completedAt)
    }
}

final class CarePlanTests: XCTestCase {
    func testCreation() {
        let p = CarePlan(clientID: "c1", strengths: ["Family"], goals: ["Walk"], interventions: ["PT"])
        XCTAssertEqual(p.clientID, "c1")
        XCTAssertEqual(p.strengths, ["Family"])
        XCTAssertEqual(p.goals, ["Walk"])
        XCTAssertEqual(p.interventions, ["PT"])
        XCTAssertTrue(p.priorityProblems.isEmpty)
        XCTAssertNil(p.nextReviewDate)
    }
}

final class MonitoringEventTests: XCTestCase {
    func testCreation() {
        let e = MonitoringEvent(clientID: "c1", eventType: "Fall", severity: "High", notes: "In hallway")
        XCTAssertEqual(e.clientID, "c1")
        XCTAssertEqual(e.eventType, "Fall")
        XCTAssertEqual(e.severity, "High")
        XCTAssertNil(e.cognitionScore)
    }
    func testEventTypeIcons() {
        XCTAssertEqual(MonitoringEventType.wandering.icon, "figure.walk")
        XCTAssertEqual(MonitoringEventType.fall.icon, "figure.fall")
        XCTAssertEqual(MonitoringEventType.agitation.icon, "exclamationmark.triangle")
        XCTAssertEqual(MonitoringEventType.missedMedication.icon, "pills")
    }
}
