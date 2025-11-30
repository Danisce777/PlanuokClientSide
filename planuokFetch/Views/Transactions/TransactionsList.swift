//
//  TransactionsList.swift
//  planuokFetch
//
//  Created by MacBook on 21/11/2025.
//

import SwiftUI

struct TransactionsList: View {
    
    @StateObject var transactionViewModel = NetworkManager()


        
    var body: some View {
        
        NavigationStack{
            
            
            List(transactionViewModel.transactions) { transaction in
                HStack{
                    Text(transaction.description)
                    Text(transaction.category)
                }
            }
            
            Button {
                transactionViewModel.getAllTransactions()

            } label: {
                Text("Get all transactions")
            }
            
            
            
        }
        .onAppear {
                  transactionViewModel.getAllTransactions()
              }
    

    }
}

#Preview {
    TransactionsList()
}


