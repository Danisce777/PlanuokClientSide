//
//  TransactionView.swift
//  planuokFetch
//
//  Created by MacBook on 28/09/2025.
//

import SwiftUI

struct AddTransactionView: View {
    
    @EnvironmentObject var transactionViewModel: NetworkManager
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var type: TransactionType = .income
    @State private var date = Date()
    
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Form{
                    
                    Section("Transaction Details") {
                        Picker("Type", selection: $type) {
                            Text("Income").tag(TransactionType.income)
                            Text("Expense").tag(TransactionType.expense)
                        }
                        .pickerStyle(.segmented)
                        
                        TextField("Enter Amount: ", text: $amount)
                            .keyboardType(.decimalPad)
                        
                        TextField("Enter description: ", text: $description)
                        
                        TextField("Category", text: $category)
                        
                        DatePicker("Please select date", selection: $date, displayedComponents: .date)
                        
                    }
                }
                
                Spacer()
                
                Section {
                    Button(action: {
                        Task {
                            await handleAddTransaction()
                        }
                    }) {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Add Transaction")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .navigationTitle("Add Transaction")
            .alert("Success!", isPresented: $showSuccess) {
                Button("OK") {
                    clearForm()
                }
            } message: {
                Text("Transaction added successfully")
            }
        }
    }
    
    private func handleAddTransaction() async {
        errorMessage = ""
        
        guard let amountValue = Double(amount) else {
            errorMessage = "Please enter a valid amount."
            return
        }
        
        isLoading = true
        
        do {
            try await transactionViewModel.createTransaction(
                amount: amountValue,
                description: description,
                category: category,
                type: type,
                date: date
            )
            showSuccess = true
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    private func clearForm() {
        amount = ""
        description = ""
        category = ""
        type = .expense
        date = Date()
    }
}
    
#Preview {
    AddTransactionView()
}
