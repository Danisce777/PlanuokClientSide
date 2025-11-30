//
//  AuthViewModel.swift
//  planuokFetch
//
//  Created by MacBook on 28/09/2025.
//

import Foundation
import Combine

protocol AuthenticationFormProtocol {
    var formIsValid: Bool {get}
}


class AuthViewModel: ObservableObject {
    
    @Published var currentUser: User
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    
    func createUser(username: String, password: String, email: String) -> User {
        
        User(username: username, password: password, email: email)
    }
    
    
    
}
