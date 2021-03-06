//
//  Goal.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/20.
//

import Foundation

// 목표 설정에 필요한 구조체
struct Goal {
    var period: String
    var amount: Int
    var time: Int
}

// 목표 설정시, 신규 or 기존 유저여부를 구분하기 위해 별도로 구조체 선언
struct ClientGoal {
    var period: String?
    var amount: Int?
    var time: Int?
    var isNewUser: Bool?
    var isValideChallenge: Bool?
}

// :MARK 책 관련

// 일반 책 추가에 필요한 구조체(챌린지 중인 책과 다름)
struct GeneralBook {
    var writer: String // 저자
    var publishDate: String // 출판일
    var publishNumber: String // isbn
    var contents: String // 줄거리
    var imageURL: String // 표지 이미지
    var title: String // 제목
    var publisher: String // 출판사
}

// 책 상세정보 창 하단에 보여지는 첫번째 리뷰
public struct UserBookReviewFirstDetail: Codable {
    public var title: String? // 책 제목
    public var imageURL: String? // 책 표지 이미지
    public var writer: String? // 작가
    public var publisher: String? // 출판사
    public var publishDate: String? // 출판일
    public var contents: String? // 줄거리
    public var reviewSum: Int // 해당 책에 작성된 리뷰 개수
    public var userId: Int?
    public var name: String? // 유저 이름
    public var profilePictureURL: String? // 유저 프사
    public var postAt: String? // 리뷰 작성일
    public var star: Int? // 평점
    public var reviewId: Int?
    public var text: String? // 리뷰 내용
    public var bookId: Int?
    public var status: String? // 완독유무 : Y or N
}

public struct UserReviewCount: Codable {
    public var currentRead: Int
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


// 책 상세 정보 -> 리뷰 리스트 진입시 보여지는 간략한 리뷰
public struct UserBookReviewListInfo: Codable {
    public var userId: Int
    public var name: String // 유저 이름
    public var profilePictureURL: String? // 유저 프사
    public var text: String? // 리뷰 내용
    public var star: Int? // 평점
    public var postAt: String // 리뷰 작성일
}
