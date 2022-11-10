import SwiftUI

enum ExploreViewTabItemType: String, CaseIterable {
    case topic = "探す"
    case timeline = "タイムライン"
    case description = "概要"
}

struct ExploreView: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @ObservedObject var viewModel: ExploreViewModel
    @State private var selectedTab: ExploreViewTabItemType = .topic

    init(viewModel: ExploreViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.channelGroup != nil {
                VStack {
                    ExploreViewChannelGroupCard(channelGroup: viewModel.channelGroup!)
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
            }

            HStack {
                Spacer()
                ForEach(ExploreViewTabItemType.allCases, id: \.self) { tabItem in
                    ExploreViewTabItem(tabItem: tabItem, text: tabItem.rawValue, selected: $selectedTab)
                    Spacer()
                }
            }
            Divider().background(MyColor.dividerColor)

            TabView(selection: $selectedTab) {
                ExploreViewChannelsView(viewModel: self.viewModel)
                    .environmentObject(self.oAuthRequest)
                    .tag(ExploreViewTabItemType.topic)
                if viewModel.channelGroup != nil {
                    ExploreViewTimeline(viewModel: ChannelGroupTimelineViewModel(oAuthRequest: self.oAuthRequest, channelGroup: self.viewModel.channelGroup!))
                        .environmentObject(self.oAuthRequest)
                        .tag(ExploreViewTabItemType.timeline)
                    ExploreViewDescriptionView(channelGroup: self.viewModel.channelGroup!)
                        .tag(ExploreViewTabItemType.description)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle(viewModel.channelGroup != nil ? viewModel.channelGroup!.name : "探す")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthRequest = OAuthRequest(credential: OAuthCredential())
        let viewModel = ExploreViewModel(oAuthRequest: oAuthRequest)
        ExploreView(viewModel: viewModel).environmentObject(oAuthRequest)
    }
}
