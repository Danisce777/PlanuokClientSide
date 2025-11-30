//
//  UserRequest.swift
//  planuokFetch
//
//  Created by MacBook on 03/11/2025.
//

import Foundation

struct UserRequest: Codable, Hashable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let createdAt: String?
}
