import Foundation

struct UserRequest: Codable, Hashable, Identifiable {
    let id: Int
    let username: String
    let email: String
//    let creationDate: String?
}
