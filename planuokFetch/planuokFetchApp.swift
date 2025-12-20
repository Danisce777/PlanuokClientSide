import SwiftUI

@main
struct planuokFetchApp: App {
    
    @StateObject private var authService = AuthService()
    @StateObject private var categoryService = CategoryService()
    @StateObject private var transactionService = TransactionService()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(authService)
            .environmentObject(categoryService)
            .environmentObject(transactionService)

        }
    }
}
