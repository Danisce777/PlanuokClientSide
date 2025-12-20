import Foundation

struct AuthResponse: Codable {
    
    let token: String
    let username: String
    let email: String
    let password: String?
    let userId: Int?
//    let creationDate: String
    
    
    
    enum CodingKeys: String, CodingKey {
        case token, username, email, password, userId
        // creationDate

    }
}
