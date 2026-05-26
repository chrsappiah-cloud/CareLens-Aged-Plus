import Foundation

enum SyncRecordType: String, Codable, Sendable {
    case client
    case assessment
    case carePlan
    case monitoringEvent
}

struct SyncRecord: Codable, Sendable, Identifiable, Equatable {
    let id: String
    let recordType: SyncRecordType
    let payload: [String: SyncValue]
    let updatedAt: Date
    let syncedAt: Date?

    nonisolated func markedSynced(at date: Date = .now) -> SyncRecord {
        SyncRecord(id: id, recordType: recordType, payload: payload, updatedAt: updatedAt, syncedAt: date)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case recordType = "record_type"
        case payload
        case updatedAt = "updated_at"
        case syncedAt = "synced_at"
    }
}

enum SyncValue: Codable, Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case stringArray([String])
    case null

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(String.self) { self = .string(v) }
        else if let v = try? c.decode([String].self) { self = .stringArray(v) }
        else if let v = try? c.decode(Int.self) { self = .int(v) }
        else if let v = try? c.decode(Double.self) { self = .double(v) }
        else if let v = try? c.decode(Bool.self) { self = .bool(v) }
        else { self = .null }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .string(let v): try c.encode(v)
        case .int(let v): try c.encode(v)
        case .double(let v): try c.encode(v)
        case .bool(let v): try c.encode(v)
        case .stringArray(let v): try c.encode(v)
        case .null: try c.encodeNil()
        }
    }
}

enum SyncDestination: String, Sendable, CaseIterable {
    case supabasePrimary = "Supabase"
    case cloudKit = "iCloud / CloudKit"
    case cloudflare = "Cloudflare"
}

struct SyncPipelineResult: Sendable {
    let primary: SyncStepResult
    let cloudKit: SyncStepResult
    let cloudflare: SyncStepResult
    let completedAt: Date

    var allBackupsSucceeded: Bool {
        cloudKit.succeeded && cloudflare.succeeded
    }

    var primarySucceeded: Bool { primary.succeeded }
}

struct SyncStepResult: Sendable {
    let destination: SyncDestination
    let succeeded: Bool
    let recordsWritten: Int
    let errorMessage: String?

    static func success(_ destination: SyncDestination, count: Int) -> SyncStepResult {
        SyncStepResult(destination: destination, succeeded: true, recordsWritten: count, errorMessage: nil)
    }

    static func failure(_ destination: SyncDestination, message: String) -> SyncStepResult {
        SyncStepResult(destination: destination, succeeded: false, recordsWritten: 0, errorMessage: message)
    }
}

// MARK: - Model mapping

extension SyncRecord {
    nonisolated static func from(client: ClientProfile) -> SyncRecord {
        SyncRecord(
            id: client.id,
            recordType: .client,
            payload: [
                "firstName": .string(client.firstName),
                "lastName": .string(client.lastName),
                "dateOfBirth": .string(ISO8601DateFormatter().string(from: client.dateOfBirth)),
                "gender": .string(client.gender),
                "preferredLanguage": .string(client.preferredLanguage),
                "culturalIdentity": .string(client.culturalIdentity),
                "consentStatus": .string(client.consentStatus),
                "referralSource": .string(client.referralSource),
                "presentingConcerns": .string(client.presentingConcerns),
                "interpreterNeeded": .bool(client.interpreterNeeded),
                "safetyFlags": .stringArray(client.safetyFlags)
            ],
            updatedAt: client.updatedAt,
            syncedAt: nil
        )
    }

    nonisolated static func from(assessment: AssessmentSession) -> SyncRecord {
        SyncRecord(
            id: assessment.id,
            recordType: .assessment,
            payload: [
                "clientID": .string(assessment.clientID),
                "type": .string(assessment.type),
                "status": .string(assessment.status),
                "assessorRole": .string(assessment.assessorRole),
                "cognitionScore": assessment.cognitionScore.map { .double($0) } ?? .null,
                "moodScore": assessment.moodScore.map { .double($0) } ?? .null
            ],
            updatedAt: assessment.updatedAt,
            syncedAt: nil
        )
    }

    nonisolated static func from(plan: CarePlan) -> SyncRecord {
        SyncRecord(
            id: plan.id,
            recordType: .carePlan,
            payload: [
                "clientID": .string(plan.clientID),
                "strengths": .stringArray(plan.strengths),
                "goals": .stringArray(plan.goals),
                "interventions": .stringArray(plan.interventions)
            ],
            updatedAt: plan.updatedAt,
            syncedAt: nil
        )
    }
}
