import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @EnvironmentObject var transactionService: TransactionService
    @State private var showSuccess = false
    @State private var showingAlert = false
    @State private var showEditView = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                Image(systemName: categoryIcon(for: transaction.category.name))
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Circle())
                
                Text(transaction.transactionType == .income ? "+$\(transaction.amount, specifier: "%.2f")" : "-$\(transaction.amount, specifier: "%.2f")")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(transaction.transactionType == .income ? .green : .red)
                
                Text(transaction.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    
                    DetailRow(
                        icon: "tag.fill",
                        label: "Category",
                        value: transaction.category.name.capitalized,
                        color: .blue
                    )
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.leading, 60)
                    
                    DetailRow(
                        icon: transaction.transactionType == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                        label: "Type",
                        value: transaction.transactionType == .income ? "Income" : "Expense",
                        color: transaction.transactionType == .income ? .green : .red
                    )
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.leading, 60)
                    
                    DetailRow(
                        icon: "calendar",
                        label: "Date",
                        value: transaction.occurredDate.formatted(date: .long, time: .omitted),
                        color: .orange
                    )
                    
                    if !transaction.description.isEmpty {
                        Divider()
                            .background(Color.white.opacity(0.3))
                            .padding(.leading, 60)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.purple)
                                    .frame(width: 24)
                                
                                Text("Description")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Text(transaction.description)
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 40)
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }
                .background(Color.black.opacity(0.85))
                .cornerRadius(16)
                .padding(.horizontal)
                .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button() {
                        showEditView = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.blue)
                    
                }
            }
        }
        
        .alert("Are you sure?", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await transactionService.deleteTransaction(by: transaction.transactionId)
                        print("Transaction deleted!")
                        dismiss()
                    } catch {
                        print("Failed to delete: \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("There is no undo")
        }
        .sheet(isPresented: $showEditView) {
            EditTransactionView(transaction: transaction)
                .environmentObject(transactionService)
        }
    }
                
    private func categoryIcon(for name: String) -> String {
            switch name.uppercased() {
            case "FOOD": return "fork.knife"
            case "TRANSPORTATION": return "car"
            case "ENTERTAINMENT": return "gamecontroller"
            case "SHOPPING": return "bag"
            case "BILLS": return "bolt.fill"
            case "HEALTHCARE": return "cross.case"
            case "DINING": return "wineglass"
            case "HOUSING": return "house"
            case "TRAVEL": return "airplane"
            case "EDUCATION": return "book"
            case "INSURANCE": return "shield.checkerboard"
            case "SUBSCRIPTIONS": return "tv"
            case "OTHER EXPENSE": return "tag"
                
            case "SALARY": return "banknote"
            case "FREELANCE": return "laptopcomputer"
            case "INVESTMENT": return "chart.line.uptrend.xyaxis"
            case "GIFT": return "gift"
            case "REFUNDS": return "arrow.uturn.left"
            case "BUSINESS INCOME": return "briefcase"
            case "SELLING": return "cart"
            case "RENTAL INCOME": return "house"
            case "INTEREST": return "percent"
            case "BONUS": return "star"
            case "PENSION": return "person.crop.circle"
            case "OTHER INCOME": return "plus.circle"
            default: return "tag"
            }
        }
    }
    
    struct DetailRow: View {
        let icon: String
        let label: String
        let value: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(width: 80, alignment: .leading)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
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
        
        let service = TransactionService()
        service.transactions = [mockTransaction]
        
        return NavigationStack {
            TransactionDetailView(transaction: mockTransaction)
                .environmentObject(service)
        
        }
}
