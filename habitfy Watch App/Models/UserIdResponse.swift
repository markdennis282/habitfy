
import Foundation
struct UserIDResponse: Codable {
    let id: Int?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case id
        case error
    }
}
