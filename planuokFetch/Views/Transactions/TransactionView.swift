//
//  TransactionView.swift
//  planuokFetch
//
//  Created by MacBook on 28/09/2025.
//

import SwiftUI

struct TransactionView: View {
    
    @StateObject var viewModel = NetworkManager()
    
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date.now
    @State private var type: TransactionType = .income
    @State private var category: String = ""
    
    
    var body: some View {
        
        VStack {
            Form{
                TextField("Enter description: ", text: $description)
                TextField("Enter Amount: ", text: $amount)
                
                DatePicker("Please select date", selection: $date, displayedComponents: [.date])
                    
                Picker(selection: $type ) {
                    Text("Income").tag(TransactionType.income)
                    Text("Expense").tag(TransactionType.expense)
                } label: {
                    Text("Choose Transaction Type")
                }
                TextField("Category", text: $category)
            }
        }
        
        Spacer()
        
        HStack {
            Button() {
                
                guard let amountValue = Double(amount) else { return
            }
                
                let tx = Transaction(transactionId: nil,
                    description: description,
                    amount: amountValue,
                    date: date,
                    category: category,
                    type: type)
                        
                description = ""
                amount = ""
                category = ""
            } label: {
                Text("Add Transaction")
            }
            .padding(8)
            .background(.blue)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 10)
            
            Button {
                
            } label: {
                Text("Cancel")
            }
        }
    }
}

#Preview {
    TransactionView()
}
