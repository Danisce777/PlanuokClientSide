import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authService: AuthService
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss

    @State private var showingRegister = false
    
    var body: some View {
        NavigationView {
            
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
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
                InputView(
                    text: $password,
                    title: "Password",
                    placeholder: "Enter your password",
                    isSecureField: true)
                .textInputAutocapitalization(.never)
                .textContentType(.none)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                
                if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await handleLogin()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Login")
                            .bold()
                    }
                }
            
                .foregroundStyle(.white)
                .frame(height: 48)
                .frame(maxWidth: 370)
                .background(Color(.systemBlue))
                .cornerRadius(10)
                
                Button {
                    showingRegister = true
                } label: {
                    HStack(spacing: 3) {
                        Text("Not a member yet?")
                        Text("Sign up")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size: 14))
                }
            }
            .padding(24)
            .sheet(isPresented: $showingRegister) {
                 RegisterView()
             }
        }
    }
    
    private func handleLogin() async {
        errorMessage = ""
        isLoading = true
        
        do {
            try await authService.login(email: email, password: password)
        } catch {
            errorMessage = "An unexpected error occured"
        }
        isLoading = false
    }
}

#Preview {
    LoginView()
}
