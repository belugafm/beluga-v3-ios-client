import SwiftUI

@main
struct BelugaApp: App {
    @State var oAuthModel = OAuthModel()
    var body: some Scene {
        WindowGroup {
            ContentView(timelineModel: TimelineModel()).environmentObject(oAuthModel).onOpenURL { url in
                print(url)
                guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                      let albumPath = components.path,
                      let params = components.queryItems
                else {
                    print("Invalid URL")
                    return
                }
                print(albumPath)
                guard let accessToken = params.getValue(for: "access_token") else {
                    return
                }
                guard let accessTokenSecret = params.getValue(for: "access_token_secret") else {
                    return
                }
                DispatchQueue.main.async {
                    oAuthModel.accessToken = accessToken
                    oAuthModel.accessTokenSecret = accessTokenSecret
                    print(accessToken)
                    print(accessTokenSecret)
                }
            }
        }
    }
}
