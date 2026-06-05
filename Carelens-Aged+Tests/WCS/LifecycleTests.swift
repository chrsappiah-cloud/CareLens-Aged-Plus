import XCTest
@testable import CarelensAged

/// WCS: Test lifecycle — clean room setup and teardown.
@MainActor
final class LifecycleTests: XCTestCase {

    private var auth: AuthenticationService!

    override func setUp() {
        super.setUp()
        auth = WCSArrange.authenticationService()
    }

    override func tearDown() {
        auth.logout()
        auth = nil
        super.tearDown()
    }

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_eachTestStartsWithFreshAuthenticationState() {
        WCSAssert.isLoggedOut(auth)
    }

    func test_loginInOneTest_doesNotLeakToNextTest() async {
        _ = await WCSAct.login(auth, email: "admin@carelens.health", password: "CareLens2026!")
        WCSAssert.isAuthenticated(auth)
    }

    func test_subsequentTest_stillStartsLoggedOut() {
        WCSAssert.isLoggedOut(auth)
    }
}
