import SwiftUI

struct TransactionsList: View {
    
    @EnvironmentObject var networkManager: NetworkManager
    @State private var errorMessage = ""
    @State private var isLoading = false
        
    private func categoryIcon(for name: String) -> String {
        switch name.uppercased() {
        case "food": return "fork.knife"
        case "transport": return "car"
        case "salary": return "banknote"
        case "shopping": return "bag"
        case "entertainment": return "music.note"
        default: return "tag"
        }
    }
        
    var body: some View {
        NavigationStack {
            List(networkManager.transactions) { transaction in
                HStack {
                    Image(systemName: categoryIcon(for: transaction.category.name))
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text(transaction.description)
                        Text(transaction.category.name)
                        Text(transaction.creationDate, style: .date)
                    }
                    Spacer()
                }
                
                Spacer()
                
                Text(transaction.transactionType == .income ? "+$\(transaction.amount, specifier: "%.2f")" : "-$\(transaction.amount, specifier: "%.2f")")
                                    .font(.headline)
                                    .bold()
                
            
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
            .onAppear()
        }
    }
        
    private func handleTransactionsFetching() async {
        isLoading = true
        errorMessage = ""
        
        do {
            try await networkManager.getUsersTransactions()
        } catch {
            errorMessage = "An unexpected error occured"
        }
        
        isLoading = false
    }
}

#Preview {
    TransactionsList().environmentObject(NetworkManager())
}
