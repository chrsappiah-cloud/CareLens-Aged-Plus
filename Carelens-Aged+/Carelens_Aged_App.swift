import SwiftUI
import SwiftData

@main
struct Carelens_Aged_App: App {
    var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema([
                ClientProfile.self,
                AssessmentSession.self,
                AssessmentSection.self,
                CarePlan.self,
                MonitoringEvent.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("CarelensApp ModelContainer: \(error)")
        }
    }()

    @StateObject private var authService = AuthenticationService.shared
    @AppStorage("hasLoadedMockData") private var hasLoadedMockData = false

    init() {
        TabBarAppearance.apply()
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
            .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
