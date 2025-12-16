import SwiftUI

@main
struct planuokFetchApp: App {
    
    @StateObject private var networkManager = NetworkManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(networkManager)
        }
    }
}
