//
//  LoginManager.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/08/05.
//

import Foundation
import KeychainSwift
import AuthenticationServices

struct LoginManager {
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)

    func isValidLoginToken() -> Bool {
        var validationResult = false
        
        if let token = keychain.get(Keys.token) {
            // 토큰이 있을 경우 검증 진행
            Network.request(req: CheckTokenRequest(token: token)) { result in
                switch result {
                case .success(let response):
                    debugPrint(response)
                    if response.code == 1000 {
                        // 토큰이 유효한 경우
                        validationResult = true
                        print("LOG-로그인 정보 조회 성공 -> 메인 페이지로 이동")
                    }
                // 토큰이 유효하지 않을 경우 (ex. 유효기간이 지났을 경우)
                case .cancel, .failure:
                    print("LOG-유효하지 않은 로그인 토큰 -> 로그인 페이지로 이동")
                }
            }
        } else {
            print("LOG-로그인 내역 없음 -> 로그인 페이지로 이동")
        }
        return validationResult
    }
    
}
