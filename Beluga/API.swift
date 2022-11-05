import Foundation

class API: ObservableObject {
    var oAuthRequest: OAuthRequest
    init(oAuthRequest: OAuthRequest) {
        self.oAuthRequest = oAuthRequest
    }

    func postMessage(text: String, channelId: Int) async throws -> Bool {
        let request = try oAuthRequest.getAuthorizedUrlRequest(endpoint: .PostMessage, httpMethod: .POST, body: [URLQueryItem(name: "text", value: text), URLQueryItem(name: "channel_id", value: String(channelId))])
        let _ = try await oAuthRequest.fetch(request: request, JsonResponse.self)
        return true
    }
}
