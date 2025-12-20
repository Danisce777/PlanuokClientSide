import Foundation

struct TransactionResponse: Codable {
    let transactionId: Int
    let title: String
    let description: String
    let amount: Double
    let creator: Creator
    let creationDate: Date
    let transactionType: String
    let category: TransactionCategory
    let occurredDate: Date
}
