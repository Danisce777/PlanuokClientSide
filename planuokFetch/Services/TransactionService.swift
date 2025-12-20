import Foundation
import Combine



class TransactionService: ObservableObject {
    
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
        
    func createTransaction(amount: Double, description: String, categoryId: Int, type: TransactionType, date: Date, occurredDate: Date, title: String ) async throws -> Transaction {
        
        guard let url = URL(string: "\(baseURL)/transactions") else {
            throw NetworkError.invalidURL
        }
        
        var request = try createAuthenticatedRequest(url: url, method: "POST")
        
        let requestBody = TransactionRequest(
            title: title,
            amount: amount,
            description: description,
            categoryId: categoryId,
            transactionType: type.rawValue.uppercased(),
            occurredDate: occurredDate
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
        let createdTransaction = try decoder.decode(Transaction.self, from: data)

        Task {
            do {
                try await self.getUsersTransactions()
            } catch {
                print("Warning: failed to refresh after create: \(error)")
            }
        }
    
        return createdTransaction
    }
        
    func getUsersTransactions() async throws {
        
        guard let url = URL(string: "\(baseURL)/transactions") else {
            throw NetworkError.invalidURL
        }
        
        let request = try createAuthenticatedRequest(url: url)
        
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
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Transactions response: \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedData = try decoder.decode([Transaction].self, from: data)
        
        DispatchQueue.main.async {
            self.transactions = decodedData
        }
    }
    
    func deleteTransaction(by id: Int) async throws {
        
        guard let url = URL(string: "\(baseURL)/transactions/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let request = try createAuthenticatedRequest(url: url, method: "DELETE")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
               throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 204 else {
            if httpResponse.statusCode == 401 {
                logout()
                throw NetworkError.unauthorized
            }
            throw NetworkError.fetchFailed(statusCode: httpResponse.statusCode)
        }
    }
    
    func modifyTransaction(by id: Int, title: String, amount: Double, description: String, categoryId: Int, type: TransactionType, occurredDate: Date) async throws -> Transaction {
        
        guard let url = URL(string: "\(baseURL)/transactions/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        var request = try createAuthenticatedRequest(url: url, method: "PUT")
        
        let requestBody = TransactionRequest(
            title: title,
            amount: amount,
            description: description,
            categoryId: categoryId,
            transactionType: type.rawValue.uppercased(),
            occurredDate: occurredDate
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                logout()
                throw NetworkError.unauthorized
            }
            throw NetworkError.transactionFailed(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let transactionResponse = try decoder.decode(TransactionResponse.self, from: data)

        let updatedTransaction = Transaction(
            transactionId: transactionResponse.transactionId,
            title: transactionResponse.title,
            description: transactionResponse.description,
            amount: transactionResponse.amount,
            creator: transactionResponse.creator,
            creationDate: transactionResponse.creationDate,
            transactionType: TransactionType(rawValue: transactionResponse.transactionType.lowercased()) ?? .expense,
            category: transactionResponse.category,
            occurredDate: transactionResponse.occurredDate
        )
        
        return updatedTransaction
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
