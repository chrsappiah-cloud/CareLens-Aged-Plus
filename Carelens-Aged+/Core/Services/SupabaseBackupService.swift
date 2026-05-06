import Foundation

struct SupabaseConfig {
    let projectURL: String
    let anonKey: String
    let serviceRoleKey: String

    static let shared = SupabaseConfig(
        projectURL: "https://your-project.supabase.co",
        anonKey: "your-anon-key",
        serviceRoleKey: "your-service-role-key"
    )
}

struct BackupPayload: Codable, Sendable {
    let id: String
    let recordType: String
    let data: [String: AnyCodableValue]
    let updatedAt: String
    let syncedAt: String
}

enum AnyCodableValue: Codable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let v = try? container.decode(String.self) { self = .string(v) }
        else if let v = try? container.decode(Int.self) { self = .int(v) }
        else if let v = try? container.decode(Double.self) { self = .double(v) }
        else if let v = try? container.decode(Bool.self) { self = .bool(v) }
        else { self = .null }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v): try container.encode(v)
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .bool(let v): try container.encode(v)
        case .null: try container.encodeNil()
        }
    }
}

actor SupabaseBackupService {
    private let config: SupabaseConfig
    private let session: URLSession
    private var retryQueue: [BackupPayload] = []

    init(config: SupabaseConfig = .shared) {
        self.config = config
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Backup Operations

    func backupClient(_ client: ClientProfile) async throws {
        let payload = BackupPayload(
            id: client.id,
            recordType: "client",
            data: [
                "firstName": .string(client.firstName),
                "lastName": .string(client.lastName),
                "gender": .string(client.gender),
                "preferredLanguage": .string(client.preferredLanguage),
                "culturalIdentity": .string(client.culturalIdentity),
                "consentStatus": .string(client.consentStatus),
                "referralSource": .string(client.referralSource),
                "interpreterNeeded": .bool(client.interpreterNeeded),
            ],
            updatedAt: ISO8601DateFormatter().string(from: client.updatedAt),
            syncedAt: ISO8601DateFormatter().string(from: .now)
        )
        try await upsertRecord(table: "clients_backup", payload: payload)
    }

    func backupAssessment(_ assessment: AssessmentSession) async throws {
        let payload = BackupPayload(
            id: assessment.id,
            recordType: "assessment",
            data: [
                "clientID": .string(assessment.clientID),
                "type": .string(assessment.type),
                "status": .string(assessment.status),
                "assessorRole": .string(assessment.assessorRole),
                "cognitionScore": assessment.cognitionScore.map { .double($0) } ?? .null,
                "moodScore": assessment.moodScore.map { .double($0) } ?? .null,
            ],
            updatedAt: ISO8601DateFormatter().string(from: assessment.updatedAt),
            syncedAt: ISO8601DateFormatter().string(from: .now)
        )
        try await upsertRecord(table: "assessments_backup", payload: payload)
    }

    func backupCarePlan(_ plan: CarePlan) async throws {
        let payload = BackupPayload(
            id: plan.id,
            recordType: "care_plan",
            data: [
                "clientID": .string(plan.clientID),
                "strengths": .string(plan.strengths.joined(separator: "|")),
                "goals": .string(plan.goals.joined(separator: "|")),
                "interventions": .string(plan.interventions.joined(separator: "|")),
            ],
            updatedAt: ISO8601DateFormatter().string(from: plan.updatedAt),
            syncedAt: ISO8601DateFormatter().string(from: .now)
        )
        try await upsertRecord(table: "care_plans_backup", payload: payload)
    }

    // MARK: - Full Backup Sync

    func performFullBackup(
        clients: [ClientProfile],
        assessments: [AssessmentSession],
        plans: [CarePlan]
    ) async throws {
        for client in clients {
            try await backupClient(client)
        }
        for assessment in assessments {
            try await backupAssessment(assessment)
        }
        for plan in plans {
            try await backupCarePlan(plan)
        }
    }

    // MARK: - Recovery

    func fetchBackupRecords(table: String) async throws -> [BackupPayload] {
        let url = URL(string: "\(config.projectURL)/rest/v1/\(table)?select=*")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw BackupError.fetchFailed
        }
        return try JSONDecoder().decode([BackupPayload].self, from: data)
    }

    // MARK: - Retry Queue

    func processRetryQueue() async {
        let pending = retryQueue
        retryQueue.removeAll()
        for payload in pending {
            do {
                try await upsertRecord(table: "\(payload.recordType)s_backup", payload: payload)
            } catch {
                retryQueue.append(payload)
            }
        }
    }

    // MARK: - Network Layer

    private func upsertRecord(table: String, payload: BackupPayload) async throws {
        let url = URL(string: "\(config.projectURL)/rest/v1/\(table)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("resolution=merge-duplicates", forHTTPHeaderField: "Prefer")

        request.httpBody = try JSONEncoder().encode(payload)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            retryQueue.append(payload)
            throw BackupError.uploadFailed
        }
    }

    enum BackupError: Error {
        case uploadFailed
        case fetchFailed
        case invalidResponse
    }
}
