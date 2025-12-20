import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var transactionService: TransactionService
    @EnvironmentObject var categoryService: CategoryService

    /*
     MARK: Add date account created
     Add Profile Picture
     Username and other stuff
     Logout option
     
    */
    
    var body: some View {
        NavigationStack {
            
            List {
                if let user = authService.currentUser {
                    Section() {
                        Text("Username: \(user.username)")
                        Text("Email: \(user.email)")
                        
//                        Text(user.creationDate)
                    }
                }
            }
            
            Button ("Logout") {
                Task {
                    authService.logout()
                }
            }
        }
        .navigationTitle(Text("Profile"))
    }
    
    func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            return date.formatted(date: .long, time: .omitted)
        }
        return iso
    }
}



#Preview {
ProfileView()
    .environmentObject(TransactionService())
    .environmentObject(CategoryService())
    .environmentObject(AuthService())
}
