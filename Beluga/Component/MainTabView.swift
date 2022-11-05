import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var timelineModel: TimelineModel
    @EnvironmentObject var api: API
    @State private var selectedIndex: Int = 0
    var body: some View {
        TabView(selection: $selectedIndex) {
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
                .onTapGesture {
                    self.selectedIndex = 0
                }
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("ホーム")
                    }
                }
                .tag(0)
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
                .onTapGesture {
                    self.selectedIndex = 1
                }
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(1)
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
                .onTapGesture {
                    self.selectedIndex = 2
                }
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(2)
            HomeView()
                .environmentObject(self.timelineModel)
                .environmentObject(self.api)
                .onTapGesture {
                    self.selectedIndex = 3
                }
                .tabItem {
                    Image(systemName: "house")
                }
                .tag(3)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthCredential = OAuthCredential()
        let oAuthRequest = OAuthRequest(credential: oAuthCredential)
        let api = API(oAuthRequest: oAuthRequest)
        let timelineModel = TimelineModel(oAuthRequest: oAuthRequest)
        MainTabView()
            .environmentObject(api)
            .environmentObject(timelineModel)
    }
}
