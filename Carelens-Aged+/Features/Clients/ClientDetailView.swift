import SwiftUI
import SwiftData

struct ClientDetailView: View {
    let client: ClientProfile
    @State private var selectedSegment = 0

    private let segments = ["Overview", "Assessments", "Monitoring", "Documents", "Timeline", "Care Circle"]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<segments.count, id: \.self) { index in
                        Button(action: { withAnimation { selectedSegment = index } }) {
                            Text(segments[index])
                                .font(.caption.bold())
                                .foregroundStyle(selectedSegment == index ? .white : CareLensTheme.Colors.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedSegment == index
                                              ? CareLensTheme.Colors.accentMint.opacity(0.3)
                                              : Color.white.opacity(0.06))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            selectedSegment == index
                                            ? CareLensTheme.Colors.accentMint.opacity(0.6)
                                            : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }

            ScrollView {
                switch selectedSegment {
                case 0: overviewTab
                case 1: assessmentsTab
                case 2: monitoringTab
                case 3: documentsTab
                case 4: timelineTab
                case 5: careCircleTab
                default: overviewTab
                }
            }
        }
        .background(Color.clear)
        .navigationTitle(client.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var overviewTab: some View {
        VStack(spacing: 18) {
            // Biopsychosocial summary card
            DiamondGlassCard(
                title: client.fullName,
                subtitle: "Biopsychosocial summary",
                icon: "person.crop.circle"
            ) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Age \(client.age) · \(client.gender) · \(client.preferredLanguage)")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline)
                        if !client.presentingConcerns.isEmpty {
                            Text(client.presentingConcerns)
                                .foregroundColor(.white.opacity(0.7))
                                .font(.footnote)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                    DiamondStatusChip(
                        text: client.consentStatus == "Active" ? "Stable" : client.consentStatus,
                        color: client.consentStatus == "Active" ? .green : .orange
                    )
                }
            }
            .frame(minHeight: 130)

            // NeuroWatch card
            DiamondGlassCard(
                title: "NeuroWatch",
                subtitle: "Early cognitive change index",
                icon: "brain.head.profile"
            ) {
                if let latestCognition = client.assessments.first(where: { $0.type == "Cognition & Dementia" }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            let band = bandForScore(latestCognition.cognitionScore)
                            Text("Band: \(band)")
                                .foregroundColor(.white)
                                .font(.subheadline.weight(.semibold))
                            Text(actionForScore(latestCognition.cognitionScore))
                                .foregroundColor(.white.opacity(0.75))
                                .font(.footnote)
                        }
                        Spacer()
                        Text("Score \(Int(latestCognition.cognitionScore ?? 0))")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                DiamondShape()
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .green],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .purple.opacity(0.6), radius: 12, x: 0, y: 8)
                    }
                } else {
                    HStack {
                        Text("No cognitive screening completed yet")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.footnote)
                        Spacer()
                        DiamondStatusChip(text: "Pending", level: .info)
                    }
                }
            }

            // Spiritual & ACP card
            DiamondGlassCard(
                title: "Spiritual & ACP",
                subtitle: "Meaning, directives, end-of-life wishes",
                icon: "sparkles"
            ) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cultural identity: \(client.culturalIdentity.isEmpty ? "Not documented" : client.culturalIdentity)")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.footnote)
                    if !client.nominatedDecisionMaker.isEmpty {
                        Text("Health proxy: \(client.nominatedDecisionMaker)")
                            .foregroundColor(.white.opacity(0.75))
                            .font(.footnote)
                    }
                    if let plan = client.carePlans.last, !plan.spiritualSupport.isEmpty {
                        Text(plan.spiritualSupport.joined(separator: " · "))
                            .foregroundColor(.white.opacity(0.75))
                            .font(.footnote)
                    }
                    HStack {
                        Spacer()
                        NavigationLink {
                            BiopsychosocialIntakeView(client: client, moduleName: "Advance Care Planning")
                        } label: {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                Text("View ACP Pack")
                            }
                        }
                        .buttonStyle(DiamondButtonStyle())
                    }
                    .padding(.top, 4)
                }
            }

            // Safety & Consent details
            DiamondGlassCard(title: "Consent & Safety", subtitle: nil, icon: "shield.checkered") {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: "Consent", value: client.consentStatus)
                    InfoRow(label: "Decision Maker", value: client.nominatedDecisionMaker)
                    InfoRow(label: "Referral Source", value: client.referralSource)
                    InfoRow(label: "Interpreter", value: client.interpreterNeeded ? "Yes" : "No")
                    if !client.safetyFlags.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(client.safetyFlags, id: \.self) { flag in
                                DiamondStatusChip(text: flag, level: .risk)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
    }

    private func bandForScore(_ score: Double?) -> String {
        guard let score = score else { return "Not assessed" }
        switch Int(score) {
        case 0..<8: return "No significant early change"
        case 8..<15: return "Mild cognitive concern"
        case 15..<24: return "Progressive concern"
        default: return "Urgent delirium rule-out"
        }
    }

    private func actionForScore(_ score: Double?) -> String {
        guard let score = score else { return "" }
        switch Int(score) {
        case 0..<8: return "Continue routine monitoring. Repeat screen in 3-6 months."
        case 8..<15: return "Review meds, collect collateral, repeat screen in 4-8 weeks."
        case 15..<24: return "Comprehensive assessment and safety planning required."
        default: return "Immediate medical review required."
        }
    }

    private var assessmentsTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            if client.assessments.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checklist")
                        .font(.system(size: 40))
                        .foregroundStyle(CareLensTheme.Colors.textTertiary)
                    Text("No Assessments")
                        .font(.headline)
                        .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    Text("Start an assessment from the Assess tab")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                ForEach(client.assessments, id: \.id) { assessment in
                    AssessmentRow(assessment: assessment)
                }
            }
        }
        .padding()
    }

    private var monitoringTab: some View {
        MonitoringChartView(client: client)
    }

    private var documentsTab: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Reports & Documents")

            NavigationLink {
                ReportsHomeView()
            } label: {
                DiamondGlassCard(title: "Generate Report", subtitle: "Clinical, Family, Facility, or ACP report", icon: "doc.richtext") {
                    HStack {
                        DiamondStatusChip(text: "4 types available", level: .safe)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(CareLensTheme.Colors.textTertiary)
                    }
                }
            }
            .buttonStyle(.plain)

            DiamondGlassCard(title: "Assessment Records", subtitle: "\(client.assessments.count) completed sessions", icon: "folder.fill") {
                ForEach(client.assessments.prefix(3), id: \.id) { session in
                    HStack(spacing: 8) {
                        DiamondShape().fill(CareLensTheme.Colors.emeraldGreen).frame(width: 6, height: 6)
                        Text(session.type)
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                        Spacer()
                        Text(session.updatedAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(CareLensTheme.Colors.textTertiary)
                    }
                }
                if client.assessments.isEmpty {
                    Text("No records yet").font(.caption).foregroundStyle(CareLensTheme.Colors.textTertiary)
                }
            }

            DiamondGlassCard(title: "Care Plans", subtitle: "\(client.carePlans.count) plan(s) on file", icon: "cross.case.fill") {
                HStack {
                    DiamondStatusChip(text: client.carePlans.isEmpty ? "None" : "Active", level: client.carePlans.isEmpty ? .warning : .safe)
                    Spacer()
                    NavigationLink {
                        CarePlanDetailView(client: client)
                    } label: {
                        HStack(spacing: 4) {
                            Text("View")
                            Image(systemName: "chevron.right")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(CareLensTheme.Colors.goldPrimary)
                    }
                }
            }

            Button(action: {}) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export All as PDF")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(DiamondSecondaryButtonStyle())
        }
        .padding()
    }

    private var timelineTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Activity Timeline")

            let allEvents = buildTimeline()
            if allEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock").font(.system(size: 40)).foregroundStyle(CareLensTheme.Colors.textTertiary)
                    Text("No activity recorded yet").font(.subheadline).foregroundStyle(CareLensTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.top, 40)
            } else {
                ForEach(allEvents, id: \.date) { event in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(spacing: 0) {
                            DiamondShape()
                                .fill(event.color)
                                .frame(width: 12, height: 12)
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 1, height: 40)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.subheadline.bold())
                                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                            Text(event.subtitle)
                                .font(.caption)
                                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                            Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(CareLensTheme.Colors.textTertiary)
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }

    private var careCircleTab: some View {
        VStack(spacing: 16) {
            SectionHeader(title: "Care Circle")

            DiamondGlassCard(title: "Primary Contact", subtitle: client.nominatedDecisionMaker.isEmpty ? "Not specified" : client.nominatedDecisionMaker, icon: "person.fill") {
                HStack {
                    DiamondStatusChip(text: "Decision Maker", level: .safe)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(CareLensTheme.Colors.emeraldGreen)
                    }
                }
            }

            DiamondGlassCard(title: "Referral Source", subtitle: client.referralSource.isEmpty ? "Unknown" : client.referralSource, icon: "arrow.turn.right.down") {
                HStack {
                    DiamondStatusChip(text: "Referring", level: .info)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(CareLensTheme.Colors.goldPrimary)
                    }
                }
            }

            DiamondGlassCard(title: "Care Team", subtitle: "Assigned professionals", icon: "person.3.fill") {
                VStack(alignment: .leading, spacing: 8) {
                    CareTeamMember(name: "Dr. Sarah Wilson", role: "Lead Clinician", isOnline: true)
                    CareTeamMember(name: "James Kim", role: "Occupational Therapist", isOnline: true)
                    CareTeamMember(name: "Nurse Chen", role: "Community Nurse", isOnline: false)
                }
            }

            NavigationLink {
                CollateralReportView(client: client)
            } label: {
                DiamondGlassCard(title: "Collateral Reports", subtitle: "Family/carer observations", icon: "text.bubble.fill") {
                    HStack {
                        DiamondStatusChip(text: "Submit Report", level: .safe)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(CareLensTheme.Colors.textTertiary)
                    }
                }
            }
            .buttonStyle(.plain)

            Button(action: {}) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Add Team Member")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(DiamondSecondaryButtonStyle())
        }
        .padding()
    }

    private struct TimelineEvent {
        let title: String
        let subtitle: String
        let date: Date
        let color: Color
    }

    private func buildTimeline() -> [TimelineEvent] {
        var events: [TimelineEvent] = []
        for assessment in client.assessments {
            events.append(TimelineEvent(
                title: assessment.type,
                subtitle: "Assessment \(assessment.status)",
                date: assessment.updatedAt,
                color: CareLensTheme.Colors.emeraldGreen
            ))
        }
        for event in client.monitoringEvents.prefix(10) {
            events.append(TimelineEvent(
                title: event.eventType,
                subtitle: event.notes,
                date: event.timestamp,
                color: event.severity == "High" ? CareLensTheme.Colors.riskRed : CareLensTheme.Colors.goldPrimary
            ))
        }
        return events.sorted { $0.date > $1.date }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.35, green: 0.40, blue: 0.88),
                        Color(red: 0.60, green: 0.35, blue: 0.80),
                        Color(red: 0.72, green: 0.50, blue: 0.32)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textTertiary)
                .frame(width: 130, alignment: .leading)
            Text(value.isEmpty ? "—" : value)
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
        }
    }
}

struct AssessmentRow: View {
    let assessment: AssessmentSession
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(assessment.type)
                    .font(.subheadline.bold())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                Text(assessment.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }
            Spacer()
            StatusChip(title: assessment.status, color: assessment.assessmentStatus.color)
        }
        .clCard()
    }
}

struct CareTeamMember: View {
    let name: String
    let role: String
    let isOnline: Bool

    var body: some View {
        HStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(CareLensTheme.Colors.goldPrimary.opacity(0.15))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.caption.bold())
                            .foregroundStyle(CareLensTheme.Colors.goldLight)
                    )
                Circle()
                    .fill(isOnline ? CareLensTheme.Colors.safeGreen : Color.gray)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().strokeBorder(Color.black, lineWidth: 1))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.caption.bold())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                Text(role)
                    .font(.caption2)
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
            }
            Spacer()
            if isOnline {
                DiamondShape()
                    .fill(CareLensTheme.Colors.safeGreen)
                    .frame(width: 6, height: 6)
            }
        }
    }
}
