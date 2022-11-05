import CommonCrypto
import Foundation
import SwiftUI

extension CharacterSet {
    static var urlRFC3986Allowed: CharacterSet {
        CharacterSet(charactersIn: "-_.~").union(.alphanumerics)
    }
}

extension String {
    var oAuthURLEncodedString: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlRFC3986Allowed) ?? self
    }

    var urlQueryItems: [URLQueryItem]? {
        URLComponents(string: "://?\(self)")?.queryItems
    }

    func hmacSHA1Hash(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
               key,
               key.count,
               self,
               self.count,
               &digest)
        return Data(digest).base64EncodedString()
    }
}

extension Array where Element == URLQueryItem {
    func getValue(for name: String) -> String? {
        return self.filter { $0.name == name }.first?.value
    }

    subscript(name: String) -> String? {
        return self.getValue(for: name)
    }

    func buildQueryString() -> String {
        guard self.count > 0 else {
            return ""
        }
        var parameterComponents: [String] = []
        for parameter in self {
            let name = parameter.name.oAuthURLEncodedString
            let value = parameter.value?.oAuthURLEncodedString ?? ""
            parameterComponents.append("\(name)=\(value)")
        }
        return parameterComponents.sorted().joined(separator: "&")
    }
}
