import SwiftUI

enum LegalDocument: String, Identifiable {
    case privacyPolicy
    case termsOfUse
    case dataRetention

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfUse: return "Terms of Use"
        case .dataRetention: return "Data Retention Policy"
        }
    }

    var bodyText: String {
        switch self {
        case .privacyPolicy:
            return """
            CareLens Aged+ ("we", "our") provides clinical decision-support tools for aged care professionals. This policy explains how we handle information in the app.

            Data we collect
            • Account details you provide (name, email, role, facility identifier).
            • Client assessment, care plan, and monitoring records you enter for care delivery.
            • Device identifiers and push notification tokens when notifications are enabled.
            • Diagnostic logs needed to operate sync, backup, and support.

            How we use data
            • To deliver assessments, care plans, reports, and NeuroWatch insights you request.
            • To sync data through Apple CloudKit and optional encrypted backup services.
            • To process in-app subscriptions through Apple In-App Purchase.
            • AI-assisted features send only the minimum clinical context required to generate decision-support text. Outputs are not a diagnosis and must be reviewed by a qualified clinician.

            Storage & security
            • Primary storage uses on-device SwiftData with CloudKit sync under your Apple ID.
            • Data in transit uses TLS. Access is limited by role-based permissions in the app.
            • We do not sell personal or health information.

            Your choices
            • You may export or delete facility data from Backup & Recovery where enabled.
            • You may disable push notifications and CloudKit sync in Settings.
            • Contact privacy@myworldclass.org for access, correction, or deletion requests.

            Retention
            • Active records are retained while your subscription and facility account remain active.
            • Deleted records are removed from primary systems within 30 days, subject to legal hold requirements.

            Contact
            World Class Scholars / CareLens
            privacy@myworldclass.org
            https://wcs-full.vercel.app/privacy
            Last updated: May 2026
            """
        case .termsOfUse:
            return """
            By using CareLens Aged+, you agree to these Terms of Use.

            Clinical disclaimer
            CareLens Aged+ is decision-support software. It does not replace professional medical judgment, emergency services, or regulated clinical protocols. You are responsible for verifying all recommendations before acting on them.

            Accounts
            • You must provide accurate registration information and safeguard credentials.
            • Organisation administrators are responsible for user provisioning and access reviews.

            Subscriptions
            • Paid tiers are billed through Apple In-App Purchase and subject to Apple's payment terms.
            • Feature availability depends on your active subscription tier.

            Acceptable use
            • Do not upload unlawful content or attempt to disrupt the service.
            • Do not reverse engineer, scrape, or misuse APIs.

            Intellectual property
            • The app, NeuroWatch Engine, and branding remain the property of World Class Scholars.
            • You retain ownership of client records you lawfully enter.

            Limitation of liability
            To the extent permitted by law, we are not liable for indirect or consequential damages arising from clinical decisions made using the app.

            Governing law
            These terms are governed by the laws of New South Wales, Australia, unless mandatory local law applies.

            Contact: legal@myworldclass.org
            Last updated: May 2026
            """
        case .dataRetention:
            return """
            CareLens Aged+ Data Retention Policy

            Active clinical records
            • Retained while the client profile remains active in your facility workspace.
            • Assessment versions and audit events are kept to support longitudinal monitoring.

            Inactive or closed clients
            • Profiles marked inactive are archived after 24 months unless your organisation policy requires earlier deletion.
            • Archived data can be restored by administrators during a 90-day grace period.

            Backups
            • CloudKit and optional Supabase backup snapshots follow the same retention schedule as primary records.
            • Backup restoration is available to Enterprise tier administrators.

            Account termination
            • On subscription cancellation, export tools remain available for 30 days.
            • After 30 days, tenant data is scheduled for deletion unless a legal hold applies.

            Compliance
            • Retention may be extended where required by healthcare record-keeping obligations in your jurisdiction.
            • Contact compliance@myworldclass.org for data processing agreements.
            """
        }
    }
}

struct LegalDocumentView: View {
    let document: LegalDocument

    var body: some View {
        ScrollView {
            Text(document.bodyText)
                .font(.body)
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color.clear)
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
