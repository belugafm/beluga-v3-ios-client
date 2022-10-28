import SwiftUI

struct TimelineView: View {
    let timelineModel = TimelineModel()
    @ObservedObject var timelineViewModel = TimelineViewModel()
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(timelineViewModel.getMessages()) { message in
                        MessageView(viewModel: MessageViewModel(message: message))
                    }
                }
            }
            Button("Load messages")
            {
                timelineModel.fetchMessages { messages in
                    DispatchQueue.main.async {
                        timelineViewModel.setMessages(messages: messages)
                    }
                }
            }
        }
        .padding()
    }
}
