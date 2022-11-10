import SwiftUI

struct TimelineViewComponent: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @State var messages: [ObservableMessage]
    var body: some View {
        VStack {
            Text("\(messages.count) messages")
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        MessageComponent(viewModel: MessageViewModel(message: message, oAuthRequest: self.oAuthRequest), message: message)
                    }
                }
            }
        }
        .padding()
    }
}
