//
//  LoginView.swift
//  planuokFetch
//
//  Created by MacBook on 05/11/2025.
//

import SwiftUI

struct LoginView: View {
    
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        
        VStack(spacing: 24) {
            Image("Track-Image")
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 140)
                .padding(.vertical, 32)
            
            InputView(
                text: $email,
                title: "Email",
                placeholder: "Enter your email")
            
            InputView(
                text: $password,
                title: "Password",
                placeholder: "Enter your password")
            
            Button {
                // implement method on network manager
            } label: {
                Text("Log In")
            }
            .foregroundStyle(.white)
            .frame(height: 48)
            .frame(maxWidth: 370)
            .background(Color(.systemBlue))
            .cornerRadius(10)
        }
        .padding(24)
        
        
    }
}

#Preview {
    LoginView()
}
