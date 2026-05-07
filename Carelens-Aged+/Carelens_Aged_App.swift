import SwiftUI
import SwiftData

@main
struct Carelens_Aged_App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ClientProfile.self,
            AssessmentSession.self,
            AssessmentSection.self,
            CarePlan.self,
            MonitoringEvent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var authService = AuthenticationService.shared
    @AppStorage("hasLoadedMockData") private var hasLoadedMockData = false

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        tabBarAppearance.backgroundColor = UIColor(Color.black.opacity(0.55))

        let selectedColor = UIColor(red: 0.95, green: 0.85, blue: 0.35, alpha: 1.0)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ]

        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.75)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.75),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    RootTabView()
                        .onAppear {
                            if !hasLoadedMockData {
                                let context = sharedModelContainer.mainContext
                                MockData.populateSampleData(context: context)
                                hasLoadedMockData = true
                            }
                        }
                } else {
                    LoginView()
                }
            }
            .environmentObject(authService)
        }
        .modelContainer(sharedModelContainer)
    }
}
