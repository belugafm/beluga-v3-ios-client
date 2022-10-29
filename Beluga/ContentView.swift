import SwiftUI

struct ContentView: View {
    @State var timelineModel: TimelineModel
    var body: some View {
        VStack {
            TimelineView()
            Button("Login") {
                Task {
                    do {
                        let model = OAuthModel()
                        let (requestToken, requestTokenSecret) = try await model.fetchRequestToken()
                        print(requestToken)
                        print(requestTokenSecret)
                        let parameters = [
                            URLQueryItem(name: "consumer_key", value: Config.consumerKey),
                            URLQueryItem(name: "consumer_secret", value: Config.consumerSecret),
                            URLQueryItem(name: "request_token", value: requestToken),
                            URLQueryItem(name: "request_token_secret", value: requestTokenSecret),
                        ]
                        let query = parameters.buildQueryString()
                        guard let url = URL(string: "https://beluga.fm/oauth/authorize?\(query)") else {
                            throw ApiError.invalidEndpointUrl
                        }

                        UIApplication.shared.open(url, options: [.universalLinksOnly: false], completionHandler: { _ in
                        })
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
        ContentView(timelineModel: TimelineModel())
    }
}
