import Foundation

struct Channel: Identifiable, Codable {
    let id: Int
    let name: String
    let unique_name: String
    let message_count: Int
    let status_string: String
}
