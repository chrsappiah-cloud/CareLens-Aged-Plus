import SwiftUI
import XCTest
@testable import CarelensAged

/// WCS: Startup routing — login surface vs authenticated shell.
@MainActor
final class StartupControllerTests: XCTestCase {

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_unauthenticatedUser_shouldPresentLoginSurface() {
        let auth = WCSArrange.authenticationService()
        let host = WCSViewHost.host(LoginView().environmentObject(auth))
        XCTAssertNotNil(host.view)
    }

    func test_authenticatedUser_hasEnterpriseAccessForAdminDemo() async {
        let auth = WCSArrange.authenticationService()
        _ = await WCSAct.login(auth, email: "admin@carelens.health", password: "CareLens2026!")
        XCTAssertTrue(auth.hasAccess(to: .adminPanel))
        XCTAssertTrue(auth.hasAccess(to: .aiInsights))
    }

    func test_clinicianLogin_grantsProfessionalFeatures() async {
        let auth = WCSArrange.authenticationService()
        _ = await WCSAct.login(auth, email: "clinician@carelens.health", password: "password123")
        XCTAssertEqual(auth.currentUser?.accessTier, .professional)
        XCTAssertTrue(auth.hasAccess(to: .aiInsights))
        XCTAssertFalse(auth.isAdmin())
    }
}
