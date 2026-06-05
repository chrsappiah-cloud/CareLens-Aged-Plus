import XCTest
@testable import CarelensAged

/// WCS: Forms — login validation rules (text entry and failure states).
@MainActor
final class TextFieldTests: XCTestCase {

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_login_rejectsEmptyEmail() async {
        let auth = WCSArrange.authenticationService()
        let succeeded = await WCSAct.login(auth, email: "", password: "password123")
        XCTAssertFalse(succeeded)
        WCSAssert.isLoggedOut(auth)
    }

    func test_login_rejectsShortPassword() async {
        let auth = WCSArrange.authenticationService()
        let succeeded = await WCSAct.login(auth, email: "user@carelens.health", password: "12345")
        XCTAssertFalse(succeeded)
    }

    func test_login_rejectsEmailWithoutAtSign() async {
        let auth = WCSArrange.authenticationService()
        let succeeded = await WCSAct.login(auth, email: "invalid-email", password: "password123")
        XCTAssertFalse(succeeded)
    }

    func test_login_acceptsValidClinicianCredentials() async {
        let auth = WCSArrange.authenticationService()
        let succeeded = await WCSAct.login(auth, email: "clinician@carelens.health", password: "password123")
        XCTAssertTrue(succeeded)
        WCSAssert.isAuthenticated(auth)
    }
}
