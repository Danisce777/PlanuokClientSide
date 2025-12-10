//
//  AuthResponse.swift
//  planuokFetch
//
//  Created by MacBook on 08/12/2025.
//

import Foundation

struct AuthResponse: Codable {
    
    let token: String
    let username: String
    let email: String
    let password: String?
    let userId: Int?
    
    enum CodingKeys: String, CodingKey {
        case token, username, email, password, userId
    }
}
