import SwiftUI

struct AddTransactionView: View {
    
    @EnvironmentObject var networkManager: NetworkManager
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategoryId: Int?
    @State private var type: TransactionType = .income
    @State private var date = Date()
    @State private var categories: [TransactionCategory] = []
    
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
                        .onChange(of: type) { oldValue, newValue in
                            Task {
                                await loadCategories()
                            }
                            selectedCategoryId = nil
                        }
                        
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        
                        TextField("Description", text: $description)
                        
                        
                        
                        Picker("Category", selection: $selectedCategoryId) {
                            Text("Select Category").tag(nil as Int?)
                            ForEach(categories) { category in
                                Text(category.name).tag(category.id as Int?)
                            }
                        }

                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        
                    }
                    
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await handleAddTransaction()
                    }
                }) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Add Transaction")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
                .disabled(isLoading || selectedCategoryId == nil)
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Add Transaction")
            .task {
                await loadCategories()
            }
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
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "Please enter a valid amount."
            return
        }
        
        guard let categoryId = selectedCategoryId else {
            errorMessage = "Please select a category."
            return
        }
        
        isLoading = true
        
        do {
            try await networkManager.createTransaction(
                amount: amountValue,
                description: description,
                categoryId: categoryId,
                type: type,
                date: date
            )
            showSuccess = true
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }


    private func loadCategories() async {
        do {
            categories = try await networkManager.getTransactionCategories(type: type)
        } catch {
            errorMessage = "Failed to load categories"
        }
    }

    private func clearForm() {
        amount = ""
        description = ""
        selectedCategoryId = nil
        type = .expense
        date = Date()
    }
}
    
#Preview {
    AddTransactionView().environmentObject(NetworkManager())
}
