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

func getOAuthSignatureBaseString(httpMethod: String,
                                 baseURLString: String,
                                 parameters: [URLQueryItem]) -> String
{
    var parameterComponents: [String] = []
    for parameter in parameters {
        let name = parameter.name.oAuthURLEncodedString
        let value = parameter.value?.oAuthURLEncodedString ?? ""
        parameterComponents.append("\(name)=\(value)")
    }
    let parameterString = parameterComponents.sorted().joined(separator: "&")
    return httpMethod + "&" +
        baseURLString.oAuthURLEncodedString + "&" +
        parameterString.oAuthURLEncodedString
}

func getOAuthSigningKey(consumerSecret: String,
                        oAuthTokenSecret: String?) -> String
{
    if let accessTokenSecret = oAuthTokenSecret {
        return consumerSecret.oAuthURLEncodedString + "&" +
            accessTokenSecret.oAuthURLEncodedString
    } else {
        return consumerSecret.oAuthURLEncodedString + "&"
    }
}

func getOAuthSignature(httpMethod: String,
                       baseURLString: String,
                       parameters: [URLQueryItem],
                       consumerSecret: String,
                       oAuthTokenSecret: String? = nil) -> String
{
    let signatureBaseString = getOAuthSignatureBaseString(httpMethod: httpMethod,
                                                          baseURLString: baseURLString,
                                                          parameters: parameters)
    let signingKey = getOAuthSigningKey(consumerSecret: consumerSecret,
                                        oAuthTokenSecret: oAuthTokenSecret)

    return signatureBaseString.hmacSHA1Hash(key: signingKey)
}

func getOAuthAuthorizationHeader(parameters: [URLQueryItem]) -> String {
    var parameterComponents: [String] = []
    for parameter in parameters {
        let name = parameter.name.oAuthURLEncodedString
        let value = parameter.value?.oAuthURLEncodedString ?? ""
        parameterComponents.append("\(name)=\"\(value)\"")
    }
    return "OAuth " + parameterComponents.sorted().joined(separator: ", ")
}

class OAuthModel: ObservableObject {
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

    func fetchRequestToken() async throws -> (requestToken: String, requestTokenSecret: String) {
        let httpMethod = "POST"
        let baseURLString = "\(Config.apiBaseUrl)/oauth/request_token"

        guard let url = URL(string: baseURLString) else {
            throw ApiError.invalidEndpointUrl
        }
        var parameters = [
            URLQueryItem(name: "oauth_consumer_key", value: Config.consumerKey),
            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ]
        let signature = getOAuthSignature(httpMethod: httpMethod,
                                          baseURLString: baseURLString,
                                          parameters: parameters,
                                          consumerSecret: Config.consumerSecret)
        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(getOAuthAuthorizationHeader(parameters: parameters),
                            forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "data is not string", code: 0)
            }
            print(jsonString)
            let res = try JSONDecoder().decode(RequestTokenJsonResponse.self, from: data)
            guard res.ok == true else {
                throw NSError(domain: "res.ok is false", code: 0)
            }
            return (res.request_token!, res.request_token_secret!)
        } catch {
            print(error.localizedDescription)
            throw ApiError.failedToFetchData
        }
    }

    func fetchAccessToken(requestToken: String, requestTokenSecret: String, verifier: String) async throws -> (accessToken: String, accessTokenSecret: String) {
        let httpMethod = "POST"
        let baseURLString = "\(Config.apiBaseUrl)/oauth/access_token"

        guard let url = URL(string: baseURLString) else {
            throw ApiError.invalidEndpointUrl
        }
        let body = [
            URLQueryItem(name: "verifier", value: verifier),
            URLQueryItem(name: "request_token", value: requestToken)
        ]
        var parameters = [
            URLQueryItem(name: "oauth_consumer_key", value: Config.consumerKey),
            URLQueryItem(name: "oauth_token", value: requestToken),
            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ] + body
        let signature = getOAuthSignature(httpMethod: httpMethod,
                                          baseURLString: baseURLString,
                                          parameters: parameters,
                                          consumerSecret: Config.consumerSecret,
                                          oAuthTokenSecret: requestTokenSecret)
        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = body.buildQueryString().data(using: .utf8)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(getOAuthAuthorizationHeader(parameters: parameters),
                            forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "data is not string", code: 0)
            }
            print(jsonString)
            let res = try JSONDecoder().decode(AccessTokenJsonResponse.self, from: data)
            guard res.ok == true else {
                throw NSError(domain: "res.ok is false", code: 0)
            }
            return (res.access_token!, res.access_token_secret!)
        } catch {
            print(error.localizedDescription)
            throw ApiError.failedToFetchData
        }
    }

    func postMessage(channelId: Int, text: String) async throws -> Bool {
        guard self.needsLogin() == false else {
            return false
        }
        let httpMethod = "POST"
        let baseURLString = "\(Config.apiBaseUrl)/message/post"

        guard let url = URL(string: baseURLString) else {
            throw ApiError.invalidEndpointUrl
        }
        let body = [
            URLQueryItem(name: "channel_id", value: String(channelId)),
            URLQueryItem(name: "text", value: text)
        ]
        var parameters = [
            URLQueryItem(name: "oauth_consumer_key", value: Config.consumerKey),
            URLQueryItem(name: "oauth_token", value: self.accessToken),
            URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
            URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
            URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
            URLQueryItem(name: "oauth_version", value: "1.0")
        ] + body
        let signature = getOAuthSignature(httpMethod: httpMethod,
                                          baseURLString: baseURLString,
                                          parameters: parameters,
                                          consumerSecret: Config.consumerSecret,
                                          oAuthTokenSecret: self.accessTokenSecret)
        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = body.buildQueryString().data(using: .utf8)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(getOAuthAuthorizationHeader(parameters: parameters),
                            forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                throw NSError(domain: "data is not string", code: 0)
            }
            print(jsonString)
            let res = try JSONDecoder().decode(AccessTokenJsonResponse.self, from: data)
            guard res.ok == true else {
                throw NSError(domain: "res.ok is false", code: 0)
            }
            return true
        } catch {
            print(error.localizedDescription)
            throw ApiError.failedToFetchData
        }
    }
}
