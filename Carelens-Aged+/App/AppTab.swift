import SwiftUI

/// Primary navigation tabs — short labels for the tab bar, full titles for headers and VoiceOver.
enum AppTab: Int, CaseIterable, Identifiable {
    case home = 0
    case clients = 1
    case admit = 7
    case assessments = 2
    case carePlans = 3
    case reports = 4
    case settings = 5

    var id: Int { rawValue }

    /// Short label shown under the tab icon (fits iPhone tab bar).
    var tabLabel: String {
        switch self {
        case .home: return "Home"
        case .clients: return "Clients"
        case .admit: return "Admit"
        case .assessments: return "Assess"
        case .carePlans: return "Plans"
        case .reports: return "Reports"
        case .settings: return "Settings"
        }
    }

    /// Full title for navigation bars and accessibility.
    var screenTitle: String {
        switch self {
        case .home: return "Care Overview"
        case .clients: return "Client Caseload"
        case .admit: return "New Client Admission"
        case .assessments: return "Clinical Assessments"
        case .carePlans: return "Care Plans"
        case .reports: return "Reports & Summaries"
        case .settings: return "Settings & Account"
        }
    }

    var subtitle: String {
        switch self {
        case .home: return "Risks, reviews, and today’s priorities"
        case .clients: return "Search profiles, open charts, and track status"
        case .admit: return "7-step biopsychosocial intake workflow"
        case .assessments: return "NeuroWatch, cognition, mood, and safety screens"
        case .carePlans: return "Goals, interventions, and review dates"
        case .reports: return "Export narratives for your care team"
        case .settings: return "Account, sync, legal, and access"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .clients: return "person.2.fill"
        case .admit: return "person.crop.circle.badge.plus"
        case .assessments: return "stethoscope"
        case .carePlans: return "list.clipboard.fill"
        case .reports: return "doc.text.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .home: return "tab_dashboard"
        case .clients: return "tab_clients"
        case .admit: return "tab_intake"
        case .assessments: return "tab_assess"
        case .carePlans: return "tab_careplan"
        case .reports: return "tab_reports"
        case .settings: return "tab_settings"
        }
    }

    var accessibilityHint: String {
        "Opens \(screenTitle). \(subtitle)"
    }

    @MainActor
    func isVisible(for auth: AuthenticationService) -> Bool {
        switch self {
        case .home, .clients, .admit, .settings:
            return true
        case .assessments:
            return auth.hasAccess(to: .basicAssessment)
        case .carePlans:
            return auth.hasAccess(to: .carePlans)
        case .reports:
            return auth.hasAccess(to: .basicReports)
        }
    }
}
