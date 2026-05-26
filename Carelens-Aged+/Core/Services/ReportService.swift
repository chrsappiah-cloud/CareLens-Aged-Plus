import Foundation
import PDFKit
import UIKit

enum ReportType: String, CaseIterable {
    case clinical = "Clinical Assessment Report"
    case family = "Family Summary"
    case facilityHandover = "Facility Handover"
    case acpSpiritual = "ACP & Spiritual Summary"
}

final class ReportService {

    func generateReport(
        type: ReportType,
        client: ClientProfile,
        assessment: AssessmentSession?,
        carePlan: CarePlan?
    ) -> String {
        switch type {
        case .clinical:
            return buildClinicalReport(client: client, assessment: assessment, carePlan: carePlan)
        case .family:
            return buildFamilySummary(client: client, assessment: assessment, carePlan: carePlan)
        case .facilityHandover:
            return buildFacilityHandover(client: client, assessment: assessment)
        case .acpSpiritual:
            return buildACPSummary(client: client, assessment: assessment, carePlan: carePlan)
        }
    }

    func buildClinicalReport(client: ClientProfile, assessment: AssessmentSession?, carePlan: CarePlan?) -> String {
        """
        CLINICAL ASSESSMENT REPORT
        ══════════════════════════════════════════
        
        Client: \(client.fullName)
        DOB: \(client.dateOfBirth.formatted(date: .abbreviated, time: .omitted))
        Age: \(client.age) years
        Gender: \(client.gender)
        Language: \(client.preferredLanguage)
        Cultural Identity: \(client.culturalIdentity)
        Consent Status: \(client.consentStatus)
        
        ──────────────────────────────────────────
        ASSESSMENT SUMMARY
        ──────────────────────────────────────────
        
        Assessment Type: \(assessment?.assessmentType ?? "N/A")
        Assessor Role: \(assessment?.assessorRole ?? "N/A")
        Status: \(assessment?.status ?? "N/A")
        Date: \(assessment?.createdAt.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
        
        DOMAIN SCORES
        • Cognition: \(assessment?.cognitionScore.map { String(format: "%.1f", $0) } ?? "Not assessed")
        • Mood: \(assessment?.moodScore.map { String(format: "%.1f", $0) } ?? "Not assessed")
        • Anxiety: \(assessment?.anxietyScore.map { String(format: "%.1f", $0) } ?? "Not assessed")
        • Delirium Risk: \(assessment?.deliriumRiskScore.map { String(format: "%.1f", $0) } ?? "Not assessed")
        • ADL Function: \(assessment?.adlScore.map { String(format: "%.1f", $0) } ?? "Not assessed")
        • IADL Function: \(assessment?.iadlScore.map { String(format: "%.1f", $0) } ?? "Not assessed")
        • Caregiver Stress: \(assessment?.caregivingStressScore.map { String(format: "%.1f", $0) } ?? "Not assessed")
        
        ──────────────────────────────────────────
        CARE PLAN
        ──────────────────────────────────────────
        
        STRENGTHS:
        \(carePlan?.strengths.enumerated().map { "  \($0.offset + 1). \($0.element)" }.joined(separator: "\n") ?? "  None documented")
        
        PRIORITY PROBLEMS:
        \(carePlan?.priorityProblems.enumerated().map { "  \($0.offset + 1). \($0.element)" }.joined(separator: "\n") ?? "  None documented")
        
        GOALS:
        \(carePlan?.goals.enumerated().map { "  \($0.offset + 1). \($0.element)" }.joined(separator: "\n") ?? "  None documented")
        
        INTERVENTIONS:
        \(carePlan?.interventions.enumerated().map { "  \($0.offset + 1). \($0.element)" }.joined(separator: "\n") ?? "  None documented")
        
        Next Review: \(carePlan?.nextReviewDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not scheduled")
        
        ──────────────────────────────────────────
        DISCLAIMER: This report is generated as a decision-support tool. Cognitive scores represent screening indicators, not definitive diagnosis.
        
        Generated: \(Date.now.formatted(date: .abbreviated, time: .shortened))
        """
    }

