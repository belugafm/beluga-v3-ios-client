import SwiftUI

struct ContentView: View {
    @State var timelineModel: TimelineModel
    @EnvironmentObject var oAuthModel: OAuthModel
    var body: some View {
        VStack {
            TimelineView()
            Text(oAuthModel.accessToken)
            Text(oAuthModel.accessTokenSecret)
            Button("Login") {
                Task {
                    guard oAuthModel.needsLogin() else {
                        return
                    }
                    do {
                        let (requestToken, requestTokenSecret) = try await oAuthModel.fetchRequestToken()
                        oAuthModel.requestToken = requestToken
                        oAuthModel.requestTokenSecret = requestTokenSecret

                        let parameters = [
                            URLQueryItem(name: "consumer_key", value: Config.consumerKey),
                            URLQueryItem(name: "consumer_secret", value: Config.consumerSecret),
                            URLQueryItem(name: "request_token", value: requestToken),
                            URLQueryItem(name: "request_token_secret", value: requestTokenSecret),
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
                Task {
                    do {
                        let succeeded = try await oAuthModel.postMessage(channelId: 2, text: "OAuth認証テスト")
                    } catch {
                        print("Error:", error.localizedDescription)
                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timelineModel: TimelineModel()).environmentObject(OAuthModel())
    }
}
