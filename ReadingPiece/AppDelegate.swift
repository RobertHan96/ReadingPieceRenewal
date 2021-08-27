//
//  AppDelegate.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/02/22.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import KeychainSwift
import FirebaseAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        // 키보드 상단에 dismiss하는 버튼을 자동 배치하는 코드
        IQKeyboardManager.shared.enableAutoToolbar = true
        // 키보드 높이에 맞게 텍스트 필드 위치를 자동으로 올려주는 코드
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        // Firebase Analytics 설정
        FirebaseApp.configure()
        Analytics.logEvent("init", parameters: nil)
//         키체인 삭제 테스트
//        if keychain.clear() {
//            print("cleared keychain")
//        }
        if let token = keychain.get(Keys.token) {
            print("token: \(token)")
        }
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.NotoSans(.medium, size: 10)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.NotoSans(.medium, size: 10)], for: .selected)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

