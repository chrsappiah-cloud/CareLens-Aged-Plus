import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var syncEnabled = true
    @State private var notificationsEnabled = true
    @State private var clinicalMode = false

    private var currentUser: AppUser? { authService.currentUser }
    private var isAdmin: Bool { authService.currentUser?.role == .admin }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ScreenIntroHeader(
                        title: AppTab.settings.screenTitle,
                        subtitle: AppTab.settings.subtitle
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

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
                                .foregroundStyle(CareLensTheme.Colors.textSecondary)
                            HStack(spacing: 6) {
                                Text(currentUser?.role.rawValue ?? "")
                                    .font(.caption2)
                                    .foregroundStyle(CareLensTheme.Colors.accentMint)
                                Text("·")
                                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
                                Text(currentUser?.accessTier.rawValue ?? "")
                                    .font(.caption2)
                                    .foregroundStyle(currentUser?.accessTier.color ?? .gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    NavigationLink {
                        UserAccessPanelView()
                            .environmentObject(authService)
                    } label: {
                        Label("My Access & Features", systemImage: "crown")
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

                if isAdmin {
                    Section {
                        NavigationLink {
                            AdminPanelView()
                        } label: {
                            Label("Facility Admin Panel", systemImage: "gear.badge")
                        }
                        Text("Manage users, roles, and facility-wide settings")
                            .font(.caption)
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    } header: {
                        Label("Administration", systemImage: "shield.lefthalf.filled")
                            .foregroundStyle(CareLensTheme.Colors.accentMagenta)
                    }
                }

                Section {
                    Toggle("Clinical Mode", isOn: $clinicalMode)
                    Text("High-contrast, reduced motion — recommended in ward environments")
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.textSecondary)
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
                    NavigationLink {
                        LegalDocumentView(document: .privacyPolicy)
                    } label: {
                        Text("Privacy Policy")
                    }
                    NavigationLink {
                        LegalDocumentView(document: .termsOfUse)
                    } label: {
                        Text("Terms of Use")
                    }
                    NavigationLink {
                        LegalDocumentView(document: .dataRetention)
                    } label: {
                        Text("Data Retention Policy")
                    }
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
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
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
            .careLensDarkForm()
            .navigationTitle(AppTab.settings.tabLabel)
            .navigationBarTitleDisplayMode(.inline)
            .careLensDarkChrome()
        }
    }
}

struct BackupSettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var middleware = NetworkMiddleware.shared
    @Query private var clients: [ClientProfile]
    @Query(sort: \AssessmentSession.updatedAt, order: .reverse) private var assessments: [AssessmentSession]
    @Query private var carePlans: [CarePlan]
    @State private var syncMessage: String?
    @State private var isSyncing = false

    var body: some View {
        Form {
            Section {
                Text("Supabase is the primary database. iCloud CloudKit and Cloudflare receive automatic backups after each successful sync. On simulator, enable CloudKit with ENABLE_CLOUDKIT=1 in the scheme environment.")
                    .font(.caption)
                    .foregroundStyle(CareLensTheme.Colors.textSecondary)
            }

            Section("Pipeline Status") {
                syncRow("Supabase (Primary)", pipeline: middleware.lastSyncPipeline?.primary)
                syncRow("iCloud / CloudKit", pipeline: middleware.lastSyncPipeline?.cloudKit)
                syncRow("Cloudflare", pipeline: middleware.lastSyncPipeline?.cloudflare)
                if let lastSync = middleware.lastSyncTime {
                    HStack {
                        Text("Last E2E Sync")
                        Spacer()
                        Text(lastSync.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(CareLensTheme.Colors.textSecondary)
                    }
                }
            }

            if let syncMessage {
                Section {
                    Text(syncMessage)
                        .font(.caption)
                        .foregroundStyle(CareLensTheme.Colors.accentMint)
                }
            }

            Section("Actions") {
                Button(isSyncing ? "Syncing…" : "Run End-to-End Sync") {
                    Task { await runSync() }
                }
                .disabled(isSyncing)
                .foregroundStyle(CareLensTheme.Colors.accentMint)
            }
        }
        .careLensDarkForm()
        .careLensDarkChrome()
        .navigationTitle("Backup & Recovery")
    }

    private func syncRow(_ title: String, pipeline: SyncStepResult?) -> some View {
        HStack {
            Text(title)
            Spacer()
            if let pipeline {
                DiamondStatusChip(
                    text: pipeline.succeeded ? "OK (\(pipeline.recordsWritten))" : "Error",
                    level: pipeline.succeeded ? .safe : .risk
                )
            } else {
                DiamondStatusChip(text: "Pending", level: .warning)
            }
        }
    }

    private func runSync() async {
        isSyncing = true
        syncMessage = nil
        let tier = authService.currentUser?.accessTier ?? .free
        do {
            try await middleware.syncData(
                clients: clients,
                assessments: assessments,
                plans: carePlans,
                userTier: tier
            )
            syncMessage = "Sync complete — primary + backups updated."
        } catch {
            syncMessage = error.localizedDescription
        }
        isSyncing = false
    }
}
