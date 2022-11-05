enum OAuthError: Error {
    case needsLogin
    case noRequestToken
    case invalidEndpointUrl
    case failedToFetchData
    case serverError
}
