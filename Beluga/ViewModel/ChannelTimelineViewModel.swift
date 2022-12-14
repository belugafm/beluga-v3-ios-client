import Foundation

enum ChannelTimelineModelError: Error {
    case failedToFetchMessages
}

class ChannelTimelineViewModel: ObservableObject {
    private let oAuthRequest: OAuthRequest
    let channel: Channel
    @Published var pendingRequest: Bool = false
    @Published var shouldScrollDown: Bool = false
    @Published var messages: [ObservableMessage] = []
    init(oAuthRequest: OAuthRequest, channel: Channel) {
        self.oAuthRequest = oAuthRequest
        self.channel = channel
        Task {
            do {
                try await self.updateTimeline()
            } catch {}
        }
    }

    func postMessage(text: String) async {
        do {
            let request = try oAuthRequest.getAuthorizedUrlRequest(endpoint: .PostMessage, httpMethod: .POST, body: [
                URLQueryItem(name: "channel_id", value: String(channel.id)),
                URLQueryItem(name: "text", value: text)
            ])
            let _ = try await oAuthRequest.fetch(request: request, JsonResponse.self)
        } catch {
            print(error)
            print(error.localizedDescription)
        }
    }

    func updateTimeline() async throws {
        DispatchQueue.main.sync {
            self.pendingRequest = true
        }
        do {
            let jsonMessages = try await fetchMessages()
            var mutableMessages: [ObservableMessage] = []
            var consecutive = false
            var lastUserId: Int?
            jsonMessages.reversed().forEach { jsonMessage in
                if lastUserId != nil, jsonMessage.user_id == lastUserId {
                    consecutive = true
                }
                let message = ObservableMessage(id: jsonMessage.id, channel_id: jsonMessage.channel_id, channel: jsonMessage.channel, user_id: jsonMessage.user_id, user: jsonMessage.user, text: jsonMessage.text, created_at: jsonMessage.created_at, favorite_count: jsonMessage.favorite_count, favorited: jsonMessage.favorited, like_count: jsonMessage.like_count, reply_count: jsonMessage.reply_count, thread_id: jsonMessage.thread_id, deleted: jsonMessage.deleted, entities: jsonMessage.entities, consecutive: consecutive)
                mutableMessages.append(message)
                lastUserId = jsonMessage.user_id
                consecutive = false
            }
            let messages = mutableMessages
            DispatchQueue.main.async {
                self.messages = messages
                self.pendingRequest = false
                self.shouldScrollDown = true
            }
        } catch {
            print(error)
            print(error.localizedDescription)
            throw ChannelTimelineModelError.failedToFetchMessages
        }
    }

    func fetchMessages() async throws -> [Message] {
        let request = try oAuthRequest.getAuthorizedUrlRequest(endpoint: .GetChannelTimeline, httpMethod: .GET, body: [
            URLQueryItem(name: "channel_id", value: String(channel.id))
        ])
        let response = try await oAuthRequest.fetch(request: request, ChannelTimelineJsonResponse.self)
        guard let messages = response.messages else {
            throw ChannelTimelineModelError.failedToFetchMessages
        }
        return messages
    }
}
