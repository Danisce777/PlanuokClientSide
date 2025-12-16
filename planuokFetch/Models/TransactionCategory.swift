import Foundation

struct TransactionCategory: Identifiable, Codable {

    let id: Int
    let name: String
    let type: TransactionType
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, isDefault
    }
}
