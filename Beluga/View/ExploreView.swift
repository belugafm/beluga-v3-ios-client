import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @ObservedObject var viewModel: ExploreViewModel
    init(viewModel: ExploreViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            ScrollView {
                if viewModel.channelGroup != nil {
                    VStack {
                        ExploreViewChannelGroupCard(channelGroup: viewModel.channelGroup!)
                    }
                }
                VStack {
                    HStack {
                        Text("チャンネルグループ").bold()
                        Spacer()
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
                    HStack {
                        Text("チャンネル").bold()
                        Spacer()
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
        .navigationTitle(viewModel.channelGroup != nil ? viewModel.channelGroup!.name : "探す")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthRequest = OAuthRequest(credential: OAuthCredential())
        let viewModel = ExploreViewModel(oAuthRequest: oAuthRequest)
        ExploreView(viewModel: viewModel)
    }
}
