import Foundation
import SwiftData
import CloudKit

final class SyncCoordinatorService: SyncCoordinator {
    private let engine: DataSyncEngine

    init(engine: DataSyncEngine = .shared) {
        self.engine = engine
    }

    func performInitialSync() async throws {
        try await engine.performInitialSync()
    }

    func syncPendingChanges() async throws {
        try await engine.syncPendingCloudKitChanges()
    }

    func rebuildFromBackupIfNeeded() async throws {
        _ = try await engine.rebuildFromBackupsIfNeeded()
    }

    func fullSync(
        clients: [ClientProfile],
        assessments: [AssessmentSession],
        plans: [CarePlan],
        enableCloudKit: Bool = true,
        enableCloudflare: Bool = true
    ) async throws {
        let result = await engine.performEndToEndSync(
            clients: clients,
            assessments: assessments,
            plans: plans,
            enableCloudKit: enableCloudKit,
            enableCloudflare: enableCloudflare
        )
        guard result.primarySucceeded else {
            throw SyncCoordinatorError.primarySyncFailed(result.primary.errorMessage)
        }
    }
}

enum SyncCoordinatorError: LocalizedError {
    case primarySyncFailed(String?)

    var errorDescription: String? {
        switch self {
        case .primarySyncFailed(let msg):
            return "Primary database sync failed: \(msg ?? "unknown error")"
        }
    }
}
