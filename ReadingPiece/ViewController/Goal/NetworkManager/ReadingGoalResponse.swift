import Foundation

public struct PostReadingGoalResponse: Codable {
    public let isSuccess: Bool?
    public let code: Int?
    public let message: String?
    public let goalId: Int?
}

public struct PatchReadingGoalResponse: Codable {
    public let isSuccess: Bool?
    public let code: Int?
    public let message: String?
}

public struct PatchReadingTimeResponse: Codable {
    public let isSuccess: Bool?
    public let code: Int?
    public let message: String?
}

public struct BookReviewResponse: Codable {
    public let isSuccess: Bool
    public let code: Int
    public let message: String
    public let review: [BookReview]?
    public let totalReader: [TotalReader]?
    
    enum CodingKeys: String, CodingKey {
        case isSuccess
        case code
        case message
        case review = "getbookRows"
        case totalReader = "currentReadRows"
    }

}

public struct BookReview: Codable {
    public let title: String // 책 제목
    public let imageURL: String? // 표지
    public let writer : String // 저자
    public let publisher: String // 출판사
    public let publishDate: String // 출판일
    public let contents: String? // 줄거리
    public let reviewSum: Int // 해당 책에 작성된 총 리뷰 개수
    public let userId: Int // 리뷰 유저 인덱스
    public let name: String // 리뷰 유저 이름
    public let profilePictureURL: String? // 리뷰 유저 프로필 이미지
    public let postAt: String // 리뷰 작성일
    public let star: Int // 별점
    public let reviewId: Int // 리뷰 인덱스
    public let text: String // 리뷰 내용
}

public struct TotalReader: Codable {
    public let currentRead: Int // 현재 같은 책을 읽고 있는 사람 수
}
