import Foundation

struct ChannelGroupTimelineJsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let messages: [Message]?
}
