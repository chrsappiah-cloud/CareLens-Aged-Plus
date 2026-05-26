import Foundation
import SwiftData

enum MockData {
    static func populateSampleData(context: ModelContext) {
        let client1 = ClientProfile(
            firstName: "Margaret",
            lastName: "Thompson",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -82, to: .now)!,
            gender: "Female",
            preferredLanguage: "English",
            culturalIdentity: "Australian",
            consentStatus: "Active",
            referralSource: "GP - Dr. Chen",
            presentingConcerns: "Family reports increasing forgetfulness, missed medications, and difficulty managing finances over past 6 months.",
            interpreterNeeded: false,
            nominatedDecisionMaker: "John Thompson (son)",
            safetyFlags: ["Fall Risk", "Medication Non-Adherence"]
        )

        let client2 = ClientProfile(
            firstName: "Arthur",
            lastName: "Williams",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -88, to: .now)!,
            gender: "Male",
            preferredLanguage: "English",
            culturalIdentity: "Greek-Australian",
            consentStatus: "Active",
            referralSource: "Aged Care Facility - Sunrise House",
            presentingConcerns: "Recent admission to residential aged care. Adjustment difficulties, low mood, grieving wife who passed 3 months ago.",
            interpreterNeeded: false,
            nominatedDecisionMaker: "Maria Papadopoulos (daughter)",
            safetyFlags: ["Mood Concerns"]
        )

        let client3 = ClientProfile(
            firstName: "Dorothy",
            lastName: "Chen",
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -79, to: .now)!,
            gender: "Female",
            preferredLanguage: "Mandarin",
            culturalIdentity: "Chinese-Australian",
            consentStatus: "Pending",
            referralSource: "Community Health Centre",
            presentingConcerns: "Isolated living alone since husband hospitalised. Neighbours report not leaving house for weeks.",
            interpreterNeeded: true,
            nominatedDecisionMaker: "Wei Chen (husband)",
            safetyFlags: ["Social Isolation"]
        )

        context.insert(client1)
        context.insert(client2)
        context.insert(client3)

        // Assessments for client 1
        let assessment1 = AssessmentSession(
            clientID: client1.id,
            assessmentType: "Cognition & Dementia",
            status: "Completed",
            assessorRole: "Social Worker"
        )
        assessment1.cognitionScore = 14.0
        assessment1.moodScore = 3.0
        assessment1.adlScore = 65.0
        assessment1.caregivingStressScore = 6.0
        context.insert(assessment1)
        client1.assessments.append(assessment1)

        let assessment2 = AssessmentSession(
            clientID: client1.id,
            assessmentType: "Biopsychosocial Intake",
            status: "In Progress",
            assessorRole: "Social Worker"
        )
        context.insert(assessment2)
        client1.assessments.append(assessment2)

        // Assessment for client 2
        let assessment3 = AssessmentSession(
            clientID: client2.id,
            assessmentType: "Mood, Anxiety & Delirium",
            status: "Needs Review",
            assessorRole: "Nurse"
        )
        assessment3.moodScore = 7.0
        assessment3.anxietyScore = 4.0
        assessment3.deliriumRiskScore = 2.0
        context.insert(assessment3)
        client2.assessments.append(assessment3)

        // Care plan for client 1
        let plan1 = CarePlan(
            clientID: client1.id,
            strengths: [
                "Supportive son who visits regularly",
                "Maintains sense of humour",
                "Good physical mobility for age",
                "Strong faith community connection"
            ],
            priorityProblems: [
                "Progressive cognitive changes affecting daily function",
                "Medication management errors increasing",
                "Fall risk due to balance changes",
                "Son showing caregiver strain"
            ],
            goals: [
                "Maintain independence in basic ADLs for 6+ months",
                "Achieve 100% medication adherence with supports",
                "Zero falls in next 3 months",
                "Reduce caregiver burden for John"
            ],
            interventions: [
                "Weekly cognitive stimulation programme",
                "Webster pack for medication management",
                "Home safety assessment and modifications",
                "Carer support group referral for John",
                "Monthly NeuroWatch monitoring"
            ],
            immediateActions: [
                "Arrange falls prevention assessment",
                "Contact pharmacy re Webster pack"
            ],
            spiritualSupport: [
                "Maintain connection with church community",
                "Arrange pastoral visits fortnightly"
            ],
            serviceReferrals: [
                "ACAT assessment for community packages",
                "Carer Gateway for son"
            ],
            responsiblePersons: ["Sarah (SW)", "Dr. Chen (GP)", "John (son)"],
            nextReviewDate: Calendar.current.date(byAdding: .month, value: 1, to: .now)
        )
        context.insert(plan1)
        client1.carePlans.append(plan1)

        // Monitoring events for client 1
        let eventTypes: [(String, String, Int)] = [
            ("Missed Medication", "Moderate", -1),
            ("Fall", "High", -5),
            ("Cognitive Fluctuation", "Moderate", -12),
            ("Missed Medication", "Low", -18),
            ("Sleep Disruption", "Low", -22),
            ("Wandering", "Moderate", -30),
        ]

        for (type, severity, daysAgo) in eventTypes {
            let event = MonitoringEvent(
                clientID: client1.id,
                eventType: type,
                severity: severity,
                notes: "Auto-generated sample event",
                reportedBy: "Care Staff",
                timestamp: Calendar.current.date(byAdding: .day, value: daysAgo, to: .now)!
            )
            event.cognitionScore = Double.random(in: 10...18)
            event.adlScore = Double.random(in: 55...75)
            event.caregiverStress = Double.random(in: 4...8)
            event.medicationAdherence = Double.random(in: 60...90)
            context.insert(event)
            client1.monitoringEvents.append(event)
        }
    }
}
