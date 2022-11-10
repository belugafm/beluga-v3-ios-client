import Foundation

class ObservableMessage: ObservableObject, Identifiable {
    let id: Int
    let channel_id: Int
    let channel: Channel?
    let user_id: Int
    let user: User?
    @Published var text: String
    let created_at: String
    @Published var favorite_count: Int
    @Published var favorited: Bool
    @Published var like_count: Int
    @Published var reply_count: Int
    let thread_id: Int?
    @Published var deleted: Bool
    let entities: MessageEntities
    @Published var consecutive: Bool

    init(id: Int, channel_id: Int, channel: Channel?, user_id: Int, user: User?, text: String, created_at: String, favorite_count: Int, favorited: Bool, like_count: Int, reply_count: Int, thread_id: Int?, deleted: Bool, entities: MessageEntities, consecutive: Bool) {
        self.id = id
        self.channel_id = channel_id
        self.channel = channel
        self.user_id = user_id
        self.user = user
        self.text = text
        self.created_at = created_at
        self.favorite_count = favorite_count
        self.favorited = favorited
        self.like_count = like_count
        self.reply_count = reply_count
        self.thread_id = thread_id
        self.deleted = deleted
        self.entities = entities
        self.consecutive = consecutive
    }
}
