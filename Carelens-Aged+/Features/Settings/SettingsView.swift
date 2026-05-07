import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var syncEnabled = true
    @State private var notificationsEnabled = true
    @State private var clinicalMode = false

    private var currentUser: AppUser? { authService.currentUser }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            DiamondShape()
                                .fill(CareLensTheme.Gradients.primaryButton)
                                .frame(width: 44, height: 44)
                            Text(String((currentUser?.displayName.prefix(1)) ?? "?"))
                                .font(.headline.bold())
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentUser?.displayName ?? "User")
                                .font(.headline)
                            Text(currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 6) {
                                Text(currentUser?.role.rawValue ?? "")
                                    .font(.caption2)
                                    .foregroundStyle(CareLensTheme.Colors.accentMint)
                                Text("·")
                                    .foregroundStyle(.secondary)
                                Text(currentUser?.subscriptionTier.rawValue ?? "")
                                    .font(.caption2)
                                    .foregroundStyle(currentUser?.subscriptionTier.color ?? .gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    NavigationLink {
                        UserAccessPanelView()
                            .environmentObject(authService)
                    } label: {
                        Label("My Subscription & Access", systemImage: "crown")
                    }

                    NavigationLink {
                        SubscriptionStoreView()
                            .environmentObject(authService)
                    } label: {
                        Label("Upgrade Plan (Apple Pay)", systemImage: "apple.logo")
                    }
                } header: {
                    Label("Account", systemImage: "person.circle")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }

                Section {
                    Toggle("CloudKit Sync", isOn: $syncEnabled)
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    NavigationLink("Backup & Recovery") {
                        BackupSettingsView()
                    }
                } header: {
                    Label("Data & Sync", systemImage: "arrow.triangle.2.circlepath")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }

                Section {
                    Toggle("Clinical Mode", isOn: $clinicalMode)
                    Text("Reduces visual effects for clinical environments")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Label("Display", systemImage: "eye")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }

                Section {
                    NavigationLink("Assessment Templates") {
                        Text("Manage custom templates")
                    }
                    NavigationLink("Report Templates") {
                        Text("Configure report layouts")
                    }
                } header: {
                    Label("Templates", systemImage: "doc.on.doc")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }

                Section {
                    NavigationLink("Privacy Policy") { Text("Privacy Policy") }
                    NavigationLink("Terms of Use") { Text("Terms of Use") }
                    NavigationLink("Data Retention Policy") { Text("Data Retention") }
                    NavigationLink("Audit Log") { Text("Audit trail") }
                } header: {
                    Label("Legal & Compliance", systemImage: "lock.shield")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }

                Section {
                    NavigationLink {
                        SocialMediaLinksView()
                    } label: {
                        Label("Social Media & Community", systemImage: "globe")
                    }
                    Link(destination: URL(string: "https://wcs-full.vercel.app")!) {
                        Label("Visit Website", systemImage: "safari")
                    }
                    Link(destination: URL(string: "mailto:christopher.appiahthompson@myworldclass.org")!) {
                        Label("Helpline", systemImage: "envelope.fill")
                    }
                    Link(destination: URL(string: "https://x.com/chaborachris")!) {
                        Label("Follow on X", systemImage: "bubble.left.and.text.bubble.right")
                    }
                    Link(destination: URL(string: "https://linkedin.com/in/christopher-appiah-thompson")!) {
                        Label("LinkedIn", systemImage: "link.circle.fill")
                    }
                } header: {
                    Label("Connect & Helpline", systemImage: "network")
                        .foregroundStyle(Color(red: 0.85, green: 0.70, blue: 0.20))
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1").foregroundStyle(.secondary)
                    }
                } header: {
                    Label("About", systemImage: "info.circle")
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }

                Section {
                    Button(action: { authService.logout() }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .foregroundStyle(CareLensTheme.Colors.riskRed)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Settings")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct BackupSettingsView: View {
    @StateObject private var middleware = NetworkMiddleware.shared

    var body: some View {
        Form {
            Section("Sync Status") {
                HStack {
                    Text("CloudKit")
                    Spacer()
                    DiamondStatusChip(text: "Connected", level: .safe)
                }
                HStack {
                    Text("Supabase Backup")
                    Spacer()
                    DiamondStatusChip(text: "Active", level: .safe)
                }
                if let lastSync = middleware.lastSyncTime {
                    HStack {
                        Text("Last Sync")
                        Spacer()
                        Text(lastSync.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Actions") {
                Button("Force Sync Now") {}
                    .foregroundStyle(CareLensTheme.Colors.accentMint)
                Button("Export All Data") {}
                    .foregroundStyle(CareLensTheme.Colors.accentMint)
                Button("Restore from Backup") {}
                    .foregroundStyle(CareLensTheme.Colors.accentAmber)
            }
        }
        .navigationTitle("Backup & Recovery")
    }
}
