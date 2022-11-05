import SwiftUI

struct HomeView: View {
    @EnvironmentObject var timelineModel: ChannelTimelineModel
    @EnvironmentObject var api: API
    var body: some View {
        VStack {
            TimelineView().environmentObject(timelineModel)
            Button {
                Task {
                    do {
                        let _ = try await api.postMessage(text: "投稿テスト", channelId: 5)
                    } catch {}
                }
            } label: {
                Text("投稿する")
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthCredential = OAuthCredential()
        let oAuthRequest = OAuthRequest(credential: oAuthCredential)
        HomeView().environmentObject(ChannelTimelineModel(oAuthRequest: oAuthRequest)).environmentObject(API(oAuthRequest: oAuthRequest))
    }
}
