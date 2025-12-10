//
//  ContentView.swift
//  planuokFetch
//
//  Created by MacBook on 09/12/2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        
        Group {
            if networkManager.isAuthenticated {
                NavigationStack {
                    MainScreen()
                }
            } else {
                NavigationStack{
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
