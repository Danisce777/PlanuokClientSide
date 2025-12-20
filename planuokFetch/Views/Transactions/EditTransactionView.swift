import SwiftUI

struct EditTransactionView: View {
    
    let transaction: Transaction

    @EnvironmentObject var transactionService: TransactionService
    @EnvironmentObject var categoryService: CategoryService
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategoryId: Int?
    @State private var type: TransactionType = .income
    @State private var date = Date()
    @State private var occurredDate = Date()
    @State private var categories: [TransactionCategory] = []
    
    @State private var categoryName = ""
    @State private var categoryType: TransactionType = .expense
    
    @State private var showCategoryCreation = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showSuccess = false

    init(transaction: Transaction) {
        self.transaction = transaction
        _title = State(initialValue: transaction.title)
        _amount = State(initialValue: String(format: "%.2f", transaction.amount))
        _description = State(initialValue: transaction.description)
        _selectedCategoryId = State(initialValue: transaction.category.id)
        _type = State(initialValue: transaction.transactionType)
        _occurredDate = State(initialValue: transaction.occurredDate)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form{
                    Section {
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
                        
                        HStack {
                            TextField("Title", text: $title)
                                .keyboardType(.default)
                                .font(.title3)
                        }
                        
                        HStack {
                            Text("$")
                                .foregroundColor(.blue)
                                .font(.title3)
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.title3)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Description")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.top, 12)
                                    .padding(.leading, 9)
                            }
                            TextEditor(text: $description)
                                .scrollContentBackground(.hidden)
                                .frame(height: 150)
                                .padding(5)
                        }
                        
                        HStack {
                            Picker("Category", selection: $selectedCategoryId) {
                                Text("Select Category").tag(nil as Int?)
                                ForEach(categories) { category in
                                    Text(category.name).tag(category.id as Int?)
                                }
                            }
                            
                            Button(action: {
                                showCategoryCreation = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        DatePicker("Date", selection: $occurredDate, displayedComponents: .date)
                    }
                    
                    if !errorMessage.isEmpty {
                        Section {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(errorMessage)
                            }
                            .foregroundColor(.red)
                            .font(.footnote)
                        }
                    }
                    
                    Section {
                        HStack(spacing: 10) {
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            
                            Button(action: {
                                Task {
                                    await handleEditTransaction()
                                }
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Save Changes")
                                        .frame(maxWidth: .infinity)
                                        .fontWeight(.semibold)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Transaction")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        
        .task {
             await loadCategories()
         }
        
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Transaction updated successfully")
        }
    }
    
    private func loadCategories() async {
        do {
            categories = try await categoryService.getTransactionCategories(type: type)
        } catch {
            errorMessage = error.localizedDescription + "Uknown error occurred. Please try again later."
        }
    }
    
    private func handleEditTransaction() async {
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
            let _ = try await transactionService.modifyTransaction(
                by: transaction.transactionId,
                title: title,
                amount: amountValue,
                description: description,
                categoryId: categoryId,
                type: type,
                occurredDate: occurredDate
            )
            
            try await transactionService.getUsersTransactions()
            
            isLoading = false
            showSuccess = true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    let dummyUser = Creator(id: 1, username: "John", email: "john@example.com")
    let foodCategory = TransactionCategory(id: 1, name: "food", type: .expense, isDefault: false)
    
    let mockTransaction = Transaction(
        transactionId: 101,
        title: "Grocery Shopping",
        description: "Weekly market run",
        amount: 50.0,
        creator: dummyUser,
        creationDate: Date(),
        transactionType: .expense,
        category: foodCategory,
        occurredDate: Date()
    )
    
    return EditTransactionView(transaction: mockTransaction)
        .environmentObject(TransactionService())
        .environmentObject(CategoryService())
}
