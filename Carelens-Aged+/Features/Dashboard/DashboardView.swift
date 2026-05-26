import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var clients: [ClientProfile]
    @Query(sort: \AssessmentSession.updatedAt, order: .reverse) private var assessments: [AssessmentSession]
    @Query(sort: \MonitoringEvent.timestamp, order: .reverse) private var recentEvents: [MonitoringEvent]

    @State private var navigateToClients = false
    @State private var navigateToAssessments = false
    @State private var navigateToMonitoring = false
    @State private var selectedClient: ClientProfile?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CareLensTheme.sectionSpacing) {
                    ScreenIntroHeader(
                        eyebrow: "Today",
                        title: AppTab.home.screenTitle,
                        subtitle: AppTab.home.subtitle
                    )
                    quickActionsBar
                    alertsSection
                    caseloadOverview
                    recentActivitySection
                    dueReviewsSection
                }
                .padding()
            }
            .background(Color.clear)
            .navigationTitle(AppTab.home.tabLabel)
            .navigationBarTitleDisplayMode(.inline)
            .careLensDarkChrome()
            .navigationDestination(isPresented: $navigateToClients) {
                ClientListView()
            }
            .navigationDestination(isPresented: $navigateToAssessments) {
                AssessmentsHomeView()
            }
            .navigationDestination(for: ClientProfile.self) { client in
                ClientDetailView(client: client)
            }
        }
    }

    private var quickActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                QuickActionButton(title: "Admit Client", icon: "person.crop.circle.badge.plus", action: {})
                QuickActionButton(title: "Run Assessment", icon: "stethoscope", action: { navigateToAssessments = true })
                QuickActionButton(title: "Open Caseload", icon: "person.2.fill", action: { navigateToClients = true })
                QuickActionButton(title: "Create Report", icon: "doc.text.fill", action: {})
                QuickActionButton(title: "Log Incident", icon: "exclamationmark.triangle.fill", action: {})
            }
        }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareLensSectionTitle(
                title: "Priority Alerts",
                footnote: "Urgent assessments and safety flags needing attention today"
            )

            let urgentAssessments = assessments.filter { $0.status == "Urgent" }
            if urgentAssessments.isEmpty {
                DiamondGlassCard(title: "All Clear", subtitle: "No urgent clinical items right now", icon: "checkmark.circle.fill") {
                    DiamondStatusChip(text: "Caseload stable", level: .safe)
                }
            } else {
                ForEach(urgentAssessments, id: \.id) { assessment in
                    DiamondGlassCard(title: assessment.assessmentType, subtitle: "Client: \(assessment.clientID)", icon: "exclamationmark.circle.fill") {
                        DiamondStatusChip(text: "Urgent", level: .risk)
                    }
                }
            }
        }
    }

    private var caseloadOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareLensSectionTitle(
                title: "Caseload at a Glance",
                footnote: "Tap a card to jump to clients or assessments"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                Button(action: { navigateToClients = true }) {
                    FuturisticStatCard(
                        title: "Active Clients",
                        value: "\(clients.count)",
                        icon: "person.2.fill",
                        level: .info
                    )
                }
                .buttonStyle(.plain)

                Button(action: { navigateToAssessments = true }) {
                    FuturisticStatCard(
                        title: "In-Progress Screens",
                        value: "\(assessments.filter { $0.status != "Completed" }.count)",
                        icon: "checklist",
                        level: .warning
                    )
                }
                .buttonStyle(.plain)

                FuturisticStatCard(
                    title: "Reviews Due (7d)",
                    value: "\(dueReviewCount)",
                    icon: "calendar.badge.exclamationmark",
                    level: .warning
                )

                FuturisticStatCard(
                    title: "Incidents (7d)",
                    value: "\(recentEvents.prefix(7).count)",
                    icon: "exclamationmark.triangle",
                    level: .risk
                )
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareLensSectionTitle(
                title: "Recent Monitoring",
                footnote: "Latest observations logged across your caseload"
            )

            if recentEvents.isEmpty {
                DiamondGlassCard(title: "No New Events", subtitle: "Monitoring activity will appear here", icon: "clock") {
                    EmptyView()
                }
            } else {
                ForEach(recentEvents.prefix(5), id: \.id) { event in
                    HStack(spacing: 12) {
                        Image(systemName: MonitoringEventType(rawValue: event.eventType)?.icon ?? "circle")
                            .foregroundStyle(CareLensTheme.Colors.accentAmber)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.eventType)
                                .font(.subheadline.bold())
                                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                            Text(event.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                        }
                        Spacer()
                        DiamondStatusChip(
                            text: event.severity,
                            level: event.severity == "High" || event.severity == "Critical" ? .risk : .warning
                        )
                    }
                    .clCard()
                }
            }
        }
    }

    private var dueReviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareLensSectionTitle(
                title: "Scheduled Reviews",
                footnote: "Follow-ups due in the next 7 days"
            )

            DiamondGlassCard(title: "Upcoming Reviews", subtitle: "Based on last assessment date + 1 month", icon: "calendar") {
                Text(dueReviewCount == 0 ? "No reviews due this week — great work." : "\(dueReviewCount) review(s) due soon")
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
            }
        }
    }

    private var dueReviewCount: Int {
        assessments.filter { assessment in
            guard let review = Calendar.current.date(byAdding: .month, value: 1, to: assessment.updatedAt) else { return false }
            return review <= Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
        }.count
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [CareLensTheme.Colors.goldLight, CareLensTheme.Colors.emeraldGreen],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 40, height: 40)
                    .background(CareLensTheme.Colors.surfaceDeep)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
            }
            .frame(width: 80)
            .padding(.vertical, 10)
            .background(CareLensTheme.Colors.surfaceElevated)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(CareLensTheme.Colors.goldPrimary.opacity(0.35), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FuturisticStatCard: View {
    let title: String
    let value: String
    let icon: String
    let level: DiamondStatusChip.RiskLevel

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(CareLensTheme.Gradients.iconGradient)

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(CareLensTheme.Colors.goldLight)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .clCard()
    }
}
