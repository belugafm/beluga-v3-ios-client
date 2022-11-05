import Foundation

struct TimelineChannelJsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let messages: [Message]?
}