    func buildFamilySummary(client: ClientProfile, assessment: AssessmentSession?, carePlan: CarePlan?) -> String {
        """
        FAMILY SUMMARY
        For: \(client.fullName)
        Date: \(Date.now.formatted(date: .abbreviated, time: .omitted))
        
        ──────────────────────────────────────────
        
        HOW \(client.firstName.uppercased()) IS DOING
        
        This summary gives you a simple overview of \(client.firstName)'s recent assessment and what the care team is focusing on.
        
        STRENGTHS WE NOTICED:
        \(carePlan?.strengths.map { "  ✓ \($0)" }.joined(separator: "\n") ?? "  Still being assessed")
        
        AREAS WHERE SUPPORT IS NEEDED:
        \(carePlan?.priorityProblems.map { "  • \($0)" }.joined(separator: "\n") ?? "  Still being assessed")
        
        WHAT THE CARE TEAM IS WORKING ON:
        \(carePlan?.goals.map { "  → \($0)" }.joined(separator: "\n") ?? "  Plan in development")
        
        WHAT YOU CAN DO TO HELP:
        • Visit regularly and engage in familiar activities
        • Let the care team know if you notice changes
        • Ask questions — we're here to support the whole family
        
        NEXT REVIEW: \(carePlan?.nextReviewDate?.formatted(date: .abbreviated, time: .omitted) ?? "To be scheduled")
        
        Questions? Contact the care team at your facility.
        """
    }

    func buildFacilityHandover(client: ClientProfile, assessment: AssessmentSession?) -> String {
        """
        FACILITY HANDOVER NOTE
        ══════════════════════════════════════════
        
        Client: \(client.fullName) | Age: \(client.age)
        Date: \(Date.now.formatted(date: .abbreviated, time: .shortened))
        
        SAFETY FLAGS: \(client.safetyFlags.isEmpty ? "None" : client.safetyFlags.joined(separator: ", "))
        
        KEY SCORES:
        • Cognition: \(assessment?.cognitionScore.map { String(format: "%.0f", $0) } ?? "—")
        • Delirium Risk: \(assessment?.deliriumRiskScore.map { String(format: "%.0f", $0) } ?? "—")
        • ADL: \(assessment?.adlScore.map { String(format: "%.0f", $0) } ?? "—")
        
        IMMEDIATE CONCERNS:
        • Monitor for: [Add from latest monitoring events]
        • Medications due: [Check medication schedule]
        • Family contact: \(client.nominatedDecisionMaker.isEmpty ? "Not specified" : client.nominatedDecisionMaker)
        
        STATUS: \(assessment?.status ?? "No current assessment")
        """
    }

    func buildACPSummary(client: ClientProfile, assessment: AssessmentSession?, carePlan: CarePlan?) -> String {
        """
        ADVANCE CARE PLANNING & SPIRITUAL SUMMARY
        ══════════════════════════════════════════
        
        Client: \(client.fullName)
        Date: \(Date.now.formatted(date: .abbreviated, time: .omitted))
        
        DECISION-MAKING CAPACITY: [Capacity assessment pending]
        
        NOMINATED DECISION MAKER:
        \(client.nominatedDecisionMaker.isEmpty ? "Not yet documented" : client.nominatedDecisionMaker)
        
        ADVANCE DIRECTIVE STATUS: [To be assessed]
        
        PREFERENCES:
        • Resuscitation: [To be documented]
        • Hospital Transfer: [To be documented]
        • Preferred Place of Care: [To be documented]
        • Preferred Place of Death: [To be documented]
        
        SPIRITUAL & CULTURAL WISHES:
        • Cultural Identity: \(client.culturalIdentity.isEmpty ? "Not documented" : client.culturalIdentity)
        • Spiritual supports: [To be assessed]
        
        SPIRITUAL SUPPORT ACTIONS:
        \(carePlan?.spiritualSupport.map { "  • \($0)" }.joined(separator: "\n") ?? "  None documented")
        
        This document reflects the expressed wishes of \(client.firstName) and should guide care decisions in alignment with their values and preferences.
        """
    }

    func renderPDF(content: String) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { context in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]

            let attributedString = NSAttributedString(string: content, attributes: attributes)
            let framesetter = CTFramesetterCreateWithAttributedString(attributedString)

            var currentRange = CFRange(location: 0, length: 0)
            var currentY: CGFloat = 0
            let textLength = attributedString.length

            while currentRange.location < textLength {
                context.beginPage()
                let textRect = pageRect.insetBy(dx: 40, dy: 50)
                let path = CGPath(rect: textRect, transform: nil)
                let frame = CTFramesetterCreateFrame(framesetter, currentRange, path, nil)
                let ctxRef = context.cgContext
                ctxRef.translateBy(x: 0, y: pageRect.height)
                ctxRef.scaleBy(x: 1, y: -1)
                CTFrameDraw(frame, ctxRef)

                let visibleRange = CTFrameGetVisibleStringRange(frame)
                currentRange.location += visibleRange.length

                if visibleRange.length == 0 { break }
            }
        }

        return data
    }
}
