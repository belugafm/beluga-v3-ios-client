import Foundation

enum ExploreViewModelError: Error {
    case failedToFetchChannelGroups
    case failedToFetchChannels
    case failedToTransition
}

class ExploreViewModel: ObservableObject {
    private let oAuthRequest: OAuthRequest
    private var channelGroupId: Int
    @Published var failedToTransition: Bool = false
    @Published var channels: [Channel] = []
    @Published var channelGroups: [ChannelGroup] = []
    init(oAuthRequest: OAuthRequest, channelGroupId: Int? = nil) {
        self.oAuthRequest = oAuthRequest
        self.channelGroupId = channelGroupId ?? 1 // 1 is global channel group id
        Task {
            do {
                try await self.transition()
            } catch {}
        }
    }

    func listChannelGroups(channelGroupId: Int) async throws -> [ChannelGroup] {
        let request = try oAuthRequest.getAuthorizedUrlRequest(endpoint: .ListChannelGroups, httpMethod: .GET, body: [
            URLQueryItem(name: "id", value: String(channelGroupId))
        ])
        let response = try await oAuthRequest.fetch(request: request, ChannelGroupListChannelGroupsJsonResponse.self)
        guard let channelGroups = response.channel_groups else {
            throw ExploreViewModelError.failedToFetchChannelGroups
        }
        return channelGroups
    }

    func listChannels(channelGroupId: Int) async throws -> [Channel] {
        let request = try oAuthRequest.getAuthorizedUrlRequest(endpoint: .ListChannels, httpMethod: .GET, body: [
            URLQueryItem(name: "id", value: String(channelGroupId))
        ])
        let response = try await oAuthRequest.fetch(request: request, ChannelGroupListChannelsJsonResponse.self)
        guard let channels = response.channels else {
            throw ExploreViewModelError.failedToFetchChannelGroups
        }
        return channels
    }

    func transition() async throws {
        do {
            let channelGroups = try await listChannelGroups(channelGroupId: channelGroupId)
            let channels = try await listChannels(channelGroupId: channelGroupId)
            print("OK!")
            DispatchQueue.main.async {
                self.channelGroups = channelGroups
                self.channels = channels
                self.failedToTransition = false
            }
        } catch {
            print(error)
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.failedToTransition = true
            }
            throw ExploreViewModelError.failedToTransition
        }
    }
}
