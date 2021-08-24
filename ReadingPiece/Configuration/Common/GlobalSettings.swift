//
//  File.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/08/13.
//

// 미사용 클래스
import Foundation

@propertyWrapper
    struct UserDefault<T: Codable> {
        let key: String
        let defaultValue: T

        init(_ key: String, defaultValue: T) {
            self.key = key
            self.defaultValue = defaultValue
        }

        var wrappedValue: T {
            get {

                if let data = UserDefaults.standard.object(forKey: key) as? Data,
                    let user = try? JSONDecoder().decode(T.self, from: data) {
                    return user

                }

                return  defaultValue
            }
            set {
                if let encoded = try? JSONEncoder().encode(newValue) {
                    UserDefaults.standard.set(encoded, forKey: key)
                }
            }
        }
    }




enum GlobalSettings {
    @UserDefault("ChallengeCompletionInformation", defaultValue: ChallengeCompletionInformation(compltedCount:0,animationShownCount:0)) static var challengeCompletionInformation: ChallengeCompletionInformation
}


struct ChallengeCompletionInformation:Codable {
    let compltedCount:Int
    let animationShownCount:Int
    
    // 챌린지 달성 애니메이션을 챌린지당 1번만 보여주기 위해서, 로컬에 (챌린지 달성 횟수, 애니메이션 표시 횟수) 저장
    func increaseAnimationShownCount() {
        let animationShownCount = GlobalSettings.challengeCompletionInformation.animationShownCount + 1
        let compltedCount = GlobalSettings.challengeCompletionInformation.compltedCount
        GlobalSettings.challengeCompletionInformation = ChallengeCompletionInformation(compltedCount: compltedCount, animationShownCount: animationShownCount)
    }

    // 챌린지 달성 애니메이션을 챌린지당 1번만 보여주기 위해서, 로컬에 (챌린지 달성 횟수, 애니메이션 표시 횟수) 저장
    func increaseCompletedCount() {
        let animationShownCount = GlobalSettings.challengeCompletionInformation.animationShownCount
        let compltedCount = GlobalSettings.challengeCompletionInformation.compltedCount + 1
        GlobalSettings.challengeCompletionInformation = ChallengeCompletionInformation(compltedCount: compltedCount, animationShownCount: animationShownCount)
    }
    
    func isValid() -> Bool {
        if animationShownCount == compltedCount {
            return false
        } else {
            return true
        }
    }

}
