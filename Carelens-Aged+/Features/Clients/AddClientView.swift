import SwiftUI
import SwiftData

struct AddClientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -75, to: .now)!
    @State private var gender = ""
    @State private var preferredLanguage = "English"
    @State private var culturalIdentity = ""
    @State private var referralSource = ""
    @State private var presentingConcerns = ""
    @State private var interpreterNeeded = false
    @State private var nominatedDecisionMaker = ""

    private let genderOptions = ["Male", "Female", "Non-binary", "Prefer not to say"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    Picker("Gender", selection: $gender) {
                        Text("Select").tag("")
                        ForEach(genderOptions, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Language & Culture") {
                    TextField("Preferred Language", text: $preferredLanguage)
                    TextField("Cultural Identity", text: $culturalIdentity)
                    Toggle("Interpreter Needed", isOn: $interpreterNeeded)
                }

                Section("Referral") {
                    TextField("Referral Source", text: $referralSource)
                    TextField("Nominated Decision Maker", text: $nominatedDecisionMaker)
                }

                Section("Presenting Concerns") {
                    TextEditor(text: $presentingConcerns)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveClient() }
                        .disabled(firstName.isEmpty || lastName.isEmpty)
                        .bold()
                }
            }
        }
    }

    private func saveClient() {
        let client = ClientProfile(
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            gender: gender,
            preferredLanguage: preferredLanguage,
            culturalIdentity: culturalIdentity,
            consentStatus: "Pending",
            referralSource: referralSource,
            presentingConcerns: presentingConcerns,
            interpreterNeeded: interpreterNeeded,
            nominatedDecisionMaker: nominatedDecisionMaker
        )
        modelContext.insert(client)
        dismiss()
    }
}
