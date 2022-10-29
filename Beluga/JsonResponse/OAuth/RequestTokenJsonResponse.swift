import Foundation

struct RequestTokenJsonResponse: Codable {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let request_token: String?
    let request_token_secret: String?
}
