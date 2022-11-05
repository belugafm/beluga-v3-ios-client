import Foundation

struct ChannelGroupListChannelsJsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let channels: [Channel]?
}
