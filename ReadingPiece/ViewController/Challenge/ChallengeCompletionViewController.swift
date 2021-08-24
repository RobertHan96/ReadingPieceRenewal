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
    var challengeInfo : ChallengerInfo?

    @IBOutlet weak var challengeRewardView: UIView!
    @IBOutlet weak var challengeRewardImage: UIImageView!
    @IBOutlet weak var challengeNameLabel: UILabel!
    @IBOutlet weak var challengeCakeNameLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var fireCrackerView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        postNewUserCakeType {
            print("LOG - 새로운 챌린지 케이크 할당 성공")
        }
    }
    
    @IBAction func continuReadingAction(_ sender: Any) {
        popRootViewController()
    }

    @objc func closeChallengeResult(sender: UIBarButtonItem) {
        popRootViewController()
    }

    @objc func shareChallengeResult(sender: UIBarButtonItem) {
        shareResult()
    }
    
    private func popRootViewController() {
        let vc = UIViewController().initViewControllerstoryBoardName(storyBoardName: UIViewController.mainStroyBoard, viewControllerId: UIViewController.mainViewControllerId)
        UIApplication.shared.keyWindow?.replaceRootViewController(vc, animated: true, completion: nil)
    }

    private func setupUI() {
        setNavBar()
        setFireCracker()
        continueButton.makeRoundedButtnon("계속하기", titleColor: .white, borderColor: UIColor.main.cgColor, backgroundColor: .main)
        challengeNameLabel.textColor = .main
        challengeCakeNameLabel.textColor = .darkgrey
        let cakeName = UserDefaults().string(forKey: Constants.USERDEFAULT_KEY_CURRENT_CAKE_NAME) ?? "cream"
        challengeRewardImage.image = UIImage(named: "\(cakeName)5Cake")
        challengeCakeNameLabel.attributedText = StringManager().attributedText(withString: "해내셨군요! 홀케이크를 완성했어요.\n다음 챌린지를 통해 독서 습관을 이어나가요! ", boldString: "홀케이크", font: challengeCakeNameLabel.font)
        challengeNameLabel.text = challengeInfo?.getChallneMissionText()
        UserDefaults().setValue(true, forKey: Constants.IS_SHOWN_CHALLENGE_COMPLETION_EFFECT)
    }

    private func postNewUserCakeType(completio: @escaping () -> Void) {
        guard let token = keychain.get(Keys.token) else { return }
        let goalId = UserDefaults().integer(forKey: Constants.USERDEFAULT_KEY_GOAL_ID)
        let cakeName = UserDefaults().string(forKey: Constants.USERDEFAULT_KEY_CURRENT_CAKE_NAME)?.getNewCakeName ?? "cream"
        let req = PostUserCakeTypeRequest(token: token, goalId: goalId, cake: cakeName)
        
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
        fireCrackerView.backgroundColor = .clear
        fireCrackerView.ignoresSiblingOrder = true
        let scene = FireCrackerScene()
        fireCrackerView.presentScene(scene)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            self.fireCrackerView.removeFromSuperview()
        }
    }
    
    private func setNavBar() {
        let rightButton = UIBarButtonItem(image: UIImage(named: "shareIconLine"), style: .plain, target: self, action: #selector(shareChallengeResult(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = .darkgrey
        self.navigationController?.navigationBar.tintColor = .darkgrey
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "XButton"), style: .plain, target: self, action: #selector(closeChallengeResult(sender:)))
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.leftBarButtonItem?.tintColor = .darkgrey
    }
    
    private func shareResult() {
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
