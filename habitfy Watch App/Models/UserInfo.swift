
import Foundation
struct UserInfo: Codable {
    let id: Int
    let name: String
    let deviceID: String
    
    enum CodingKeys: String, CodingKey {//change to suit api responses
        case id
        case name
        case deviceID = "device_id"
    }
}
