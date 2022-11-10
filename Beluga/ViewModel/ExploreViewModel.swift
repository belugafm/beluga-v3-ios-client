import Foundation

enum ExploreViewModelError: Error {
    case failedToFetchChannelGroup
    case failedToFetchChannelGroups
    case failedToFetchChannels
    case failedToTransition
}

class ExploreViewModel: ObservableObject {
    private let oAuthRequest: OAuthRequest
    @Published var channelGroup: ChannelGroup?
    @Published var failedToTransition: Bool = false
    @Published var channels: [Channel] = []
    @Published var channelGroups: [ChannelGroup] = []
    init(oAuthRequest: OAuthRequest) {
        self.oAuthRequest = oAuthRequest
        Task {
            do {
                self.channelGroup = try await self.getChannelGroup(channelGroupId: 1) // 1 is global channel group id
                try await self.transition()
            } catch {}
        }
    }

    init(oAuthRequest: OAuthRequest, channelGroup: ChannelGroup) {
        self.oAuthRequest = oAuthRequest
        self.channelGroup = channelGroup
        Task {
            do {
                try await self.transition()
            } catch {}
        }
    }

    func getChannelGroup(channelGroupId: Int) async throws -> ChannelGroup {
        let request = try oAuthRequest.getAuthorizedUrlRequest(endpoint: .ShowChannelGroup, httpMethod: .GET, body: [
            URLQueryItem(name: "id", value: String(channelGroupId))
        ])
        let response = try await oAuthRequest.fetch(request: request, ChannelGroupShowJsonResponse.self)
        guard let channelGroup = response.channel_group else {
            throw ExploreViewModelError.failedToFetchChannelGroup
        }
        return channelGroup
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
        guard let channelGroup = channelGroup else {
            throw ExploreViewModelError.failedToTransition
        }
        do {
            channelGroups = try await listChannelGroups(channelGroupId: channelGroup.id)
            channels = try await listChannels(channelGroupId: channelGroup.id)
            failedToTransition = false
        } catch {
            failedToTransition = true
            print(error)
            print(error.localizedDescription)
            throw ExploreViewModelError.failedToTransition
        }
    }
}
