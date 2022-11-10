import SwiftUI

struct ExploreViewChannelsView: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @ObservedObject var viewModel: ExploreViewModel

    init(viewModel: ExploreViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack {
                if viewModel.channelGroups.count > 0 {
                    HStack {
                        Text("チャンネルグループ").bold()
                        Spacer()
                    }
                }
                LazyVStack {
                    ForEach(viewModel.channelGroups) { channelGroup in
                        NavigationLink {
                            ExploreView(viewModel: ExploreViewModel(oAuthRequest: oAuthRequest, channelGroup: channelGroup))
                                .environmentObject(oAuthRequest)
                        } label: {
                            ExploreViewChannelGroupLink(channelGroup: channelGroup)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)

            Divider()

            VStack {
                if viewModel.channels.count > 0 {
                    HStack {
                        Text("チャンネル").bold()
                        Spacer()
                    }
                }
                LazyVStack {
                    ForEach(viewModel.channels) { channel in
                        NavigationLink {
                            ChannelTimelineView(viewModel: ChannelTimelineViewModel(oAuthRequest: oAuthRequest, channel: channel))
                        } label: {
                            ExploreViewChannelLink(channel: channel)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
    }
}

struct ExploreViewChannelsView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthRequest = OAuthRequest(credential: OAuthCredential())
        let viewModel = ExploreViewModel(oAuthRequest: oAuthRequest)
        ExploreViewChannelsView(viewModel: viewModel).environmentObject(oAuthRequest)
    }
}
