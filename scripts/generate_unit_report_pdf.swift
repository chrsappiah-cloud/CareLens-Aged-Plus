#!/usr/bin/env swift

import Foundation

//============================================================
// CareLens Aged+ — Standalone Units Display + PDF Report
// Generates a PDF cataloging ALL units and saves to Desktop.
//============================================================

let fileManager = FileManager.default
let desktop = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
let timestamp = Date()
let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd_HH.mm.ss"
let dateStr = formatter.string(from: timestamp)

//=============================================================================
// DATA: All units in the CareLens Aged+ system
//=============================================================================

struct UnitCategory {
    let name: String
    let description: String
    let items: [UnitItem]
}

struct UnitItem {
    let name: String
    let description: String
    let values: [String]
    let status: String
}

let categories: [UnitCategory] = [
    // MARK: - Enums
    UnitCategory(name: "AccessTier", description: "Organisation access and feature groups", items: [
        UnitItem(name: "basic", description: "Basic access — 3 clients, 3 features", values: ["Max Clients: 3", "Features: dashboard, clientProfiles, basicAssessment"], status: "✓"),
        UnitItem(name: "starter", description: "Starter access — 15 clients, 8 features", values: ["Max Clients: 15"], status: "✓"),
        UnitItem(name: "professional", description: "Professional access — 100 clients, 15 features", values: ["Max Clients: 100"], status: "✓"),
        UnitItem(name: "enterprise", description: "Enterprise access — unlimited, all 19 features", values: ["Max Clients: ∞"], status: "✓"),
    ]),
    UnitCategory(name: "AppFeature", description: "19 feature flags controlling app access", items: [
        UnitItem(name: "dashboard, clientProfiles, basicAssessment, neuroWatch", description: "Core features", values: [], status: "✓"),
        UnitItem(name: "differentialScreen, carePlans, basicReports, advancedReports", description: "Clinical features", values: [], status: "✓"),
        UnitItem(name: "monitoring, spiritualAssessment, acpModule, aiInsights", description: "Advanced clinical", values: [], status: "✓"),
        UnitItem(name: "caregivingModule, incomeServices, interventionReview", description: "Support features", values: [], status: "✓"),
        UnitItem(name: "cloudSync, supabasePrimary, cloudflareBackup, supabaseBackup", description: "Sync & backup", values: [], status: "✓"),
        UnitItem(name: "adminPanel, multiUser, facilityDashboard", description: "Admin features", values: [], status: "✓"),
    ]),
    UnitCategory(name: "UserRole", description: "6 user roles with access levels", items: [
        UnitItem(name: "Administrator", description: "Access level 100 — full system access", values: [], status: "✓"),
        UnitItem(name: "Clinician", description: "Access level 80 — clinical features", values: [], status: "✓"),
        UnitItem(name: "Facility Manager", description: "Access level 70 — facility ops", values: [], status: "✓"),
        UnitItem(name: "Family Member", description: "Access level 30 — read-only family view", values: [], status: "✓"),
        UnitItem(name: "Carer", description: "Access level 25 — care delivery", values: [], status: "✓"),
        UnitItem(name: "External Clinician", description: "Access level 20 — referral only", values: [], status: "✓"),
    ]),
    UnitCategory(name: "AssessmentStatus", description: "5 assessment lifecycle states", items: [
        UnitItem(name: "Draft, In Progress, Needs Review, Completed, Urgent", description: "Status with color mapping", values: [], status: "✓"),
    ]),
    UnitCategory(name: "MonitoringEventType", description: "10 clinical event categories", items: [
        UnitItem(name: "Wandering, Agitation, Missed Medication, Fall, Sleep Disruption", description: "Physical events", values: [], status: "✓"),
        UnitItem(name: "Appetite Change, Behaviour Change, Incontinence", description: "Physiological events", values: [], status: "✓"),
        UnitItem(name: "Social Withdrawal, Cognitive Fluctuation", description: "Psychosocial events", values: [], status: "✓"),
    ]),
    UnitCategory(name: "NeuroWatchBand", description: "4 cognitive screening outcome bands", items: [
        UnitItem(name: "No Significant Early Change", description: "Score 0-7 — routine monitoring", values: ["Action: Routine review", "Color: green"], status: "✓"),
        UnitItem(name: "Mild Cognitive Concern", description: "Score 8-14 — repeat screen", values: ["Action: Repeat screen, gather collateral", "Color: yellow"], status: "✓"),
        UnitItem(name: "Progressive Concern", description: "Score 15-23 — comprehensive assessment", values: ["Action: Comprehensive assessment", "Color: orange"], status: "✓"),
        UnitItem(name: "Urgent Delirium Rule-Out", description: "Score 24+ — immediate medical", values: ["Action: Immediate medical review", "Color: red"], status: "✓"),
    ]),
    UnitCategory(name: "ReportType", description: "4 report templates", items: [
        UnitItem(name: "Clinical Assessment Report", description: "Full clinical documentation", values: [], status: "✓"),
        UnitItem(name: "Family Summary", description: "Plain-language family update", values: [], status: "✓"),
        UnitItem(name: "Facility Handover", description: "Shift-change summary", values: [], status: "✓"),
        UnitItem(name: "ACP & Spiritual Summary", description: "Advance care planning", values: [], status: "✓"),
    ]),
    UnitCategory(name: "SyncRecordType", description: "4 sync entity types", items: [
        UnitItem(name: "client, assessment, carePlan, monitoringEvent", description: "Sync record type identifiers", values: [], status: "✓"),
    ]),
    UnitCategory(name: "SyncDestination", description: "3 backup targets", items: [
        UnitItem(name: "Supabase (Primary DB)", description: "PostgREST primary store", values: [], status: "✓"),
        UnitItem(name: "iCloud / CloudKit", description: "Apple CloudKit zones", values: [], status: "✓"),
        UnitItem(name: "Cloudflare (Backup)", description: "Cloudflare R2/Worker backup", values: [], status: "✓"),
    ]),
    UnitCategory(name: "CKZoneName", description: "6 CloudKit custom zones", items: [
        UnitItem(name: "ClientZone, AssessmentZone, CarePlanZone, ReportZone, CareCircleZone, AuditZone", description: "Organized CloudKit record zones", values: [], status: "✓"),
    ]),
    UnitCategory(name: "CKRecordType", description: "11 CloudKit record types", items: [
        UnitItem(name: "CKClient, CKAssessment, CKAssessmentSection, CKMonitoringEvent", description: "Data records", values: [], status: "✓"),
        UnitItem(name: "CKCarePlan, CKGoal, CKIntervention, CKReport", description: "Care plan records", values: [], status: "✓"),
        UnitItem(name: "CKCaregiver, CKACPDocument, CKSpiritualProfile", description: "Support records", values: [], status: "✓"),
    ]),

    // MARK: - Models
    UnitCategory(name: "MODELS (SwiftData)", description: "5 Core Data models", items: [
        UnitItem(name: "ClientProfile", description: "Client demographics, consent, flags", values: ["17 fields + 3 relationships"], status: "✓"),
        UnitItem(name: "AssessmentSession", description: "Clinical assessment with 9 domain scores", values: ["9 score fields + sections relation"], status: "✓"),
        UnitItem(name: "AssessmentSection", description: "Assessment domain sub-sections", values: ["domain, fieldsJSON, notes, completedAt"], status: "✓"),
        UnitItem(name: "CarePlan", description: "Multi-domain care plan", values: ["11 array fields + dates"], status: "✓"),
        UnitItem(name: "MonitoringEvent", description: "Event tracking with scores", values: ["eventType, severity + 4 score fields"], status: "✓"),
    ]),

    // MARK: - Services
    UnitCategory(name: "SERVICES (Backend)", description: "10 core services", items: [
        UnitItem(name: "AuthenticationService", description: "Login/logout, role gating, access check", values: ["admin + clinician credentials"], status: "✓"),
        UnitItem(name: "AccessManager", description: "Feature access control, user CRUD", values: ["4 tiers x 19 features matrix"], status: "✓"),
        UnitItem(name: "NeuroWatchEngine", description: "Cognitive screening evaluation engine", values: ["9 inputs -> score -> band + recommendations"], status: "✓"),
        UnitItem(name: "HealthAPIService", description: "OpenAI GPT-4o clinical insight API", values: ["4 endpoints + mock fallback"], status: "✓"),
        UnitItem(name: "NetworkMiddleware", description: "Feature gating + request routing + sync orchestration", values: ["6 API endpoints"], status: "✓"),
        UnitItem(name: "SupabasePrimaryService", description: "Primary database CRUD + sync", values: ["REST + in-memory fallback + retry queue"], status: "✓"),
        UnitItem(name: "CloudflareBackupService", description: "Worker-based backup", values: ["batch upload + fetch + in-memory fallback"], status: "✓"),
        UnitItem(name: "DataSyncEngine", description: "E2E sync pipeline orchestrator", values: ["Supabase -> CloudKit -> Cloudflare"], status: "✓"),
        UnitItem(name: "ReportService", description: "4 report types + PDF rendering", values: ["Clinical, Family, Handover, ACP + PDF"], status: "✓"),
        UnitItem(name: "CloudKitManager", description: "Custom zone management + CRUD", values: ["6 zones, conflict resolution, push notifications"], status: "✓"),
    ]),

    // MARK: - Data Layer
    UnitCategory(name: "DATA LAYER", description: "Sync infrastructure", items: [
        UnitItem(name: "SyncRecord + SyncValue", description: "Universal sync envelope with typed payload", values: ["6 value types"], status: "✓"),
        UnitItem(name: "SyncPipelineResult", description: "Pipeline status across all destinations", values: ["primary + cloudKit + cloudflare"], status: "✓"),
        UnitItem(name: "SyncStepResult", description: "Per-destination sync outcome", values: ["success/failure + count + error"], status: "✓"),
        UnitItem(name: "InMemorySyncStore", description: "Actor-based in-memory store (tests/demo)", values: ["Thread-safe actor"], status: "✓"),
        UnitItem(name: "AppEnvironment", description: "Runtime config: URLs, keys, test detection", values: ["Supabase, Cloudflare, XCTest detection"], status: "✓"),
    ]),

    // MARK: - Repositories
    UnitCategory(name: "REPOSITORY PROTOCOLS", description: "Data access abstractions", items: [
        UnitItem(name: "ClientRepository, AssessmentRepository, CarePlanRepository", description: "CRUD protocols", values: [], status: "✓"),
        UnitItem(name: "MonitoringRepository, ReportRepository, SyncCoordinator", description: "Event + report + sync protocols", values: [], status: "✓"),
    ]),

    // MARK: - UI/UX Theme
    UnitCategory(name: "UI/UX THEME", description: "Design system components", items: [
        UnitItem(name: "CareLensTheme.Colors", description: "15 named colors", values: ["background, accent, gold, emerald, text, risk/safe"], status: "✓"),
        UnitItem(name: "CareLensTheme.Gradients", description: "12 gradient presets", values: ["background, button, status, card, diamond, text"], status: "✓"),
        UnitItem(name: "CareLensTheme", description: "Layout constants", values: ["cornerRadius: 22, touchTarget: 44, spacing: 16, sectionSpacing: 24"], status: "✓"),
        UnitItem(name: "CLCardStyle + StatusChip", description: "Reusable UI components", values: ["Glass card modifier + status indicator chip"], status: "✓"),
    ]),
]

