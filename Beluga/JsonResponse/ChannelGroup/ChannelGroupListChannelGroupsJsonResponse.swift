import Foundation

struct ChannelGroupListChannelGroupsJsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
    let channel_groups: [ChannelGroup]?
}
