//
//  planuokFetchTests.swift
//  planuokFetchTests
//
//  Created by MacBook on 27/09/2025.
//

import Testing
import Foundation
@testable import planuokFetch

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

struct TestHelpers {
    static func createMockTransaction(
        id: Int = 123,
        title: String = "Test Transaction",
        amount: Double = 100.0,
        type: TransactionType = .expense
    ) -> Transaction {
        let creator = Creator(id: 1, username: "testuser", email: "test@example.com")
        let category = TransactionCategory(id: 1, name: "Food", type: type, isDefault: true)
        
        return Transaction(
            transactionId: id,
            title: title,
            description: "Test Description",
            amount: amount,
            creator: creator,
            creationDate: Date(),
            transactionType: type,
            category: category,
            occurredDate: Date()
        )
    }
    
    static func createMockCategory(
        id: Int = 1,
        name: String = "Food",
        type: TransactionType = .expense
    ) -> TransactionCategory {
        return TransactionCategory(id: id, name: name, type: type, isDefault: true)
    }
    
    static func setupMockResponse(statusCode: Int, data: Data? = nil) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }
    }
}

@Suite("Transaction Validation Tests")
struct TransactionValidationTests {
    
    @Test("Invalid amount returns nil")
     func invalidAmountParsing() {
         let amount = "invalid"
         #expect(Double(amount) == nil)
    }
    
    @Test("Empty amount returns nil")
     func emptyAmountParsing() {
         let amount = ""
         #expect(Double(amount) == nil)
    }
    
    
    @Test("Negative amount is valid number")
    func negativeAmountParsing() {
        let amount = "-50.00"
        #expect(Double(amount) == -50.0)
    }

}

@Suite("Transaction Model Tests")
struct TransactionModelTests {
    
    @Test("Create expense transaction")
    func createExpenseTransaction() {
        let transaction = TestHelpers.createMockTransaction(
            id: 1,
            title: "Groceries",
            amount: 50.0,
            type: .expense
        )
        
        #expect(transaction.title == "Groceries")
        #expect(transaction.amount == 50.0)
        #expect(transaction.transactionType == .expense)
    }
    
    
    @Test("Create income transaction")
     func createIncomeTransaction() {
         let transaction = TestHelpers.createMockTransaction(
             id: 2,
             title: "Salary",
             amount: 5000.0,
             type: .income
         )
         
         #expect(transaction.title == "Salary")
         #expect(transaction.amount == 5000.0)
         #expect(transaction.transactionType == .income)
     }
    
}

@Suite("Transaction Service Tests")
struct TransactionServiceTests {
    
    @Test("Create transaction fails with unauthorized")
    @MainActor
    func createTransactionUnauthorized() async throws {

        TestHelpers.setupMockResponse(statusCode: 401)
        let service = TransactionService()
        
        do {
            _ = try await service.createTransaction(
                amount: 100.0,
                description: "Test",
                categoryId: 1,
                type: .expense,
                date: Date(),
                occurredDate: Date(),
                title: "Test"
            )
            #expect(Bool(false), "Should have thrown unauthorized error")
        } catch let error as TransactionService.NetworkError {
            print("Error occurred")
        }
    }
    
    @Test("Create income category")
    func createIncomeCategory() {
        let category = TestHelpers.createMockCategory(
            id: 2,
            name: "Salary",
            type: .income
        )
        
        #expect(category.name == "Salary")
        #expect(category.type == .income)
    }
    
    @Test("Transaction has valid creator")
    func transactionCreator() {
        let transaction = TestHelpers.createMockTransaction()
        
        #expect(transaction.creator.username == "testuser")
        #expect(transaction.creator.email == "test@example.com")
    }
    
 
}

enum NetworkError: LocalizedError, Equatable {
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
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noToken, .noToken),
             (.unauthorized, .unauthorized):
            return true
        case (.authenticationFailed(let lCode), .authenticationFailed(let rCode)),
             (.registrationFailed(let lCode), .registrationFailed(let rCode)),
             (.transactionFailed(let lCode), .transactionFailed(let rCode)),
             (.fetchFailed(let lCode), .fetchFailed(let rCode)):
            return lCode == rCode
        default:
            return false
        }
    }
}
