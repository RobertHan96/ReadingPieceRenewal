//
//  UIViewController.swift
//  ReadingPiece
//
//  Created by 정지현 on 2021/03/19.
//

import UIKit
import SnapKit
import Toast_Swift
import Network

extension UIViewController {
    static let loginStroyBoard = "Login"
    static let mainStroyBoard = "Main"
    static let walkThroughStroyBoard = "WalkThrough"
    static let secondWalkThroughViewControllerId = "secondWalkThrough"
    static let thridWalkThroughtViewControllerId = "thirdWalkThrough"
    static let mainViewControllerId = "TabController"
    static let loginViewControllerId = "LoginNav"

    func pushViewController(storyBoardName: String, viewControllerId: String) {
        let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: viewControllerId)
        navigationController?.pushViewController(tabBarController, animated: false)
    }
    
    func initViewControllerstoryBoardName(storyBoardName: String, viewControllerId: String) -> UIViewController{
        let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerId)
        
        return viewController
    }
    
    func checkNetworkConnectivity() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("LOG - 네트워크 연결 성공")
            } else {
                print("LOG - 네트워크 연결 실패 : 기기의 인터넷 접속 상태를 확인하세요.")
                DispatchQueue.main.async {
                    self.presentAlert(title: "네트워크 연결 상태를 확인해주세요.")
                    monitor.cancel()
                }
            }
        }
    }
    
    func showToastMessage(title: String) {
        self.view.makeToast(title, duration: 2.0, position: .top)
    }
    
    // MARK: 공통 네비게이션바 디자인 적용
    func setupMyPageNavigationBar(_ leftButtonTitle: String?, _ rightButtonTitle: String, _ barTitle: String, buttonImage: UIImage? ) {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevorn.left"),
                                            style: .plain,
                                            target: nil,
                                            action: nil )
        let rightButton = UIBarButtonItem(image: nil,
                                         style: .plain,
                                         target: nil,
                                         action: nil)
        self.navigationItem.leftBarButtonItem?.title = leftButtonTitle
        self.navigationItem.rightBarButtonItem?.title = rightButtonTitle
        self.navigationItem.title = barTitle
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem?.tintColor = .darkgrey
        self.navigationItem.rightBarButtonItem?.tintColor = .main
    }
    
    @objc func dismissCurrentViewController(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: 하단 border line 없는 네비게이션바 디자인 적용
    func setupCleanNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        self.navigationController?.navigationBar.tintColor = .darkgrey
    }
    
    // MARK: 하단 border line + shadow 있는 기본 네비게이션바 디자인 적용
    func restoreNavigationBar() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.1
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.tintColor = .darkgrey
        
    }
    
    
    
    // MARK: 빈 화면을 눌렀을 때 키보드가 내려가도록 처리
    func dismissKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer =
            UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        //        tap.cance@objc @objc lsTouche@objc sInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    // MARK: 취소와 확인이 뜨는 UIAlertController
    func presentAlert(title: String, message: String? = nil,
                      isCancelActionIncluded: Bool = false,
                      preferredStyle style: UIAlertController.Style = .alert,
                      handler: ((UIAlertAction) -> Void)? = nil) {
        self.dismissIndicator()
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let actionDone = UIAlertAction(title: "확인", style: .default, handler: handler)
        alert.addAction(actionDone)
        if isCancelActionIncluded {
            let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(actionCancel)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: 커스텀 UIAction이 뜨는 UIAlertController
    func presentAlert(title: String, message: String? = nil,
                      isCancelActionIncluded: Bool = false,
                      preferredStyle style: UIAlertController.Style = .alert,
                      with actions: UIAlertAction ...) {
        self.dismissIndicator()
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { alert.addAction($0) }
        if isCancelActionIncluded {
            let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(actionCancel)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: UIWindow의 rootViewController를 변경하여 화면전환
    func changeRootViewController(_ viewControllerToPresent: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = viewControllerToPresent
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        } else {
            viewControllerToPresent.modalPresentationStyle = .overFullScreen
            self.present(viewControllerToPresent, animated: true, completion: nil)
        }
    }
        
    // MARK: 인디케이터 표시
    func showIndicator() {
        IndicatorView.shared.show()
        IndicatorView.shared.showIndicator()
    }
    
    // MARK: 흰배경 인디케이터 표시
    func showWhiteIndicator() {
        IndicatorView.shared.show()
        IndicatorView.shared.showWhiteIndicator()
    }
    
    // MARK: 인디케이터 숨김
    @objc func dismissIndicator() {
        IndicatorView.shared.dismiss()
    }
}
