import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var clients: [ClientProfile]
    @Query(sort: \AssessmentSession.updatedAt, order: .reverse) private var assessments: [AssessmentSession]
    @Query(sort: \MonitoringEvent.timestamp, order: .reverse) private var recentEvents: [MonitoringEvent]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CareLensTheme.sectionSpacing) {
                    alertsSection
                    caseloadOverview
                    recentActivitySection
                    dueReviewsSection
                }
                .padding()
            }
            .background(Color.clear)
            .navigationTitle("Dashboard")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(CareLensTheme.Colors.riskRed)
                Text("Alerts")
                    .font(.headline)
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
            }

            let urgentAssessments = assessments.filter { $0.status == "Urgent" }
            if urgentAssessments.isEmpty {
                DiamondGlassCard(title: "All Clear", subtitle: "No urgent items", icon: "checkmark.circle.fill") {
                    DiamondStatusChip(text: "Stable", level: .safe)
                }
            } else {
                ForEach(urgentAssessments, id: \.id) { assessment in
                    DiamondGlassCard(title: assessment.type, subtitle: "Client: \(assessment.clientID)", icon: "exclamationmark.circle.fill") {
                        DiamondStatusChip(text: "Urgent", level: .risk)
                    }
                }
            }
        }
    }

    private var caseloadOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Caseload Overview")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.4, green: 0.85, blue: 0.9), Color(red: 0.3, green: 0.65, blue: 0.95)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                FuturisticStatCard(
                    title: "Total Clients",
                    value: "\(clients.count)",
                    icon: "person.2.fill",
                    level: .info
                )
                FuturisticStatCard(
                    title: "Active Assessments",
                    value: "\(assessments.filter { $0.status != "Completed" }.count)",
                    icon: "checklist",
                    level: .warning
                )
                FuturisticStatCard(
                    title: "Due Reviews",
                    value: "\(dueReviewCount)",
                    icon: "calendar.badge.exclamationmark",
                    level: .warning
                )
                FuturisticStatCard(
                    title: "Recent Incidents",
                    value: "\(recentEvents.prefix(7).count)",
                    icon: "exclamationmark.triangle",
                    level: .risk
                )
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.4, green: 0.85, blue: 0.9), Color(red: 0.3, green: 0.65, blue: 0.95)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            if recentEvents.isEmpty {
                DiamondGlassCard(title: "No Events", subtitle: "No recent monitoring events", icon: "clock") {
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
            Text("Due for Review")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.4, green: 0.85, blue: 0.9), Color(red: 0.3, green: 0.65, blue: 0.95)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            DiamondGlassCard(title: "Upcoming Reviews", subtitle: "Reviews scheduled within 7 days", icon: "calendar") {
                Text("No reviews due this week")
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
            }
        }
    }

    private var dueReviewCount: Int { 0 }
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
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.95, blue: 0.9),
                            Color(red: 0.3, green: 0.7, blue: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(title)
                .font(.caption)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .clCard()
    }
}
