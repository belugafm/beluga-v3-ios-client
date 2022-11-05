import Foundation

struct AccessTokenJsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let access_token: String?
    let access_token_secret: String?
}
