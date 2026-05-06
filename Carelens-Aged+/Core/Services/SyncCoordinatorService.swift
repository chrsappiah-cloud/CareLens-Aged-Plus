import Foundation
import SwiftData
import CloudKit

final class SyncCoordinatorService: SyncCoordinator {
    private let cloudKit: CloudKitManager
    private let supabase: SupabaseBackupService
    private var lastSyncToken: CKServerChangeToken?

    init(
        cloudKit: CloudKitManager = CloudKitManager(),
        supabase: SupabaseBackupService = SupabaseBackupService()
    ) {
        self.cloudKit = cloudKit
        self.supabase = supabase
    }

    func performInitialSync() async throws {
        try await cloudKit.createCustomZones()
        try await cloudKit.setupPushSubscriptions()
    }

    func syncPendingChanges() async throws {
        let (changed, deleted, newToken) = try await cloudKit.fetchChanges(since: lastSyncToken)
        if let newToken {
            lastSyncToken = newToken
        }
        _ = changed
        _ = deleted
    }

    func rebuildFromBackupIfNeeded() async throws {
        let _ = try await supabase.fetchBackupRecords(table: "clients_backup")
    }

    func fullSync(
        clients: [ClientProfile],
        assessments: [AssessmentSession],
        plans: [CarePlan]
    ) async throws {
        try await cloudKit.performFullSync(
            localClients: clients,
            localAssessments: assessments,
            localPlans: plans
        )
        try await supabase.performFullBackup(
            clients: clients,
            assessments: assessments,
            plans: plans
        )
    }
}
