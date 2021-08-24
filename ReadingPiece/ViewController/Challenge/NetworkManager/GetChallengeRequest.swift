import Foundation
import SwiftyJSON
import Alamofire

// API 문서 : https://docs.google.com/spreadsheets/d/1nY5_ryn5OeViz3lUqXVRPNYvNR4hLHJx4nahqUGKcRo/edit#gid=2070942099
// 챌린지 현황 조회 API

final class GetChallengeRequest: Requestable {
    typealias ResponseType = ChallengeResponse
    
    private var token: String
    init(token: String) {
        self.token = token
    }
    
    var baseUrl: URL {
        return  URL(string: Constants.BASE_URL)!
    }
    
    var endpoint: String {
        return "challenge"
    }
    
    var method: Network.Method {
        return .get
    }
    
    var query: Network.QueryType {
        return .path
    }
    
    
    var parameters: [String : Any]? {
        return defaultJSONHeader
    }
    
    var headers: [String : String]? {
        return ["x-access-token": token]
    }
    
    var timeout: TimeInterval {
        return 5.0
    }
    
    var cachePolicy: NSURLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }
}
