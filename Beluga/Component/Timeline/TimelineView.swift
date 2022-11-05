import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var timelineModel: ChannelTimelineModel
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
            Button("Load messages") {
                Task {
                    do {
                        let messages = try await timelineModel.fetchMessages()
                        timelineViewModel.setMessages(messages: messages)
                    } catch {}
                }
            }
        }
        .padding()
    }
}
