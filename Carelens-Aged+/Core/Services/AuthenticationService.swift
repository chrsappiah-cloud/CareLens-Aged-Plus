import Foundation
import SwiftUI
import Combine

enum UserRole: String, Codable, CaseIterable {
    case admin = "Administrator"
    case clinician = "Clinician"
    case facilityManager = "Facility Manager"
    case familyMember = "Family Member"
    case carer = "Carer"
    case externalClinician = "External Clinician"

    var accessLevel: Int {
        switch self {
        case .admin: return 100
        case .clinician: return 80
        case .facilityManager: return 70
        case .familyMember: return 30
        case .carer: return 25
        case .externalClinician: return 20
        }
    }
}

struct AppUser: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String
    var role: UserRole
    var subscriptionTier: SubscriptionTier
    var isActive: Bool
    var facilityID: String?
    var createdAt: Date
    var lastLoginAt: Date?
}

@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentUser: AppUser?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    static let shared = AuthenticationService()

    private let adminCredentials: [(email: String, password: String)] = [
        ("admin@carelens.health", "CareLens2026!"),
    ]

    func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        if !ProcessInfo.processInfo.arguments.contains("-UITesting") {
            try? await Task.sleep(nanoseconds: 800_000_000)
        }

        if let _ = adminCredentials.first(where: { $0.email == email && $0.password == password }) {
            currentUser = AppUser(
                id: UUID().uuidString,
                email: email,
                displayName: "System Administrator",
                role: .admin,
                subscriptionTier: .enterprise,
                isActive: true,
                facilityID: "facility_001",
                createdAt: .now,
                lastLoginAt: .now
            )
            isAuthenticated = true
            isLoading = false
            return true
        }

        if isValidUserCredentials(email: email, password: password) {
            currentUser = AppUser(
                id: UUID().uuidString,
                email: email,
                displayName: extractName(from: email),
                role: .clinician,
                subscriptionTier: .professional,
                isActive: true,
                facilityID: "facility_001",
                createdAt: .now,
                lastLoginAt: .now
            )
            isAuthenticated = true
            isLoading = false
            return true
        }

        errorMessage = "Invalid credentials. Please try again."
        isLoading = false
        return false
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
    }

    func isAdmin() -> Bool {
        currentUser?.role == .admin
    }

    func hasAccess(to feature: AppFeature) -> Bool {
        guard let user = currentUser else { return false }
        return SubscriptionManager.shared.canAccess(feature: feature, tier: user.subscriptionTier)
    }

    private func isValidUserCredentials(email: String, password: String) -> Bool {
        !email.isEmpty && password.count >= 6 && email.contains("@")
    }

    private func extractName(from email: String) -> String {
        let name = email.components(separatedBy: "@").first ?? "User"
        return name.replacingOccurrences(of: ".", with: " ").capitalized
    }
}
