import SwiftUI

struct DifferentialInput {
    var onsetType: OnsetType = .gradual
    var progression: ProgressionType = .stable
    var moodSymptomsSeverity: Int = 0
    var anxietyLevel: Int = 0
    var attentionFluctuation: Bool = false
    var sleepDisturbance: Int = 0
    var recentMedicalChange: Bool = false
    var functionalDecline: Int = 0
    var appetiteChange: Bool = false
    var socialWithdrawal: Bool = false
    var disorganizedThinking: Bool = false
    var psychomotorChange: Bool = false

    enum OnsetType: String, CaseIterable {
        case acute = "Acute (hours/days)"
        case subacute = "Subacute (days/weeks)"
        case gradual = "Gradual (weeks/months)"
    }

    enum ProgressionType: String, CaseIterable {
        case fluctuating = "Fluctuating"
        case stable = "Stable"
        case progressive = "Progressive"
        case episodic = "Episodic"
    }
}

enum DifferentialPattern: String, CaseIterable {
    case depressionLikely = "Depression Pattern Likely"
    case anxietyLikely = "Anxiety Pattern Likely"
    case progressiveDecline = "Progressive Cognitive Decline Likely"
    case deliriumRedFlag = "Acute Delirium Red Flag"
    case mixedPresentation = "Mixed Presentation — Comprehensive Review Required"

    var icon: String {
        switch self {
        case .depressionLikely: return "cloud.rain"
        case .anxietyLikely: return "bolt.heart"
        case .progressiveDecline: return "brain.head.profile"
        case .deliriumRedFlag: return "exclamationmark.octagon.fill"
        case .mixedPresentation: return "questionmark.diamond"
        }
    }

    var color: Color {
        switch self {
        case .depressionLikely: return .indigo
        case .anxietyLikely: return .orange
        case .progressiveDecline: return CLTheme.warningOrange
        case .deliriumRedFlag: return CLTheme.alertRed
        case .mixedPresentation: return .purple
        }
    }

    var guidance: [String] {
        switch self {
        case .depressionLikely:
            return [
                "Screen with validated depression tool (e.g. GDS)",
                "Assess suicidal ideation and safety",
                "Consider psychosocial interventions (CBT, reminiscence)",
                "Review medications for depressive side effects",
                "Evaluate grief, loss, and isolation factors"
            ]
        case .anxietyLikely:
            return [
                "Identify specific triggers and avoidance patterns",
                "Assess physical symptoms (restlessness, GI, sleep)",
                "Consider relaxation training and graded exposure",
                "Review caffeine, medications, and pain",
                "Evaluate generalized vs situational anxiety"
            ]
        case .progressiveDecline:
            return [
                "Arrange comprehensive neuropsychological assessment",
                "Gather detailed collateral history from family/carers",
                "Assess safety: driving, finances, medication management",
                "Discuss advance care planning early",
                "Refer to geriatrician or neurologist",
                "Plan longitudinal monitoring with NeuroWatch"
            ]
        case .deliriumRedFlag:
            return [
                "URGENT: Immediate medical review required",
                "Check for infection, dehydration, constipation",
                "Review recent medication changes or toxicity",
                "Assess pain, sensory deprivation, environment",
                "Increase supervision and reorientation",
                "Document onset timing and fluctuation pattern"
            ]
        case .mixedPresentation:
            return [
                "Request multidisciplinary case review",
                "Obtain detailed collateral from multiple sources",
                "Consider serial assessments over 2-4 weeks",
                "Rule out delirium first (reversible causes)",
                "Assess contribution of each suspected condition",
                "Avoid premature diagnostic labelling"
            ]
        }
    }
}

struct DifferentialView: View {
    let client: ClientProfile
    @State private var input = DifferentialInput()
    @State private var result: DifferentialPattern?

