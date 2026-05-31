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

        let inMemory = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let onDisk = ModelConfiguration(
            "CareLensLocalStore",
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        if AppEnvironment.isRunningTests {
            if let container = try? ModelContainer(for: schema, configurations: inMemory) {
                print("[CarelensAged] ModelContainer created (in-memory test)")
                return container
            }
            fatalError("SwiftData ModelContainer could not start for tests")
        }

        if let container = try? ModelContainer(for: schema, configurations: onDisk) {
            print("[CarelensAged] ModelContainer created (on-disk)")
            return container
        }

        if let container = try? ModelContainer(for: schema, configurations: inMemory) {
            print("[CarelensAged] ModelContainer created (in-memory fallback)")
            return container
        }

        fatalError("SwiftData ModelContainer could not start with on-disk or in-memory configuration")
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
