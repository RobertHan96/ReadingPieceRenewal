//
//  Goal.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/20.
//

import Foundation

// 진행 중인 챌린지 정보 : API의 getchallenge1Rows Response에 해당되는 부분
public struct ReadingBook: Codable {
    public let goalId: Int
    public let bookId: Int
    public let title: String?
    public let writer: String?
    public let imageURL: String?
    public let publishNumber: String?
    public let goalBookId: Int
    public let isComplete: Int
}

// 진행 중인 챌린지 정보 : API의 getchallenge2Rows Response에 해당되는 부분
public struct ReadingGoal: Codable {
    public let goalBookId: Int?
    public let page: Int?
    public let percent: Int?
    public let totalTime: String?
    public let isReading: String // N or Y로 구분
    
    enum CodingKeys: String, CodingKey {
        case goalBookId
        case page
        case percent
        case totalTime = "sum(time)"
        case isReading
    }
}


// 진행 중인 챌린지 정보 : API의 getchallenge3Rows Response에 해당되는 부분
public struct Challenge: Codable {
    public let cake: String
    public let totalJournal: Int? // 해당 챌린지동안 작성한 일지 개수
    public let todayTime: String? // 오늘 독서 시간
    public let amount: Int? // 챌린지 단위 기간당 목표 책 권수
    public let time: Int? // 챌린지 단위 기간당 목표 독서시간
    public let period: String? // 챌린지 단위 기간 (일, 주, 월)
    public let userId: Int?
    public let totalReadBook: Int? // 완독한 책수
    public let name: String? // 유저 이름
    public let expriodAt: String? // 챌린지 만료일
    public let dDay: Int? // 챌린지 남은 일자
    public let challengeId: Int?
    
    enum CodingKeys: String, CodingKey {
        case cake
        case totalJournal = "sumJournal"
        case todayTime
        case amount
        case time
        case period
        case userId
        case totalReadBook = "sumAmount"
        case name
        case expriodAt
        case dDay = "Dday"
        case challengeId
    }
}

// 오늘의 챌린지 진행 현황 정보

//
public struct ReadingContinuity: Codable {
    public let goalId: Int? // 목표인덱스
    public let continuanceDay: Int? // 연속 독서일
    public let createAt: String? // 처음읽은날
    
    enum CodingKeys: String, CodingKey {
        case goalId
        case continuanceDay = "countDay"
        case createAt
    }
}

public struct TodayReadingStatus: Codable {
    public let sumjournal: Int? // 일지합계
    public let todayTime: String? // 오늘읽은 시간합계
    public let todayPercent: String? // 오늘읽은 퍼센트
    public let startAt: String? // 목표시작일
    public let expriodAt: String? // 목표만료일
    public let period: String? // 목표기간
    public let amount: Int? // 목표책수
    public let sumAmount: Int? // 완독한책수
    public let name: String? // 유저닉네임
    public let Dday: Int? // 만료일까지 남은 디데이
}

// CH2 API에서 받아온 정보들을 모두 합쳐서 반환한 객체
struct ChallengerInfo {
    var readingBook : [ReadingBook]
    var readingGoal : [ReadingGoal]
    var todayChallenge : Challenge
    var isExpired: Bool
    
    var challengeName: String {
        return "\(todayChallenge.time ?? 00)일동안 \(todayChallenge.amount ?? 00)권 챌린지"
    }
    
    func getChallengeStatusText(name: String, time: String, bookAmount: Int) -> String {
        return "\(StringManager().getUserNameByLength(name))님은 \(time)동안\n\(bookAmount)권 읽기에 도전 중"
    }
    
    func getChallneMissionText() -> String {
        let targetBookAmount = self.todayChallenge.amount ?? 0// 읽기 목표 권수
        let period = self.todayChallenge.period ?? "D"// 읽기 주기
        let formattedPeriod = StringManager().getDateFromPeriod(period: period)
        
        return "\(formattedPeriod)동안 \(targetBookAmount)권 챌린지!"
    }

    // userdefualt로 조건 한개 더 추가
    func isExpiredChallenge() -> Bool {
        if isExpired == true && readingGoal.first?.percent ?? 99 != 100 || UserDefaults().bool(forKey: Constants.IS_SHOWN_CHALLENGE_COMPLETION_EFFECT) == true {
            return true
        } else {
            return false
        }
    }

    func isCompletedChallenge() -> Bool {
        if isExpired == true && readingGoal.first?.percent == 100 && UserDefaults().bool(forKey: Constants.IS_SHOWN_CHALLENGE_COMPLETION_EFFECT) == false {
            return true
        } else {
            return false
        }
    }
}
