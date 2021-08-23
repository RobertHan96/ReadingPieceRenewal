//
//  MainViewNetworkManager.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/08/15.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainSwift

extension ViewController {

    func getChallengeRequest(currentView: UIViewController , completion:@escaping (ChallengerInfo?) -> Void) {
        let reqUrl =  "https://prod.maekuswant.shop/challenge"
        guard let token = keychain.get(Keys.token) else { return }
        let tokenHeader = HTTPHeader(name: "x-access-token", value: token)
        let typeHeader = HTTPHeader(name: "Content-Type", value: "application/json")
        let header = HTTPHeaders([typeHeader, tokenHeader])
        
        
        AF.request(reqUrl, method: .get, headers: header).validate(statusCode: 200..<300).responseJSON { response in
            switch(response.result) {
            case .success(_) :
                if let data = response.data {
                    guard let jsonData = try? JSON(data: data) else { return }
                    let isSuccess = jsonData["isSuccess"].boolValue
                    let responseCode = jsonData["code"].intValue
                    let message = jsonData["message"].stringValue
                    let isExpired = jsonData["isExpired"].boolValue

                    if isSuccess == true {
                        switch responseCode {
                        case 1000:
                            print("LOG - 책, 챌린지, 목표 정보 조회 성공")

                            let goalBookInfo = jsonData["getchallenge1Rows"].arrayValue
                            let challengeStatus = jsonData["getchallenge2Rows"].arrayValue
                            guard let todayReadingJson = jsonData["getchallenge3Rows"].arrayValue.first else { return }
                            let books =  goalBookInfo.compactMap{ MainViewNetworkManager().getBookInfoFromJson(json: $0) }
                            let challengeStatusList = challengeStatus.compactMap{ MainViewNetworkManager().getReadingGoalFromJson(json: $0[0])}// 지금 읽는 책 1권으로 고정이라 0번째 인덱스값만 받도록함. 추후 여러권 보여준다면 수정 필요.
                            let todayReading = MainViewNetworkManager().getChallengeFromJson(json: todayReadingJson)
                            let challengerInfo = ChallengerInfo(readingBook: books, readingGoal: challengeStatusList, todayChallenge: todayReading, isExpired: isExpired)
                            completion(challengerInfo)
                        case 2223:
                            currentView.presentAlert(title: "읽을 책을 먼저 설정해주세요.", isCancelActionIncluded: false)
                        case 2224:
                            currentView.presentAlert(title: "독서 목표를 먼저 설정해주세요.", isCancelActionIncluded: false)
                        case 4020:
                            currentView.presentAlert(title: "로그인 정보를 다시 확인해주세요.", isCancelActionIncluded: false)
                        default:
                            print("파싱결과 : 도전하고 있는 책 정보 없음", isSuccess, responseCode, message)
                            completion(nil)
                        }
                    } else {
                        print("파싱결과 : 도전하고 있는 책 정보 없음", isSuccess, responseCode, message)
                        completion(nil)
                    }
                }
                break ;
            case .failure(_):
                print("LOG - 책, 챌린지, 목표 정보 조회 실패")
                completion(nil)
                break;
            }
        }
    }

}

struct MainViewNetworkManager {
    func getBookInfoFromJson(json: JSON) -> ReadingBook {
        let goalId = json["goalId"].intValue
        let bookId = json["bookId"].intValue
        let title = json["title"].stringValue
        let writer = json["writer"].stringValue
        let imageUrl = json["imageURL"].stringValue
        let isbn = json["publishNumber"].stringValue
        let goalBookId = json["goalBookId"].intValue
        let isComplete = json["isComplete"].intValue
        let chllengeReadingBook = ReadingBook(goalId: goalId, bookId: bookId, title: title, writer: writer, imageURL: imageUrl, publishNumber: isbn, goalBookId: goalBookId, isComplete: isComplete)

        return chllengeReadingBook
    }

    func getReadingGoalFromJson(json: JSON) -> ReadingGoal {
        let goalBookId = json["goalBookId"].intValue
        let page = json["page"].intValue
        let percent = json["percent"].intValue
        let totalReadingTime = json["time"].stringValue
        let isReading = json["isReading"].stringValue

        let readongGoal = ReadingGoal(goalBookId: goalBookId, page: page, percent: percent, totalTime: totalReadingTime, isReading: isReading)

        return readongGoal
    }

    func getChallengeFromJson(json: JSON) -> Challenge {
        let cake = json["cake"].stringValue
        let totalJournal = json["sumJournal"].intValue
        let todayReadingTime = json["todayTime"].string
        let amount = json["amount"].intValue
        let time = json["time"].intValue
        let period = json["period"].stringValue
        let userId = json["userId"].intValue
        let totalReadingBook = json["sumAmount"].intValue
        let name = json["name"].stringValue
        let expriodAt = json["expriodAt"].stringValue
        let dDay = json["Dday"].intValue
        let challengeId = json["challengeId"].intValue

        let challenge = Challenge(cake: cake, totalJournal: totalJournal, todayTime: todayReadingTime, amount: amount, time: time, period: period, userId: userId,
                                  totalReadBook: totalReadingBook, name: name, expriodAt: expriodAt, dDay: dDay, challengeId: challengeId)

        return challenge
    }

}
