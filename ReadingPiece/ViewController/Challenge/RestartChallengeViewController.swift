//
//  RestartChallengeViewController.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/25.
//

import UIKit
import KeychainSwift

// 설정한 목표가 만료되어 재설정이 필요할 때 나오는 VC
// : 챌린지를 조기 달성한 경우, 챌린지 기간이 만료된 경우
protocol ViewChangeDelegate: class {
    func dismissViewController(_ controller: UIViewController)
}

class RestartChallengeViewController: UIViewController {
    var challengeName: String?
    var delegate: ViewChangeDelegate?
    var challengeValidationDelegate: ChallengeValidationDelegate?
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupTitleLabel: UILabel!
    @IBOutlet weak var popupDescLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var popupViewHeight: NSLayoutConstraint!
    @IBOutlet weak var popupViewWidth: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        view.isOpaque = false
        popupView.layer.cornerRadius = 14
        popupDescLabel.text = """
                                    \(challengeName ?? "챌린지")가 끝났어요.
                                    같은 목표에 7일 추가로 다시 도전하거나,
                                    모든 것을 초기화하고 새로 시작할 수 있어요.
                              """
        closeButton.tintColor = .darkgrey
        popupViewHeight.constant = CGFloat(DeviceManager().getsPopupViewHeightConstraints())
        if DeviceManager().getsPopupViewHeightConstraints() > 0 {
            popupViewWidth.constant = 20
        }
    }
    
    @IBAction func closePopupAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 챌린지 재연장 API 호출
    @IBAction func retryChallengeAction(_ sender: UIButton) {
        reTryChallenge()
    }
    
    // 목표/책 추가 씬으로 이동 (처음 로그인하는 유저와 동일)
    @IBAction func restartChallengeAction(_ sender: UIButton) {
        let termVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "TermViewController") as! TermViewController

        guard let pvc = self.presentingViewController else { return }
        self.dismiss(animated: true) {
            self.delegate?.dismissViewController(self)
        }
    }
    
    // 읽고있는 책과 목표 정보 그대로 재시작 - CH11 API 호출
    func reTryChallenge() {
        guard let token = keychain.get(Keys.token) else { return }
        
        let req = PatchRestartChallengeRequest(token: token)
        _ = Network.request(req: req) { (result) in
                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        print("LOG - 챌린지 재시작 성공")
                        self.dismiss(animated: true, completion: nil)
                        //self.navigationController?.popToRootViewController(animated: true)
                    case 2263:
                        self.presentAlert(title: "아직 진행 중인 목표가 있습니다! 다시 확인해주세요.", isCancelActionIncluded: false)
                    default:
                        self.presentAlert(title: "챌린지 재시작 실패\(userResponse.code)", isCancelActionIncluded: false)
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    debugPrint("LOG", error)
                    self.presentAlert(title: "서버와의 연결이 원활하지 않습니다.", isCancelActionIncluded: false)
            }
        }
    }
}
