import Foundation

struct SupabaseConfig: Sendable {
    let projectURL: String
    let anonKey: String

    static let defaultProjectURL = "https://your-project.supabase.co"

    static var live: SupabaseConfig {
        SupabaseConfig(
            projectURL: AppEnvironment.supabaseURL,
            anonKey: AppEnvironment.supabaseAnonKey
        )
    }
}

/// Primary database — Supabase PostgREST. Falls back to in-memory store when unconfigured (tests / demo).
actor SupabasePrimaryService {
    private let config: SupabaseConfig
    private let session: URLSession
    private let inMemoryStore: InMemorySyncStore
    private let useInMemory: Bool
    private var retryQueue: [SyncRecord] = []

    init(config: SupabaseConfig = .live, session: URLSession = .shared) {
        self.config = config
        self.session = session
        self.inMemoryStore = InMemorySyncStore()
        self.useInMemory = AppEnvironment.usesMockBackends
            || config.projectURL.contains("your-project")
            || config.anonKey.isEmpty
    }

    // MARK: - Primary CRUD

    func upsert(_ record: SyncRecord) async throws {
        if useInMemory {
            try await inMemoryStore.upsert(record)
            return
        }
        do {
            try await postgrestUpsert(record)
        } catch {
            retryQueue.append(record)
            throw error
        }
    }

    func fetchAll(type: SyncRecordType) async throws -> [SyncRecord] {
        if useInMemory {
            return await inMemoryStore.fetchAll(type: type)
        }
        return try await postgrestFetch(table: tableName(for: type))
    }

    func fetch(id: String, type: SyncRecordType) async throws -> SyncRecord? {
        if useInMemory {
            return await inMemoryStore.fetch(id: id, type: type)
        }
        let rows = try await postgrestFetch(
            table: tableName(for: type),
            query: "id=eq.\(id)&limit=1"
        )
        return rows.first
    }

    func delete(id: String, type: SyncRecordType) async throws {
        if useInMemory {
            await inMemoryStore.delete(id: id, type: type)
            return
        }
        let url = URL(string: "\(config.projectURL)/rest/v1/\(tableName(for: type))?id=eq.\(id)")!
        var request = authorizedRequest(url: url, method: "DELETE")
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw SupabaseError.requestFailed
        }
    }

    // MARK: - Batch sync (primary write path)

    func syncRecords(_ records: [SyncRecord]) async throws -> Int {
        var written = 0
        for record in records {
            try await upsert(record)
            written += 1
        }
        return written
    }

    func performFullSync(
        clients: [ClientProfile],
        assessments: [AssessmentSession],
        plans: [CarePlan]
    ) async throws {
        var records: [SyncRecord] = clients.map(SyncRecord.from)
        records += assessments.map(SyncRecord.from)
        records += plans.map(SyncRecord.from)
        _ = try await syncRecords(records)
    }

    func processRetryQueue() async -> Int {
        let pending = retryQueue
        retryQueue.removeAll()
        var recovered = 0
        for record in pending {
            if (try? await upsert(record)) != nil {
                recovered += 1
            } else {
                retryQueue.append(record)
            }
        }
        return recovered
    }

    var pendingRetryCount: Int { retryQueue.count }

    // MARK: - Legacy backup aliases

    func backupClient(_ client: ClientProfile) async throws {
        try await upsert(SyncRecord.from(client: client))
    }

    func backupAssessment(_ assessment: AssessmentSession) async throws {
        try await upsert(SyncRecord.from(assessment: assessment))
    }

    func backupCarePlan(_ plan: CarePlan) async throws {
        try await upsert(SyncRecord.from(plan: plan))
    }

    func performFullBackup(
        clients: [ClientProfile],
        assessments: [AssessmentSession],
        plans: [CarePlan]
    ) async throws {
        try await performFullSync(clients: clients, assessments: assessments, plans: plans)
    }

    func fetchBackupRecords(table: String) async throws -> [SyncRecord] {
        let type: SyncRecordType
        switch table {
        case "clients", "clients_backup": type = .client
        case "assessments", "assessments_backup": type = .assessment
        default: type = .carePlan
        }
        return try await fetchAll(type: type)
    }

    // MARK: - HTTP

    private func tableName(for type: SyncRecordType) -> String {
        switch type {
        case .client: return "clients"
        case .assessment: return "assessments"
        case .carePlan: return "care_plans"
        case .monitoringEvent: return "monitoring_events"
        }
    }

    private func postgrestUpsert(_ record: SyncRecord) async throws {
        let table = tableName(for: record.recordType)
        let url = URL(string: "\(config.projectURL)/rest/v1/\(table)")!
        var request = authorizedRequest(url: url, method: "POST")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        var body = try JSONEncoder().encode(record)
        if var dict = try JSONSerialization.jsonObject(with: body) as? [String: Any] {
            dict["synced_at"] = ISO8601DateFormatter().string(from: .now)
            body = try JSONSerialization.data(withJSONObject: dict)
        }
        request.httpBody = body
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw SupabaseError.requestFailed
        }
    }

    private func postgrestFetch(table: String, query: String = "select=*") async throws -> [SyncRecord] {
        let url = URL(string: "\(config.projectURL)/rest/v1/\(table)?\(query)")!
        let request = authorizedRequest(url: url, method: "GET")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw SupabaseError.requestFailed
        }
        return try JSONDecoder().decode([SyncRecord].self, from: data)
    }

    private func authorizedRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        return request
    }

    enum SupabaseError: Error, LocalizedError {
        case requestFailed
        case notConfigured

        var errorDescription: String? {
            switch self {
            case .requestFailed: return "Supabase request failed."
            case .notConfigured: return "Supabase is not configured."
            }
        }
    }
}

/// In-memory primary store for XCTest, UI tests, and offline demo mode.
actor InMemorySyncStore {
    private var records: [String: SyncRecord] = [:]

    func upsert(_ record: SyncRecord) throws {
        records[key(record)] = record.markedSynced()
    }

    func fetchAll(type: SyncRecordType) -> [SyncRecord] {
        records.values.filter { $0.recordType == type }
    }

    func fetch(id: String, type: SyncRecordType) -> SyncRecord? {
        records["\(type.rawValue):\(id)"]
    }

    func delete(id: String, type: SyncRecordType) {
        records.removeValue(forKey: "\(type.rawValue):\(id)")
    }

    private func key(_ record: SyncRecord) -> String {
        "\(record.recordType.rawValue):\(record.id)"
    }
}

typealias SupabaseBackupService = SupabasePrimaryService
