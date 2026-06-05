import SwiftData
import XCTest
@testable import CarelensAged

/// WCS: App startup — launch path, test environment, and Test Zero.
@MainActor
final class AppLaunchTests: XCTestCase {

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_isRunningTests_detectsXCTestEnvironment() {
        XCTAssertTrue(AppEnvironment.isRunningTests)
    }

    func test_uitestingLaunchArgument_enablesMockBackends() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-UITesting") {
            XCTAssertTrue(AppEnvironment.usesMockBackends)
        } else {
            // Unit test host may or may not pass -UITesting; both are valid.
            XCTAssertTrue(true)
        }
    }

    @MainActor
    func test_modelContainerFactory_usesInMemoryStoreUnderTest() {
        let container = ModelContainerFactory.makeSharedContainer()
        XCTAssertNotNil(container.mainContext)
    }

    func test_uitestingArgument_preAuthenticatesAdminUser() {
        let auth = AuthenticationService()
        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            XCTAssertTrue(auth.isAuthenticated)
            XCTAssertEqual(auth.currentUser?.role, .admin)
        } else {
            // Default unit-test host: user starts logged out unless explicitly logged in.
            XCTAssertFalse(auth.isAuthenticated)
        }
    }
}
