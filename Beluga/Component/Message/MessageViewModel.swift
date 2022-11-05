import SwiftUI

class MessageViewModel: ObservableObject {
    let message: Message
    init(message: Message) {
        self.message = message
    }
}
