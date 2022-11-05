
import Foundation

enum Endpoint: String {
    case GenerateRequestToken = "/oauth/request_token"
    case GenerateAccessToken = "/oauth/access_token"
    case GetChannelGroupTimeline = "/timeline/channel_group"
    case GetChannelTimeline = "/timeline/channel"
    case PostMessage = "/message/post"
}

enum HTTPMethod: String {
    case POST
    case GET
}
