//
//  Carelens_Aged_App.swift
//  Carelens-Aged+
//
//  Created by Christopher Appiah-Thompson  on 7/5/2026.
//

import SwiftUI
import SwiftData

@main
struct Carelens_Aged_App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
