import SwiftUI

struct UsersView: View {
    
    @StateObject var networkManager = NetworkManager()
    
    var body: some View {
        
        NavigationStack{
            
            List(networkManager.users){ user in
                HStack{
                    Text(user.username)
                    Text(user.email)

                }
                .padding()
            }
            .navigationTitle("Users list")
            
            HStack {
                Button(action: {
                    networkManager.fetchUsers()
                }, label: {
                    Text("Fetch")
                })
                .background(Color.green)
                .buttonStyle(BorderedButtonStyle())
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(Color.white)

                
                Button("Add New User") {
                    
                }

                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8.0)
                .buttonStyle(BorderedButtonStyle())
            }
            
            .onAppear{
                networkManager.fetchUsers()
            }
        }
    }
}

#Preview {
    UsersView()
}
