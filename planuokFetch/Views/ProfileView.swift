//
//  ProfileView.swift
//  planuokFetch
//
//  Created by MacBook on 10/12/2025.
//

import SwiftUI

struct ProfileView: View {
    
    
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                Button {
                    Task {
                        networkManager.logout()
                    }
                } label: {
                    Text("Logout")
                }
                
            }
            
        }
        .navigationTitle(Text("Profile"))
    }
}

#Preview {
    ProfileView()
}
