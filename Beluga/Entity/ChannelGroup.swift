import Foundation

struct ChannelGroup: Identifiable, Codable {
    let id: Int
    let name: String
    let unique_name: String
    let description: String?
    let parent_id: Int
    let message_count: Int
}
