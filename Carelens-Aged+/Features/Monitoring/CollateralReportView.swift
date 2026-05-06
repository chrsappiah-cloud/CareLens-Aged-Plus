import SwiftUI
import SwiftData

struct CollateralReportView: View {
    let client: ClientProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var reporterName = ""
    @State private var relationship = "Family Member"
    @State private var observedChanges = ""
    @State private var timeframe = "Last 2 weeks"
    @State private var memoryWorries = ""
    @State private var behaviourChanges = ""
    @State private var moodChanges = ""
    @State private var safetyWorries = ""
    @State private var dailyFunctionChanges = ""
    @State private var additionalNotes = ""
    @State private var concernLevel: Int = 1

    private let relationships = [
        "Spouse/Partner", "Son/Daughter", "Sibling",
        "Grandchild", "Friend", "Neighbour",
        "Paid Carer", "Other Family Member", "Other"
    ]

    private let timeframes = [
        "Last week", "Last 2 weeks", "Last month",
        "Last 3 months", "Last 6 months", "Gradual over a year+"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("About You") {
                    TextField("Your Name", text: $reporterName)
                    Picker("Relationship to Client", selection: $relationship) {
                        ForEach(relationships, id: \.self) { Text($0) }
                    }
                    Picker("When did you notice changes?", selection: $timeframe) {
                        ForEach(timeframes, id: \.self) { Text($0) }
                    }
                }

                Section("Overall Concern") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How worried are you? (1 = a little, 5 = very)")
                            .font(.subheadline)
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { level in
                                Button(action: { concernLevel = level }) {
                                    Circle()
                                        .fill(level <= concernLevel ? CLTheme.accentTeal : Color.gray.opacity(0.3))
                                        .frame(width: 36, height: 36)
                                        .overlay {
                                            Text("\(level)")
                                                .font(.subheadline.bold())
                                                .foregroundStyle(level <= concernLevel ? .white : CLTheme.textSecondary)
                                        }
                                }
                            }
                        }
                    }
                }

                Section("Memory & Thinking") {
                    TextEditor(text: $memoryWorries)
                        .frame(minHeight: 60)
                    Text("e.g. repeating questions, getting lost, forgetting appointments")
                        .font(.caption)
                        .foregroundStyle(CLTheme.textSecondary)
                }

                Section("Behaviour Changes") {
                    TextEditor(text: $behaviourChanges)
                        .frame(minHeight: 60)
                    Text("e.g. agitation, wandering, sleep changes, personality shifts")
                        .font(.caption)
                        .foregroundStyle(CLTheme.textSecondary)
                }

                Section("Mood Changes") {
                    TextEditor(text: $moodChanges)
                        .frame(minHeight: 60)
                    Text("e.g. sadness, anxiety, withdrawal, irritability")
                        .font(.caption)
                        .foregroundStyle(CLTheme.textSecondary)
                }

                Section("Daily Function") {
                    TextEditor(text: $dailyFunctionChanges)
                        .frame(minHeight: 60)
                    Text("e.g. difficulty cooking, managing money, personal care")
                        .font(.caption)
                        .foregroundStyle(CLTheme.textSecondary)
                }

                Section("Safety Concerns") {
                    TextEditor(text: $safetyWorries)
                        .frame(minHeight: 60)
                    Text("e.g. leaving stove on, falls, getting lost, driving concerns")
                        .font(.caption)
                        .foregroundStyle(CLTheme.textSecondary)
                }

                Section("Anything Else") {
                    TextEditor(text: $additionalNotes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Collateral Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") { saveReport() }
                        .disabled(reporterName.isEmpty)
                        .bold()
                }
            }
        }
    }

    private func saveReport() {
        let allNotes = """
        COLLATERAL REPORT
        Reporter: \(reporterName) (\(relationship))
        Timeframe: \(timeframe)
        Concern Level: \(concernLevel)/5
        
        MEMORY & THINKING: \(memoryWorries)
        BEHAVIOUR: \(behaviourChanges)
        MOOD: \(moodChanges)
        DAILY FUNCTION: \(dailyFunctionChanges)
        SAFETY: \(safetyWorries)
        ADDITIONAL: \(additionalNotes)
        """

        let event = MonitoringEvent(
            clientID: client.id,
            eventType: "Collateral Report",
            severity: concernLevel >= 4 ? "High" : (concernLevel >= 2 ? "Moderate" : "Low"),
            notes: allNotes,
            reportedBy: "\(reporterName) (\(relationship))"
        )
        modelContext.insert(event)
        client.monitoringEvents.append(event)
        dismiss()
    }
}
