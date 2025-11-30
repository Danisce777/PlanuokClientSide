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
    let date: Date
    let category: String
    let type: TransactionType
    
    
    
    var id: Int {
        return transactionId
    }
    
    
    enum TransactionType: String, Codable  {
        case income
        case expense
    }
 
}
