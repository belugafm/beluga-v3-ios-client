import Foundation

struct TimelineChannelJsonResponse: Codable {
    let ok: Bool
    let messages: [Message]?
}
