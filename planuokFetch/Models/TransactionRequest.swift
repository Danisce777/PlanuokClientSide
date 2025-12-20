import Foundation
import Combine


struct TransactionRequest: Codable {
    
    let title: String
    let amount: Double
    let description: String
    let categoryId: Int
    let transactionType: String
    let occurredDate: Date
    
    enum TransactionType: String, Codable  {
        case income = "INCOME"
        case expense = "EXPENSE"
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case amount
        case description
        case categoryId
        case transactionType
        case occurredDate
    }

}
