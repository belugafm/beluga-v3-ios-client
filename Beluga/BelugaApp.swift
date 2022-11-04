import SwiftUI

@main
struct BelugaApp: App {
    @State var oAuthModel = OAuthModel()
    var body: some Scene {
        WindowGroup {
            ContentView(timelineModel: TimelineModel()).environmentObject(oAuthModel).onOpenURL { url in
                print(url)
                guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                      let path = components.path,
                      let params = components.queryItems
                else {
                    print("Invalid URL")
                    return
                }
                print(path)
                guard let requestToken = params.getValue(for: "request_token") else {
                    return
                }
                guard let verifier = params.getValue(for: "verifier") else {
                    return
                }
                guard oAuthModel.requestToken == requestToken else {
                    print("Invalid session")
                    return
                }
                Task {
                    do {
                        guard let requestToken = oAuthModel.requestToken else {
                            return
                        }
                        guard let requestTokenSecret = oAuthModel.requestTokenSecret else {
                            return
                        }
                        let (accessToken, accessTokenSecret) = try await oAuthModel.fetchAccessToken(requestToken: requestToken, requestTokenSecret: requestTokenSecret, verifier: verifier)
                        DispatchQueue.main.async {
                            oAuthModel.accessToken = accessToken
                            oAuthModel.accessTokenSecret = accessTokenSecret
                            print(accessToken)
                            print(accessTokenSecret)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
