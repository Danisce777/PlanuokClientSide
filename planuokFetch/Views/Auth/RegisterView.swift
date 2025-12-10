//
//  RegisterView.swift
//  planuokFetch
//
//  Created by MacBook on 28/09/2025.
//

import SwiftUI


struct RegisterView: View {
    
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.dismiss) var dismiss

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showingLogin = false

    var body: some View {
        NavigationStack {
        
            VStack {
                Image("Track-Image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 140)
                    .padding(.vertical, 32)
                
                VStack(spacing: 24) {
                    
                    InputView(
                        text: $username,
                        title: "Username",
                        placeholder: "Enter your username")
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    
                    InputView(
                        text: $email,
                        title: "Email",
                        placeholder: "name@example.com")
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    
                    InputView(
                        text: $password,
                        title: "Password",
                        placeholder: "Enter your password",
                        isSecureField: true)
                    .autocorrectionDisabled()
                    .textContentType(.newPassword)
                    
                    InputView(
                        text: $confirmPassword,
                        title: "Confirm Password",
                        placeholder: "Confirm your password",
                        isSecureField: true)
                    .textContentType(.newPassword)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                Spacer()
                                
                Button {
                    Task { await handleRegister() }
                } label: {
                    HStack {
                        Text("Create new Account")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(height: 48)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: 370)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 24)
            }
            .sheet(isPresented: $showingLogin) {
                  LoginView()
            }
        }
    }
    
    private func handleRegister() async {
        errorMessage = ""
        isLoading = true
        do {
            try await networkManager.register(
                username: username,
                password: password,
                email: email
            )
            
            username = ""
            email = ""
            password = ""
            confirmPassword = ""
            
            showingLogin = true

        } catch {
            errorMessage = "An unexpected error occurred"
        }
        isLoading = false
    }
}

extension RegisterView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count >= 8
        && confirmPassword == password
        && !username.isEmpty
    }
}

#Preview {
    RegisterView()
}
