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
}

extension Array where Element == URLQueryItem {
    func getValue(for name: String) -> String? {
        return self.filter { $0.name == name }.first?.value
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

class OAuthModel: ObservableObject {
    @AppStorage("accessToken") var accessToken = "null"
    @AppStorage("accessTokenSecret") var accessTokenSecret = "null"
    func needsLogin() -> Bool {
        if self.accessToken == "null" {
            return true
        }
        if self.accessTokenSecret == "null" {
            return true
        }
        return false
    }

    func fetchRequestToken() async throws -> (requestToken: String, requestTokenSecret: String) {
        guard let url = URL(string: "\(Config.apiBaseUrl)/oauth/request_token") else {
            throw ApiError.invalidEndpointUrl
        }
        let query = ["consumer_key": Config.consumerKey, "consumer_secret": Config.consumerSecret]
        let queryJsonData = try JSONSerialization.data(withJSONObject: query)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = queryJsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "data is not string", code: 0)
            }
            print(jsonString)
            let res = try JSONDecoder().decode(RequestTokenJsonResponse.self, from: data)
            guard res.ok == true else {
                throw NSError(domain: "res.ok is false", code: 0)
            }
            let requestToken = res.request_token!
            let requestTokenSecret = res.request_token_secret!
            return (requestToken, requestTokenSecret)
        } catch {
            print(error.localizedDescription)
            throw ApiError.failedToFetchData
        }
    }
}
