import XCTest
import Foundation
@testable import CarelensAged

// MARK: - Data Sync Backend Units

final class E2ESupabasePrimaryServiceTests: XCTestCase {
    func testUpsertAndFetch() async throws {
        let s = SupabasePrimaryService(config: SupabaseConfig(projectURL: "https://test.local", anonKey: "test"))
        let c = ClientProfile(firstName: "J", lastName: "D", dateOfBirth: .now)
        try await s.upsert(SyncRecord.from(client: c))
        let f = try await s.fetch(id: c.id, type: .client)
        XCTAssertNotNil(f)
        XCTAssertEqual(f?.id, c.id)
    }
    func testFullSync() async throws {
        let s = SupabasePrimaryService(config: SupabaseConfig(projectURL: "https://test.local", anonKey: "test"))
        let c = ClientProfile(firstName: "A", lastName: "B", dateOfBirth: .now)
        let a = AssessmentSession(clientID: c.id, assessmentType: "NW", status: "Draft", assessorRole: "C")
        let p = CarePlan(clientID: c.id)
        try await s.performFullSync(clients: [c], assessments: [a], plans: [p])
        let clients = try await s.fetchAll(type: .client)
        let assessments = try await s.fetchAll(type: .assessment)
        let plans = try await s.fetchAll(type: .carePlan)
        XCTAssertEqual(clients.count, 1)
        XCTAssertEqual(assessments.count, 1)
        XCTAssertEqual(plans.count, 1)
    }
    func testRetryQueue() async throws {
        let s = SupabasePrimaryService(config: SupabaseConfig(projectURL: "https://test.local", anonKey: "test"))
        let r = SyncRecord.from(client: ClientProfile(firstName: "X", lastName: "Y", dateOfBirth: .now))
        try await s.upsert(r)
        let recovered = await s.processRetryQueue()
        XCTAssertGreaterThanOrEqual(recovered, 0)
    }
    func testDelete() async throws {
        let s = SupabasePrimaryService(config: SupabaseConfig(projectURL: "https://test.local", anonKey: "test"))
        let c = ClientProfile(firstName: "D", lastName: "E", dateOfBirth: .now)
        try await s.upsert(SyncRecord.from(client: c))
        try await s.delete(id: c.id, type: .client)
        let f = try await s.fetch(id: c.id, type: .client)
        XCTAssertNil(f)
    }
}

final class E2ECloudflareBackupServiceTests: XCTestCase {
    func testBackupAndFetch() async throws {
        let cf = CloudflareBackupService(workerURL: "", authToken: "")
        let c = ClientProfile(firstName: "C", lastName: "F", dateOfBirth: .now)
        let count = try await cf.backupRecords([SyncRecord.from(client: c)])
        XCTAssertEqual(count, 1)
        let records = try await cf.fetchRecords(type: .client)
        XCTAssertEqual(records.count, 1)
    }
}

final class E2EDataSyncEngineTests: XCTestCase {
    func testEndToEndSync() async {
        let e = DataSyncEngine()
        let c = ClientProfile(firstName: "E2E", lastName: "T", dateOfBirth: .now)
        let r = await e.performEndToEndSync(clients: [c], assessments: [], plans: [], enableCloudKit: false, enableCloudflare: true)
        XCTAssertTrue(r.primarySucceeded)
        XCTAssertEqual(r.primary.recordsWritten, 1)
        XCTAssertTrue(r.cloudflare.succeeded)
    }
    func testEmptySync() async {
        let r = await DataSyncEngine().performEndToEndSync(clients: [], assessments: [], plans: [])
        XCTAssertTrue(r.primarySucceeded)
        XCTAssertEqual(r.primary.recordsWritten, 0)
    }
    func testMultiRecordSync() async {
        let e = DataSyncEngine()
        let c1 = ClientProfile(firstName: "A", lastName: "1", dateOfBirth: .now)
        let c2 = ClientProfile(firstName: "B", lastName: "2", dateOfBirth: .now)
        let r = await e.performEndToEndSync(clients: [c1, c2], assessments: [], plans: [], enableCloudKit: false, enableCloudflare: true)
        XCTAssertTrue(r.primarySucceeded)
        XCTAssertEqual(r.primary.recordsWritten, 2)
    }
}
