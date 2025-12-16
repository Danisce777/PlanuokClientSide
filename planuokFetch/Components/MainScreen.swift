import SwiftUI

struct MainScreen: View {
    
    @EnvironmentObject var networkManager: NetworkManager
    
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
    MainScreen().environmentObject(NetworkManager())
}
