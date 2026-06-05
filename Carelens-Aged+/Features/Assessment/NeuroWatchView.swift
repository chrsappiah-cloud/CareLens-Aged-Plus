import SwiftUI
import SwiftData
import Charts

struct NeuroWatchView: View {
    let client: ClientProfile
    @Environment(\.modelContext) private var modelContext

    @State private var input = NeuroWatchInput()
    @State private var result: NeuroWatchResult?

    var body: some View {
        ScrollView {
            VStack(spacing: CareLensTheme.sectionSpacing) {
                headerSection
                inputSection
                if let result = result {
                    resultSection(result)
                }
                monitoringChartSection
                referencesSection
            }
            .padding()
        }
        .background(Color.clear)
        .navigationTitle("NeuroWatch")
        .navigationBarTitleDisplayMode(.inline)
        .careLensDarkChrome()
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button("Save Draft") { saveDraft() }
                    .buttonStyle(DiamondSecondaryButtonStyle())
                    .frame(minHeight: 50)
                Spacer()
                Button(action: { evaluate() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Evaluate")
                    }
                }
                .buttonStyle(DiamondButtonStyle())
                .frame(minHeight: 50)
                .accessibilityIdentifier("button.evaluate")
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .overlay(Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1), alignment: .top)
        }
    }

    private var headerSection: some View {
        DiamondGlassCard(
            title: "NeuroWatch Early Change Index",
            subtitle: "Screening tool to detect early cognitive change patterns. This is a monitoring indicator, not a diagnostic tool.",
            icon: "brain.head.profile"
        ) {
            DiamondStatusChip(text: "Screening Mode", level: .info)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Screening Inputs")

            StepperRow(label: "Orientation Errors (0-3)", value: $input.orientationErrors, range: 0...3)
            StepperRow(label: "Delayed Recall Score (0-5)", value: $input.delayedRecallScore, range: 0...5)
            StepperRow(label: "Clock/Sequencing Task (0-5)", value: $input.clockTaskScore, range: 0...5)
            StepperRow(label: "Category Fluency Count", value: $input.categoryFluencyCount, range: 0...30)
            StepperRow(label: "Medication Errors (0-5)", value: $input.medicationErrors, range: 0...5)

            Toggle("Attention Fluctuation Reported", isOn: $input.attentionFluctuation)
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                .tint(CareLensTheme.Colors.accentMint)
                .padding(.vertical, 4)

            StepperRow(label: "Family Concern Level (0-3)", value: $input.familyConcernLevel, range: 0...3)
            StepperRow(label: "Functional Decline Level (0-3)", value: $input.functionalDeclineLevel, range: 0...3)

            Toggle("Acute Medical Trigger", isOn: $input.acuteMedicalTrigger)
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                .tint(CareLensTheme.Colors.riskRed)
                .padding(.vertical, 4)
        }
        .clCard()
    }

    private func resultSection(_ result: NeuroWatchResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Screening Result")

            HStack {
                VStack(alignment: .leading) {
                    Text("Total Score")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    Text("\(result.totalScore)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.35, green: 0.40, blue: 0.90),
                                    Color(red: 0.58, green: 0.35, blue: 0.82),
                                    Color(red: 0.70, green: 0.50, blue: 0.30)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                Spacer()
                DiamondStatusChip(text: result.band.rawValue, level: bandLevel(result.band))
            }

            Divider().overlay(Color.white.opacity(0.1))

            Text("Suggested Action")
                .font(.subheadline.bold())
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
            Text(result.band.suggestedAction)
                .font(.body)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)

            Divider().overlay(Color.white.opacity(0.1))

            Text("Recommendations")
                .font(.subheadline.bold())
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
            ForEach(result.recommendations, id: \.self) { rec in
                HStack(alignment: .top, spacing: 8) {
                    DiamondShape()
                        .fill(CareLensTheme.Colors.accentMint)
                        .frame(width: 8, height: 8)
                        .padding(.top, 5)
                    Text(rec)
                        .font(.subheadline)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                }
            }

            if result.band == .urgentDeliriumRuleOut {
                HStack {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundStyle(.white)
                    Text("URGENT: Immediate medical review required")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CareLensTheme.Colors.riskRed)
                )
            }
        }
        .clCard()
    }

    private var referencesSection: some View {
        ClinicalReferencesView.neuroWatch()
    }

    private var monitoringChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Longitudinal Monitoring")

            let mockData = generateMockChartData()
            Chart(mockData) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(CareLensTheme.Colors.accentMint)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(CareLensTheme.Colors.accentMint.opacity(0.15))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Score", point.score)
                )
                .foregroundStyle(CareLensTheme.Colors.accentMint)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel().foregroundStyle(CareLensTheme.Colors.textTertiary)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.05))
                    AxisValueLabel().foregroundStyle(CareLensTheme.Colors.textTertiary)
                }
            }

            Text("Cognition score trend over time")
                .font(.caption)
                .foregroundStyle(CareLensTheme.Colors.textTertiary)
        }
        .clCard()
    }

    private func evaluate() {
        withAnimation {
            result = NeuroWatchEngine.evaluate(input)
        }
    }

    private func saveDraft() {
        let assessment = AssessmentSession(
            clientID: client.id,
            assessmentType: "Cognition & Dementia",
            status: "Draft",
            assessorRole: "Social Worker"
        )
        if let result = result {
            assessment.cognitionScore = Double(result.totalScore)
        }
        modelContext.insert(assessment)
    }

    private func bandLevel(_ band: NeuroWatchBand) -> DiamondStatusChip.RiskLevel {
        switch band {
        case .noSignificantChange: return .safe
        case .mildConcern: return .warning
        case .progressiveConcern: return .warning
        case .urgentDeliriumRuleOut: return .risk
        }
    }

    private func generateMockChartData() -> [CognitionDataPoint] {
        (0..<6).map { month in
            CognitionDataPoint(
                date: Calendar.current.date(byAdding: .month, value: -5 + month, to: .now)!,
                score: Double.random(in: 4...18)
            )
        }
    }
}

struct CognitionDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
}

struct StepperRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
            Spacer()
            HStack(spacing: 12) {
                Button(action: { if value > range.lowerBound { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(CareLensTheme.Colors.textTertiary)
                }
                .frame(minWidth: CareLensTheme.minTouchTarget, minHeight: CareLensTheme.minTouchTarget)

                Text("\(value)")
                    .font(.body.bold().monospacedDigit())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    .frame(width: 30)

                Button(action: { if value < range.upperBound { value += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }
                .frame(minWidth: CareLensTheme.minTouchTarget, minHeight: CareLensTheme.minTouchTarget)
            }
        }
    }
}
