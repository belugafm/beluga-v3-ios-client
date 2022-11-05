import SwiftUI

class TimelineViewModel: ObservableObject {
    @Published private var messages = [Message]()

    func setMessages(messages: [Message]) {
        self.messages = messages
    }

    func getMessages() -> [Message] {
        return messages
    }
}
