import Foundation

/// Secondary backup via Cloudflare Worker / R2-compatible endpoint.
actor CloudflareBackupService {
    private let workerURL: String
    private let authToken: String
    private let session: URLSession
    private let inMemoryStore: InMemorySyncStore
    private let useInMemory: Bool

    init(
        workerURL: String = AppEnvironment.cloudflareWorkerURL,
        authToken: String = AppEnvironment.cloudflareBackupToken,
        session: URLSession = .shared
    ) {
        self.workerURL = workerURL
        self.authToken = authToken
        self.session = session
        self.inMemoryStore = InMemorySyncStore()
        self.useInMemory = AppEnvironment.usesMockBackends || workerURL.isEmpty
    }

    func backupRecords(_ records: [SyncRecord]) async throws -> Int {
        if useInMemory {
            for record in records {
                try await inMemoryStore.upsert(record)
            }
            return records.count
        }

        let url = URL(string: "\(workerURL)/v1/backup/batch")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(CloudflareBackupBatch(records: records))

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw CloudflareBackupError.uploadFailed
        }
        return records.count
    }

    func fetchRecords(type: SyncRecordType) async throws -> [SyncRecord] {
        if useInMemory {
            return await inMemoryStore.fetchAll(type: type)
        }
        let url = URL(string: "\(workerURL)/v1/backup/\(type.rawValue)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw CloudflareBackupError.fetchFailed
        }
        return try JSONDecoder().decode([SyncRecord].self, from: data)
    }

    enum CloudflareBackupError: Error {
        case uploadFailed
        case fetchFailed
    }
}

private struct CloudflareBackupBatch: Codable {
    let records: [SyncRecord]
}
