import SwiftUI

struct LoginView: View {
    @EnvironmentObject var oAuthCredential: OAuthCredential
    @EnvironmentObject var oAuthRequest: OAuthRequest
    var body: some View {
        VStack {
            Text("認証情報を取得する必要があります。「ログインする」を押すとブラウザが起動するのでログイン後「認証する」ボタンを押してください。").padding(10)
            Button {
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
            } label: {
                Text("ログインする")
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(Color(uiColor: .systemBlue))
                    .clipShape(Capsule())
            }
        }
        .padding()
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthCredential = OAuthCredential()
        let oAuthRequest = OAuthRequest(credential: oAuthCredential)
        LoginView().environmentObject(oAuthCredential).environmentObject(oAuthRequest)
    }
}
