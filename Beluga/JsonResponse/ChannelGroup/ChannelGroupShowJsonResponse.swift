import Foundation

struct ChannelGroupShowJsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let channel_group: ChannelGroup?
}
