//
//  TransactionCategoryRequest.swift
//  planuokFetch
//
//  Created by MacBook on 17/12/2025.
//

import Foundation

struct TransactionCategoryRequest: Codable {
    
    let name: String
    let type: TransactionType
    let isDefault: Bool

    enum CodingKeys: String, CodingKey {
        case name, type, isDefault
    }
}

