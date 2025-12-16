//import Foundation
//import Combine
//
//
//struct TransactionRequest: Codable, Identifiable {
//    
//    let transactionId: Int
//    let description: String
//    let amount: Double
//    let creationDate: Date
//    let transactionCategory: TransactionCategory
//    let transactionType: TransactionType
//    
//    var id: Int {
//        return transactionId
//    }
//    
//    enum TransactionType: String, Codable  {
//        case income = "INCOME"
//        case expense = "EXPENSE"
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case transactionId
//        case description
//        case amount
//        case creationDate
//        case transactionCategory
//        case transactionType
//    }
//
//}
