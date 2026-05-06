import Foundation
import SwiftData

@Model
final class AssessmentSession {
    @Attribute(.unique) var id: String
    var clientID: String
    var type: String
    var status: String
    var assessorRole: String
    var createdAt: Date
    var updatedAt: Date

    var cognitionScore: Double?
    var moodScore: Double?
    var anxietyScore: Double?
    var deliriumRiskScore: Double?
    var adlScore: Double?
    var iadlScore: Double?
    var caregivingStressScore: Double?
    var spiritualDistressScore: Double?
    var safetyScore: Double?

    var summaryJSON: Data?
    var sectionsJSON: Data?

    @Relationship(deleteRule: .cascade) var sections: [AssessmentSection] = []

    var assessmentStatus: AssessmentStatus {
        AssessmentStatus(rawValue: status) ?? .draft
    }

    init(
        id: String = UUID().uuidString,
        clientID: String,
        type: String,
        status: String = "Draft",
        assessorRole: String = "Social Worker",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.clientID = clientID
        self.type = type
        self.status = status
        self.assessorRole = assessorRole
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@Model
final class AssessmentSection {
    @Attribute(.unique) var id: String
    var assessmentID: String
    var domain: String
    var fieldsJSON: Data?
    var notes: String
    var completedAt: Date?

    init(
        id: String = UUID().uuidString,
        assessmentID: String,
        domain: String,
        notes: String = "",
        completedAt: Date? = nil
    ) {
        self.id = id
        self.assessmentID = assessmentID
        self.domain = domain
        self.notes = notes
        self.completedAt = completedAt
    }
}
