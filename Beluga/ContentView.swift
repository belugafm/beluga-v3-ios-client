import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timelineModel: TimelineModel
    @EnvironmentObject var oAuthCredential: OAuthCredential
    @EnvironmentObject var oAuthRequest: OAuthRequest
    var body: some View {
        VStack {
            TimelineView().environmentObject(timelineModel)
            Text(oAuthCredential.accessToken)
            Text(oAuthCredential.accessTokenSecret)
            Button("Login") {
                Task {
                    guard oAuthCredential.needsLogin() else {
                        return
                    }
                    do {
                        print("do")
                        let request = try oAuthRequest.getUrlRequestForRequestToken()
                        print("request")
                        let response = try await oAuthRequest.fetch(request: request, RequestTokenJsonResponse.self)
                        print("response")
                        guard let requestToken = response.request_token else {
                            return
                        }
                        guard let requestTokenSecret = response.request_token_secret else {
                            return
                        }
                        oAuthCredential.requestToken = requestToken
                        oAuthCredential.requestTokenSecret = requestTokenSecret

                        let parameters = [
                            URLQueryItem(name: "consumer_key", value: Config.consumerKey),
                            URLQueryItem(name: "consumer_secret", value: Config.consumerSecret),
                            URLQueryItem(name: "request_token", value: oAuthCredential.requestToken),
                            URLQueryItem(name: "request_token_secret", value: oAuthCredential.requestTokenSecret),
                        ]
                        let query = parameters.buildQueryString()
                        guard let url = URL(string: "\(Config.webBaseUrl)/oauth/authorize?\(query)") else {
                            throw ApiError.invalidEndpointUrl
                        }

                        UIApplication.shared.open(url, options: [.universalLinksOnly: false], completionHandler: { _ in
                        })
                    } catch {
                        print("Error:", error.localizedDescription)
                    }
                }
            }
            Button("Post") {
                Task {}
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthCredential = OAuthCredential()
        let oAuthRequest = OAuthRequest(credential: oAuthCredential)
        ContentView().environmentObject(oAuthCredential).environmentObject(TimelineModel(oAuthRequest: oAuthRequest)).environmentObject(oAuthRequest)
    }
}
