import SwiftUI

class MessageViewModel: ObservableObject {
    private let oAuthRequest: OAuthRequest
    var message: ObservableMessage
    init(message: ObservableMessage, oAuthRequest: OAuthRequest) {
        self.message = message
        self.oAuthRequest = oAuthRequest
    }
}
