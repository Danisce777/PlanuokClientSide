//
//  MainScreen.swift
//  planuokFetch
//
//  Created by MacBook on 12/11/2025.
//

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
            }
                .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
        
    }
}

#Preview {
    MainScreen()
}
