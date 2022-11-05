import SwiftUI

struct ChannelTimelineView: View {
    @ObservedObject var viewModel: ChannelTimelineViewModel
    @State var inputText: String = ""
    @State var scrollProxy: ScrollViewProxy?
    @FocusState var keyboardVisible: Bool
    @State private var offsetY = CGFloat(0)

    struct ViewOffsetKey: PreferenceKey {
        typealias Value = [CGFloat]
        static var defaultValue: [CGFloat] = [0]
        static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
            value.append(contentsOf: nextValue())
        }
    }

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            MessageView(viewModel: MessageViewModel(message: message)).id(message.id)
                        }
                    }.background(GeometryReader { geometry in
                        Color.clear.preference(key: ViewOffsetKey.self, value: [geometry.frame(in: .global).minY])
                    })

                }.onAppear {
                    self.scrollProxy = scrollProxy
                    if viewModel.shouldScrollDown {
                        if let lastMessageId = viewModel.messages.last?.id {
                            scrollProxy.scrollTo(lastMessageId)
                        }
                    }
                }.onChange(of: keyboardVisible) { keyboardVisible in
                    if keyboardVisible, viewModel.shouldScrollDown {
                        if let lastMessageId = viewModel.messages.last?.id {
                            scrollProxy.scrollTo(lastMessageId)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                scrollProxy.scrollTo(lastMessageId)
                            }
                        }
                    }
                }.onPreferenceChange(ViewOffsetKey.self) { value in
                    self.offsetY = value[0]
                    print(self.offsetY)
                }
            }
            Button {
                Task {
                    do {
                        try await viewModel.updateTimeline()
                    } catch {}
                }
            } label: {
                Text("更新する")
            }.padding(10)
            HStack {
                TextField("メッセージを入力", text: $inputText).focused($keyboardVisible)
                Button {
                    Task {
                        do {
                            await viewModel.postMessage(text: inputText)
                            try await viewModel.updateTimeline()
                            DispatchQueue.main.async {
                                inputText = ""
                                if viewModel.shouldScrollDown {
                                    if let lastMessageId = viewModel.messages.last?.id {
                                        scrollProxy?.scrollTo(lastMessageId)
                                    }
                                }
                            }
                        } catch {}
                    }
                } label: {
                    Text("投稿する")
                }
            }.padding(10)
        }
        .navigationTitle(viewModel.channel.status_string + " " + viewModel.channel.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChannelTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthRequest = OAuthRequest(credential: OAuthCredential())
        let channel = Channel(id: 1, name: "hoge", unique_name: "fuga", message_count: 0, status_string: "#")
        ChannelTimelineView(viewModel: ChannelTimelineViewModel(oAuthRequest: oAuthRequest, channel: channel))
    }
}
