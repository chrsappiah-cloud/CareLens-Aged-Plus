import XCTest

/// Captures App Store screenshots for iPhone and iPad simulators.
/// Run via: scripts/generate_screenshots.sh
final class Carelens_Aged_ScreenshotTests: XCTestCase {

    private struct Screen {
        let name: String
        let tabIdentifier: String
        let shellMarker: String
    }

    private let screens: [Screen] = [
        Screen(name: "01_Dashboard", tabIdentifier: "tab_dashboard", shellMarker: "Care Overview"),
        Screen(name: "02_Clients", tabIdentifier: "tab_clients", shellMarker: "Client Caseload"),
        Screen(name: "03_Intake", tabIdentifier: "tab_intake", shellMarker: "New Client Admission"),
        Screen(name: "04_Assessments", tabIdentifier: "tab_assess", shellMarker: "Clinical Assessments"),
        Screen(name: "05_CarePlan", tabIdentifier: "tab_careplan", shellMarker: "Care Plans"),
        Screen(name: "06_Reports", tabIdentifier: "tab_reports", shellMarker: "Reports & Summaries"),
        Screen(name: "07_Settings", tabIdentifier: "tab_settings", shellMarker: "Settings & Account")
    ]

    @MainActor
    func testCaptureAppStoreScreenshots() throws {
        for screen in screens {
            let app = XCUIApplication()
            app.launchArguments = ["-UITesting", "-ScreenshotTab=\(screen.tabIdentifier)"]
            app.launch()
            XCTAssertTrue(
                waitForShell(app: app, marker: screen.shellMarker, timeout: 30),
                "\(screen.name): expected '\(screen.shellMarker)'"
            )
            sleep(2)
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = screen.name
            attachment.lifetime = .keepAlways
            add(attachment)
            app.terminate()
        }
    }

    private func waitForShell(app: XCUIApplication, marker: String, timeout: TimeInterval) -> Bool {
        let candidates = [
            app.staticTexts[marker],
            app.navigationBars[marker]
        ]
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if candidates.contains(where: { $0.exists }) { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.25))
        }
        return false
    }
}
