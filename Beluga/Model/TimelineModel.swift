import Foundation

enum ApiError: Error {
    case invalidEndpointUrl
    case failedToFetchData
}

struct TimelineModel {
    func fetchMessages() async throws -> [Message] {
        guard let url = URL(string: "https://beluga.fm/api/v1/timeline/channel_debug?channel_id=2") else { throw ApiError.invalidEndpointUrl }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(TimelineChannelJsonResponse.self, from: data)
            return decodedData.messages!
        } catch {
            throw ApiError.failedToFetchData
        }
    }
}
