import SwiftUI

struct TimelineViewComponent: View {
    @State var messages: [Message]
    var body: some View {
        VStack {
            Text("\(messages.count) messages")
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        MessageView(viewModel: MessageViewModel(message: message))
                    }
                }
            }
        }
        .padding()
    }
}
