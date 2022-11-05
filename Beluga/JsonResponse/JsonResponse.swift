import Foundation

struct JsonResponse: CodableJSONResponse {
    let ok: Bool
    let error_code: String?
    let description: [String]?
}
