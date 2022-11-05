import Foundation

enum ChannelTimelineModelError: Error {
    case failedToFetchMessages
}

class ChannelTimelineViewModel: ObservableObject {
    private let oAuthRequest: OAuthRequest
    let channel: Channel
    @Published var pendingRequest: Bool = false
    @Published var shouldScrollDown: Bool = false
    @Published var messages: [Message] = []
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
            let messages = try await fetchMessages()
            DispatchQueue.main.async {
                self.messages = messages.reversed()
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
