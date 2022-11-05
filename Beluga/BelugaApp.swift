import SwiftUI

@main
struct BelugaApp: App {
    @State var oAuthCredential: OAuthCredential
    @State var oAuthRequest: OAuthRequest
    @State var presentLoginView: Bool
    init() {
        let oAuthCredential = OAuthCredential()
        self.oAuthCredential = oAuthCredential
        self.oAuthRequest = OAuthRequest(credential: oAuthCredential)
        self.presentLoginView = oAuthCredential.needsLogin()
    }

    var body: some Scene {
        WindowGroup {
            if presentLoginView {
                LoginView()
                    .environmentObject(oAuthCredential)
                    .environmentObject(oAuthRequest)
                    .onOpenURL { url in
                        print(url)
                        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                              let action = components.host,
                              let params = components.queryItems
                        else {
                            print("Invalid URL")
                            return
                        }
                        if action == "signin" {
                            guard let incomingRequestToken = params.getValue(for: "request_token") else {
                                return
                            }
                            guard let verifier = params.getValue(for: "verifier") else {
                                return
                            }
                            Task {
                                do {
                                    guard let requestToken = oAuthCredential.requestToken else {
                                        return
                                    }
                                    guard requestToken == incomingRequestToken else {
                                        return
                                    }
                                    guard let requestTokenSecret = oAuthCredential.requestTokenSecret else {
                                        return
                                    }
                                    let request = try oAuthRequest.getUrlRequestForAccessToken(requestToken: requestToken, requestTokenSecret: requestTokenSecret, verifier: verifier)
                                    let response = try await oAuthRequest.fetch(request: request, AccessTokenJsonResponse.self)
                                    guard let accessToken = response.access_token else {
                                        return
                                    }
                                    guard let accessTokenSecret = response.access_token_secret else {
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        oAuthCredential.accessToken = accessToken
                                        oAuthCredential.accessTokenSecret = accessTokenSecret
                                        presentLoginView = false
                                        print(accessToken)
                                        print(accessTokenSecret)
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    }
            } else {
                MainTabView()
                    .environmentObject(ChannelTimelineModel(oAuthRequest: oAuthRequest))
                    .environmentObject(API(oAuthRequest: oAuthRequest))
                    .environmentObject(oAuthRequest)
            }
        }
    }
}
