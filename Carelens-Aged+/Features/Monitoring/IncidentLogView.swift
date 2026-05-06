import SwiftUI
import SwiftData

struct IncidentLogView: View {
    let client: ClientProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var eventType: MonitoringEventType = .fall
    @State private var severity: SeverityLevel = .moderate
    @State private var notes = ""
    @State private var reportedBy = ""
    @State private var cognitionScore: Double = 0
    @State private var adlScore: Double = 0
    @State private var caregiverStress: Double = 0
    @State private var medicationAdherence: Double = 100

    enum SeverityLevel: String, CaseIterable {
        case low = "Low"
        case moderate = "Moderate"
        case high = "High"
        case critical = "Critical"

        var color: Color {
            switch self {
            case .low: return CLTheme.successGreen
            case .moderate: return CLTheme.warningOrange
            case .high: return .orange
            case .critical: return CLTheme.alertRed
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    Picker("Event Type", selection: $eventType) {
                        ForEach(MonitoringEventType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon).tag(type)
                        }
                    }

                    Picker("Severity", selection: $severity) {
                        ForEach(SeverityLevel.allCases, id: \.self) { level in
                            HStack {
                                Circle().fill(level.color).frame(width: 10, height: 10)
                                Text(level.rawValue)
                            }.tag(level)
                        }
                    }

                    TextField("Reported By", text: $reportedBy)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                Section("Associated Scores (Optional)") {
                    HStack {
                        Text("Cognition")
                        Spacer()
                        Slider(value: $cognitionScore, in: 0...30, step: 1)
                            .frame(width: 150)
                        Text("\(Int(cognitionScore))")
                            .font(.caption.monospacedDigit())
                            .frame(width: 30)
                    }

                    HStack {
                        Text("ADL Function")
                        Spacer()
                        Slider(value: $adlScore, in: 0...100, step: 5)
                            .frame(width: 150)
                        Text("\(Int(adlScore))%")
                            .font(.caption.monospacedDigit())
                            .frame(width: 40)
                    }

                    HStack {
                        Text("Carer Stress")
                        Spacer()
                        Slider(value: $caregiverStress, in: 0...10, step: 1)
                            .frame(width: 150)
                        Text("\(Int(caregiverStress))/10")
                            .font(.caption.monospacedDigit())
                            .frame(width: 40)
                    }

                    HStack {
                        Text("Medication Adherence")
                        Spacer()
                        Slider(value: $medicationAdherence, in: 0...100, step: 5)
                            .frame(width: 150)
                        Text("\(Int(medicationAdherence))%")
                            .font(.caption.monospacedDigit())
                            .frame(width: 40)
                    }
                }
            }
            .navigationTitle("Log Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEvent() }
                        .bold()
                }
            }
        }
    }

    private func saveEvent() {
        let event = MonitoringEvent(
            clientID: client.id,
            eventType: eventType.rawValue,
            severity: severity.rawValue,
            notes: notes,
            reportedBy: reportedBy
        )
        event.cognitionScore = cognitionScore > 0 ? cognitionScore : nil
        event.adlScore = adlScore > 0 ? adlScore : nil
        event.caregiverStress = caregiverStress > 0 ? caregiverStress : nil
        event.medicationAdherence = medicationAdherence < 100 ? medicationAdherence : nil

        modelContext.insert(event)
        client.monitoringEvents.append(event)
        dismiss()
    }
}
