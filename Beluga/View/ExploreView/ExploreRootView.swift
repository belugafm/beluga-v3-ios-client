import SwiftUI

struct ExploreRootView: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    init() {
        let coloredNavAppearance = UINavigationBarAppearance()
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = UIColor(MyColor.navigationBarBgColor)
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }

    var body: some View {
        NavigationView {
            ZStack {
                MyColor.bgColor.edgesIgnoringSafeArea(.all)
                ExploreView(viewModel: ExploreViewModel(oAuthRequest: oAuthRequest)).environmentObject(oAuthRequest)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExploreRootView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthRequest = OAuthRequest(credential: OAuthCredential())
        ExploreRootView().environmentObject(oAuthRequest)
    }
}
