import XCTest

/// Captures App Store screenshots for iPhone and iPad simulators.
/// Run via: scripts/generate_screenshots.sh
final class Carelens_Aged_ScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
    }

    @MainActor
    func testCaptureAppStoreScreenshots() throws {
        XCTAssertTrue(waitForTab("tab_dashboard", fallbackLabel: "Home"), "Dashboard did not load")

        capture("01_Dashboard", tab: "tab_dashboard", fallbackLabel: "Home")
        capture("02_Clients", tab: "tab_clients", fallbackLabel: "Clients")
        capture("03_Intake", tab: "tab_intake", fallbackLabel: "Admit")
        capture("04_Assessments", tab: "tab_assess", fallbackLabel: "Assess")
        capture("05_CarePlan", tab: "tab_careplan", fallbackLabel: "Plans")
        capture("06_Reports", tab: "tab_reports", fallbackLabel: "Reports")
        capture("07_Settings", tab: "tab_settings", fallbackLabel: "Settings")
    }

    // MARK: - Helpers

    private func waitForTab(_ identifier: String, fallbackLabel: String, timeout: TimeInterval = 12) -> Bool {
        let tab = app.tabBars.buttons[identifier]
        if tab.waitForExistence(timeout: timeout) { return true }
        return app.tabBars.buttons[fallbackLabel].waitForExistence(timeout: 4)
    }

    private func selectTab(_ identifier: String, fallbackLabel: String) {
        let tab = app.tabBars.buttons[identifier]
        if tab.exists {
            tab.tap()
        } else {
            app.tabBars.buttons[fallbackLabel].tap()
        }
        sleep(1)
    }

    private func capture(_ name: String, tab identifier: String, fallbackLabel: String) {
        selectTab(identifier, fallbackLabel: fallbackLabel)
        let shot = app.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
