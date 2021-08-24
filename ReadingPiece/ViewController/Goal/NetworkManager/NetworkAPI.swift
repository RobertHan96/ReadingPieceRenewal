//
//  NetworkAPI.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/03/11.
//

import Foundation
import Alamofire

class NetworkAPI {
    
    static func getTotalUserReviews(isbn: String, token: String, completion: @escaping (Int) -> Void ){
        let getReviewsReq = GetUserBookReviewsRequest(isbn: isbn, token: token)
        _ = Network.request(req: getReviewsReq) { (result) in
                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        completion(userResponse.reviews?.count ?? 0)
                    default:
                        print("LOG - 총 리뷰 작성한 유저수 로딩 실패", userResponse.code, isbn, token)
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    print("LOG", error)
            }
        }
    }
    
    static func search(query: String, page: Int, completion: @escaping ([Book],Int,Bool) -> Void) {
        let APIKey = "7e7729343ca056b32e80622098e52b27"

        var urlComponents = URLComponents(string: "https://dapi.kakao.com/v3/search/book?")!
        let queryItem = URLQueryItem(name: "query", value: query)
        let pageItem = URLQueryItem(name: "page", value: String(page))
        urlComponents.queryItems?.append(queryItem)
        urlComponents.queryItems?.append(pageItem)
        
        let requestURL = urlComponents.url!
        
        AF.request(requestURL,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.queryString,
                   headers: ["Content-Type":"application/json", "Accept":"application/json;charset=UTF-8", "Authorization":"KakaoAK \(APIKey)"])
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                        case .success:
                            guard let resultData = response.data else {
                                completion([],0,true)
                                return
                            }
                            let parseData = NetworkAPI.parseBooks(resultData)
                            
                            let books = parseData.0
                            let resultCount = parseData.1
                            let isEnd = parseData.2
                            completion(books, resultCount, isEnd)
                            
                        case let .failure(error):
                            print(error)
                        }
                
            }
    }
    
    static func parseBooks(_ data: Data) -> ([Book],Int,Bool) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let response = try decoder.decode(Response.self, from: data)
            print("res = \(response.meta.isEnd), cnt = \(response.meta.resultCount)")
            let books = response.books
            let isEnd = response.meta.isEnd
            let count = response.meta.resultCount
            return (books,count,isEnd)
        } catch let error {
            print("--> parsing error: \(error)")
            return ([],0,true)
        }
    }
}
