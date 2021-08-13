//
//  LoginViewController.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/02/28.
//

import UIKit
import KeychainSwift

class LoginViewController: UIViewController {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var IDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var IDCancelButton: UIButton!
    @IBOutlet weak var passwordCancelButton: UIButton!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IDTextField.delegate = self
        passwordTextField.delegate = self
        IDTextField.font = .NotoSans(.regular, size: 14)
        passwordTextField.font = .NotoSans(.regular, size: 14)
        loginButton.makeRoundedButtnon("로그인", titleColor: #colorLiteral(red: 0.7097406387, green: 0.7098445296, blue: 0.7097179294, alpha: 1) , borderColor: #colorLiteral(red: 0.8548267484, green: 0.8549502492, blue: 0.8547996879, alpha: 1), backgroundColor: #colorLiteral(red: 0.8548267484, green: 0.8549502492, blue: 0.8547996879, alpha: 1))
        loginButton.titleLabel?.font = .NotoSans(.medium, size: 16)
        loginButton.isEnabled = false
        
        self.setupLabelTap()
        self.dismissKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func IDCancelButtonTapped(_ sender: Any) {
        IDTextField.text = ""
        loginButton.isEnabled = false
    }
    
    @IBAction func PWCancelButtonTapped(_ sender: Any) {
        passwordTextField.text = ""
        loginButton.isEnabled = false
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.showIndicator()
        Network.request(req: LoginRequest(email: self.IDTextField.text!, password: self.passwordTextField.text!)) {
            result in
            switch result {
            case .success(let response):
                self.dismissIndicator()
                let code = response.code
                if code == 1000 {
                    print("로그인 성공")
                    // 키체인에 토큰 등록
                    guard let token = response.jwt else { return }
                    if self.keychain.set(token, forKey: Keys.token, withAccess: KeychainSwiftAccessOptions.accessibleAfterFirstUnlock) {
                        print("Keychain: token setting success.")
                    } else {
                        print("Failed to set token on Keychain")
                    }
                    // 키체인에 이메일 등록
                    let email = self.IDTextField.text
                    if self.keychain.set(email!, forKey: Keys.email, withAccess: KeychainSwiftAccessOptions.accessibleAfterFirstUnlock) {
                        print("Keychain: email setting success. ")
                    } else {
                        print("Failed to set email on Keychain")
                    }
                    
                    if response.result == 0 {
                        print("챌린지 모두 달성했거나 등록한 챌린지가 없는 경우")
                        // 챌린지 모두 달성했거나 등록한 챌린지가 없는 경우
                        let vc = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(identifier: "TermViewController") as! TermViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        // 달성하지 않은 챌린지가 있는 경우
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabController")
                        tabBarController.modalPresentationStyle = .fullScreen
                        self.present(tabBarController, animated: true, completion: nil)
                    }
                    
                    
                } else {
                    print(response.message)
                    self.presentAlert(title: response.message, isCancelActionIncluded: false) {_ in
                        self.IDTextField.text = ""
                        self.passwordTextField.text = ""
                    }
                }
            case .cancel(let cancelError):
                self.dismissIndicator()
                print(cancelError as Any)
            case .failure(let error):
                self.dismissIndicator()
                print(error as Any)
                self.presentAlert(title: "서버와의 연결이 원활하지 않습니다.", isCancelActionIncluded: false)
            }
        }
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        let popupVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "PasswordResetViewController") as! PasswordResetViewController
        popupVC.modalPresentationStyle = .overCurrentContext
        self.present(popupVC, animated: true, completion: nil)
    }
    
    // 개인정보 처리방침 웹뷰
    func setupLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.policyLabelTapped(_:)))
        self.privacyPolicyLabel.isUserInteractionEnabled = true
        self.privacyPolicyLabel.addGestureRecognizer(labelTap)
    }
    
    @objc func policyLabelTapped(_ sender: UITapGestureRecognizer) {
        let vc = PrivacyPolicyViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == IDTextField {
            passwordTextField.becomeFirstResponder()
        }else{
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if IDTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false {
            loginButton.makeRoundedButtnon("로그인", titleColor: .white, borderColor: UIColor.melon.cgColor, backgroundColor: .melon)
            loginButton.isEnabled = true
        } else {
            loginButton.isEnabled = false
        }
        
    }
}
