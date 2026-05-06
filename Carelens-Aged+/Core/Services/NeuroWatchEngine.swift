import Foundation

struct NeuroWatchInput {
    var orientationErrors: Int = 0
    var delayedRecallScore: Int = 5
    var clockTaskScore: Int = 5
    var categoryFluencyCount: Int = 15
    var medicationErrors: Int = 0
    var attentionFluctuation: Bool = false
    var familyConcernLevel: Int = 0
    var functionalDeclineLevel: Int = 0
    var acuteMedicalTrigger: Bool = false
}

struct NeuroWatchResult {
    let totalScore: Int
    let band: NeuroWatchBand
    let recommendations: [String]
}

enum NeuroWatchBand: String, CaseIterable {
    case noSignificantChange = "No Significant Early Change"
    case mildConcern = "Mild Cognitive Concern"
    case progressiveConcern = "Progressive Concern"
    case urgentDeliriumRuleOut = "Urgent Delirium Rule-Out"

    var color: String {
        switch self {
        case .noSignificantChange: return "green"
        case .mildConcern: return "yellow"
        case .progressiveConcern: return "orange"
        case .urgentDeliriumRuleOut: return "red"
        }
    }

    var suggestedAction: String {
        switch self {
        case .noSignificantChange: return "Routine review"
        case .mildConcern: return "Repeat screen, gather collateral"
        case .progressiveConcern: return "Comprehensive assessment and safety review"
        case .urgentDeliriumRuleOut: return "Immediate medical review"
        }
    }
}

enum NeuroWatchEngine {
    static func evaluate(_ input: NeuroWatchInput) -> NeuroWatchResult {
        var score = 0

        score += min(input.orientationErrors * 2, 6)
        score += max(0, 5 - input.delayedRecallScore)
        score += max(0, 5 - input.clockTaskScore)
        score += input.categoryFluencyCount < 8 ? 4 : (input.categoryFluencyCount < 12 ? 2 : 0)
        score += min(input.medicationErrors, 4)
        score += input.attentionFluctuation ? 5 : 0
        score += min(input.familyConcernLevel * 2, 6)
        score += min(input.functionalDeclineLevel * 3, 9)
        score += input.acuteMedicalTrigger ? 6 : 0

        let band: NeuroWatchBand
        var recommendations: [String] = []

        switch score {
        case 0..<8:
            band = .noSignificantChange
            recommendations = [
                "Continue routine monitoring",
                "Repeat screen in 3-6 months",
                "Encourage cognitive engagement activities"
            ]
        case 8..<15:
            band = .mildConcern
            recommendations = [
                "Review medications for cognitive side effects",
                "Collect collateral history from family/carers",
                "Repeat screening in 4-6 weeks",
                "Consider neuropsychological referral if persistent"
            ]
        case 15..<24:
            band = .progressiveConcern
            recommendations = [
                "Arrange comprehensive cognitive assessment",
                "Review safety and supervision needs",
                "Assess driving and financial capacity",
                "Discuss advance care planning",
                "Consider specialist referral (geriatrician/neurologist)"
            ]
        default:
            if input.acuteMedicalTrigger || input.attentionFluctuation {
                band = .urgentDeliriumRuleOut
                recommendations = [
                    "Urgent medical review required",
                    "Assess infection, dehydration, medication toxicity",
                    "Check for recent illness, surgery, or environmental change",
                    "Increase supervision until reviewed",
                    "Document onset timing and fluctuation pattern"
                ]
            } else {
                band = .progressiveConcern
                recommendations = [
                    "Arrange comprehensive cognitive assessment",
                    "Review safety and supervision needs",
                    "Consider specialist referral"
                ]
            }
        }

        return NeuroWatchResult(totalScore: score, band: band, recommendations: recommendations)
    }
}
