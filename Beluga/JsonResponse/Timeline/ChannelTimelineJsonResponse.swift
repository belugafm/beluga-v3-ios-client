import Foundation

struct ChannelTimelineJsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let messages: [Message]?
}
