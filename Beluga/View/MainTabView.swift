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
//                .onTapGesture {
//                    self.selectedIndex = 0
//                }
                .tabItem {
                    VStack {
                        Image(systemName: "house").environment(\.symbolVariants, .none)
                        Text("ホーム")
                    }
                }
//                .tag(0)

            ExploreRootView()
                .environmentObject(self.oAuthRequest)
//                .onTapGesture {
//                    self.selectedIndex = 1
//                }
                .tabItem {
                    VStack {
                        Image(systemName: "number").environment(\.symbolVariants, .none)
                        Text("チャンネル")
                    }
                }
//                .tag(1)
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
//                .onTapGesture {
//                    self.selectedIndex = 2
//                }
                .tabItem {
                    VStack {
                        Image(systemName: "text.bubble").environment(\.symbolVariants, .none)
                        Text("スレッド")
                    }
                }
//                .tag(2)
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
//                .onTapGesture {
//                    self.selectedIndex = 3
//                }
                .tabItem {
                    VStack {
                        Image(systemName: "at").environment(\.symbolVariants, .none)
                        Text("通知")
                    }
                }
//                .tag(3)
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
//                .onTapGesture {
//                    self.selectedIndex = 4
//                }
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass").environment(\.symbolVariants, .none)
                        Text("検索")
                    }
                }
//                .tag(4)
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
