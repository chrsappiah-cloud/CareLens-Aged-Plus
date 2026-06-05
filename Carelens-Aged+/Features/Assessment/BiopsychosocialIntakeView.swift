import SwiftData
import SwiftUI

struct BiopsychosocialIntakeView: View {
    let client: ClientProfile
    let moduleName: String
    @Environment(\.modelContext) private var modelContext
    @State private var currentSection = 0
    @State private var notes: [String: String] = [:]
    @State private var ratings: [String: Double] = [:]

    private var sections: [(title: String, fields: [FormField])] {
        switch moduleName {
        case "Biopsychosocial Intake":
            return biopsychosocialSections
        case "Mood, Anxiety & Delirium":
            return moodAnxietySections
        case "Function & Safety":
            return functionSafetySections
        case "Spiritual Assessment":
            return spiritualSections
        case "Advance Care Planning":
            return acpSections
        case "Support Systems & Caregiving":
            return caregivingSections
        case "Income, Insurance & Services":
            return incomeSections
        case "Intervention Review":
            return interventionSections
        default:
            return biopsychosocialSections
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CLTheme.spacing) {
                progressBar
                    .frame(height: 4)

                if currentSection < sections.count {
                    let section = sections[currentSection]
                    Text(section.title)
                        .font(.title3.bold())
                        .foregroundStyle(CareLensTheme.Colors.textPrimary)
                        .padding(.top)

                    ForEach(section.fields, id: \.label) { field in
                        fieldView(for: field)
                    }
                }

                if currentSection == sections.count - 1 {
                    clinicalReferencesForModule
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .background(Color.clear)
        .navigationTitle(moduleName)
        .navigationBarTitleDisplayMode(.inline)
        .careLensDarkChrome()
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                Rectangle()
                    .fill(CareLensTheme.Gradients.primaryButton)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 4)
    }

    private var progress: CGFloat {
        guard !sections.isEmpty else { return 0 }
        return CGFloat(currentSection + 1) / CGFloat(sections.count)
    }

    private var bottomBar: some View {
        HStack {
            Button("Save Draft") { saveDraft() }
                .buttonStyle(DiamondSecondaryButtonStyle())

            Spacer()

            if currentSection > 0 {
                Button("Back") {
                    withAnimation { currentSection -= 1 }
                }
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }

            if currentSection < sections.count - 1 {
                Button(action: { withAnimation { currentSection += 1 } }) {
                    HStack { Text("Next"); Image(systemName: "arrow.right") }
                }
                .buttonStyle(DiamondButtonStyle())
                .frame(minHeight: 50)
                .accessibilityIdentifier("button.next")
            } else {
                Button(action: { completeAssessment() }) {
                    HStack { Image(systemName: "checkmark"); Text("Complete") }
                }
                .buttonStyle(DiamondButtonStyle())
                .frame(minHeight: 50)
                .accessibilityIdentifier("button.complete")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func fieldView(for field: FormField) -> some View {
        switch field.type {
        case .text:
            VStack(alignment: .leading, spacing: 4) {
                Text(field.label).font(.subheadline.bold())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                TextField(field.placeholder, text: binding(for: field.label))
                    .textFieldStyle(.roundedBorder)
            }
        case .multiline:
            VStack(alignment: .leading, spacing: 4) {
                Text(field.label).font(.subheadline.bold())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                TextEditor(text: binding(for: field.label))
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color.white.opacity(0.05))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.15)))
            }
        case .rating:
            VStack(alignment: .leading, spacing: 4) {
                Text(field.label).font(.subheadline.bold())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                HStack {
                    ForEach(0..<5) { i in
                        Button(action: { ratings[field.label] = Double(i + 1) }) {
                            DiamondShape()
                                .fill((ratings[field.label] ?? 0) > Double(i)
                                      ? CareLensTheme.Colors.accentMint
                                      : Color.white.opacity(0.2))
                                .frame(width: 20, height: 20)
                                .shadow(color: (ratings[field.label] ?? 0) > Double(i)
                                        ? CareLensTheme.Colors.accentMint.opacity(0.5)
                                        : .clear, radius: 4)
                        }
                        .frame(minWidth: CareLensTheme.minTouchTarget, minHeight: CareLensTheme.minTouchTarget)
                    }
                    Text("\(Int(ratings[field.label] ?? 0))/5")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textTertiary)
                }
            }
        case .toggle:
            Toggle(field.label, isOn: .constant(false))
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                .tint(CareLensTheme.Colors.accentMint)
        }
    }

    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { notes[key] ?? "" },
            set: { notes[key] = $0 }
        )
    }

    private func saveDraft() {
        let assessment = AssessmentSession(
            clientID: client.id,
            assessmentType: moduleName,
            status: "Draft",
            assessorRole: "Social Worker"
        )
        modelContext.insert(assessment)
    }

    @ViewBuilder
    private var clinicalReferencesForModule: some View {
        switch moduleName {
        case "Function & Safety":
            ClinicalReferencesView.functionSafety()
        case "Biopsychosocial Intake", "Mood, Anxiety & Delirium",
             "Spiritual Assessment", "Advance Care Planning",
             "Support Systems & Caregiving", "Income, Insurance & Services",
             "Intervention Review":
            ClinicalReferencesView.biopsychosocial()
        default:
            ClinicalReferencesView.biopsychosocial()
        }
    }

    private func completeAssessment() {
        let assessment = AssessmentSession(
            clientID: client.id,
            assessmentType: moduleName,
            status: "Completed",
            assessorRole: "Social Worker"
        )
        modelContext.insert(assessment)
    }

    // MARK: - Section Definitions

    private var biopsychosocialSections: [(title: String, fields: [FormField])] {
        [
            ("Presenting Concerns", [
                FormField(label: "Referral Origin", type: .text, placeholder: "Source of referral"),
                FormField(label: "Presenting Concerns", type: .multiline, placeholder: "Primary reasons for assessment"),
            ]),
            ("Physical Health", [
                FormField(label: "Chronic Conditions", type: .multiline, placeholder: "List chronic conditions"),
                FormField(label: "Sensory Issues", type: .text, placeholder: "Vision, hearing, etc."),
                FormField(label: "Continence", type: .text, placeholder: "Continence status"),
                FormField(label: "Medication Profile", type: .multiline, placeholder: "Current medications"),
                FormField(label: "Mobility & Falls", type: .text, placeholder: "Mobility level, recent falls"),
            ]),
            ("ADLs & IADLs", [
                FormField(label: "Bathing & Dressing", type: .rating, placeholder: ""),
                FormField(label: "Transfers & Toileting", type: .rating, placeholder: ""),
                FormField(label: "Meal Preparation", type: .rating, placeholder: ""),
                FormField(label: "Medication Management", type: .rating, placeholder: ""),
                FormField(label: "Transport & Shopping", type: .rating, placeholder: ""),
                FormField(label: "Financial Management", type: .rating, placeholder: ""),
            ]),
            ("Emotional Well-being", [
                FormField(label: "Mood Symptoms", type: .multiline, placeholder: "Describe mood"),
                FormField(label: "Anxiety Indicators", type: .multiline, placeholder: "Anxiety signs"),
                FormField(label: "Sleep Quality", type: .rating, placeholder: ""),
                FormField(label: "Grief & Loss", type: .multiline, placeholder: ""),
                FormField(label: "Protective Factors", type: .multiline, placeholder: "Strengths and resilience"),
            ]),
            ("Social Functioning", [
                FormField(label: "Network Strength", type: .rating, placeholder: ""),
                FormField(label: "Frequency of Contact", type: .text, placeholder: ""),
                FormField(label: "Community Participation", type: .multiline, placeholder: ""),
                FormField(label: "Formal Services", type: .multiline, placeholder: "Current services"),
            ]),
            ("Environment & Capacity", [
                FormField(label: "Home Hazards", type: .multiline, placeholder: "Environmental risks"),
                FormField(label: "Transport Access", type: .text, placeholder: ""),
                FormField(label: "Supervision Needs", type: .text, placeholder: ""),
                FormField(label: "Decision-Making Capacity", type: .multiline, placeholder: "Capacity for medications, finances, healthcare, residence"),
            ])
        ]
    }

    private var moodAnxietySections: [(title: String, fields: [FormField])] {
        [
            ("Mood Assessment", [
                FormField(label: "Depressive Symptoms", type: .rating, placeholder: ""),
                FormField(label: "Duration of Low Mood", type: .text, placeholder: ""),
                FormField(label: "Sleep Disturbance", type: .rating, placeholder: ""),
                FormField(label: "Appetite Change", type: .text, placeholder: ""),
                FormField(label: "Suicidal Ideation", type: .toggle, placeholder: ""),
            ]),
            ("Anxiety Screen", [
                FormField(label: "Anxiety Level", type: .rating, placeholder: ""),
                FormField(label: "Triggers", type: .multiline, placeholder: ""),
                FormField(label: "Physical Symptoms", type: .multiline, placeholder: ""),
            ]),
            ("Delirium Indicators", [
                FormField(label: "Acute Onset", type: .toggle, placeholder: ""),
                FormField(label: "Attention Fluctuation", type: .toggle, placeholder: ""),
                FormField(label: "Recent Medical Change", type: .multiline, placeholder: ""),
                FormField(label: "Disorganized Thinking", type: .toggle, placeholder: ""),
            ])
        ]
    }

    private var functionSafetySections: [(title: String, fields: [FormField])] {
        [
            ("Mobility & Falls", [
                FormField(label: "Mobility Level", type: .rating, placeholder: ""),
                FormField(label: "Falls History (last 6 months)", type: .text, placeholder: ""),
                FormField(label: "Wandering Risk", type: .rating, placeholder: ""),
            ]),
            ("Safety", [
                FormField(label: "Environmental Hazards", type: .multiline, placeholder: ""),
                FormField(label: "Abuse/Neglect Concerns", type: .multiline, placeholder: ""),
                FormField(label: "Emergency Contacts Ready", type: .toggle, placeholder: ""),
                FormField(label: "Driving/Transport Issues", type: .text, placeholder: ""),
            ])
        ]
    }

    private var spiritualSections: [(title: String, fields: [FormField])] {
        [
            ("Meaning & Hope", [
                FormField(label: "Sources of Meaning", type: .multiline, placeholder: ""),
                FormField(label: "Hope & Resilience", type: .multiline, placeholder: ""),
                FormField(label: "Legacy & Life Review", type: .multiline, placeholder: ""),
            ]),
            ("Faith & Practice", [
                FormField(label: "Faith/Spiritual Identity", type: .text, placeholder: ""),
                FormField(label: "Desired Practices", type: .multiline, placeholder: ""),
                FormField(label: "Clergy/Community Involvement", type: .text, placeholder: ""),
            ]),
            ("Spiritual Distress", [
                FormField(label: "Distress Level", type: .rating, placeholder: ""),
                FormField(label: "Guilt, Fear, Conflict", type: .multiline, placeholder: ""),
                FormField(label: "Preferences for End-of-Life Support", type: .multiline, placeholder: ""),
            ])
        ]
    }

    private var acpSections: [(title: String, fields: [FormField])] {
        [
            ("Advance Directives", [
                FormField(label: "Capacity Snapshot", type: .multiline, placeholder: ""),
                FormField(label: "Advance Directive Status", type: .text, placeholder: ""),
                FormField(label: "Health Proxy/SDM", type: .text, placeholder: ""),
                FormField(label: "Resuscitation Preferences", type: .text, placeholder: ""),
                FormField(label: "Hospital Transfer Preferences", type: .text, placeholder: ""),
            ]),
            ("End-of-Life Preferences", [
                FormField(label: "Preferred Place of Care", type: .text, placeholder: ""),
                FormField(label: "Preferred Place of Death", type: .text, placeholder: ""),
                FormField(label: "Cultural/Spiritual EOL Wishes", type: .multiline, placeholder: ""),
                FormField(label: "Family Meeting Notes", type: .multiline, placeholder: ""),
                FormField(label: "Anticipatory Grief", type: .multiline, placeholder: ""),
            ])
        ]
    }

    private var caregivingSections: [(title: String, fields: [FormField])] {
        [
            ("Support Systems", [
                FormField(label: "Primary Carer", type: .text, placeholder: ""),
                FormField(label: "Secondary Carers", type: .multiline, placeholder: ""),
                FormField(label: "Caregiver Burden", type: .rating, placeholder: ""),
                FormField(label: "Depression Risk in Carer", type: .rating, placeholder: ""),
            ]),
            ("Family Dynamics", [
                FormField(label: "Family Conflict", type: .multiline, placeholder: ""),
                FormField(label: "Communication Gaps", type: .multiline, placeholder: ""),
                FormField(label: "Respite Needs", type: .rating, placeholder: ""),
                FormField(label: "Strengths in Caregiving", type: .multiline, placeholder: ""),
            ])
        ]
    }

    private var incomeSections: [(title: String, fields: [FormField])] {
        [
            ("Financial Resources", [
                FormField(label: "Income Sources", type: .multiline, placeholder: ""),
                FormField(label: "Pension/Retirement Benefits", type: .text, placeholder: ""),
                FormField(label: "Government Support", type: .text, placeholder: ""),
                FormField(label: "Insurance Status", type: .text, placeholder: ""),
                FormField(label: "Medication Affordability", type: .rating, placeholder: ""),
            ]),
            ("Housing & Services", [
                FormField(label: "Housing Type & Risk", type: .text, placeholder: ""),
                FormField(label: "Transport Access", type: .text, placeholder: ""),
                FormField(label: "Current Community Services", type: .multiline, placeholder: ""),
                FormField(label: "Unmet Needs", type: .multiline, placeholder: ""),
            ])
        ]
    }

    private var interventionSections: [(title: String, fields: [FormField])] {
        [
            ("Intervention Planning", [
                FormField(label: "Immediate Safety Actions", type: .multiline, placeholder: ""),
                FormField(label: "Psychosocial Interventions", type: .multiline, placeholder: "CBT, reminiscence, life review, group work, validation"),
                FormField(label: "Medical Review/Referral", type: .multiline, placeholder: ""),
                FormField(label: "Support System Activation", type: .multiline, placeholder: ""),
                FormField(label: "Environmental Modifications", type: .multiline, placeholder: ""),
                FormField(label: "ACP/Directive Actions", type: .multiline, placeholder: ""),
                FormField(label: "Spiritual Support Actions", type: .multiline, placeholder: ""),
                FormField(label: "Service Access & Benefits", type: .multiline, placeholder: ""),
            ])
        ]
    }
}

struct FormField {
    let label: String
    let type: FormFieldType
    let placeholder: String

    enum FormFieldType {
        case text, multiline, rating, toggle
    }
}
