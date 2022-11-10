import SwiftUI

struct ExploreViewTimeline: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @ObservedObject var viewModel: ChannelGroupTimelineViewModel
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
                            MessageComponent(viewModel: MessageViewModel(message: message, oAuthRequest: self.oAuthRequest), message: message)
                                .id(message.id)
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
        }
    }
}
