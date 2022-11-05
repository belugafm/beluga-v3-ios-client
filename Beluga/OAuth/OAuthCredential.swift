import Foundation
import SwiftUI

class OAuthCredential: ObservableObject {
    @AppStorage("accessToken") var accessToken = "null"
    @AppStorage("accessTokenSecret") var accessTokenSecret = "null"
    var requestToken: String?
    var requestTokenSecret: String?
    func needsLogin() -> Bool {
        if self.accessToken == "null" {
            return true
        }
        if self.accessTokenSecret == "null" {
            return true
        }
        return false
    }

    func authorized() -> Bool {
        return self.needsLogin() == false
    }
}
