import SwiftUI

struct CategoryCreationView: View {
    
    @EnvironmentObject private var categoryService: CategoryService
    @State private var categoryName = ""
    @State private var categoryType: TransactionType = .expense
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("Create Category")
                   .font(.system(.title2, design: .rounded).bold())
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Name")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Category name", text: $categoryName)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    .autocorrectionDisabled()
            }
            
            Picker("Type", selection: $categoryType) {
                Text("Income").tag(TransactionType.income)
                Text("Expense").tag(TransactionType.expense)
            }
            .pickerStyle(.segmented)
            .padding(.top, 4)

            Button(action: {
                Task { await handleCategoryCreation() }
            }) {
                HStack {
                    if isLoading { ProgressView() }
                    Text("Add Category")
                }
                .frame(maxWidth: .infinity)
                          .padding()
                          .background(categoryName.isEmpty || isLoading ? Color.blue.opacity(0.5) : Color.blue)
                          .foregroundColor(.white)
                          .cornerRadius(12)
                          .shadow(color: .black.opacity(0.15), radius: 5)
            }
            .disabled(categoryName.isEmpty || isLoading)

        }
        .padding()
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1)
    }
    
    private func handleCategoryCreation() async {
        guard !categoryName.isEmpty else { return }

        isLoading = true
        errorMessage = ""
        
        do {
            _ = try await categoryService.addCategory(
                name: categoryName,
                type: categoryType,
                isDefault: false
            )
            
            categoryName = ""
            categoryType = .expense
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    CategoryCreationView()
}
