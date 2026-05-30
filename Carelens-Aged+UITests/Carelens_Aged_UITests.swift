import XCTest

final class Carelens_Aged_UITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    private func launchForLoginTests() {
        app.launchArguments = []
        app.launch()
    }

    private func launchAuthenticated() {
        app.launchArguments = ["-UITesting"]
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 10))
    }

    // MARK: - Login Tests

    @MainActor
    func testLoginScreenAppears() throws {
        launchForLoginTests()
        XCTAssertTrue(app.staticTexts["CareLens Aged+"].exists)
        XCTAssertTrue(app.staticTexts["Intelligent aged care for clinicians & care teams"].exists)
    }

    /// Smoke test for deep-dark theme: primary actions remain visible on login.
    @MainActor
    func testDarkThemeLoginControlsVisible() throws {
        launchForLoginTests()
        XCTAssertTrue(app.staticTexts["CareLens Aged+"].waitForExistence(timeout: 5))
        let signIn = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Sign In'")).firstMatch
        XCTAssertTrue(signIn.waitForExistence(timeout: 5))
        XCTAssertTrue(signIn.isHittable)
        XCTAssertTrue(app.staticTexts["Quick demo sign-in"].exists)
    }

    @MainActor
    func testDemoCredentialButtonsExist() throws {
        launchForLoginTests()
        XCTAssertTrue(app.staticTexts["Quick demo sign-in"].exists)
    }

    @MainActor
    func testSignInButtonExists() throws {
        launchForLoginTests()
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS 'Sign In'")).count > 0)
    }

    @MainActor
    func testAdminLoginFlow() throws {
        launchForLoginTests()
        let adminButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'admin@carelens.health'")).firstMatch
        if adminButton.exists {
            adminButton.tap()
        }

        let signInButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Sign In'")).firstMatch
        if signInButton.exists && signInButton.isEnabled {
            signInButton.tap()
            sleep(2)
            let dashboardTab = app.tabBars.buttons["Home"]
            XCTAssertTrue(dashboardTab.waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testCliniciainLoginFlow() throws {
        launchForLoginTests()
        let clinicianButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'clinician@carelens.health'")).firstMatch
        if clinicianButton.exists {
            clinicianButton.tap()
        }

        let signInButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Sign In'")).firstMatch
        if signInButton.exists && signInButton.isEnabled {
            signInButton.tap()
            sleep(2)
            let dashboardTab = app.tabBars.buttons["Home"]
            XCTAssertTrue(dashboardTab.waitForExistence(timeout: 5))
        }
    }

    // MARK: - Tab Navigation Tests

    @MainActor
    func testTabBarNavigation() throws {
        launchAuthenticated()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        let expectedTabs = ["Home", "Clients", "Admit", "Assess", "Plans", "Reports", "Settings"]
        for tab in expectedTabs {
            let tabButton = tabBar.buttons[tab]
            if tabButton.exists {
                tabButton.tap()
                sleep(1)
            }
        }
    }

    @MainActor
    func testAdminPanelInSettingsForAdmin() throws {
        launchAuthenticated()
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        sleep(1)
        XCTAssertTrue(app.staticTexts["Facility Admin Panel"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testAdmitTabExists() throws {
        launchAuthenticated()
        let admitTab = app.tabBars.buttons["Admit"]
        XCTAssertTrue(admitTab.waitForExistence(timeout: 5))
    }

    // MARK: - Dashboard Tests

    @MainActor
    func testDashboardLoads() throws {
        launchAuthenticated()
        let dashboardTab = app.tabBars.buttons["Home"]
        dashboardTab.tap()
        sleep(1)
        XCTAssertTrue(app.navigationBars.firstMatch.exists || app.staticTexts.count > 0)
    }

    // MARK: - Client Intake Tests

    @MainActor
    func testIntakeFormNavigation() throws {
        launchAuthenticated()
        let intakeTab = app.tabBars.buttons["Admit"]
        if intakeTab.exists {
            intakeTab.tap()
            sleep(1)
            let nextButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Next'")).firstMatch
            if nextButton.exists {
                nextButton.tap()
                sleep(1)
            }
        }
    }

    // MARK: - Settings Tests

    @MainActor
    func testSettingsShowsAccountInfo() throws {
        launchAuthenticated()
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)
            XCTAssertTrue(app.staticTexts["System Administrator"].exists ||
                          app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'admin'")).count > 0)
        }
    }

    @MainActor
    func testSignOutButton() throws {
        launchAuthenticated()
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
            sleep(1)
            let signOut = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Sign Out'")).firstMatch
            XCTAssertTrue(signOut.exists)
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let launchApp = XCUIApplication()
            launchApp.launch()
        }
    }
}
