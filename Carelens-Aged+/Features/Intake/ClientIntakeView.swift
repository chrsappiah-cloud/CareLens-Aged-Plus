import SwiftUI
import SwiftData

struct ClientIntakeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authService: AuthenticationService
    @State private var currentStep = 0
    @State private var showingConfirmation = false
    @State private var intakeComplete = false

    // Demographics
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var gender = "Female"
    @State private var preferredLanguage = "English"
    @State private var address = ""
    @State private var phoneNumber = ""
    @State private var emergencyContact = ""
    @State private var emergencyPhone = ""

    // Referral
    @State private var referralSource = ""
    @State private var referringPractitioner = ""
    @State private var referralReason = ""
    @State private var referralDate = Date()
    @State private var priorityLevel = "Routine"

    // Medical History
    @State private var primaryDiagnosis = ""
    @State private var comorbidities = ""
    @State private var currentMedications = ""
    @State private var allergies = ""
    @State private var recentHospitalisation = false
    @State private var hospitalisationDetails = ""

    // Functional Status
    @State private var mobilityLevel = "Independent"
    @State private var adlScore: Double = 0
    @State private var fallsHistory = false
    @State private var fallsDetails = ""
    @State private var cognitiveStatus = "Intact"
    @State private var visionHearing = ""

    // Psychosocial
    @State private var livingArrangement = "Lives at home alone"
    @State private var primaryCarer = ""
    @State private var socialSupports = ""
    @State private var culturalConsiderations = ""
    @State private var spiritualNeeds = ""
    @State private var moodScreening = "Normal"

    // Presenting Concerns
    @State private var presentingConcerns = ""
    @State private var clientGoals = ""
    @State private var strengthsIdentified = ""
    @State private var riskFactors = ""

    // Consent
    @State private var consentObtained = false
    @State private var consentDate = Date()
    @State private var advanceDirective = false
    @State private var healthProxy = ""

    private let steps = [
        "Demographics",
        "Referral",
        "Medical History",
        "Functional Status",
        "Psychosocial",
        "Presenting Concerns",
        "Consent & Safety"
    ]

    private let genderOptions = ["Female", "Male", "Non-binary", "Other", "Prefer not to say"]
    private let priorityOptions = ["Urgent", "High", "Routine", "Low"]
    private let mobilityOptions = ["Independent", "Uses aid", "Requires assistance", "Wheelchair", "Bed-bound"]
    private let cognitiveOptions = ["Intact", "Mild concerns", "Moderate impairment", "Severe impairment", "Untested"]
    private let moodOptions = ["Normal", "Low mood", "Anxious", "Agitated", "Withdrawn", "Requires assessment"]
    private let livingOptions = [
        "Lives at home alone", "Lives with spouse/partner", "Lives with family",
        "Residential aged care", "Supported independent living", "Boarding/shared"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator
                progressBar

                if intakeComplete {
                    completionView
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ScreenIntroHeader(
                                title: AppTab.admit.screenTitle,
                                subtitle: AppTab.admit.subtitle
                            )
                            stepContent
                        }
                        .padding()
                    }

                    navigationButtons
                }
            }
            .background(Color.clear)
            .navigationTitle(AppTab.admit.tabLabel)
            .navigationBarTitleDisplayMode(.inline)
            .careLensDarkChrome()
            .alert("Submit Intake?", isPresented: $showingConfirmation) {
                Button("Submit", role: .destructive) { submitIntake() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will create a new client profile and begin the assessment process.")
            }
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Button(action: { withAnimation { currentStep = index } }) {
                        HStack(spacing: 4) {
                            DiamondShape()
                                .fill(stepColor(for: index))
                                .frame(width: 8, height: 8)
                            if index == currentStep {
                                Text(steps[index])
                                    .font(.caption2.bold())
                                    .foregroundStyle(CareLensTheme.Colors.goldLight)
                            }
                        }
                        .padding(.horizontal, index == currentStep ? 10 : 6)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(
                                index == currentStep
                                    ? CareLensTheme.Colors.goldPrimary.opacity(0.2)
                                    : Color.white.opacity(0.04)
                            )
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                index == currentStep
                                    ? CareLensTheme.Colors.goldPrimary.opacity(0.5)
                                    : .clear,
                                lineWidth: 0.8
                            )
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func stepColor(for index: Int) -> LinearGradient {
        if index < currentStep {
            return LinearGradient(colors: [CareLensTheme.Colors.safeGreen, CareLensTheme.Colors.emeraldGreen], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if index == currentStep {
            return LinearGradient(colors: [CareLensTheme.Colors.goldPrimary, CareLensTheme.Colors.goldLight], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.white.opacity(0.08))
                Rectangle()
                    .fill(CareLensTheme.Gradients.goldGreen)
                    .frame(width: geo.size.width * CGFloat(currentStep + 1) / CGFloat(steps.count))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Content per Step

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0: demographicsSection
        case 1: referralSection
        case 2: medicalHistorySection
        case 3: functionalStatusSection
        case 4: psychosocialSection
        case 5: presentingConcernsSection
        case 6: consentSection
        default: EmptyView()
        }
    }

    // MARK: - Demographics

    private var demographicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Personal Details", icon: "person.fill")

            IntakeTextField(label: "First Name", text: $firstName)
            IntakeTextField(label: "Last Name", text: $lastName)

            VStack(alignment: .leading, spacing: 6) {
                Text("Date of Birth").font(.caption.bold()).foregroundStyle(CareLensTheme.Colors.textSecondary)
                DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(CareLensTheme.Colors.goldPrimary)
            }

            IntakePicker(label: "Gender", selection: $gender, options: genderOptions)
            IntakeTextField(label: "Preferred Language", text: $preferredLanguage)
            IntakeTextField(label: "Address", text: $address)
            IntakeTextField(label: "Phone Number", text: $phoneNumber, keyboard: .phonePad)

            sectionHeader("Emergency Contact", icon: "phone.fill")
            IntakeTextField(label: "Contact Name", text: $emergencyContact)
            IntakeTextField(label: "Contact Phone", text: $emergencyPhone, keyboard: .phonePad)
        }
    }

    // MARK: - Referral

    private var referralSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Referral Information", icon: "arrow.turn.right.down")

            IntakeTextField(label: "Referral Source", text: $referralSource, placeholder: "e.g. GP, Hospital, Self")
            IntakeTextField(label: "Referring Practitioner", text: $referringPractitioner)

            VStack(alignment: .leading, spacing: 6) {
                Text("Referral Date").font(.caption.bold()).foregroundStyle(CareLensTheme.Colors.textSecondary)
                DatePicker("", selection: $referralDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .tint(CareLensTheme.Colors.goldPrimary)
            }

            IntakePicker(label: "Priority Level", selection: $priorityLevel, options: priorityOptions)
            IntakeTextArea(label: "Reason for Referral", text: $referralReason, placeholder: "Describe the main reason for this assessment referral...")
        }
    }

    // MARK: - Medical History

    private var medicalHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Medical History", icon: "cross.case.fill")

            IntakeTextField(label: "Primary Diagnosis", text: $primaryDiagnosis)
            IntakeTextArea(label: "Comorbidities", text: $comorbidities, placeholder: "List significant conditions...")
            IntakeTextArea(label: "Current Medications", text: $currentMedications, placeholder: "Include dosages if known...")
            IntakeTextField(label: "Allergies", text: $allergies)

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $recentHospitalisation) {
                    Text("Recent Hospitalisation (past 3 months)")
                        .font(.subheadline)
                        .foregroundStyle(CareLensTheme.Colors.textPrimary)
                }
                .tint(CareLensTheme.Colors.goldPrimary)

                if recentHospitalisation {
                    IntakeTextArea(label: "Hospitalisation Details", text: $hospitalisationDetails, placeholder: "When, where, reason, outcomes...")
                }
            }
            .padding()
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
        }
    }

    // MARK: - Functional Status

    private var functionalStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Functional Assessment", icon: "figure.walk")

            IntakePicker(label: "Mobility Level", selection: $mobilityLevel, options: mobilityOptions)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("ADL Independence").font(.caption.bold()).foregroundStyle(CareLensTheme.Colors.textSecondary)
                    Spacer()
                    Text("\(Int(adlScore))/10")
                        .font(.caption.bold())
                        .foregroundStyle(CareLensTheme.Colors.goldLight)
                }
                Slider(value: $adlScore, in: 0...10, step: 1)
                    .tint(CareLensTheme.Colors.goldPrimary)
            }
            .padding()
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $fallsHistory) {
                    Text("Falls History (past 12 months)")
                        .font(.subheadline)
                        .foregroundStyle(CareLensTheme.Colors.textPrimary)
                }
                .tint(CareLensTheme.Colors.riskRed)

                if fallsHistory {
                    IntakeTextArea(label: "Falls Details", text: $fallsDetails, placeholder: "Frequency, context, injuries...")
                }
            }
            .padding()
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)

            IntakePicker(label: "Cognitive Status", selection: $cognitiveStatus, options: cognitiveOptions)
            IntakeTextArea(label: "Vision & Hearing", text: $visionHearing, placeholder: "Any impairments, aids used...")
        }
    }

    // MARK: - Psychosocial

    private var psychosocialSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Psychosocial Profile", icon: "person.3.fill")

            IntakePicker(label: "Living Arrangement", selection: $livingArrangement, options: livingOptions)
            IntakeTextField(label: "Primary Carer/Support Person", text: $primaryCarer)
            IntakeTextArea(label: "Social Supports & Networks", text: $socialSupports, placeholder: "Family, friends, services, community groups...")
            IntakeTextArea(label: "Cultural Considerations", text: $culturalConsiderations, placeholder: "Cultural, language, dietary needs...")
            IntakeTextArea(label: "Spiritual Needs", text: $spiritualNeeds, placeholder: "Faith, meaning, spiritual practices...")
            IntakePicker(label: "Mood Screening", selection: $moodScreening, options: moodOptions)
        }
    }

    // MARK: - Presenting Concerns

    private var presentingConcernsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Presenting Concerns & Goals", icon: "target")

            IntakeTextArea(label: "Presenting Concerns", text: $presentingConcerns, placeholder: "What prompted this assessment? Client's words where possible...")
            IntakeTextArea(label: "Client Goals", text: $clientGoals, placeholder: "What does the client hope to achieve?")
            IntakeTextArea(label: "Strengths Identified", text: $strengthsIdentified, placeholder: "Personal strengths, resilience factors, supports...")
            IntakeTextArea(label: "Risk Factors", text: $riskFactors, placeholder: "Safety concerns, vulnerabilities, environmental risks...")
        }
    }

    // MARK: - Consent

    private var consentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Consent & Safety", icon: "shield.checkered")

            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $consentObtained) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Informed Consent Obtained")
                            .font(.subheadline.bold())
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                        Text("Client has been informed of assessment purpose, data use, and privacy rights.")
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.textTertiary)
                    }
                }
                .tint(CareLensTheme.Colors.emeraldGreen)

                if consentObtained {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Consent Date").font(.caption.bold()).foregroundStyle(CareLensTheme.Colors.textSecondary)
                        DatePicker("", selection: $consentDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .tint(CareLensTheme.Colors.goldPrimary)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $advanceDirective) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Advance Directive on File")
                            .font(.subheadline.bold())
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                        Text("Client has a registered advance care directive or enduring power of attorney.")
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.textTertiary)
                    }
                }
                .tint(CareLensTheme.Colors.emeraldGreen)

                IntakeTextField(label: "Health Proxy / Decision Maker", text: $healthProxy)
            }
            .padding()
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)

            DiamondGlassCard(title: "Review Summary", subtitle: "Check before submission", icon: "checkmark.diamond") {
                VStack(alignment: .leading, spacing: 8) {
                    summaryRow("Name", value: "\(firstName) \(lastName)")
                    summaryRow("Priority", value: priorityLevel)
                    summaryRow("Referral", value: referralSource)
                    summaryRow("Mobility", value: mobilityLevel)
                    summaryRow("Cognitive", value: cognitiveStatus)
                    summaryRow("Consent", value: consentObtained ? "Obtained" : "Pending")
                }
            }
        }
    }

    private func summaryRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(CareLensTheme.Colors.textTertiary)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(.caption.bold())
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
        }
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button(action: { withAnimation { currentStep -= 1 } }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
                .buttonStyle(DiamondSecondaryButtonStyle())
            }

            Spacer()

            if currentStep < steps.count - 1 {
                Button(action: { withAnimation { currentStep += 1 } }) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(DiamondButtonStyle())
            } else {
                Button(action: { showingConfirmation = true }) {
                    HStack {
                        Image(systemName: "checkmark.diamond.fill")
                        Text("Submit Intake")
                    }
                }
                .buttonStyle(DiamondButtonStyle())
                .disabled(!consentObtained || firstName.isEmpty || lastName.isEmpty)
                .opacity(consentObtained && !firstName.isEmpty && !lastName.isEmpty ? 1 : 0.5)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Completion

    private var completionView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                DiamondShape()
                    .fill(CareLensTheme.Gradients.goldGreen)
                    .frame(width: 100, height: 100)
                    .shadow(color: CareLensTheme.Colors.goldPrimary.opacity(0.5), radius: 20)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text("Intake Complete")
                .font(.title.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [CareLensTheme.Colors.goldLight, CareLensTheme.Colors.emeraldGreen],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Text("\(firstName) \(lastName) has been registered as a new client. Assessment modules are now available.")
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { resetForm() }) {
                HStack {
                    Image(systemName: "plus.diamond")
                    Text("New Intake")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(DiamondButtonStyle())
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(CareLensTheme.Colors.goldPrimary)
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [CareLensTheme.Colors.goldLight, CareLensTheme.Colors.emeraldGreen],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
        }
    }

    private func submitIntake() {
        let newClient = ClientProfile(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            gender: gender,
            preferredLanguage: preferredLanguage,
            culturalIdentity: culturalConsiderations,
            consentStatus: consentObtained ? "Obtained" : "Pending",
            referralSource: referralSource,
            presentingConcerns: presentingConcerns,
            nominatedDecisionMaker: healthProxy,
            safetyFlags: riskFactors.isEmpty ? [] : [riskFactors]
        )
        modelContext.insert(newClient)
        try? modelContext.save()
        withAnimation { intakeComplete = true }
    }

    private func resetForm() {
        firstName = ""
        lastName = ""
        dateOfBirth = Date()
        gender = "Female"
        preferredLanguage = "English"
        address = ""
        phoneNumber = ""
        emergencyContact = ""
        emergencyPhone = ""
        referralSource = ""
        referringPractitioner = ""
        referralReason = ""
        referralDate = Date()
        priorityLevel = "Routine"
        primaryDiagnosis = ""
        comorbidities = ""
        currentMedications = ""
        allergies = ""
        recentHospitalisation = false
        hospitalisationDetails = ""
        mobilityLevel = "Independent"
        adlScore = 0
        fallsHistory = false
        fallsDetails = ""
        cognitiveStatus = "Intact"
        visionHearing = ""
        livingArrangement = "Lives at home alone"
        primaryCarer = ""
        socialSupports = ""
        culturalConsiderations = ""
        spiritualNeeds = ""
        moodScreening = "Normal"
        presentingConcerns = ""
        clientGoals = ""
        strengthsIdentified = ""
        riskFactors = ""
        consentObtained = false
        advanceDirective = false
        healthProxy = ""
        currentStep = 0
        intakeComplete = false
    }
}

// MARK: - Reusable Intake Components

struct IntakeTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textFieldStyle(.plain)
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                )
        }
    }
}

struct IntakeTextArea: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
            TextEditor(text: $text)
                .frame(minHeight: 80)
                .foregroundStyle(CareLensTheme.Colors.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                )
                .overlay(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .font(.subheadline)
                            .foregroundStyle(CareLensTheme.Colors.textTertiary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}

struct IntakePicker: View {
    let label: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection)
                        .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.goldPrimary)
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                )
            }
        }
    }
}
