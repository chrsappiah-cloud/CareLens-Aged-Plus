import SwiftUI
import SwiftData

struct AssessmentsHomeView: View {
    @Query(sort: \ClientProfile.lastName) private var clients: [ClientProfile]
    @State private var selectedClient: ClientProfile?

    private let modules: [(title: String, icon: String, description: String)] = [
        ("Biopsychosocial Intake", "heart.text.square", "Physical, emotional, social, spiritual, financial, environmental"),
        ("Cognition & Dementia", "brain.head.profile", "NeuroWatch screening, monitoring, collateral reports"),
        ("Mood, Anxiety & Delirium", "waveform.path.ecg", "Differential screen for depression, anxiety, delirium"),
        ("Function & Safety", "figure.walk", "ADLs, IADLs, falls, mobility, environmental hazards"),
        ("Spiritual Assessment", "sparkles", "Meaning, faith, spiritual distress, legacy"),
        ("Advance Care Planning", "doc.plaintext", "Directives, proxies, end-of-life preferences"),
        ("Support Systems & Caregiving", "person.3", "Carers, burden, respite, family dynamics"),
        ("Income, Insurance & Services", "creditcard", "Financial resources, benefits, housing, transport"),
        ("Intervention Review", "stethoscope", "Safety actions, referrals, psychosocial interventions")
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CareLensTheme.spacing) {
                    if let client = selectedClient {
                        clientBanner(client)
                        assessmentGrid(client: client)
                    } else {
                        clientPickerSection
                    }
                }
                .padding(.bottom, 36)
            }
            .background(Color.clear)
            .navigationTitle("Assessments")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func clientBanner(_ client: ClientProfile) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Assessing")
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                Text(client.fullName)
                    .font(.headline)
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
            }
            Spacer()
            Button("Change") { selectedClient = nil }
                .font(.caption.bold())
                .foregroundStyle(CareLensTheme.Colors.accentMint)
        }
        .padding()
        .background(.ultraThinMaterial)
        .background(CareLensTheme.Colors.accentMint.opacity(0.08))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(CareLensTheme.Colors.accentMint.opacity(0.3), lineWidth: 0.8)
        )
        .padding(.horizontal)
    }

    private func assessmentGrid(client: ClientProfile) -> some View {
        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(modules, id: \.title) { module in
                NavigationLink(destination: assessmentDestination(for: module.title, client: client)) {
                    DiamondGlassCard(
                        title: module.title,
                        subtitle: module.description,
                        icon: module.icon
                    ) {
                        HStack {
                            DiamondStatusChip(text: "Ready", level: .safe)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.caption)
                        }
                    }
                    .frame(minHeight: 150)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var clientPickerSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 52))
                .foregroundStyle(CareLensTheme.Gradients.iconGradient)
                .padding(.top, 40)

            Text("Select a Client")
                .font(.title2.bold())
                .foregroundStyle(CareLensTheme.Colors.textPrimary)

            Text("Choose a client to begin or continue an assessment")
                .font(.subheadline)
                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)

            ForEach(clients, id: \.id) { client in
                Button(action: { selectedClient = client }) {
                    DiamondGlassCard(
                        title: client.fullName,
                        subtitle: "Age \(client.age)",
                        icon: "person.fill"
                    ) {
                        HStack {
                            if !client.safetyFlags.isEmpty {
                                DiamondStatusChip(text: "Flags", level: .warning)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            if clients.isEmpty {
                Text("No clients yet. Add a client from the Clients tab.")
                    .foregroundStyle(CareLensTheme.Colors.textTertiary)
                    .padding()
            }
        }
        .padding()
    }

    @ViewBuilder
    private func assessmentDestination(for module: String, client: ClientProfile) -> some View {
        switch module {
        case "Cognition & Dementia":
            NeuroWatchView(client: client)
        case "Mood, Anxiety & Delirium":
            DifferentialView(client: client)
        default:
            BiopsychosocialIntakeView(client: client, moduleName: module)
        }
    }
}

struct AssessmentModuleCard: View {
    let title: String
    let icon: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(CareLensTheme.Gradients.iconGradient)
                .frame(width: 44, height: 44)
                .background(CareLensTheme.Colors.accentMint.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.bold())
                    .foregroundStyle(CareLensTheme.Colors.textPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(CareLensTheme.Colors.textTertiary)
        }
        .padding()
        .frame(minHeight: CareLensTheme.minTouchTarget)
        .clCard()
    }
}
