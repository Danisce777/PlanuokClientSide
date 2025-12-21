import SwiftUI

struct MainScreen: View {
    
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var categoryService: CategoryService
    @EnvironmentObject private var transactionService: TransactionService
    
    var body: some View {
        
        TabView {
            
            NavigationStack {
                TransactionsList()
            }
                .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                AddTransactionView()
            }
                .tabItem {
                Image(systemName: "wallet.pass.fill")
                Text("Transactions")
            }
            
            NavigationStack {
            }
                .tabItem {
                Image(systemName: "chart.pie.fill")
                Text("Assets")
            }
            
            NavigationStack {
            }
                .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Trending")
            }
            
            NavigationStack {
                ProfileView()
            }
                .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
        .background(Color(.blue))
    }
}

#Preview {
    MainScreen()
    .environmentObject(CategoryService())
    .environmentObject(TransactionService())
}
