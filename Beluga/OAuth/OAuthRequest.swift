import Foundation

class OAuthRequest: ObservableObject {
    private var credential: OAuthCredential
    init(credential: OAuthCredential) {
        self.credential = credential
    }

    func getUrlRequestForRequestToken() throws -> URLRequest {
        let parameters = getOAuthParameters()
        return try self.getUrlRequest(endpoint: .GenerateRequestToken, httpMethod: .POST, requestParams: [], oAuthParams: parameters)
    }

    func getUrlRequestForAccessToken(requestToken: String, requestTokenSecret: String, verifier: String) throws -> URLRequest {
        let parameters = getOAuthParameters(oAuthToken: requestToken)
        return try self.getUrlRequest(endpoint: .GenerateAccessToken, httpMethod: .POST, requestParams: [
            URLQueryItem(name: "verifier", value: verifier),
            URLQueryItem(name: "request_token", value: requestToken)
        ], oAuthParams: parameters, oAuthTokenSecret: requestTokenSecret)
    }

    func getUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod, body: [URLQueryItem]) throws -> URLRequest {
        let parameters = getOAuthParameters(oAuthToken: self.credential.accessToken)
        return try self.getUrlRequest(endpoint: endpoint, httpMethod: httpMethod, requestParams: body, oAuthParams: parameters, oAuthTokenSecret: self.credential.accessTokenSecret)
    }

    func getUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod, requestParams: [URLQueryItem], oAuthParams: [URLQueryItem], oAuthTokenSecret: String? = nil) throws -> URLRequest {
//        GETリクエストの場合、OAuthの署名に使うURLは?以降を含めないので注意
        let baseUrlString = "\(Config.apiBaseUrl)\(endpoint.rawValue)"
        var requestUrlString = baseUrlString
        if httpMethod == .GET {
            requestUrlString += "?" + requestParams.buildQueryString()
        }
        print(requestUrlString)

        guard let url = URL(string: requestUrlString) else {
            throw OAuthError.invalidEndpointUrl
        }
        var signatureParams = oAuthParams + requestParams
        let signature = getOAuthSignature(httpMethod: httpMethod.rawValue,
                                          baseURLString: baseUrlString,
                                          parameters: signatureParams,
                                          consumerSecret: Config.consumerSecret,
                                          oAuthTokenSecret: oAuthTokenSecret)
        signatureParams.append(URLQueryItem(name: "oauth_signature", value: signature))

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        if httpMethod == .POST {
            urlRequest.httpBody = requestParams.buildQueryString().data(using: .utf8)
        }
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(getOAuthAuthorizationHeader(parameters: signatureParams),
                            forHTTPHeaderField: "Authorization")
        return urlRequest
    }

    func getAuthorizedUrlRequest(endpoint: Endpoint, httpMethod: HTTPMethod, body: [URLQueryItem]) throws -> URLRequest {
        return try self.getUrlRequest(endpoint: endpoint, httpMethod: httpMethod, requestParams: body, oAuthParams: getOAuthParameters(oAuthToken: self.credential.accessToken), oAuthTokenSecret: self.credential.accessTokenSecret)
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
