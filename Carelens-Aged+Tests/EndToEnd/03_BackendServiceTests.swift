import XCTest
import Foundation
@testable import CarelensAged

// MARK: - Backend Service Units

final class AuthenticationServiceTests: XCTestCase {
    @MainActor
    func testAdminLogin() async {
        let auth = AuthenticationService.makeForTesting()
        let r = await auth.login(email: "admin@carelens.health", password: "CareLens2026!")
        XCTAssertTrue(r)
        XCTAssertTrue(auth.isAuthenticated)
        XCTAssertEqual(auth.currentUser?.role, .admin)
        XCTAssertEqual(auth.currentUser?.accessTier, .enterprise)
    }
    @MainActor
    func testClinicianLogin() async {
        let auth = AuthenticationService.makeForTesting()
        let r = await auth.login(email: "clinician@carelens.health", password: "password123")
        XCTAssertTrue(r)
        XCTAssertEqual(auth.currentUser?.role, .clinician)
        XCTAssertEqual(auth.currentUser?.accessTier, .professional)
    }
    @MainActor
    func testInvalidLogin() async {
        let auth = AuthenticationService.makeForTesting()
        let r = await auth.login(email: "x@y.com", password: "wrong")
        XCTAssertFalse(r)
        XCTAssertFalse(auth.isAuthenticated)
    }
    @MainActor
    func testValidation() async {
        let auth = AuthenticationService.makeForTesting()
        let r1 = await auth.login(email: "", password: "pass123")
        XCTAssertFalse(r1)
        let r2 = await auth.login(email: "t@t.com", password: "12345")
        XCTAssertFalse(r2)
        let r3 = await auth.login(email: "noatsign", password: "password123")
        XCTAssertFalse(r3)
    }
    @MainActor
    func testLogout() async {
        let auth = AuthenticationService.makeForTesting()
        _ = await auth.login(email: "admin@carelens.health", password: "CareLens2026!")
        auth.logout()
        XCTAssertFalse(auth.isAuthenticated)
        XCTAssertNil(auth.currentUser)
    }
    @MainActor
    func testAccess() async {
        let auth = AuthenticationService.makeForTesting()
        _ = await auth.login(email: "admin@carelens.health", password: "CareLens2026!")
        XCTAssertTrue(auth.isAdmin())
        XCTAssertTrue(auth.hasAccess(to: .adminPanel))
        auth.logout()
        _ = await auth.login(email: "clinician@carelens.health", password: "password123")
        XCTAssertFalse(auth.isAdmin())
        XCTAssertTrue(auth.hasAccess(to: .aiInsights))
    }
}

final class E2EAccessMgrTests: XCTestCase {
    @MainActor
    func testFeatureAccess() {
        let m = AccessManager()
        XCTAssertTrue(m.canAccess(feature: .dashboard, tier: .free))
        XCTAssertFalse(m.canAccess(feature: .aiInsights, tier: .free))
        XCTAssertTrue(m.canAccess(feature: .neuroWatch, tier: .starter))
        XCTAssertTrue(m.canAccess(feature: .aiInsights, tier: .professional))
        XCTAssertTrue(m.canAccess(feature: .adminPanel, tier: .enterprise))
    }
    @MainActor
    func testUserManagement() {
        let m = AccessManager()
        let u = AppUser(id: "nu", email: "n@t.com", displayName: "N", role: .clinician, accessTier: .starter, isActive: true, facilityID: nil, createdAt: .now, lastLoginAt: nil)
        m.addUser(u)
        XCTAssertTrue(m.managedUsers.contains(where: { $0.id == "nu" }))
        m.setAccessTier(for: "nu", to: .professional)
        XCTAssertEqual(m.managedUsers.first(where: { $0.id == "nu" })?.accessTier, .professional)
        m.removeUser("nu")
        XCTAssertFalse(m.managedUsers.contains(where: { $0.id == "nu" }))
    }
}

