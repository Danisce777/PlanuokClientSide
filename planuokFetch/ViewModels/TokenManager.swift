//
//  TokenManager.swift
//  planuokFetch
//
//  Created by MacBook on 22/11/2025.
//

import Foundation
import Security

class TokenManager {
    
    static let shared = TokenManager()
    
    private let tokenKey = "jwt_token"
    
    private init(){}
    
    func saveToken(_ token: String) {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("Token saved successfully")
        } else {
            print("Failed to save token: \(status)")
        }
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            let token = String(data: data, encoding: .utf8)
            print("Token retrieved: \(token?.prefix(20) ?? "nil")...")
            return token
        } else {
            print("Failed to retrieve token: \(status)")
            return nil
        }
    }
    
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            print("Token deleted successfully")
        } else {
            print("Failed to delete token: \(status)")
        }
    }
    
}
