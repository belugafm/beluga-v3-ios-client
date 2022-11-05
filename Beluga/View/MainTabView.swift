import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var timelineModel: ChannelTimelineModel
    @EnvironmentObject var api: API
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @State private var selectedIndex: Int = 0
    var body: some View {
        TabView(selection: $selectedIndex) {
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
                .tabItem {
                    VStack {
                        Image(systemName: "house").environment(\.symbolVariants, .none)
                        Text("ホーム")
                    }
                }

            ExploreRootView()
                .environmentObject(self.oAuthRequest)
                .tabItem {
                    VStack {
                        Image(systemName: "number").environment(\.symbolVariants, .none)
                        Text("探す")
                    }
                }
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
                .tabItem {
                    VStack {
                        Image(systemName: "text.bubble").environment(\.symbolVariants, .none)
                        Text("スレッド")
                    }
                }
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
                .tabItem {
                    VStack {
                        Image(systemName: "at").environment(\.symbolVariants, .none)
                        Text("通知")
                    }
                }
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass").environment(\.symbolVariants, .none)
                        Text("検索")
                    }
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthCredential = OAuthCredential()
        let oAuthRequest = OAuthRequest(credential: oAuthCredential)
        let api = API(oAuthRequest: oAuthRequest)
        let timelineModel = ChannelTimelineModel(oAuthRequest: oAuthRequest)
        MainTabView()
            .environmentObject(api)
            .environmentObject(timelineModel)
    }
}
