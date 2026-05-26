import XCTest
import CoreGraphics

let _e2eObserverInit: Void = {
    XCTestObservationCenter.shared.addTestObserver(UnitTestReportObserver())
}()

final class UnitTestReportObserver: NSObject, XCTestObservation {
    private var results: [(suite: String, test: String, status: String)] = []
    private var currentSuite = ""
    private var startDate = Date()

    func testBundleWillStart(_ testBundle: Bundle) {
        startDate = Date()
        print("[E2E Observer] Bundle started: \(testBundle.bundlePath)")
    }

    func testSuiteWillStart(_ testSuite: XCTestSuite) {
        currentSuite = testSuite.name
    }

    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        results.append((currentSuite, testCase.name, "FAIL: \(description)"))
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        let name = testCase.name
        let hasFailure = results.contains(where: { $0.test == name && $0.status.hasPrefix("FAIL") })
        if !hasFailure {
            results.append((currentSuite, name, "PASS"))
        }
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        print("[E2E Observer] Bundle finished. Generating PDF...")
        generatePDF()
    }

    private func generatePDF() {
        let pageWidth: CGFloat = 840
        let pageHeight: CGFloat = 960
        let leftMargin: CGFloat = 50
        let textWidth: CGFloat = 740

        let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSHomeDirectory()
        let desktop = URL(fileURLWithPath: documentsDir).deletingLastPathComponent().appendingPathComponent("Desktop")
        try? FileManager.default.createDirectory(at: desktop, withIntermediateDirectories: true)
        let fileName = "CareLensAged_E2E_TestReport.pdf"
        let fileURL = desktop.appendingPathComponent(fileName)

        guard let consumer = CGDataConsumer(url: fileURL as CFURL) else {
            print("[E2E Observer] Failed to create PDF consumer")
            return
        }
        var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        guard let ctx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil as CFDictionary?) else {
            print("[E2E Observer] Failed to create PDF context")
            return
        }

        var yOffset: CGFloat = pageHeight - 40

        func drawText(_ text: String, size: CGFloat = 11, bold: Bool = false, red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1) {
            let fontName: String = bold ? "Helvetica-Bold" : "Helvetica"
            let font = CTFontCreateWithName(fontName as CFString, size, nil)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: CGColor(red: red, green: green, blue: blue, alpha: alpha)
            ]
            let attrStr = NSAttributedString(string: text, attributes: attrs)
            let line = CTLineCreateWithAttributedString(attrStr)
            ctx.textMatrix = CGAffineTransform.identity
            ctx.textPosition = CGPoint(x: leftMargin, y: yOffset - size)
            CTLineDraw(line, ctx)
            yOffset -= (size + 4)
        }

        func checkPage() {
            if yOffset < 60 {
                ctx.endPDFPage()
                ctx.beginPDFPage(nil)
                yOffset = pageHeight - 40
            }
        }

        ctx.beginPDFPage(nil)

        drawText("CareLens Aged+ \u{2014} End-to-End Unit Test Report", size: 18, bold: true, red: 0.07, green: 0.02, blue: 0.15)
        drawText("Generated: \(Date().formatted(date: .long, time: .shortened))", size: 10, red: 0.5, green: 0.5, blue: 0.5)
        drawText("", size: 6)

        drawText(String(repeating: "=", count: 90), size: 8, red: 0.7, green: 0.7, blue: 0.7)
        drawText("", size: 4)

        drawText("SECTION 1: ENUM UNITS", size: 14, bold: true, red: 0.05, green: 0.45, blue: 0.25)
        drawText("", size: 4)

        let enumUnits: [(String, String, [String])] = [
            ("SubscriptionTier", "Business pricing tiers", ["free", "starter", "professional", "enterprise"]),
            ("AppFeature", "Feature flags (19 features)", ["dashboard", "clientProfiles", "neuroWatch", "aiInsights", "adminPanel", "cloudSync", "supabasePrimary", "cloudflareBackup", "..."]),
            ("UserRole", "User access roles", ["admin", "clinician", "facilityManager", "familyMember", "carer", "externalClinician"]),
            ("AssessmentStatus", "Assessment lifecycle", ["draft", "inProgress", "needsReview", "completed", "urgent"]),
            ("MonitoringEventType", "Event categories (10)", ["wandering", "fall", "agitation", "missedMedication", "sleepDisruption", "..."]),
            ("NeuroWatchBand", "Cognitive screening bands", ["noSignificantChange", "mildConcern", "progressiveConcern", "urgentDeliriumRuleOut"]),
            ("SubscriptionProduct", "IAP products (6)", ["starterMonthly", "starterAnnual", "professionalMonthly", "professionalAnnual", "enterpriseMonthly", "enterpriseAnnual"]),
            ("ReportType", "Report templates", ["clinical", "family", "facilityHandover", "acpSpiritual"]),
            ("SyncRecordType", "Sync entity types", ["client", "assessment", "carePlan", "monitoringEvent"]),
            ("SyncDestination", "Backend targets", ["supabasePrimary", "cloudKit", "cloudflare"]),
            ("SyncValue", "Dynamic value types", ["string", "int", "double", "bool", "stringArray", "null"]),
            ("CKZoneName", "CloudKit zones (6)", ["ClientZone", "AssessmentZone", "CarePlanZone", "ReportZone", "CareCircleZone", "AuditZone"]),
            ("CKRecordType", "CloudKit record types (11)", ["CKClient", "CKAssessment", "CKCarePlan", "CKGoal", "..."]),
            ("APIEndpoint", "Network API routes", ["assessmentInsight", "differentialAnalysis", "carePlanSuggestions", "reportNarrative", "syncStatus", "backupStatus"]),
            ("TransactionStatus", "Purchase states", ["idle", "processing", "success", "failed", "restored", "pending"]),
            ("MiddlewareError", "Network error types", ["featureNotAvailable", "networkUnavailable", "serverError"]),
        ]

        for (name, purpose, values) in enumUnits {
            checkPage()
            drawText("  \(name) \u{2014} \(purpose)", size: 11, bold: true)
            drawText("    Values: \(values.joined(separator: ", "))", size: 9, red: 0.3, green: 0.3, blue: 0.3)
            drawText("", size: 2)
        }

        checkPage()
        drawText("", size: 4)
        drawText("SECTION 2: MODEL UNITS (SwiftData)", size: 14, bold: true, red: 0.05, green: 0.45, blue: 0.25)
        drawText("", size: 4)

        let modelUnits: [(String, String, [String])] = [
            ("ClientProfile", "Client demographic & consent data", ["firstName", "lastName", "dateOfBirth", "gender", "preferredLanguage", "culturalIdentity", "consentStatus", "safetyFlags", "assessments", "carePlans", "monitoringEvents"]),
            ("AssessmentSession", "Clinical assessment scores", ["cognitionScore", "moodScore", "anxietyScore", "deliriumRiskScore", "adlScore", "iadlScore", "caregivingStressScore", "spiritualDistressScore", "safetyScore"]),
            ("AssessmentSection", "Assessment domain sections", ["domain", "fieldsJSON", "notes"]),
            ("CarePlan", "Care plan with goals & interventions", ["strengths", "priorityProblems", "goals", "interventions", "immediateActions", "environmentalMods", "spiritualSupport", "serviceReferrals"]),
            ("MonitoringEvent", "Monitoring event records", ["eventType", "severity", "cognitionScore", "adlScore", "caregiverStress", "medicationAdherence"]),
        ]

        for (name, purpose, fields) in modelUnits {
            checkPage()
            drawText("  \(name) \u{2014} \(purpose)", size: 11, bold: true)
            drawText("    Fields: \(fields.joined(separator: ", "))", size: 9, red: 0.3, green: 0.3, blue: 0.3)
            drawText("", size: 2)
        }

        checkPage()
        drawText("", size: 4)
        drawText("SECTION 3: SERVICE UNITS (Backend)", size: 14, bold: true, red: 0.05, green: 0.45, blue: 0.25)
        drawText("", size: 4)

        let serviceUnits: [(String, String)] = [
            ("AuthenticationService", "Login/logout, role-based access, subscription gating"),
            ("SubscriptionManager", "Feature access control, user management, tier upgrades"),
            ("NeuroWatchEngine", "Cognitive screening evaluation (4 bands, score 0-36+)"),
            ("HealthAPIService", "OpenAI GPT-4o clinical insight, differential, care plan, narrative"),
            ("NetworkMiddleware", "Feature gating, request routing, sync orchestration"),
            ("SupabasePrimaryService", "Primary DB: CRUD, full sync, retry queue, in-memory fallback"),
            ("CloudflareBackupService", "Secondary backup: batch upload, fetch, in-memory fallback"),
            ("DataSyncEngine", "E2E pipeline: Supabase -> CloudKit -> Cloudflare"),
            ("ApplePaySubscriptionService", "StoreKit purchase, restore, cancel, mock mode"),
            ("ReportService", "4 report types + PDF rendering with Core Text"),
            ("CloudKitManager", "Custom zones, CRUD, change tracking, conflict resolution"),
        ]

        for (name, desc) in serviceUnits {
            checkPage()
            drawText("  \(name)", size: 11, bold: true)
            drawText("    \(desc)", size: 9, red: 0.3, green: 0.3, blue: 0.3)
            drawText("", size: 2)
        }

        checkPage()
        drawText("", size: 4)
        drawText("SECTION 4: DATA LAYER UNITS", size: 14, bold: true, red: 0.05, green: 0.45, blue: 0.25)
        drawText("", size: 4)

        let dataUnits: [(String, String)] = [
            ("SyncRecord", "Universal sync envelope with typed payload"),
            ("SyncPipelineResult", "Pipeline status for primary + 2 backup destinations"),
            ("SyncStepResult", "Per-destination sync result (success/failure + count)"),
            ("SyncRebuildReport", "Rebuild source tracking"),
            ("InMemorySyncStore", "Actor-based in-memory store for tests/demo"),
            ("AppEnvironment", "Runtime config: Supabase, Cloudflare URLs, test detection"),
        ]

        for (name, desc) in dataUnits {
            checkPage()
            drawText("  \(name)", size: 11, bold: true)
            drawText("    \(desc)", size: 9, red: 0.3, green: 0.3, blue: 0.3)
            drawText("", size: 2)
        }

        checkPage()
        drawText("", size: 4)
        drawText("SECTION 5: REPOSITORY PROTOCOLS", size: 14, bold: true, red: 0.05, green: 0.45, blue: 0.25)
        drawText("", size: 4)

        let repoUnits: [String] = ["ClientRepository", "AssessmentRepository", "CarePlanRepository", "MonitoringRepository", "ReportRepository", "SyncCoordinator"]
        for r in repoUnits {
            drawText("  \(r)", size: 11)
        }

        checkPage()
        drawText("", size: 6)

        drawText(String(repeating: "=", count: 90), size: 8, red: 0.7, green: 0.7, blue: 0.7)
        drawText("", size: 4)
        drawText("SECTION 6: XCTEST RESULTS", size: 14, bold: true, red: 0.07, green: 0.02, blue: 0.15)
        drawText("", size: 6)

        if results.isEmpty {
            drawText("  No test results recorded (tests may not have run yet)", size: 11, red: 1.0, green: 0.6, blue: 0.0)
        } else {
            let passCount = results.filter { $0.status == "PASS" }.count
            let failCount = results.filter { $0.status.hasPrefix("FAIL") }.count
            let total = results.count

            let summaryColor = failCount > 0 ? (red: 1, green: 0, blue: 0) : (red: 0.18, green: 0.80, blue: 0.45)
            drawText("  Total: \(total)  |  Passed: \(passCount)  |  Failed: \(failCount)", size: 12, bold: true,
                     red: summaryColor.red, green: summaryColor.green, blue: summaryColor.blue)

            var lastSuite = ""
            for r in results {
                checkPage()
                if r.suite != lastSuite {
                    drawText("", size: 2)
                    drawText("  [\(r.suite)]", size: 10, bold: true, red: 0.3, green: 0.3, blue: 0.3)
                    lastSuite = r.suite
                }
                let isPass = r.status == "PASS"
                let symbol = isPass ? "  \u{2713}" : "  \u{2717}"
                if isPass {
                    drawText("\(symbol) \(r.test)", size: 9, red: 0.18, green: 0.80, blue: 0.45)
                } else {
                    drawText("\(symbol) \(r.test)", size: 9, red: 1.0, green: 0, blue: 0)
                    drawText("    \(r.status)", size: 8, red: 1.0, green: 0, blue: 0)
                }
            }

            drawText("", size: 6)
            drawText("TEST SUMMARY", size: 12, bold: true)
            drawText("  Total: \(total) tests", size: 10)
            drawText("  Passed: \(passCount)", size: 10, red: 0.18, green: 0.80, blue: 0.45)
            drawText("  Failed: \(failCount)", size: 10, red: 1.0, green: 0, blue: 0)
            drawText("  Pass Rate: \(total > 0 ? String(format: "%.1f", Double(passCount)/Double(total)*100) : "N/A")%", size: 10)
        }

        drawText("", size: 10)
        drawText(String(repeating: "=", count: 90), size: 8, red: 0.7, green: 0.7, blue: 0.7)
        drawText("", size: 4)
        drawText("DISCLAIMER: This report is for quality assurance purposes only.", size: 8, red: 0.7, green: 0.7, blue: 0.7)
        drawText("CareLens Aged+ \u{2014} All Units E2E Test Report", size: 8, red: 0.7, green: 0.7, blue: 0.7)

        ctx.endPDFPage()
        ctx.closePDF()

        print("[E2E Observer] PDF report saved to: \(fileURL.path)")
    }
}
