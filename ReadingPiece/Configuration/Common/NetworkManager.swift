
import Foundation
import Alamofire

// 참고한 소스코드 : https://github.com/ahmetkgunay/NetworkLayer
protocol Requestable {
    
    associatedtype ResponseType: Codable
    
    var endpoint: String { get }
    var method: Network.Method { get }
    var query:  Network.QueryType { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var baseUrl: URL { get }
    var timeout : TimeInterval { get }
    var cachePolicy : NSURLRequest.CachePolicy { get }
}

extension Requestable {
    
    var defaultJSONHeader : [String: String] {
        return ["Content-Type": "application/json"]
    }
}

enum NetworkResult<T> {
    case success(T)
    case cancel(Error?)
    case failure(Error?)
}

class Network {
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    public enum QueryType {
        case json, path
    }
    
    @discardableResult
    static func request<T: Requestable>(req: T, completionHandler: @escaping (NetworkResult<T.ResponseType>) -> Void) -> DataRequest? {
        
        let url = req.baseUrl.appendingPathComponent(req.endpoint)
        let request = prepareRequest(for: url, req: req)
        return AF.request(request).responseJSON { (response) in
            if let err = response.error {
                if let urlError = err as? URLError, urlError.code == URLError.cancelled {
                    // cancelled
                    completionHandler(NetworkResult.cancel(urlError))
                } else {
                    // other failures
                    completionHandler(NetworkResult.failure(err))
                }
                return
            }
            
            if let data = response.data {
                let decoder = JSONDecoder()
                
                do {
                    let object = try decoder.decode(T.ResponseType.self, from: data)
                    completionHandler(NetworkResult.success(object))
                } catch let error {
                    completionHandler(NetworkResult.failure(error))
                }
            }
        }
    }
}

extension Network {
    
    private static func prepareRequest<T: Requestable>(for url: URL, req: T) -> URLRequest {
        
        var request : URLRequest? = nil
        
        switch req.query {
        case .json:
            request = URLRequest(url: url, cachePolicy: req.cachePolicy,
                                 timeoutInterval: req.timeout)
            if let params = req.parameters {
                do {
                    let body = try JSONSerialization.data(withJSONObject: params, options: [])
                    request!.httpBody = body
                } catch {
                    assertionFailure("Error : while attemping to serialize the data for preparing httpBody \(error)")
                }
            }
        case .path:
            var query = ""
            
            req.parameters?.forEach { key, value in
                query = query + "\(key)=\(value)&"
            }
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.query = query
            request = URLRequest(url: components.url!, cachePolicy: req.cachePolicy, timeoutInterval: req.timeout)
        }
        
        request!.allHTTPHeaderFields = req.headers
        request!.httpMethod = req.method.rawValue
        
        return request!
    }
}
