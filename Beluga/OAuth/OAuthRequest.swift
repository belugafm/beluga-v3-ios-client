import Foundation

class OAuthRequest: ObservableObject {
    private var credential: OAuthCredential
    init(credential: OAuthCredential) {
        self.credential = credential
    }

    func getUrlRequestForRequestToken() throws -> URLRequest {
        let parameters = getOAuthParameters()
        return try self.getUrlRequest(endpoint: .GenerateRequestToken, httpMethod: .POST, body: [], oAuthParams: parameters)
    }

    func getUrlRequestForAccessToken(requestToken: String, requestTokenSecret: String, verifier: String) throws -> URLRequest {
        let parameters = getOAuthParameters(oAuthToken: requestToken)
        return try self.getUrlRequest(endpoint: .GenerateAccessToken, httpMethod: .POST, body: [
            URLQueryItem(name: "verifier", value: verifier),
            URLQueryItem(name: "request_token", value: requestToken)
        ], oAuthParams: parameters, oAuthTokenSecret: requestTokenSecret)
    }

    func getUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod, body: [URLQueryItem]) throws -> URLRequest {
        let parameters = getOAuthParameters(oAuthToken: self.credential.accessToken)
        return try self.getUrlRequest(endpoint: endpoint, httpMethod: httpMethod, body: body, oAuthParams: parameters, oAuthTokenSecret: self.credential.accessTokenSecret)
    }

    func getUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod, body: [URLQueryItem], oAuthParams: [URLQueryItem], oAuthTokenSecret: String? = nil) throws -> URLRequest {
        let baseURLString = "\(Config.apiBaseUrl)\(endpoint.rawValue)"

        guard let url = URL(string: baseURLString) else {
            throw OAuthError.invalidEndpointUrl
        }
        var parameters = oAuthParams + body
        let signature = getOAuthSignature(httpMethod: httpMethod.rawValue,
                                          baseURLString: baseURLString,
                                          parameters: parameters,
                                          consumerSecret: Config.consumerSecret,
                                          oAuthTokenSecret: oAuthTokenSecret)
        parameters.append(URLQueryItem(name: "oauth_signature", value: signature))

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.httpBody = body.buildQueryString().data(using: .utf8)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(getOAuthAuthorizationHeader(parameters: parameters),
                            forHTTPHeaderField: "Authorization")
        return urlRequest
    }

    func getAuthorizedUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod, body: [URLQueryItem]) throws -> URLRequest {
        return try self.getUrlRequest(endpoint: endpoint, httpMethod: httpMethod, body: body, oAuthParams: getOAuthParameters(oAuthToken: self.credential.accessToken), oAuthTokenSecret: self.credential.accessTokenSecret)
    }

    func fetch<T>(request: URLRequest, _ type: T.Type) async throws -> T where T: CodableJSONResponse {
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw OAuthError.failedToFetchData
        }
        print(jsonString)
        let res = try JSONDecoder().decode(type, from: data)
        guard res.ok == true else {
            throw OAuthError.serverError
        }
        return res
    }
}
