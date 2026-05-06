import Foundation
import SwiftData

@Model
final class CarePlan {
    @Attribute(.unique) var id: String
    var clientID: String
    var strengths: [String]
    var priorityProblems: [String]
    var goals: [String]
    var interventions: [String]
    var immediateActions: [String]
    var environmentalMods: [String]
    var spiritualSupport: [String]
    var serviceReferrals: [String]
    var responsiblePersons: [String]
    var nextReviewDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        clientID: String,
        strengths: [String] = [],
        priorityProblems: [String] = [],
        goals: [String] = [],
        interventions: [String] = [],
        immediateActions: [String] = [],
        environmentalMods: [String] = [],
        spiritualSupport: [String] = [],
        serviceReferrals: [String] = [],
        responsiblePersons: [String] = [],
        nextReviewDate: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.clientID = clientID
        self.strengths = strengths
        self.priorityProblems = priorityProblems
        self.goals = goals
        self.interventions = interventions
        self.immediateActions = immediateActions
        self.environmentalMods = environmentalMods
        self.spiritualSupport = spiritualSupport
        self.serviceReferrals = serviceReferrals
        self.responsiblePersons = responsiblePersons
        self.nextReviewDate = nextReviewDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
