import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var selectedTab: AppTab = .home

    private var visibleTabs: [AppTab] {
        AppTab.allCases.filter { $0.isVisible(for: authService) }
    }

    var body: some View {
        ZStack {
            FuturisticBackground()

            TabView(selection: $selectedTab) {
                tabContent(.home) {
                    DashboardView()
                }

                tabContent(.clients) {
                    ClientListView()
                }

                tabContent(.admit) {
                    ClientIntakeView()
                }

                if authService.hasAccess(to: .basicAssessment) {
                    tabContent(.assessments) {
                        AssessmentsHomeView()
                    }
                }

                if authService.hasAccess(to: .carePlans) {
                    tabContent(.carePlans) {
                        CarePlanHomeView()
                    }
                }

                if authService.hasAccess(to: .basicReports) {
                    tabContent(.reports) {
                        ReportsHomeView()
                    }
                }

                tabContent(.settings) {
                    SettingsView()
                }
            }
            .tint(CareLensTheme.Colors.tabSelected)
            .toolbarBackground(CareLensTheme.Colors.tabBarBackground, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
            .tabViewStyle(.tabBarOnly)
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: applyScreenshotTabIfNeeded)
    }

    /// `-ScreenshotTab=tab_dashboard` etc. — used by UI screenshot tests to land on a tab without tab-bar tapping.
    private func applyScreenshotTabIfNeeded() {
        guard let arg = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-ScreenshotTab=") }) else {
            return
        }
        let identifier = String(arg.dropFirst("-ScreenshotTab=".count))
        if let tab = AppTab.allCases.first(where: { $0.accessibilityIdentifier == identifier }) {
            selectedTab = tab
        }
    }

    @ViewBuilder
    private func tabContent<Content: View>(_ tab: AppTab, @ViewBuilder content: () -> Content) -> some View {
        content()
            .tabItem {
                Label(tab.tabLabel, systemImage: tab.icon)
            }
            .tag(tab)
            .accessibilityIdentifier(tab.accessibilityIdentifier)
            .accessibilityLabel(tab.screenTitle)
            .accessibilityHint(tab.accessibilityHint)
    }
}
