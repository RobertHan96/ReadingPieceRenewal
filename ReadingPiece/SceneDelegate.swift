//
//  SceneDelegate.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/02/22.
//

import UIKit
import KeychainSwift
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    var timerTime = 0
    var window: UIWindow?
    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let windowScene = scene as? UIWindowScene {
            if hasAppBeenLaunchedBefore() == true {
                moveToMainView(windowScene: windowScene)
            } else {
                showWalkThroughView(windowScene: windowScene)
            }
        }
        
    }

    
    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
    
    func moveToMainView(windowScene: UIWindowScene) { // 로그인 여부에 따라 보여질 최초 화면 변경
        // 토큰 유무, 검증 결과 따른 루트 뷰 전환
        if let token = keychain.get(Keys.token) {
            // 토큰이 있을 경우 검증 진행
            Network.request(req: CheckTokenRequest(token: token)) { result in
                switch result {
                case .success(let response):
                    debugPrint(response)
                    if response.code == 1000 {
                        // 토큰이 유효한 경우
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabController")
                        let window = UIWindow(windowScene: windowScene)
                        window.rootViewController = tabBarController
                        self.window = window
                        window.makeKeyAndVisible()
                        window.overrideUserInterfaceStyle = .light
                    }
                case .cancel, .failure:
                    // 토큰이 유효하지 않을 경우 (ex. 유효기간이 지났을 경우)
                    let storyboard = UIStoryboard(name: "Login", bundle: nil)
                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginNav")
                    
                    let window = UIWindow(windowScene: windowScene)
                    window.rootViewController = loginViewController
                    self.window = window
                    window.makeKeyAndVisible()
                    window.overrideUserInterfaceStyle = .light
                }
            }
        } else {
            // 토큰이 없을 경우 (로그인 이력이 없을 경우)
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginNav")
            
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = loginViewController
            self.window = window
            window.makeKeyAndVisible()
            window.overrideUserInterfaceStyle = .light
        }
    }
    
    func showWalkThroughView(windowScene: UIWindowScene) {
        let storyboard = UIStoryboard(name: "WalkThrough", bundle: nil)
        let walkThroughViewController = storyboard.instantiateViewController(withIdentifier: "walkThrough")
        let navigationController = UINavigationController(rootViewController: walkThroughViewController)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        window.overrideUserInterfaceStyle = .light
    }
    
    func hasAppBeenLaunchedBefore() -> Bool {
          let defaults = UserDefaults.standard
          if let hasAppBeenLaunchedBefore = defaults.string(forKey: "hasAppBeenLaunchedBefore") {
              print("App has been launched before. \(hasAppBeenLaunchedBefore)")
              return true
          }
          else{
              defaults.set(true, forKey: "hasAppBeenLaunchedBefore")
              print("App is launched first time")
              return false
          }
    }
}