//=============================================================================
// GENERATE PDF
//=============================================================================

let pageWidth: CGFloat = 840
let pageHeight: CGFloat = 960
let leftMargin: CGFloat = 50
let rightMargin: CGFloat = 50
let textWidth = pageWidth - leftMargin - rightMargin
let topMargin: CGFloat = 50

// We'll generate a simple text-based PDF using Core Text
// Since we can't import UIKit/PDFKit in a swift script, we'll generate a formatted text report
// and then use the system's built-in tools to convert to PDF.

var reportContent = """
============================================================
CareLens Aged+ — COMPLETE SYSTEM UNITS CATALOG
End-to-End Display of All Units
============================================================
Generated: \(Date().formatted(date: .long, time: .shortened))
Total Unit Categories: \(categories.count)
Total Individual Units: \(categories.reduce(0) { $0 + $1.items.count })
============================================================

"""

for category in categories {
    reportContent += """

    ┌──────────────────────────────────────────────────────────
    │ SECTION: \(category.name)
    │ \(category.description)
    ├──────────────────────────────────────────────────────────

    """
    for item in category.items {
        reportContent += "  [\(item.status)] \(item.name)\n"
        if !item.description.isEmpty {
            reportContent += "       \(item.description)\n"
        }
        for val in item.values {
            reportContent += "       • \(val)\n"
        }
        reportContent += "\n"
    }
}

