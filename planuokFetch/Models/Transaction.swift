import Foundation
import Combine

struct Transaction: Codable, Identifiable {
    
    let transactionId: Int
    let description: String
    let amount: Double
    let creator: Creator
    let creationDate: Date
    let transactionType: TransactionType
    let category: TransactionCategory
    
    var id: Int {
        return transactionId
    }
    
    enum CodingKeys: String, CodingKey {
        case transactionId, description, amount, creator, creationDate, transactionType, category
    }
}

enum TransactionType: String, Codable  {
    case income = "INCOME"
    case expense = "EXPENSE"
}

struct Creator: Codable {
    let id: Int
    let username: String
    let email: String
}
