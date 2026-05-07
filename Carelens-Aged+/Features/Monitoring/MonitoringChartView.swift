import SwiftUI
import SwiftData
import Charts

struct MonitoringChartView: View {
    let client: ClientProfile

    @State private var selectedMetric: MonitoringMetric = .cognition
    @State private var showingIncidentLog = false
    @State private var showingCollateralReport = false

    enum MonitoringMetric: String, CaseIterable {
        case cognition = "Cognition"
        case adlFunction = "ADL Function"
        case caregiverStress = "Carer Stress"
        case incidents = "Incidents"
        case medication = "Medication"

        var icon: String {
            switch self {
            case .cognition: return "brain.head.profile"
            case .adlFunction: return "figure.walk"
            case .caregiverStress: return "heart.text.square"
            case .incidents: return "exclamationmark.triangle"
            case .medication: return "pills"
            }
        }

        var color: Color {
            switch self {
            case .cognition: return CLTheme.accentTeal
            case .adlFunction: return .blue
            case .caregiverStress: return .purple
            case .incidents: return CLTheme.warningOrange
            case .medication: return CLTheme.successGreen
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CareLensTheme.sectionSpacing) {
                metricPicker
                chartSection
                trendSummary
                recentEventsSection
                actionsSection
            }
            .padding()
        }
        .background(Color.clear)
        .navigationTitle("Monitoring")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showingIncidentLog) {
            IncidentLogView(client: client)
        }
        .sheet(isPresented: $showingCollateralReport) {
            CollateralReportView(client: client)
        }
    }

    private var metricPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MonitoringMetric.allCases, id: \.self) { metric in
                    Button(action: { selectedMetric = metric }) {
                        VStack(spacing: 4) {
                            Image(systemName: metric.icon)
                                .font(.body)
                            Text(metric.rawValue)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedMetric == metric ? metric.color.opacity(0.15) : Color.white.opacity(0.06))
                        .foregroundStyle(selectedMetric == metric ? metric.color : CareLensTheme.Colors.textSecondary)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedMetric == metric ? metric.color : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(selectedMetric.rawValue) Over Time")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            let data = chartData(for: selectedMetric)
            if data.isEmpty {
                Text("No monitoring data yet. Log events to see trends.")
                    .font(.subheadline)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.score)
                    )
                    .foregroundStyle(selectedMetric.color)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.score)
                    )
                    .foregroundStyle(selectedMetric.color.opacity(0.1))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.score)
                    )
                    .foregroundStyle(selectedMetric.color)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .clCard()
    }

    private var trendSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trend Summary")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            let events = client.monitoringEvents
            let last30 = events.filter { $0.timestamp > Calendar.current.date(byAdding: .day, value: -30, to: .now)! }
            let last90 = events.filter { $0.timestamp > Calendar.current.date(byAdding: .day, value: -90, to: .now)! }

            HStack(spacing: 16) {
                TrendStat(label: "30-day events", value: "\(last30.count)", color: CLTheme.accentTeal)
                TrendStat(label: "90-day events", value: "\(last90.count)", color: CLTheme.warningOrange)
                TrendStat(label: "Total events", value: "\(events.count)", color: CLTheme.primaryNavy)
            }
        }
        .clCard()
    }

    private var recentEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Events")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.35, green: 0.40, blue: 0.88), Color(red: 0.60, green: 0.35, blue: 0.80), Color(red: 0.72, green: 0.50, blue: 0.32)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            let sortedEvents = client.monitoringEvents.sorted { $0.timestamp > $1.timestamp }
            if sortedEvents.isEmpty {
                Text("No events recorded")
                    .font(.subheadline)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
            } else {
                ForEach(sortedEvents.prefix(5), id: \.id) { event in
                    HStack(spacing: 12) {
                        Image(systemName: MonitoringEventType(rawValue: event.eventType)?.icon ?? "circle")
                            .foregroundStyle(CareLensTheme.Colors.accentAmber)
                            .frame(width: 28)
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
                }
            }
        }
        .clCard()
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showingIncidentLog = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Log New Incident")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(DiamondButtonStyle())

            Button(action: { showingCollateralReport = true }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Add Collateral Report")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(DiamondSecondaryButtonStyle())
        }
    }

    // MARK: - Data

    private func chartData(for metric: MonitoringMetric) -> [CognitionDataPoint] {
        let events = client.monitoringEvents.sorted { $0.timestamp < $1.timestamp }
        switch metric {
        case .cognition:
            return events.compactMap { e in
                e.cognitionScore.map { CognitionDataPoint(date: e.timestamp, score: $0) }
            }
        case .adlFunction:
            return events.compactMap { e in
                e.adlScore.map { CognitionDataPoint(date: e.timestamp, score: $0) }
            }
        case .caregiverStress:
            return events.compactMap { e in
                e.caregiverStress.map { CognitionDataPoint(date: e.timestamp, score: $0) }
            }
        case .medication:
            return events.compactMap { e in
                e.medicationAdherence.map { CognitionDataPoint(date: e.timestamp, score: $0) }
            }
        case .incidents:
            let grouped = Dictionary(grouping: events) { event in
                Calendar.current.startOfDay(for: event.timestamp)
            }
            return grouped.map { CognitionDataPoint(date: $0.key, score: Double($0.value.count)) }
                .sorted { $0.date < $1.date }
        }
    }

    private func severityColor(_ severity: String) -> Color {
        switch severity {
        case "Low": return CLTheme.successGreen
        case "Moderate": return CLTheme.warningOrange
        case "High": return .orange
        case "Critical": return CLTheme.alertRed
        default: return .gray
        }
    }
}

struct TrendStat: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
