import SwiftUI

struct AdminPanelView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingAddUser = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                adminSegmentPicker
                ScrollView {
                    switch selectedTab {
                    case 0: userManagementSection
                    case 1: subscriptionOverview
                    case 2: systemHealthSection
                    default: userManagementSection
                    }
                }
            }
            .background(Color.clear)
            .navigationTitle("Admin Panel")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "person.badge.plus")
                            .foregroundStyle(CareLensTheme.Colors.accentMint)
                    }
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView()
            }
        }
    }

    private var adminSegmentPicker: some View {
        HStack(spacing: 8) {
            ForEach(["Users", "Subscriptions", "System"], id: \.self) { tab in
                let index = ["Users", "Subscriptions", "System"].firstIndex(of: tab) ?? 0
                Button(action: { withAnimation { selectedTab = index } }) {
                    Text(tab)
                        .font(.caption.bold())
                        .foregroundStyle(selectedTab == index ? .white : CareLensTheme.Colors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(selectedTab == index
                                           ? CareLensTheme.Colors.accentMagenta.opacity(0.3)
                                           : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule().strokeBorder(
                                selectedTab == index ? CareLensTheme.Colors.accentMagenta.opacity(0.6) : .clear,
                                lineWidth: 1
                            )
                        )
                }
            }
        }
        .padding()
    }

    private var userManagementSection: some View {
        VStack(spacing: 12) {
            ForEach(subscriptionManager.managedUsers) { user in
                AdminUserCard(user: user)
            }
        }
        .padding()
    }

    private var subscriptionOverview: some View {
        VStack(spacing: 16) {
            ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                let count = subscriptionManager.managedUsers.filter { $0.subscriptionTier == tier }.count
                DiamondGlassCard(
                    title: tier.rawValue,
                    subtitle: "$\(String(format: "%.2f", tier.monthlyPrice))/mo · \(count) user(s)",
                    icon: "crown"
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Max Clients: \(tier.maxClients == Int.max ? "Unlimited" : "\(tier.maxClients)")")
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                        Text("Features: \(tier.features.count)")
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                        HStack {
                            Spacer()
                            DiamondStatusChip(text: "\(count) active", color: tier.color)
                        }
                    }
                }
            }
        }
        .padding()
    }

    private var systemHealthSection: some View {
        VStack(spacing: 16) {
            DiamondGlassCard(title: "API Status", subtitle: "OpenAI Health API", icon: "network") {
                HStack {
                    DiamondStatusChip(text: "Connected", level: .safe)
                    Spacer()
                    Text("gpt-4o")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                }
            }

            DiamondGlassCard(title: "CloudKit Sync", subtitle: "Primary data store", icon: "icloud") {
                HStack {
                    DiamondStatusChip(text: "Active", level: .safe)
                    Spacer()
                    Text("Last sync: just now")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                }
            }

            DiamondGlassCard(title: "Supabase Backup", subtitle: "Encrypted backup layer", icon: "externaldrive.badge.checkmark") {
                HStack {
                    DiamondStatusChip(text: "Healthy", level: .safe)
                    Spacer()
                    Text("Last backup: 2h ago")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
                }
            }

            DiamondGlassCard(title: "Active Sessions", subtitle: "Currently logged in", icon: "person.3.sequence") {
                HStack {
                    Text("\(subscriptionManager.managedUsers.filter { $0.isActive }.count) users online")
                        .font(.subheadline)
                        .foregroundStyle(CareLensTheme.Colors.textPrimary)
                    Spacer()
                    DiamondStatusChip(text: "Normal", level: .safe)
                }
            }
        }
        .padding()
    }
}

struct AdminUserCard: View {
    let user: AppUser
    @StateObject private var manager = SubscriptionManager.shared
    @State private var showingTierPicker = false

    var body: some View {
        DiamondGlassCard(
            title: user.displayName,
            subtitle: "\(user.email) · \(user.role.rawValue)",
            icon: user.isActive ? "person.fill.checkmark" : "person.fill.xmark"
        ) {
            HStack(spacing: 8) {
                DiamondStatusChip(text: user.subscriptionTier.rawValue, color: user.subscriptionTier.color)
                DiamondStatusChip(
                    text: user.isActive ? "Active" : "Disabled",
                    level: user.isActive ? .safe : .risk
                )
                Spacer()
                Menu {
                    Button("Toggle Active") { manager.toggleUserActive(user.id) }
                    Menu("Change Tier") {
                        ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                            Button(tier.rawValue) { manager.upgradeUser(user.id, to: tier) }
                        }
                    }
                    Button("Remove User", role: .destructive) { manager.removeUser(user.id) }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }
            }
        }
    }
}

struct AddUserView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = SubscriptionManager.shared
    @State private var email = ""
    @State private var displayName = ""
    @State private var role: UserRole = .clinician
    @State private var tier: SubscriptionTier = .starter

    var body: some View {
        NavigationStack {
            Form {
                Section("User Details") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Display Name", text: $displayName)
                    Picker("Role", selection: $role) {
                        ForEach(UserRole.allCases, id: \.self) { Text($0.rawValue) }
                    }
                }
                Section("Subscription") {
                    Picker("Tier", selection: $tier) {
                        ForEach(SubscriptionTier.allCases, id: \.self) {
                            Text("\($0.rawValue) — $\(String(format: "%.2f", $0.monthlyPrice))/mo")
                        }
                    }
                }
            }
            .navigationTitle("Add User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addUser() }
                        .disabled(email.isEmpty || displayName.isEmpty)
                        .bold()
                }
            }
        }
    }

    private func addUser() {
        let user = AppUser(
            id: UUID().uuidString,
            email: email,
            displayName: displayName,
            role: role,
            subscriptionTier: tier,
            isActive: true,
            facilityID: "facility_001",
            createdAt: .now,
            lastLoginAt: nil
        )
        manager.addUser(user)
        dismiss()
    }
}
