protocol JSONResponse {
    var ok: Bool { get }
    var error_code: String? { get }
    var description: [String]? { get }
}

typealias CodableJSONResponse = JSONResponse & Codable
