import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let display_name: String?
}
