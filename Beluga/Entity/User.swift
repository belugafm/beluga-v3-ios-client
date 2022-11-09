import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let display_name: String?
    let profile_image_url: String?
}
