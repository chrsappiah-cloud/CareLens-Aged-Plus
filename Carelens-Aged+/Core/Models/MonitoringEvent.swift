import Foundation
import SwiftData

@Model
final class MonitoringEvent {
    @Attribute(.unique) var id: String
    var clientID: String
    var eventType: String
    var severity: String
    var notes: String
    var reportedBy: String
    var timestamp: Date

    var cognitionScore: Double?
    var adlScore: Double?
    var caregiverStress: Double?
    var medicationAdherence: Double?

    var client: ClientProfile?

    init(
        id: String = UUID().uuidString,
        clientID: String,
        eventType: String,
        severity: String = "Low",
        notes: String = "",
        reportedBy: String = "",
        timestamp: Date = .now
    ) {
        self.id = id
        self.clientID = clientID
        self.eventType = eventType
        self.severity = severity
        self.notes = notes
        self.reportedBy = reportedBy
        self.timestamp = timestamp
    }
}

enum MonitoringEventType: String, CaseIterable {
    case wandering = "Wandering"
    case agitation = "Agitation"
    case missedMedication = "Missed Medication"
    case fall = "Fall"
    case sleepDisruption = "Sleep Disruption"
    case appetiteChange = "Appetite Change"
    case behaviourChange = "Behaviour Change"
    case incontinence = "Incontinence"
    case socialWithdrawal = "Social Withdrawal"
    case cognitiveFluctuation = "Cognitive Fluctuation"

    var icon: String {
        switch self {
        case .wandering: return "figure.walk"
        case .agitation: return "exclamationmark.triangle"
        case .missedMedication: return "pills"
        case .fall: return "figure.fall"
        case .sleepDisruption: return "moon.zzz"
        case .appetiteChange: return "fork.knife"
        case .behaviourChange: return "brain.head.profile"
        case .incontinence: return "drop.triangle"
        case .socialWithdrawal: return "person.slash"
        case .cognitiveFluctuation: return "waveform.path.ecg"
        }
    }
}
