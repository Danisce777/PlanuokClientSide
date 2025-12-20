
import Foundation
import Combine

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}

class AuthService: ObservableObject {
    
    @Published var transactions: [Transaction] = []
    @Published var isAuthenticated = false
    @Published var currentUser: AuthResponse?
    
    private let baseURL = "http://localhost:8081"
    
    init(){
        isAuthenticated = TokenManager.shared.getToken() != nil
    }
    
    func login(email: String, password: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/auth/login") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.authenticationFailed(statusCode: httpResponse.statusCode)
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        TokenManager.shared.saveToken(authResponse.token)
        
        DispatchQueue.main.async {
            self.currentUser = authResponse
            self.isAuthenticated = true
        }
    }
    
    func register(username: String, password: String, email: String) async throws {
        
        guard let url = URL(string: "\(baseURL)/api/auth/register") else {
            throw NetworkError.invalidURL
        }
        
        print("Registering user:")
        print("Username: \(username)")
        print("Email: \(email)")
        print("Password length: \(password.count)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let registerRequest = RegisterRequest(username: username, email: email, password: password)
        request.httpBody = try JSONEncoder().encode(registerRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 201 else {
            throw NetworkError.registrationFailed(statusCode: httpResponse.statusCode)
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        TokenManager.shared.saveToken(authResponse.token)
        
        print(authResponse.token)
        
        DispatchQueue.main.async {
            self.currentUser = authResponse
            self.isAuthenticated = true
        }
    }
    
    func logout() {
        TokenManager.shared.deleteToken()
        
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
            self.transactions = []
        }
    }
    
    enum NetworkError: LocalizedError {
        case invalidURL
        case invalidResponse
        case noToken
        case unauthorized
        case authenticationFailed(statusCode: Int)
        case registrationFailed(statusCode: Int)
        case transactionFailed(statusCode: Int)
        case fetchFailed(statusCode: Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid server response"
            case .noToken:
                return "No authentication token found. Please login again."
            case .unauthorized:
                return "Session expired. Please login again."
            case .authenticationFailed(let code):
                return "Login failed (Status: \(code)). Please check your credentials."
            case .registrationFailed(let code):
                return "Registration failed (Status: \(code)). User may already exist."
            case .transactionFailed(let code):
                return "Failed to create transaction (Status: \(code))"
            case .fetchFailed(let code):
                return "Failed to fetch data (Status: \(code))"
            }
        }
    }
    
}
