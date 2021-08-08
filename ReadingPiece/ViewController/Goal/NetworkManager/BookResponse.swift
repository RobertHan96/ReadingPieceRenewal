import Foundation

public struct BookResponse: Codable {
    public let isSuccess: Bool
    public let code: Int
    public let message: String
    public let bookId: Int
}

public struct PostChalleneBookResponse: Codable {
    public let isSuccess: Bool
    public let code: Int
    public let message: String
}

// 책 추가 하단 => 리뷰 로딩에 쓰는 리스폰스 객체
public struct UserBookReviewResponse: Codable {
    public let isSuccess: Bool
    public let code: Int
    public let message: String
    public let userBookReview: [UserBookReviewFirstDetail]?
    public let ReviewlikeCount: Int?
    public let ReviewcommentCount: Int?
    public let totalReadingUser: [UserReviewCount]?
    
    enum CodingKeys: String, CodingKey {
        case isSuccess
        case code
        case message
        case userBookReview = "getbookRows"
        case ReviewlikeCount
        case ReviewcommentCount
        case totalReadingUser = "currentReadRows"
    }
}

