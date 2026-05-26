import Foundation
import CloudKit

/// End-to-end sync: **Supabase (primary)** → **CloudKit / iCloud** → **Cloudflare** backups.
actor DataSyncEngine {
    static let shared = DataSyncEngine()

    private let supabase: SupabasePrimaryService
    private let cloudKit: CloudKitManager
    private let cloudflare: CloudflareBackupService
    private var lastSyncToken: CKServerChangeToken?
    private(set) var lastPipelineResult: SyncPipelineResult?

    init(
        supabase: SupabasePrimaryService = SupabasePrimaryService(),
        cloudKit: CloudKitManager = CloudKitManager(),
        cloudflare: CloudflareBackupService = CloudflareBackupService()
    ) {
        self.supabase = supabase
        self.cloudKit = cloudKit
        self.cloudflare = cloudflare
    }

    // MARK: - E2E pipeline

    func performEndToEndSync(
        clients: [ClientProfile],
        assessments: [AssessmentSession],
        plans: [CarePlan],
        enableCloudKit: Bool = true,
        enableCloudflare: Bool = true
    ) async -> SyncPipelineResult {
        var records: [SyncRecord] = clients.map(SyncRecord.from)
        records += assessments.map(SyncRecord.from)
        records += plans.map(SyncRecord.from)

        let primaryResult: SyncStepResult
        do {
            let count = try await supabase.syncRecords(records)
            primaryResult = .success(.supabasePrimary, count: count)
        } catch {
            primaryResult = .failure(.supabasePrimary, message: error.localizedDescription)
        }

        let cloudKitResult: SyncStepResult
        if enableCloudKit, primaryResult.succeeded {
            if await cloudKit.isEnabled {
                do {
                    try await cloudKit.performFullSync(
                        localClients: clients,
                        localAssessments: assessments,
                        localPlans: plans
                    )
                    cloudKitResult = .success(.cloudKit, count: records.count)
                } catch {
                    cloudKitResult = .failure(.cloudKit, message: error.localizedDescription)
                }
            } else {
                cloudKitResult = .success(.cloudKit, count: 0)
            }
        } else if !enableCloudKit {
            cloudKitResult = .success(.cloudKit, count: 0)
        } else {
            cloudKitResult = .failure(.cloudKit, message: "Skipped — primary sync failed")
        }

        let cloudflareResult: SyncStepResult
        if enableCloudflare, primaryResult.succeeded {
            do {
                let count = try await cloudflare.backupRecords(records)
                cloudflareResult = .success(.cloudflare, count: count)
            } catch {
                cloudflareResult = .failure(.cloudflare, message: error.localizedDescription)
            }
        } else if !enableCloudflare {
            cloudflareResult = .success(.cloudflare, count: 0)
        } else {
            cloudflareResult = .failure(.cloudflare, message: "Skipped — primary sync failed")
        }

        let result = SyncPipelineResult(
            primary: primaryResult,
            cloudKit: cloudKitResult,
            cloudflare: cloudflareResult,
            completedAt: .now
        )
        lastPipelineResult = result
        return result
    }

    /// Pull from Supabase primary into local models (simplified — returns record count).
    func pullFromPrimary(type: SyncRecordType) async throws -> [SyncRecord] {
        try await supabase.fetchAll(type: type)
    }

    func rebuildFromBackupsIfNeeded() async throws -> SyncRebuildReport {
        var source = SyncDestination.supabasePrimary
        var records: [SyncRecord] = []

        do {
            records = try await supabase.fetchAll(type: .client)
        } catch {
            if await cloudKit.isEnabled {
                source = .cloudKit
                let ckRecords = try await cloudKit.fetchClients()
                records = ckRecords.compactMap { Self.syncRecord(from: $0) }
            }
        }

        if records.isEmpty {
            let cfRecords = try await cloudflare.fetchRecords(type: .client)
            if !cfRecords.isEmpty {
                source = .cloudflare
                records = cfRecords
            }
        }

        return SyncRebuildReport(source: source, clientRecords: records.count)
    }

    func performInitialSync() async throws {
        try await cloudKit.createCustomZones()
        try await cloudKit.setupPushSubscriptions()
    }

    func syncPendingCloudKitChanges() async throws {
        let (changed, deleted, newToken) = try await cloudKit.fetchChanges(since: lastSyncToken)
        if let newToken { lastSyncToken = newToken }
        _ = changed
        _ = deleted
    }

    func processSupabaseRetryQueue() async -> Int {
        await supabase.processRetryQueue()
    }

    private static func syncRecord(from ck: CKRecord) -> SyncRecord? {
        let id = ck.recordID.recordName
        guard let first = ck["firstName"] as? String,
              let last = ck["lastName"] as? String else { return nil }
        return SyncRecord(
            id: id,
            recordType: .client,
            payload: [
                "firstName": .string(first),
                "lastName": .string(last)
            ],
            updatedAt: ck["updatedAt"] as? Date ?? .now,
            syncedAt: nil
        )
    }
}

struct SyncRebuildReport: Sendable {
    let source: SyncDestination
    let clientRecords: Int
}
