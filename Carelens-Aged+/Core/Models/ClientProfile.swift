import Foundation
import SwiftData

@Model
final class ClientProfile {
    @Attribute(.unique) var id: String
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var gender: String
    var preferredLanguage: String
    var culturalIdentity: String
    var consentStatus: String
    var referralSource: String
    var presentingConcerns: String
    var preferredCommunicationStyle: String
    var interpreterNeeded: Bool
    var nominatedDecisionMaker: String
    var safetyFlags: [String]
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \AssessmentSession.client)
    var assessments: [AssessmentSession] = []
    @Relationship(deleteRule: .cascade, inverse: \CarePlan.client)
    var carePlans: [CarePlan] = []
    @Relationship(deleteRule: .cascade, inverse: \MonitoringEvent.client)
    var monitoringEvents: [MonitoringEvent] = []

    var fullName: String { "\(firstName) \(lastName)" }
    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: .now).year ?? 0
    }

    init(
        id: String = UUID().uuidString,
        firstName: String,
        lastName: String,
        dateOfBirth: Date,
        gender: String = "",
        preferredLanguage: String = "English",
        culturalIdentity: String = "",
        consentStatus: String = "Pending",
        referralSource: String = "",
        presentingConcerns: String = "",
        preferredCommunicationStyle: String = "",
        interpreterNeeded: Bool = false,
        nominatedDecisionMaker: String = "",
        safetyFlags: [String] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.preferredLanguage = preferredLanguage
        self.culturalIdentity = culturalIdentity
        self.consentStatus = consentStatus
        self.referralSource = referralSource
        self.presentingConcerns = presentingConcerns
        self.preferredCommunicationStyle = preferredCommunicationStyle
        self.interpreterNeeded = interpreterNeeded
        self.nominatedDecisionMaker = nominatedDecisionMaker
        self.safetyFlags = safetyFlags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
