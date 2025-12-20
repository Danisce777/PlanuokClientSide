import Foundation
import Combine

class CategoryService: ObservableObject {
    
    @Published var users: [UserRequest] = []
    @Published var transactions: [Transaction] = []
    @Published var isAuthenticated = false
    @Published var currentUser: AuthResponse?
    
    private let baseURL = "http://localhost:8081"

    init(){
        isAuthenticated = TokenManager.shared.getToken() != nil
    }
    
    func logout() {
        TokenManager.shared.deleteToken()

        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUser = nil
            self.transactions = []
        }
    }
    
    private func createAuthenticatedRequest(url: URL, method: String = "GET") throws -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = TokenManager.shared.getToken() else {
            throw NetworkError.noToken
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
        
    func getTransactionCategories(type: TransactionType) async throws -> [TransactionCategory] {
                
        guard let url = URL(string: "\(baseURL)/categories?type=\(type.rawValue)") else {
            throw NetworkError.invalidURL
        }
        
        let request = try createAuthenticatedRequest(url: url, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
               throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                logout()
                throw NetworkError.unauthorized
            }
            throw NetworkError.fetchFailed(statusCode: httpResponse.statusCode)
        }
        
        if let json = String(data: data, encoding: .utf8) {
            print("Categories JSON:", json)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
                
        return try decoder.decode([TransactionCategory].self, from: data)
    }

    func addCategory(name: String, type: TransactionType, isDefault: Bool = false) async throws -> TransactionCategory {
        
        guard let url = URL(string: "\(baseURL)/categories") else {
            throw NetworkError.invalidURL
        }
        
        var request = try createAuthenticatedRequest(url: url, method: "POST")
        
        let requestBody = TransactionCategoryRequest(
            name: name,
            type: type,
            isDefault: isDefault
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 201 else {
            if httpResponse.statusCode == 401 { logout(); throw NetworkError.unauthorized }
            throw NetworkError.transactionFailed(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let createdCategory = try decoder.decode(TransactionCategory.self, from: data)

        return createdCategory
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


   



