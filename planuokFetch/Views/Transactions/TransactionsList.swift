//
//  TransactionsList.swift
//  planuokFetch
//
//  Created by MacBook on 21/11/2025.
//

import SwiftUI

struct TransactionsList: View {
    
    @EnvironmentObject var networkManager: NetworkManager
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
    
        NavigationStack {
            VStack {
                List(networkManager.transactions) { transaction in
                    Text(transaction.description)
                    Text(transaction.transactionCategory)
                    Text(transaction.creationDate, style: .date)
                    Text(" \(transaction.amount)")
                }
            
                Button(action: {
                    Task {
                        await handleTransactionsFetching()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Get Transactions")
                            .bold()
                    }
                }
                .foregroundStyle(.white)
                .frame(height: 48)
                .frame(maxWidth: 370)
                .background(Color(.systemBlue))
                .cornerRadius(10)
            }
        }
    }
        
    private func handleTransactionsFetching() async {
        
        
        do {
            try await networkManager.getUsersTransactions()
        } catch {
            errorMessage = "An unexpected error occured"
        }
    }
}

#Preview {
    TransactionsList().environmentObject(NetworkManager())
}
