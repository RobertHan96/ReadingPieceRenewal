//
//  ReviewResponse.swift
//  ReadingPiece
//
//  Created by 정지현 on 2021/03/25.
//

import Foundation

// 리뷰 조회, 생성, 삭제 api 응답구조
struct GetReviewResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let results: [GetReviewResult]?
}

struct GetReviewResult: Codable {
    let userID: Int
    let isCompleted: String
    let bookID: Int
    let title, writer: String
    let imageURL: String
    let reviewID, star: Int
    let text, isPublic, postAt: String
    let timeSum: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case isCompleted
        case bookID = "bookId"
        case title, writer, imageURL
        case reviewID = "reviewId"
        case star, text, isPublic, postAt, timeSum
    }
}

// 리뷰 수정 시 데이터 조회 응답구조
struct GetReviewEditResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let result: GetReviewEditResponseResult
}

struct GetReviewEditResponseResult: Codable {
    let bookID: Int
    let title, writer, publisher, publishAt: String
    let imageURL: String
    let reviewID, star: Int
    let text, isPublic, postAt: String

    enum CodingKeys: String, CodingKey {
        case bookID = "bookId"
        case title, writer, publisher, publishAt, imageURL
        case reviewID = "reviewId"
        case star, text, isPublic, postAt
    }
}
