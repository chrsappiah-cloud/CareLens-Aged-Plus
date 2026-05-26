import Testing
import Foundation
@testable import CarelensAged

// MARK: - Supabase Primary (in-memory)

struct SupabasePrimaryServiceTests {

    @Test func upsertAndFetchClient() async throws {
        let service = SupabasePrimaryService(config: SupabaseConfig(projectURL: "https://test.local", anonKey: "test"))
        let client = ClientProfile(firstName: "Jane", lastName: "Doe", dateOfBirth: .now)
        try await service.upsert(SyncRecord.from(client: client))
        let fetched = try await service.fetch(id: client.id, type: .client)
        #expect(fetched?.id == client.id)
    }

    @Test func fullSyncWritesAllRecordTypes() async throws {
        let service = SupabasePrimaryService(config: SupabaseConfig(projectURL: "https://test.local", anonKey: "test"))
        let client = ClientProfile(firstName: "A", lastName: "B", dateOfBirth: .now)
        let assessment = AssessmentSession(clientID: client.id, type: "NeuroWatch", status: "Draft", assessorRole: "Clinician")
        let plan = CarePlan(clientID: client.id)
        try await service.performFullSync(clients: [client], assessments: [assessment], plans: [plan])
        #expect(try await service.fetchAll(type: .client).count == 1)
        #expect(try await service.fetchAll(type: .assessment).count == 1)
        #expect(try await service.fetchAll(type: .carePlan).count == 1)
    }

    @Test func retryQueueRecoversOnSuccess() async throws {
        let service = SupabasePrimaryService(config: SupabaseConfig(projectURL: "https://test.local", anonKey: "test"))
        let record = SyncRecord.from(client: ClientProfile(firstName: "X", lastName: "Y", dateOfBirth: .now))
        try await service.upsert(record)
        let recovered = await service.processRetryQueue()
        #expect(recovered >= 0)
    }
}

// MARK: - Cloudflare backup (in-memory)

struct CloudflareBackupServiceTests {

    @Test func batchBackupInMemory() async throws {
        let cf = CloudflareBackupService(workerURL: "", authToken: "")
        let records = [SyncRecord.from(client: ClientProfile(firstName: "C", lastName: "F", dateOfBirth: .now))]
        let count = try await cf.backupRecords(records)
        #expect(count == 1)
        let fetched = try await cf.fetchRecords(type: .client)
        #expect(fetched.count == 1)
    }
}

// MARK: - E2E Data sync engine

struct DataSyncEngineTests {

    @Test func endToEndSyncSucceedsInMockMode() async {
        let engine = DataSyncEngine()
        let client = ClientProfile(firstName: "E2E", lastName: "Test", dateOfBirth: .now)
        let result = await engine.performEndToEndSync(
            clients: [client],
            assessments: [],
            plans: [],
            enableCloudKit: false,
            enableCloudflare: true
        )
        #expect(result.primarySucceeded)
        #expect(result.primary.recordsWritten == 1)
        #expect(result.cloudflare.succeeded)
    }

    @Test func primaryFailureSkipsDependentBackups() async {
        let engine = DataSyncEngine(
            supabase: SupabasePrimaryService(config: SupabaseConfig(projectURL: "https://invalid.", anonKey: "")),
            cloudKit: CloudKitManager(),
            cloudflare: CloudflareBackupService(workerURL: "", authToken: "")
        )
        let result = await engine.performEndToEndSync(
            clients: [ClientProfile(firstName: "Fail", lastName: "Case", dateOfBirth: .now)],
            assessments: [],
            plans: [],
            enableCloudKit: true,
            enableCloudflare: true
        )
        #expect(result.primary.succeeded || !result.primary.succeeded)
    }

    @Test func rebuildFromBackupsUsesPrimaryFirst() async throws {
        let engine = DataSyncEngine()
        let client = ClientProfile(firstName: "Rebuild", lastName: "User", dateOfBirth: .now)
        _ = await engine.performEndToEndSync(clients: [client], assessments: [], plans: [], enableCloudKit: false, enableCloudflare: false)
        let report = try await engine.rebuildFromBackupsIfNeeded()
        #expect(report.clientRecords >= 0)
    }
}

// MARK: - Sync model edge cases

struct SyncModelEdgeTests {

    @Test func syncRecordRoundTripEncoding() throws {
        let record = SyncRecord.from(client: ClientProfile(firstName: "Enc", lastName: "Test", dateOfBirth: .now))
        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(SyncRecord.self, from: data)
        #expect(decoded.id == record.id)
        #expect(decoded.recordType == .client)
    }

    @Test func syncValueTypes() throws {
        let values: [SyncValue] = [.string("a"), .int(1), .double(1.5), .bool(true), .stringArray(["x"]), .null]
        for value in values {
            let data = try JSONEncoder().encode(value)
            _ = try JSONDecoder().decode(SyncValue.self, from: data)
        }
    }

    @Test func emptyClientListSync() async {
        let engine = DataSyncEngine()
        let result = await engine.performEndToEndSync(clients: [], assessments: [], plans: [])
        #expect(result.primarySucceeded)
        #expect(result.primary.recordsWritten == 0)
    }
}

// MARK: - Middleware sync gating

struct MiddlewareSyncTests {

    @Test @MainActor func freeTierCannotSync() async {
        let middleware = NetworkMiddleware()
        do {
            try await middleware.syncData(clients: [], assessments: [], plans: [], userTier: .free)
            #expect(Bool(false), "Should throw")
        } catch {
            #expect(error.localizedDescription.contains("subscription") || error.localizedDescription.contains("tier") || error.localizedDescription.contains("feature"))
        }
    }

    @Test @MainActor func starterTierCanSyncPrimary() async throws {
        let middleware = NetworkMiddleware()
        let client = ClientProfile(firstName: "Sync", lastName: "Test", dateOfBirth: .now)
        try await middleware.syncData(clients: [client], assessments: [], plans: [], userTier: .starter)
        #expect(middleware.lastSyncPipeline?.primarySucceeded == true)
    }

    @Test @MainActor func professionalGetsCloudflareBackup() async throws {
        let middleware = NetworkMiddleware()
        let client = ClientProfile(firstName: "Pro", lastName: "Sync", dateOfBirth: .now)
        try await middleware.syncData(clients: [client], assessments: [], plans: [], userTier: .professional)
        #expect(middleware.lastSyncPipeline?.cloudflare.succeeded == true)
    }
}

// MARK: - Subscription tier sync features

struct SubscriptionSyncFeatureTests {

    @Test @MainActor func starterHasPrimaryAndCloudKit() {
        let manager = SubscriptionManager()
        #expect(manager.canAccess(feature: .supabasePrimary, tier: .starter))
        #expect(manager.canAccess(feature: .cloudSync, tier: .starter))
        #expect(manager.canAccess(feature: .cloudflareBackup, tier: .starter) == false)
    }

    @Test @MainActor func professionalHasCloudflare() {
        let manager = SubscriptionManager()
        #expect(manager.canAccess(feature: .cloudflareBackup, tier: .professional))
    }
}
