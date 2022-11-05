import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @ObservedObject var viewModel: ExploreViewModel
    init(viewModel: ExploreViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.failedToTransition {
            Text("読み込みに失敗しました")
        } else {
            VStack {
                ScrollView {
                    Text("チャンネルグループ").bold()
                    LazyVStack {
                        ForEach(viewModel.channelGroups) { channelGroup in
                            NavigationLink {
                                ExploreView(viewModel: ExploreViewModel(oAuthRequest: oAuthRequest, channelGroup: channelGroup))
                                    .environmentObject(oAuthRequest)
                            } label: {
                                Text(channelGroup.name)
                            }
                        }
                    }
                    Text("チャンネル").bold()
                    LazyVStack {
                        ForEach(viewModel.channels) { channel in
                            NavigationLink {
                                ChannelTimelineView(viewModel: ChannelTimelineViewModel(oAuthRequest: oAuthRequest, channel: channel))
                            } label: {
                                Text(channel.status_string + " " + channel.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.channelGroup != nil ? viewModel.channelGroup!.name : "探す")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthRequest = OAuthRequest(credential: OAuthCredential())
        ExploreView(viewModel: ExploreViewModel(oAuthRequest: oAuthRequest))
    }
}