final class E2ENeuroWatchEngineTests: XCTestCase {
    func testNoSignificantChange() {
        let r = NeuroWatchEngine.evaluate(NeuroWatchInput(orientationErrors: 0, delayedRecallScore: 5, clockTaskScore: 5, categoryFluencyCount: 15, medicationErrors: 0, attentionFluctuation: false, familyConcernLevel: 0, functionalDeclineLevel: 0, acuteMedicalTrigger: false))
        XCTAssertEqual(r.band, .noSignificantChange)
        XCTAssertLessThan(r.totalScore, 8)
    }
    func testMildConcern() {
        let r = NeuroWatchEngine.evaluate(NeuroWatchInput(orientationErrors: 2, delayedRecallScore: 3, clockTaskScore: 4, categoryFluencyCount: 10, medicationErrors: 1, attentionFluctuation: false, familyConcernLevel: 1, functionalDeclineLevel: 0, acuteMedicalTrigger: false))
        XCTAssertEqual(r.band, .mildConcern)
        XCTAssertTrue((8..<15).contains(r.totalScore))
    }
    func testProgressiveConcern() {
        // functionalDeclineLevel * 3 — keep total in 15..<24 for progressive band
        let r = NeuroWatchEngine.evaluate(NeuroWatchInput(orientationErrors: 2, delayedRecallScore: 2, clockTaskScore: 2, categoryFluencyCount: 7, medicationErrors: 2, attentionFluctuation: false, familyConcernLevel: 2, functionalDeclineLevel: 1, acuteMedicalTrigger: false))
        XCTAssertEqual(r.band, .progressiveConcern)
        XCTAssertTrue((15..<24).contains(r.totalScore))
    }
    func testUrgentDelirium() {
        let r = NeuroWatchEngine.evaluate(NeuroWatchInput(orientationErrors: 3, delayedRecallScore: 1, clockTaskScore: 1, categoryFluencyCount: 5, medicationErrors: 3, attentionFluctuation: true, familyConcernLevel: 3, functionalDeclineLevel: 3, acuteMedicalTrigger: true))
        XCTAssertEqual(r.band, .urgentDeliriumRuleOut)
        XCTAssertGreaterThanOrEqual(r.totalScore, 24)
    }
    func testHighScoreWithoutTrigger() {
        let r = NeuroWatchEngine.evaluate(NeuroWatchInput(orientationErrors: 4, delayedRecallScore: 0, clockTaskScore: 0, categoryFluencyCount: 3, medicationErrors: 4, attentionFluctuation: false, familyConcernLevel: 3, functionalDeclineLevel: 3, acuteMedicalTrigger: false))
        XCTAssertEqual(r.band, .progressiveConcern)
    }
}

final class E2EHealthAPIServiceTests: XCTestCase {
    @MainActor
    func testGenerateInsight() async throws {
        let s = HealthAPIService()
        let r = try await s.generateClinicalInsight(assessmentType: "NW", scores: ["t": 12], clientAge: 82, concerns: "Memory")
        XCTAssertFalse(r.summary.isEmpty)
        XCTAssertEqual(r.category, "NW")
        XCTAssertGreaterThan(r.confidence, 0)
    }
    @MainActor
    func testDifferential() async throws {
        let s = HealthAPIService()
        let r = try await s.generateDifferentialAnalysis(symptoms: ["mood": "low"])
        XCTAssertFalse(r.summary.isEmpty)
    }
    @MainActor
    func testCarePlanSuggestions() async throws {
        let s = HealthAPIService()
        let r = try await s.generateCarePlanSuggestions(strengths: ["Family"], problems: ["Fall risk"], assessmentScores: ["adl": 7.0])
        XCTAssertFalse(r.summary.isEmpty)
    }
    @MainActor
    func testReportNarrative() async throws {
        let s = HealthAPIService()
        let r = try await s.generateReportNarrative(reportType: "Clinical", clientName: "Mrs. K", assessmentData: ["cognition": "mild"])
        XCTAssertFalse(r.isEmpty)
    }
}

final class E2ENetworkMiddlewareTests: XCTestCase {
    @MainActor
    func testBlocksFree() async {
        let m = NetworkMiddleware()
        do {
            _ = try await m.requestInsight(for: .assessmentInsight(type: "T", scores: [:], age: 80, concerns: ""), requiredFeature: .aiInsights, userTier: .free)
            XCTFail("Should throw")
        } catch { XCTAssertTrue(true) }
    }
    @MainActor
    func testAllowsPro() async throws {
        let m = NetworkMiddleware()
        let r = try await m.requestInsight(for: .assessmentInsight(type: "NW", scores: ["t": 10], age: 75, concerns: "Mem"), requiredFeature: .aiInsights, userTier: .professional)
        XCTAssertNotNil(r)
    }
    @MainActor
    func testReportGating() async {
        let m = NetworkMiddleware()
        do {
            _ = try await m.generateReportNarrative(type: "C", clientName: "T", data: [:], userTier: .starter)
            XCTFail("Should throw")
        } catch { XCTAssertTrue(true) }
    }
}
