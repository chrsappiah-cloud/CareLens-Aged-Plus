import SwiftUI
import SwiftData

enum ModelContainerFactory {
    static func makeSharedContainer() -> ModelContainer {
        let schema = Schema([
            ClientProfile.self,
            AssessmentSession.self,
            AssessmentSection.self,
            CarePlan.self,
            MonitoringEvent.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)

        do {
            let container = try ModelContainer(for: schema, configurations: config)
            print("[CarelensAged] ModelContainer created successfully")
            return container
        } catch {
            print("[CarelensAged] ModelContainer failed: \(error)")
            preconditionFailure("SwiftData ModelContainer could not start: \(error)")
        }
    }
}

@main
struct Carelens_Aged_App: App {
    var sharedModelContainer: ModelContainer = ModelContainerFactory.makeSharedContainer()

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
                            guard !AppEnvironment.isRunningTests else { return }
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