    var body: some View {
        ScrollView {
            VStack(spacing: CLTheme.sectionSpacing) {
                headerSection
                inputSection
                if let result = result {
                    resultSection(result)
                }
            }
            .padding()
        }
        .navigationTitle("Differential Screen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Button("Analyse Pattern") { analyse() }
                        .buttonStyle(.borderedProminent)
                        .tint(CLTheme.accentTeal)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Differential Assessment")
                .font(.title3.bold())
            Text("Compares symptom patterns to differentiate depression, anxiety, progressive cognitive decline, and delirium. This is a clinical decision-support tool, not a diagnostic instrument.")
                .font(.caption)
                .foregroundStyle(CLTheme.textSecondary)
        }
        .clCard()
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Symptom Profile")

            VStack(alignment: .leading, spacing: 6) {
                Text("Onset").font(.subheadline.bold())
                Picker("Onset", selection: $input.onsetType) {
                    ForEach(DifferentialInput.OnsetType.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Progression").font(.subheadline.bold())
                Picker("Progression", selection: $input.progression) {
                    ForEach(DifferentialInput.ProgressionType.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }

            StepperRow(label: "Mood Symptoms (0-3)", value: $input.moodSymptomsSeverity, range: 0...3)
            StepperRow(label: "Anxiety Level (0-3)", value: $input.anxietyLevel, range: 0...3)
            StepperRow(label: "Sleep Disturbance (0-3)", value: $input.sleepDisturbance, range: 0...3)
            StepperRow(label: "Functional Decline (0-3)", value: $input.functionalDecline, range: 0...3)

            Toggle("Attention Fluctuation", isOn: $input.attentionFluctuation)
            Toggle("Recent Medical/Medication Change", isOn: $input.recentMedicalChange)
            Toggle("Appetite Change", isOn: $input.appetiteChange)
            Toggle("Social Withdrawal", isOn: $input.socialWithdrawal)
            Toggle("Disorganized Thinking", isOn: $input.disorganizedThinking)
            Toggle("Psychomotor Change", isOn: $input.psychomotorChange)
        }
        .clCard()
    }

    private func resultSection(_ pattern: DifferentialPattern) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Pattern Analysis")

            HStack {
                Image(systemName: pattern.icon)
                    .font(.title2)
                    .foregroundStyle(pattern.color)
                Text(pattern.rawValue)
                    .font(.headline)
                    .foregroundStyle(pattern.color)
            }

            Divider()

            Text("Clinical Guidance")
                .font(.subheadline.bold())
            ForEach(pattern.guidance, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundStyle(pattern.color)
                        .font(.caption)
                        .padding(.top, 3)
                    Text(item).font(.subheadline)
                }
            }

            if pattern == .deliriumRedFlag {
                HStack {
                    Image(systemName: "exclamationmark.octagon.fill")
                        .foregroundStyle(.white)
                    Text("URGENT: Requires immediate medical assessment")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(CLTheme.alertRed)
                .cornerRadius(10)
            }
        }
        .clCard()
    }

    private func analyse() {
        withAnimation {
            result = evaluateDifferential(input)
        }
    }

    private func evaluateDifferential(_ input: DifferentialInput) -> DifferentialPattern {
        if input.onsetType == .acute && (input.attentionFluctuation || input.recentMedicalChange) && input.disorganizedThinking {
            return .deliriumRedFlag
        }

        if input.attentionFluctuation && input.recentMedicalChange {
            return .deliriumRedFlag
        }

        var depressionScore = 0
        var anxietyScore = 0
        var declineScore = 0

        depressionScore += input.moodSymptomsSeverity * 3
        depressionScore += input.sleepDisturbance * 2
        depressionScore += input.appetiteChange ? 3 : 0
        depressionScore += input.socialWithdrawal ? 3 : 0
        depressionScore += input.psychomotorChange ? 2 : 0

        anxietyScore += input.anxietyLevel * 3
        anxietyScore += input.sleepDisturbance
        anxietyScore += input.psychomotorChange ? 2 : 0

        declineScore += input.functionalDecline * 3
        declineScore += (input.progression == .progressive) ? 5 : 0
        declineScore += (input.onsetType == .gradual) ? 3 : 0

        let maxScore = max(depressionScore, anxietyScore, declineScore)
        let scores = [depressionScore, anxietyScore, declineScore]
        let closeCount = scores.filter { maxScore - $0 < 3 }.count

        if closeCount >= 2 && maxScore > 5 {
            return .mixedPresentation
        }

        if maxScore == depressionScore && depressionScore > 5 {
            return .depressionLikely
        } else if maxScore == anxietyScore && anxietyScore > 5 {
            return .anxietyLikely
        } else if maxScore == declineScore && declineScore > 5 {
            return .progressiveDecline
        }

        return .mixedPresentation
    }
}
