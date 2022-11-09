
import Foundation

enum Endpoint: String {
    case GenerateRequestToken = "/oauth/request_token"
    case GenerateAccessToken = "/oauth/access_token"
    case GetChannelGroupTimeline = "/timeline/channel_group"
    case GetChannelTimeline = "/timeline/channel"
    case PostMessage = "/message/post"
    case ListChannelGroups = "/channel_group/list_channel_groups"
    case ListChannels = "/channel_group/list_channels"
    case ShowChannelGroup = "/channel_group/show"
}

enum HTTPMethod: String {
    case POST
    case GET
}
