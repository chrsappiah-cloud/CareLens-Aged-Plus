import SwiftUI
import SwiftData

@main
struct Carelens_Aged_App: App {
    var sharedModelContainer: ModelContainer = {
        print("[CarelensAged] Creating ModelContainer...")
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: ClientProfile.self, AssessmentSession.self, AssessmentSection.self, CarePlan.self, MonitoringEvent.self,
            configurations: config
        )
        print("[CarelensAged] ModelContainer created successfully!")
        return container
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
