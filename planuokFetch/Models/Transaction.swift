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
    let date: Date
    let category: String
    let type: TransactionType
 
}

enum TransactionType: String, Codable  {
    case income
    case expense
}
