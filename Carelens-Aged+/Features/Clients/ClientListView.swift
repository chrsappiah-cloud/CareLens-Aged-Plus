import SwiftUI
import SwiftData

struct ClientListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClientProfile.lastName) private var clients: [ClientProfile]
    @State private var searchText = ""
    @State private var showingAddClient = false

    var filteredClients: [ClientProfile] {
        guard !searchText.isEmpty else { return clients }
        return clients.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ScreenIntroHeader(
                        title: AppTab.clients.screenTitle,
                        subtitle: AppTab.clients.subtitle
                    )
                    .padding(.horizontal)

                    ForEach(filteredClients, id: \.id) { client in
                        NavigationLink(destination: ClientDetailView(client: client)) {
                            ClientRow(client: client)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .background(Color.clear)
            .searchable(text: $searchText, prompt: "Search by name or ID")
            .navigationTitle(AppTab.clients.tabLabel)
            .navigationBarTitleDisplayMode(.inline)
            .careLensDarkChrome()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(CareLensTheme.Colors.accentMint)
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView()
            }
            .overlay {
                if clients.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(CareLensTheme.Colors.textTertiary)
                        Text("No Clients Yet")
                            .font(.title3.bold())
                            .foregroundStyle(CareLensTheme.Colors.textPrimary)
                        Text("Tap + to add a client, or use the Admit tab for full intake")
                            .font(.subheadline)
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
}

struct ClientRow: View {
    let client: ClientProfile

    var body: some View {
        DiamondGlassCard(
            title: client.fullName,
            subtitle: "Age \(client.age) · \(client.consentStatus)",
            icon: "person.fill"
        ) {
            HStack(spacing: 8) {
                if !client.safetyFlags.isEmpty {
                    DiamondStatusChip(text: "\(client.safetyFlags.count) Flag(s)", level: .warning)
                }
                DiamondStatusChip(
                    text: client.consentStatus,
                    level: client.consentStatus == "Active" ? .safe : .info
                )
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.4))
                    .font(.caption)
            }
        }
    }
}
