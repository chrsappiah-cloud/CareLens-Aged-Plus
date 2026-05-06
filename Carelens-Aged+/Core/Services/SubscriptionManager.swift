import Foundation
import SwiftUI
import Combine

enum SubscriptionTier: String, Codable, CaseIterable {
    case free = "Free"
    case starter = "Starter"
    case professional = "Professional"
    case enterprise = "Enterprise"

    var monthlyPrice: Double {
        switch self {
        case .free: return 0
        case .starter: return 29.99
        case .professional: return 79.99
        case .enterprise: return 199.99
        }
    }

    var maxClients: Int {
        switch self {
        case .free: return 3
        case .starter: return 15
        case .professional: return 100
        case .enterprise: return Int.max
        }
    }

    var color: Color {
        switch self {
        case .free: return .gray
        case .starter: return CareLensTheme.Colors.accentAmber
        case .professional: return CareLensTheme.Colors.accentMint
        case .enterprise: return CareLensTheme.Colors.accentMagenta
        }
    }

    var features: [AppFeature] {
        switch self {
        case .free:
            return [.dashboard, .clientProfiles, .basicAssessment]
        case .starter:
            return [.dashboard, .clientProfiles, .basicAssessment, .neuroWatch,
                    .carePlans, .basicReports]
        case .professional:
            return [.dashboard, .clientProfiles, .basicAssessment, .neuroWatch,
                    .differentialScreen, .carePlans, .basicReports, .advancedReports,
                    .monitoring, .spiritualAssessment, .acpModule, .aiInsights]
        case .enterprise:
            return AppFeature.allCases
        }
    }
}

enum AppFeature: String, Codable, CaseIterable {
    case dashboard = "Dashboard"
    case clientProfiles = "Client Profiles"
    case basicAssessment = "Basic Assessment"
    case neuroWatch = "NeuroWatch Screening"
    case differentialScreen = "Differential Screen"
    case carePlans = "Care Plans"
    case basicReports = "Basic Reports"
    case advancedReports = "Advanced Reports"
    case monitoring = "Longitudinal Monitoring"
    case spiritualAssessment = "Spiritual Assessment"
    case acpModule = "Advance Care Planning"
    case aiInsights = "AI Clinical Insights"
    case caregivingModule = "Caregiving & Support"
    case incomeServices = "Income & Services"
    case interventionReview = "Intervention Review"
    case cloudSync = "CloudKit Sync"
    case supabaseBackup = "Supabase Backup"
    case adminPanel = "Admin Panel"
    case multiUser = "Multi-User Access"
    case facilityDashboard = "Facility Dashboard"

    var icon: String {
        switch self {
        case .dashboard: return "rectangle.3.group"
        case .clientProfiles: return "person.2"
        case .basicAssessment: return "checklist"
        case .neuroWatch: return "brain.head.profile"
        case .differentialScreen: return "waveform.path.ecg"
        case .carePlans: return "cross.case"
        case .basicReports: return "doc.text"
        case .advancedReports: return "doc.richtext"
        case .monitoring: return "chart.line.uptrend.xyaxis"
        case .spiritualAssessment: return "sparkles"
        case .acpModule: return "doc.plaintext"
        case .aiInsights: return "brain"
        case .caregivingModule: return "person.3"
        case .incomeServices: return "creditcard"
        case .interventionReview: return "stethoscope"
        case .cloudSync: return "icloud"
        case .supabaseBackup: return "externaldrive.badge.checkmark"
        case .adminPanel: return "gear.badge"
        case .multiUser: return "person.3.sequence"
        case .facilityDashboard: return "building.2"
        }
    }
}

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var managedUsers: [AppUser] = []

    func canAccess(feature: AppFeature, tier: SubscriptionTier) -> Bool {
        tier.features.contains(feature)
    }

    func upgradeUser(_ userID: String, to tier: SubscriptionTier) {
        if let index = managedUsers.firstIndex(where: { $0.id == userID }) {
            managedUsers[index].subscriptionTier = tier
        }
    }

    func toggleUserActive(_ userID: String) {
        if let index = managedUsers.firstIndex(where: { $0.id == userID }) {
            managedUsers[index].isActive.toggle()
        }
    }

    func addUser(_ user: AppUser) {
        managedUsers.append(user)
    }

    func removeUser(_ userID: String) {
        managedUsers.removeAll { $0.id == userID }
    }

    init() {
        managedUsers = [
            AppUser(id: "u1", email: "sarah.w@carelens.health", displayName: "Sarah Wilson", role: .clinician, subscriptionTier: .professional, isActive: true, facilityID: "facility_001", createdAt: Calendar.current.date(byAdding: .month, value: -3, to: .now)!, lastLoginAt: .now),
            AppUser(id: "u2", email: "james.k@carelens.health", displayName: "James Kim", role: .clinician, subscriptionTier: .starter, isActive: true, facilityID: "facility_001", createdAt: Calendar.current.date(byAdding: .month, value: -1, to: .now)!, lastLoginAt: Calendar.current.date(byAdding: .day, value: -2, to: .now)),
            AppUser(id: "u3", email: "maria.p@family.com", displayName: "Maria Papadopoulos", role: .familyMember, subscriptionTier: .free, isActive: true, facilityID: nil, createdAt: Calendar.current.date(byAdding: .day, value: -14, to: .now)!, lastLoginAt: nil),
            AppUser(id: "u4", email: "nurse.chen@sunrise.care", displayName: "Nurse Chen", role: .carer, subscriptionTier: .starter, isActive: false, facilityID: "facility_001", createdAt: Calendar.current.date(byAdding: .month, value: -2, to: .now)!, lastLoginAt: Calendar.current.date(byAdding: .day, value: -21, to: .now)),
        ]
    }
}
