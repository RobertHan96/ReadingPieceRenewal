//
//  Constants.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/15.
//

import Foundation
import KeychainSwift

struct Constants {
    static let KEYCHAIN_TOKEN = KeychainSwift(keyPrefix: Keys.keyPrefix).get(Keys.token)
    static let DEV_BASE_URL = "https://prod.maekuswant.shop/"
    static let BASE_URL = "https://prod.maekuswant.shop/"
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    static let USERDEFAULT_KEY_CURRENT_CAKE_NAME = "berry"
    static let USERDEFAULT_KEY_CURRENT_TIMER_TIME = "savedTimeInt"
    static let USERDEFAULT_KEY_GOAL_ID = "goalId"
    static let USERDEFAULT_KEY_GOAL_BOOK_ID = "goalBookId"
    static let USERDEFAULT_KEY_CHALLENGE_ID = "challengeId"
    static let USERDEFAULT_KEY_GOAL_USER_NAME = "userName"
    static let USERDEFAULT_KEY_GOAL_TARGET_TIME = "targetTime"
    static let IS_SHOWN_CHALLENGE_COMPLETION_EFFECT = "isShownChallengeCompletionEffect"
    let ACCESS_TOKEN_HEADER: [String : String] = ["Content-Type": "application/json", "x-access-token": KEYCHAIN_TOKEN ?? ""]
}

