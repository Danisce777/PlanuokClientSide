//
//  NetworkManager.swift
//  planuokFetch
//
//  Created by MacBook on 27/09/2025.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    
    @Published var users: [UserRequest] = []
    @Published var transactions: [TransactionRequest] = []

    
    init(){}
    
    func fetchUsers(){
        
        guard let url = URL(string: "http://localhost:8081/users" ) else {return}
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    print(String(data: data, encoding: .utf8)!)
                    let decodedData = try JSONDecoder().decode([UserRequest].self, from: data)
                    
                    DispatchQueue.main.async{
                        self.users = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("Network error: \(error.localizedDescription)")
            }
        } .resume( )
    }
    
    func postUser(username: String, password: String, email: String) {
                            
        guard let url = URL(string: "http://localhost:8081/api/auth/register" ) else {return}

        let newUser = User(username: username, password: password, email: email)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(newUser)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.fetchUsers()
            }
            
        } .resume()
    }
    
    
    func createTransaction(_ transaction: Transaction) async throws {
        
        guard let url = URL(string: "http://localhost:8081/transactions" ) else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        

        
    }
    
    func getAllTransactions(){
        
        guard let url = URL(string: "http://localhost:8081/transactions" ) else {return}
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    print(String(data: data, encoding: .utf8)!)
                    let decodedData = try JSONDecoder().decode([TransactionRequest].self, from: data)
                    
                    DispatchQueue.main.async{
                        self.transactions = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("Network error: \(error.localizedDescription)")
            }
        } .resume( )
    }
    
    
    
    
}
