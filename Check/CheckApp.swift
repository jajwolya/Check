import Firebase
import SwiftUI

@main
struct CheckApp: App {

    init() {
        FirebaseApp.configure()
        print("Firebase configured!")
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
            }
        }
    }
}
