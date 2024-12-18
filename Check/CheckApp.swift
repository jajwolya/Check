//
//  CheckApp.swift
//  Check
//
//  Created by Jajwol Bajracharya on 11/12/2024.
//

import Firebase
import SwiftData
import SwiftUI

@main
struct CheckApp: App {

    init() {
        FirebaseApp.configure()
        print("Firebase configured!")
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
//            Item.self,
//            Category.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(
                for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
            }
            
        }
        .modelContainer(sharedModelContainer)
    }
}
