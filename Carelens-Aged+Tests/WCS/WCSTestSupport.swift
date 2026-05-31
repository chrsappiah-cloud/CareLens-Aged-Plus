import SwiftData
import SwiftUI
import UIKit
import XCTest
@testable import CarelensAged

// MARK: - Test Zero

/// Confirms a new suite is wired into the test target before behavior tests are added.
enum WCSTestZero {
    static func assertSuiteWiring(in testCase: XCTestCase, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(true, "Test Zero: suite wiring OK", file: file, line: line)
    }
}

// MARK: - AAA helpers

enum WCSArrange {
    @MainActor
    static func authenticationService(
        accessControl: (any AccessControlProviding)? = nil
    ) -> AuthenticationService {
        AuthenticationService.makeForTesting(accessControl: accessControl)
    }

    static func inMemoryModelContainer() -> ModelContainer {
        ModelContainerFactory.makeSharedContainer()
    }
}

enum WCSAct {
    @MainActor
    static func login(
        _ auth: AuthenticationService,
        email: String,
        password: String
    ) async -> Bool {
        await auth.login(email: email, password: password)
    }
}

enum WCSAssert {
    @MainActor
    static func isAuthenticated(_ auth: AuthenticationService, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(auth.isAuthenticated, file: file, line: line)
    }

    @MainActor
    static func isLoggedOut(_ auth: AuthenticationService, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertFalse(auth.isAuthenticated, file: file, line: line)
        XCTAssertNil(auth.currentUser, file: file, line: line)
    }
}

// MARK: - SwiftUI hosting (view controller discipline for SwiftUI)

@MainActor
enum WCSViewHost {
    @discardableResult
    static func host<V: View>(
        _ view: V,
        size: CGSize = CGSize(width: 390, height: 844)
    ) -> UIHostingController<V> {
        let controller = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.frame = window.bounds
        controller.view.layoutIfNeeded()
        return controller
    }
}

// MARK: - Spy

@MainActor
final class AccessControlSpy: AccessControlProviding {
    private(set) var requestedFeatures: [AppFeature] = []
    var allowedFeatures: Set<AppFeature> = Set(AppFeature.allCases)

    func canAccess(feature: AppFeature, tier: AccessTier) -> Bool {
        requestedFeatures.append(feature)
        return allowedFeatures.contains(feature)
    }
}
