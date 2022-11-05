import SwiftUI

struct ExploreRootView: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    var body: some View {
        NavigationView {
            ExploreView(viewModel: ExploreViewModel(oAuthRequest: oAuthRequest)).environmentObject(oAuthRequest)
        }.navigationBarTitleDisplayMode(.inline)
    }
}

struct Explore_Previews: PreviewProvider {
    static var previews: some View {
        ExploreRootView()
    }
}
