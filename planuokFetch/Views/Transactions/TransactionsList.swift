import SwiftUI

struct TransactionsList: View {
    
    @EnvironmentObject var transactionService: TransactionService
    @State private var errorMessage = ""
    @State private var isLoading = false
    
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
    
    var body: some View {
        NavigationStack {
            List(transactionService.transactions) { transaction in
                NavigationLink(destination: TransactionDetailView(transaction: transaction)) {
                    HStack (spacing: 10) {
                        Image(systemName: categoryIcon(for: transaction.category.name))
                            .font(.title)
                            .frame(width: 55, height: 55)
                            .background(Color.black.opacity(0.88))
                            .clipShape(Circle())
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.title)
                                .font(.subheadline)
                                .lineLimit(1)
                            
                            Text(transaction.category.name.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: 150, alignment: .leading)
                            
                            Text(transaction.occurredDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                                                
                        Text(transaction.transactionType == .income ? "+$\(transaction.amount, specifier: "%.2f")" : "-$\(transaction.amount, specifier: "%.2f")")
                            .foregroundColor(transaction.transactionType == .income ? .green : .red)
                            .bold()
                            .font(.headline)
                            .fixedSize()
                    }
                    .frame(height: 50)
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Transactions")
            .task {
                await handleTransactionsFetching()
            }
        }
    }
    
    private func handleTransactionsFetching() async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await transactionService.getUsersTransactions()
        } catch {
            errorMessage = "An unexpected error occured"
        }
        isLoading = false
    }

}

#Preview {
    let dummyUser = Creator(id: 1, username: "John", email: "john@example.com")
    
    let foodCategory = TransactionCategory(id: 1, name: "Wedding Expenses", type: .expense, isDefault: false)
    let salaryCategory = TransactionCategory(id: 2, name: "salary", type: .income, isDefault: true)
    let Wedding = TransactionCategory(id: 2, name: "Wedding Expenses", type: .income, isDefault: true)

    let mockTransactions = [
        Transaction(
            transactionId: 199,
            title: "Grocery shopping",
            description: "Weekly groceries",
            amount: 50.0,
            creator: dummyUser,
            creationDate: Date(),
            transactionType: .expense,
            category: foodCategory,
            occurredDate: Date()
        ),
        Transaction(
            transactionId: 200,
            title: "Monthly Salary",
            description: "Main job",
            amount: 2000.0,
            creator: dummyUser,
            creationDate: Date(),
            transactionType: .income,
            category: salaryCategory,
            occurredDate: Date()
        ),
        Transaction(
            transactionId: 200,
            title: "Wedding Expenses",
            description: "Main job",
            amount: 1000.0,
            creator: dummyUser,
            creationDate: Date(),
            transactionType: .income,
            category: Wedding,
            occurredDate: Date()
        )
    ]
    
    let service = TransactionService()
    service.transactions = mockTransactions
    
    return NavigationStack {
        TransactionsList()
            .environmentObject(service)
    }
}