reportContent += """

============================================================
END OF SYSTEM UNITS CATALOG
============================================================

Total units displayed: \(categories.reduce(0) { $0 + $1.items.count })
Organized into \(categories.count) categories

CareLens Aged+ — Comprehensive Unit Inventory Report
============================================================
"""

// Save as text file
let txtURL = desktop.appendingPathComponent("CareLensAged_UnitsCatalog_\(dateStr).txt")
try reportContent.write(to: txtURL, atomically: true, encoding: .utf8)
print("Text report saved: \(txtURL.path)")

// Convert to PDF using macOS built-in tools
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/textutil")
process.arguments = [
    "-convert", "pdf",
    "-output", desktop.appendingPathComponent("CareLensAged_UnitsCatalog_\(dateStr).pdf").path,
    "-font", "Menlo",
    "-fontsize", "8",
    txtURL.path
]

do {
    try process.run()
    process.waitUntilExit()
    if process.terminationStatus == 0 {
        print("PDF report saved: \(desktop.appendingPathComponent("CareLensAged_UnitsCatalog_\(dateStr).pdf").path)")
    } else {
        print("textutil conversion failed with status \(process.terminationStatus)")
    }
} catch {
    print("PDF conversion error: \(error)")
}

print("")
print("Done! Report saved to Desktop.")
