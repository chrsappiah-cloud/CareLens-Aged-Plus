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
                    quickActionsBar
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
                QuickActionButton(title: "New Intake", icon: "person.badge.plus", action: {})
                QuickActionButton(title: "Start Assessment", icon: "checklist", action: { navigateToAssessments = true })
                QuickActionButton(title: "View Clients", icon: "person.2", action: { navigateToClients = true })
                QuickActionButton(title: "Generate Report", icon: "doc.text", action: {})
                QuickActionButton(title: "Log Incident", icon: "exclamationmark.triangle", action: {})
            }
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
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                Button(action: { navigateToClients = true }) {
                    FuturisticStatCard(
                        title: "Total Clients",
                        value: "\(clients.count)",
                        icon: "person.2.fill",
                        level: .info
                    )
                }
                .buttonStyle(.plain)

                Button(action: { navigateToAssessments = true }) {
                    FuturisticStatCard(
                        title: "Active Assessments",
                        value: "\(assessments.filter { $0.status != "Completed" }.count)",
                        icon: "checklist",
                        level: .warning
                    )
                }
                .buttonStyle(.plain)

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
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
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
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
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
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 80)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.03))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
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
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.40, green: 0.45, blue: 0.92),
                            Color(red: 0.65, green: 0.40, blue: 0.82),
                            Color(red: 0.72, green: 0.52, blue: 0.35)
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
