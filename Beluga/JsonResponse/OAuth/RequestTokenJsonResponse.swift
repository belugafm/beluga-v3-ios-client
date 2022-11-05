import Foundation

struct RequestTokenJsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let request_token: String?
    let request_token_secret: String?
}
