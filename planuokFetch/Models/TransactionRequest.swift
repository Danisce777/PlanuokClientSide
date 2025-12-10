//
//  TransactionRequest.swift
//  planuokFetch
//
//  Created by MacBook on 22/11/2025.
//

import Foundation
import Combine


struct TransactionRequest: Codable, Identifiable {
    
    let transactionId: Int
    let description: String
    let amount: Double
    let creationDate: Date
    let transactionCategory: String
    let transactionType: TransactionType
    
    var id: Int {
        return transactionId
    }
    
    enum TransactionType: String, Codable  {
        case income
        case expense
    }
    
    enum CodingKeys: String, CodingKey {
        case transactionId
        case description
        case amount
        case creationDate
        case transactionCategory
        case transactionType
    }

}
