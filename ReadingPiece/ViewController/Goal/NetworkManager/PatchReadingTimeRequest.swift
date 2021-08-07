import Foundation

// CH12 API 문서 : https://docs.google.com/spreadsheets/d/1nY5_ryn5OeViz3lUqXVRPNYvNR4hLHJx4nahqUGKcRo/edit#gid=481649594
// 독서 목표 시간만 변경하는 API
final class PatchReadingTimeRequest: Requestable {
    typealias ResponseType = PatchReadingTimeResponse
    private var time: Int
    private var goalId: Int
    private var token: String

    init(_ time: Int, goalId: Int, token: String) {
        self.time = time
        self.goalId = goalId
        self.token = token
    }

    var baseUrl: URL {
        return  URL(string: Constants.BASE_URL)!
    }

    var endpoint: String {
        return "challenge/time"
    }

    var method: Network.Method {
        return .patch
    }

    var query: Network.QueryType {
        return .json

    }

    var parameters: [String : Any]? {
        return ["time": self.time, "goalId": self.goalId]
    }

    var headers: [String : String]? {
        return ["Content-Type": "application/json", "x-access-token": self.token]
    }

    var timeout: TimeInterval {
        return 5.0
    }

    var cachePolicy: NSURLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }
}
