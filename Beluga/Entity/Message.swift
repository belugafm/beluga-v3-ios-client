import Foundation


struct MessageEntityChannel:Codable{
    let channel_id: Int
    let channel: Channel?
    let indices:[Int]
}

struct MessageEntityChannelGroup:Codable{
    let channel_group_id: Int
    let channel_group: ChannelGroup?
    let indices:[Int]
}

struct MessageEntityMessage:Codable{
    let message_id: Int
    let message: Message?
    let indices:[Int]
}

struct MessageEntityFile:Codable{
    let file_id: Int
    let file: File?
    let indices:[Int]
}

struct MessageEntityUrl:Codable{
    let title: String
    let description: String?
    let image_url: String?
    let indices:[Int]
}

struct MessageEntityStyle:Codable{
}

struct MessageEntities:Codable{
    let channels: [MessageEntityChannel]
    let channel_groups:[MessageEntityChannelGroup]
    let messages: [MessageEntityMessage]
    let files: [MessageEntityFile]
    let urls: [MessageEntityUrl]
    let favorited_users: [User]
    let style: [MessageEntityStyle]
}

struct Message:Identifiable, Codable {
    let id: Int
    let channel_id: Int
    let channel: Channel?
    let user_id: Int
    let user: User?
    let text: String
    let created_at: String
    let favorite_count: Int
    let favorited: Bool
    let like_count: Int
    let reply_count: Int
    let thread_id: Int?
    let deleted: Bool
    let entities: MessageEntities
}
