import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var selectedTab = 0

    private var isAdmin: Bool {
        authService.currentUser?.role == .admin
    }

    private var userTier: SubscriptionTier {
        authService.currentUser?.subscriptionTier ?? .free
    }

    var body: some View {
        ZStack {
            FuturisticBackground()

            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "rectangle.3.group") }
                    .tag(0)

                ClientIntakeView()
                    .tabItem { Label("Intake", systemImage: "person.badge.plus") }
                    .tag(7)

                ClientListView()
                    .tabItem { Label("Clients", systemImage: "person.2") }
                    .tag(1)

                if authService.hasAccess(to: .basicAssessment) {
                    AssessmentsHomeView()
                        .tabItem { Label("Assess", systemImage: "checklist") }
                        .tag(2)
                }

                if authService.hasAccess(to: .carePlans) {
                    CarePlanHomeView()
                        .tabItem { Label("Care Plan", systemImage: "cross.case") }
                        .tag(3)
                }

                if authService.hasAccess(to: .basicReports) {
                    ReportsHomeView()
                        .tabItem { Label("Reports", systemImage: "doc.text") }
                        .tag(4)
                }

                if isAdmin {
                    AdminPanelView()
                        .tabItem { Label("Admin", systemImage: "gear.badge") }
                        .tag(6)
                }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
                    .tag(5)
            }
            .tint(CareLensTheme.Colors.accentMint)
        }
    }
}
