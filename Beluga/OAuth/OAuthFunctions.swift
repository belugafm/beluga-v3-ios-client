import CommonCrypto
import Foundation
import SwiftUI

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
    if let oAuthTokenSecret = oAuthTokenSecret {
        return consumerSecret.oAuthURLEncodedString + "&" +
            oAuthTokenSecret.oAuthURLEncodedString
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

func getOAuthParameters(oAuthToken: String? = nil) -> [URLQueryItem] {
    var parameters = [
        URLQueryItem(name: "oauth_consumer_key", value: Config.consumerKey),
        URLQueryItem(name: "oauth_nonce", value: UUID().uuidString),
        URLQueryItem(name: "oauth_signature_method", value: "HMAC-SHA1"),
        URLQueryItem(name: "oauth_timestamp", value: String(Int(Date().timeIntervalSince1970))),
        URLQueryItem(name: "oauth_version", value: "1.0")
    ]
    if let oAuthToken = oAuthToken {
        parameters.append(URLQueryItem(name: "oauth_token", value: oAuthToken))
    }
    return parameters
}
