import Foundation

enum ExploreViewModelError: Error {
    case failedToFetchChannelGroups
    case failedToFetchChannels
    case failedToTransition
}

class ExploreViewModel: ObservableObject {
    private let oAuthRequest: OAuthRequest
    private var channelGroupId: Int
    let channelGroup: ChannelGroup?
    @Published var failedToTransition: Bool = false
    @Published var channels: [Channel] = []
    @Published var channelGroups: [ChannelGroup] = []
    init(oAuthRequest: OAuthRequest, channelGroup: ChannelGroup? = nil) {
        self.oAuthRequest = oAuthRequest
        self.channelGroupId = channelGroup != nil ? channelGroup!.id : 1 // 1 is global channel group id
        self.channelGroup = channelGroup
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
            channelGroups = try await listChannelGroups(channelGroupId: channelGroupId)
            channels = try await listChannels(channelGroupId: channelGroupId)
            failedToTransition = false
        } catch {
            failedToTransition = true
            print(error)
            print(error.localizedDescription)
            throw ExploreViewModelError.failedToTransition
        }
    }
}
