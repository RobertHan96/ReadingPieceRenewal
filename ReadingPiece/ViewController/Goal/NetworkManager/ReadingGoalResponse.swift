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



public struct BookReviewsResponse: Codable {
    public let isSuccess: Bool
    public let code: Int
    public let message: String
    public let reviews: [UserBookReviewListInfo]?

    enum CodingKeys: String, CodingKey {
        case isSuccess
        case code
        case message
        case reviews = "getbookreview"
    }

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
