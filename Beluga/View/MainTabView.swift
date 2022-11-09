import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var api: API
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @State private var selectedIndex: Int = 0
    init() {
        UITabBar.appearance().backgroundColor = UIColor(MyColor.tabViewBgColor)
        UITabBar.appearance().unselectedItemTintColor = UIColor(MyColor.unselectedFontColor)
    }

    var body: some View {
        TabView {
            HomeView()
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
                .environmentObject(self.api)
                .tabItem {
                    VStack {
                        Image(systemName: "text.bubble").environment(\.symbolVariants, .none)
                        Text("スレッド")
                    }
                }
            HomeView()
                .environmentObject(self.api)
                .tabItem {
                    VStack {
                        Image(systemName: "at").environment(\.symbolVariants, .none)
                        Text("通知")
                    }
                }
            HomeView()
                .environmentObject(self.api)
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass").environment(\.symbolVariants, .none)
                        Text("検索")
                    }
                }
        }
        .accentColor(MyColor.tabViewAccentColor)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthCredential = OAuthCredential()
        let oAuthRequest = OAuthRequest(credential: oAuthCredential)
        let api = API(oAuthRequest: oAuthRequest)
        MainTabView()
            .environmentObject(api)
            .environmentObject(oAuthRequest)
    }
}
