import Foundation
import SwiftUI
import Combine

enum APIEndpoint {
    case assessmentInsight(type: String, scores: [String: Double], age: Int, concerns: String)
    case differentialAnalysis(symptoms: [String: Any])
    case carePlanSuggestions(strengths: [String], problems: [String], scores: [String: Double])
    case reportNarrative(type: String, clientName: String, data: [String: String])
    case syncStatus
    case backupStatus

    var path: String {
        switch self {
        case .assessmentInsight: return "/api/v1/insights/assessment"
        case .differentialAnalysis: return "/api/v1/insights/differential"
        case .carePlanSuggestions: return "/api/v1/insights/care-plan"
        case .reportNarrative: return "/api/v1/reports/narrative"
        case .syncStatus: return "/api/v1/system/sync-status"
        case .backupStatus: return "/api/v1/system/backup-status"
        }
    }
}

@MainActor
class NetworkMiddleware: ObservableObject {
    static let shared = NetworkMiddleware()

    @Published var isConnected = true
    @Published var lastSyncTime: Date?
    @Published var pendingRequests = 0
    @Published var lastSyncPipeline: SyncPipelineResult?

    private let healthAPI = HealthAPIService()

    /// Created only when sync runs — avoids CloudKit init during lightweight middleware tests.
    private var syncEngine: DataSyncEngine {
        DataSyncEngine.shared
    }

    func requestInsight(
        for endpoint: APIEndpoint,
        requiredFeature: AppFeature,
        userTier: AccessTier
    ) async throws -> ClinicalInsight? {
        guard AccessManager.shared.canAccess(feature: requiredFeature, tier: userTier) else {
            throw MiddlewareError.featureNotAvailable
        }

        pendingRequests += 1
        defer { pendingRequests -= 1 }

        switch endpoint {
        case .assessmentInsight(let type, let scores, let age, let concerns):
            return try await healthAPI.generateClinicalInsight(
                assessmentType: type,
                scores: scores,
                clientAge: age,
                concerns: concerns
            )
        case .differentialAnalysis(let symptoms):
            return try await healthAPI.generateDifferentialAnalysis(symptoms: symptoms)
        case .carePlanSuggestions(let strengths, let problems, let scores):
            return try await healthAPI.generateCarePlanSuggestions(
                strengths: strengths,
                problems: problems,
                assessmentScores: scores
            )
        default:
            return nil
        }
    }

    func generateReportNarrative(
        type: String,
        clientName: String,
        data: [String: String],
        userTier: AccessTier
    ) async throws -> String {
        guard AccessManager.shared.canAccess(feature: .advancedReports, tier: userTier) else {
            throw MiddlewareError.featureNotAvailable
        }

        pendingRequests += 1
        defer { pendingRequests -= 1 }

        return try await healthAPI.generateReportNarrative(
            reportType: type,
            clientName: clientName,
            assessmentData: data
        )
    }

    /// End-to-end sync: Supabase primary → CloudKit → Cloudflare.
    func syncData(
        clients: [ClientProfile],
        assessments: [AssessmentSession],
        plans: [CarePlan],
        userTier: AccessTier
    ) async throws {
        guard AccessManager.shared.canAccess(feature: .supabasePrimary, tier: userTier) else {
            throw MiddlewareError.featureNotAvailable
        }

        pendingRequests += 1
        defer { pendingRequests -= 1 }

        let enableCloudKit = AccessManager.shared.canAccess(feature: .cloudSync, tier: userTier)
        let enableCloudflare = AccessManager.shared.canAccess(feature: .cloudflareBackup, tier: userTier)

        let result = await syncEngine.performEndToEndSync(
            clients: clients,
            assessments: assessments,
            plans: plans,
            enableCloudKit: enableCloudKit,
            enableCloudflare: enableCloudflare
        )

        lastSyncPipeline = result
        lastSyncTime = result.completedAt

        guard result.primarySucceeded else {
            throw MiddlewareError.serverError(result.primary.errorMessage ?? "Primary sync failed")
        }
    }

    enum MiddlewareError: LocalizedError {
        case featureNotAvailable
        case networkUnavailable
        case serverError(String)

        var errorDescription: String? {
            switch self {
            case .featureNotAvailable: return "This feature requires a higher access tier."
            case .networkUnavailable: return "No network connection. Data saved locally."
            case .serverError(let msg): return "Server error: \(msg)"
            }
        }
    }
}
