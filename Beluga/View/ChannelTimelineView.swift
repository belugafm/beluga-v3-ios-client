import Foundation
import SwiftUI
import UIKit

func getScrollViewHeight(origHeight: CGFloat, keyboardHeight: CGFloat) -> CGFloat {
    if keyboardHeight == 0 {
        return origHeight - 140
    } else {
        return origHeight - keyboardHeight + 200
    }
}

class KeyboardHeightHelper: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    init() {
        listenForKeyboardNotifications()
    }

    private func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                               object: nil,
                                               queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

            self.keyboardHeight = keyboardRect.height
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                               object: nil,
                                               queue: .main) { _ in
            self.keyboardHeight = 0
        }
    }
}

struct ChannelTimelineView: View {
    @EnvironmentObject var oAuthRequest: OAuthRequest
    @ObservedObject var viewModel: ChannelTimelineViewModel
    @State var inputText: String = ""
    @State var scrollProxy: ScrollViewProxy?
    @FocusState var keyboardVisible: Bool
    @State private var offsetY = CGFloat(0)
    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()
    @State var initialScrollViewHeight = CGFloat(-1)

    struct ViewOffsetKey: PreferenceKey {
        typealias Value = [CGFloat]
        static var defaultValue: [CGFloat] = [0]
        static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
            value.append(contentsOf: nextValue())
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(String(Int(self.keyboardHeightHelper.keyboardHeight)))
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
                    }
                    .frame(height: getScrollViewHeight(origHeight: geometry.size.height, keyboardHeight: self.keyboardHeightHelper.keyboardHeight))
                    .onAppear {
                        self.scrollProxy = scrollProxy
                        if viewModel.shouldScrollDown {
                            if let lastMessageId = viewModel.messages.last?.id {
                                scrollProxy.scrollTo(lastMessageId)
                            }
                        }
                        if self.initialScrollViewHeight < 0 {
                            self.initialScrollViewHeight = geometry.size.height
                            print(self.initialScrollViewHeight)
                        }
                    }
                    .onChange(of: keyboardVisible) { keyboardVisible in
                        if keyboardVisible, viewModel.shouldScrollDown {
                            if let lastMessageId = viewModel.messages.last?.id {
                                scrollProxy.scrollTo(lastMessageId)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    scrollProxy.scrollTo(lastMessageId)
                                }
                            }
                        }
                    }
                    .onPreferenceChange(ViewOffsetKey.self) { value in
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
}

struct ChannelTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        let oAuthRequest = OAuthRequest(credential: OAuthCredential())
        let channel = Channel(id: 1, name: "hoge", unique_name: "fuga", message_count: 0, status_string: "#")
        ChannelTimelineView(viewModel: ChannelTimelineViewModel(oAuthRequest: oAuthRequest, channel: channel))
    }
}
