//
//  ChallengeCompletionViewController.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/08.
//

import UIKit
import KeychainSwift
import SpriteKit

class ChallengeCompletionViewController: UIViewController {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)

    @IBOutlet weak var challengeRewardView: UIView!
    @IBOutlet weak var challengeRewardImage: UIImageView!
    @IBOutlet weak var challengeNameLabel: UILabel!
    @IBOutlet weak var challengeCakeNameLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var fireCrackerView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        postNewUserCakeType()
    }
    
    private func setupUI() {
        setNavBar()
        setFireCracker()
        continueButton.makeRoundedButtnon("계속하기", titleColor: .white, borderColor: UIColor.main.cgColor, backgroundColor: .main)
        challengeNameLabel.textColor = .main
        challengeCakeNameLabel.textColor = .darkgrey
        GlobalSettings.challengeCompletionInformation.increaseAnimationShownCount()
    }
    
    func postNewUserCakeType() {
        guard let token = keychain.get(Keys.token) else { return }
        // 유저디폴트에 있는 goalId, 케이크 이름을 받아오도록 추후 변경 필요
        let req = PostUserCakeTypeRequest(token: token, goalId: 33, cake: "bery")
        
        _ = Network.request(req: req) { (result) in
                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        print("LOG - 케이크 종류 변경 성공", userResponse.code)
                    default:
                        print("LOG - 케이크 종류 변경 실패", userResponse.message, userResponse.code)
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    debugPrint("LOG", error)
            }
        }
    }
    
    func setFireCracker() {
        self.fireCrackerView.backgroundColor = .clear
        let scene = FireCrackerScene()
        self.fireCrackerView.presentScene(scene)
    }
    
    private func setNavBar() {
        let rightButton = UIBarButtonItem(image: UIImage(named: "shareIconLine"), style: .plain, target: self, action: #selector(shareDaillyReadingResult(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = .darkgrey
        self.navigationController?.navigationBar.tintColor = .darkgrey
    }
    
    @objc func shareDaillyReadingResult(sender: UIBarButtonItem) {
        shareResult()
    }

    @IBAction func continueReading(_ sender: UIButton) {
        // 챌린지 달성 이후, [계속하기] 버튼 선택시 메인 화면으로 rootViewController 변경
        let vc = UIViewController().initViewControllerstoryBoardName(storyBoardName: UIViewController.mainStroyBoard, viewControllerId: UIViewController.mainViewControllerId)
        UIApplication.shared.keyWindow?.replaceRootViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func closeModal(_ sender: UIButton) {
        // 계속하기화 마찬가지로 [X] 버튼 선택했을 때도 메인 화면으로 rootViewController 변경
        let vc = UIViewController().initViewControllerstoryBoardName(storyBoardName: UIViewController.mainStroyBoard, viewControllerId: UIViewController.mainViewControllerId)
        UIApplication.shared.keyWindow?.replaceRootViewController(vc, animated: true, completion: nil)
    }
    
    func shareResult() {
        let image = challengeRewardView.captureScreenToImage()
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        self.present(activityViewController, animated: true, completion: nil)
    }
        
}


extension UIView {    
    func captureScreenToImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image {
            rendererContext in layer.render(in: rendererContext.cgContext)
        }
    }
}
