//
//  Transaction.swift
//  planuokFetch
//
//  Created by MacBook on 28/09/2025.
//


import Foundation
import Combine

struct Transaction: Codable {
    
    let transactionId: Int64?
    let description: String
    let amount: Double
    let creationDate: Date
    let transactionCategory: String
    let transactionType: TransactionType
}

enum TransactionType: String, Codable  {
    case income
    case expense
}
