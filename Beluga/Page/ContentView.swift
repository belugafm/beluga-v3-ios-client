import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timelineModel: TimelineModel
    @EnvironmentObject var api: API
    var body: some View {
        VStack {
            TimelineView().environmentObject(timelineModel)
            Button("Post") {
                Task {
                    do {
                        let _ = try await api.postMessage(text: "投稿テスト", channelId: 2)
                    } catch {}
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthCredential = OAuthCredential()
        let oAuthRequest = OAuthRequest(credential: oAuthCredential)
        ContentView().environmentObject(TimelineModel(oAuthRequest: oAuthRequest)).environmentObject(API(oAuthRequest: oAuthRequest))
    }
}
