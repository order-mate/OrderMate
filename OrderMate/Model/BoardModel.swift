import Foundation

struct BoardModel: Codable {
    var ownerName: String? = nil
    var title: String
    var createdAt: Date? = nil
    var postStatus: Bool? = nil
    var maxPeopleNum: Int
    var currentPeopleNum: Int
    var isAnonymous: Bool
    var content: String
    var withOrderLink: String?
    var pickupSpace: String
    var spaceType: String
    var accountNum: String
//    var estimatedOrderTime: Date? = nil
//    var participationList: [String: String]? = nil
    var commentList: [String]? = nil

}
