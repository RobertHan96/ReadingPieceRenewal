//
//  JoinViewController.swift
//  ReadingPiece
//
//  Created by 정지현 on 2021/03/18.
//

import UIKit
import KeychainSwift

class JoinViewController: UIViewController {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    let emailValidityType: String.ValidityType = .email  // 이메일 형식
    let passwordValidityType: String.ValidityType = .password  // 비밀번호 형식
    
    // 가입 완료 버튼 활성화여부 체크
    var joinActivated: Bool = false {
        didSet {
            if joinActivated == true {
                joinButton.isEnabled = true
                joinButton.makeRoundedButtnon("가입 완료", titleColor: .white, borderColor: UIColor.melon.cgColor, backgroundColor: .melon)
            } else {
                joinButton.isEnabled = false
                joinButton.makeRoundedButtnon("가입 완료", titleColor: .grey, borderColor: UIColor.fillDisabled.cgColor, backgroundColor: .fillDisabled)
            }
        }
    }
    
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var pwConfirmTextField: UITextField!
    
    @IBOutlet weak var nicknameVerifyLabel: UILabel!
    @IBOutlet weak var emailVerifyLabel: UILabel!
    @IBOutlet weak var pwVerifyLabel: UILabel!
    @IBOutlet weak var pwConfirmLabel: UILabel!
    
    
    @IBOutlet weak var nicknameImageView: UIImageView!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var pwImageView: UIImageView!
    @IBOutlet weak var pwConfirmImageView: UIImageView!
    
    @IBOutlet weak var joinButton: UIButton!
    
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        nicknameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        pwConfirmTextField.delegate = self
        
        self.setupLabelTap()
        self.dismissKeyboardWhenTappedAround()
    }
    
    private func setupUI() {
        nicknameTextField.font = .NotoSans(.regular, size: 14)
        nicknameTextField.textColor = .black
        emailTextField.font = .NotoSans(.regular, size: 14)
        emailTextField.textColor = .black
        emailTextField.keyboardType = UIKeyboardType.asciiCapable
        passwordTextField.font = .NotoSans(.regular, size: 14)
        passwordTextField.textColor = .black
        passwordTextField.keyboardType = UIKeyboardType.asciiCapable
        pwConfirmTextField.font = .NotoSans(.regular, size: 14)
        pwConfirmTextField.textColor = .black
        pwConfirmTextField.keyboardType = UIKeyboardType.asciiCapable
        nicknameVerifyLabel.font = .NotoSans(.regular, size: 12)
        nicknameVerifyLabel.textColor = .red
        nicknameVerifyLabel.isHidden = true
        emailVerifyLabel.font = .NotoSans(.regular, size: 12)
        emailVerifyLabel.textColor = .red
        emailVerifyLabel.isHidden = true
        pwVerifyLabel.font = .NotoSans(.regular, size: 12)
        pwVerifyLabel.textColor = .red
        pwVerifyLabel.isHidden = true
        pwConfirmLabel.font = .NotoSans(.regular, size: 12)
        pwConfirmLabel.textColor = .red
        pwConfirmLabel.isHidden = true
        
        joinButton.makeRoundedButtnon("가입 완료", titleColor: .grey, borderColor: UIColor.fillDisabled.cgColor, backgroundColor: .fillDisabled)
        joinButton.isEnabled = false
    }
    
    @IBAction func nicknameVerify(_ sender: Any) {
        verifyNickname()
    }
    
    
    @IBAction func emailCancel(_ sender: Any) {
        emailTextField.text  = ""
        joinActivated = false
    }
    @IBAction func pwCancel(_ sender: Any) {
        passwordTextField.text = ""
        joinActivated = false
    }
    @IBAction func pwConfifmCancel(_ sender: Any) {
        pwConfirmTextField.text = ""
        joinActivated = false
    }
    
    
    @IBAction func joinComplete(_ sender: Any) {
        guard let nickname = self.nicknameTextField.text else { return }
        Network.request(req: JoinRequest(name: nickname, email: self.emailTextField.text!, password: self.pwConfirmTextField.text!)) { [self] result in
            switch result {
            case .success(let response):
                let result = response.code
                didSendJoinRequest(resultCode: result, response: response)
            case .cancel(let cancelError):
                print(cancelError as Any)
            case .failure(let error):
                print(error as Any)
                self.presentAlert(title: "회원가입에 실패하였습니다. ", isCancelActionIncluded: false)
            }
        }
    }
    
    private func didSendJoinRequest(resultCode: Int, response: JoinRequest.ResponseType) {
        print("TEST", resultCode)
        switch resultCode {
        case 1000:
            self.presentAlert(title: "회원가입에 성공하였습니다. ", isCancelActionIncluded: false, handler: { _ in
                
                // 키체인에 토큰 등록
                let token = response.jwt
                if self.keychain.set(token ?? "", forKey: Keys.token, withAccess: KeychainSwiftAccessOptions.accessibleAfterFirstUnlock) {
                    print("Keychain setting success.")
                } else {
                    print("Failed to set on Keychain")
                }
                // 키체인에 이메일 등록
                let email = self.emailTextField.text
                if self.keychain.set(email!, forKey: Keys.email, withAccess: KeychainSwiftAccessOptions.accessibleAfterFirstUnlock) {
                    print("Keychain: email setting success. ")
                } else {
                    print("Failed to set email on Keychain")
                }
                let vc = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(identifier: "TermViewController") as! TermViewController
                self.navigationController?.pushViewController(vc, animated: true)
            })
        case 2001, 2002:
            self.presentAlert(title: response.message, isCancelActionIncluded: false, handler: {_ in
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.pwConfirmTextField.text = ""
            })
        case 2003, 2004:
            self.presentAlert(title: response.message, isCancelActionIncluded: false) {_ in
                self.passwordTextField.text = ""
                self.pwConfirmTextField.text = ""
            }
        default:
            self.presentAlert(title: response.message, isCancelActionIncluded: false, handler: {_ in
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.pwConfirmTextField.text = ""
            })
        }
    }

    
    @IBAction func nicknameEditingChanged(_ sender: Any) {
        if let text = nicknameTextField.text {
            if text.utf8.count > 30 {
                nicknameVerifyLabel.isHidden = false
                nicknameVerifyLabel.text = "유효하지 않은 형식입니다. "
            } else {
                nicknameVerifyLabel.isHidden = true
            }
        }
    }
    @IBAction func emailEditingChanged(_ sender: Any) {
        if let text = emailTextField.text {
            if text.isValid(emailValidityType) || text == "" {
                emailVerifyLabel.isHidden = true
            } else {
                emailVerifyLabel.isHidden = false
                emailVerifyLabel.text = "유효하지 않은 형식입니다. "
            }
        }
    }
    
    @IBAction func passwordEditingChanged(_ sender: Any) {
        if let text = passwordTextField.text {
            if text.isValid(passwordValidityType) {
                pwVerifyLabel.isHidden = true
            } else {
                pwVerifyLabel.isHidden = false
                pwVerifyLabel.text = "유효하지 않은 형식입니다. "
            }
        }
    }
    
    // 비밀번호 일치여부 검사
    @IBAction func pwConfirmEditingChanged(_ sender: UITextField) {
        if sender.text != self.passwordTextField.text {
            pwConfirmLabel.isHidden = false
            pwConfirmLabel.text = "비밀번호가 일치하지 않습니다."
            joinActivated = false
        } else {
            pwConfirmLabel.isHidden = true
            print("password confirmed")
        }
        
    }
    
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

// TextField Delegate
extension JoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nicknameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            pwConfirmTextField.becomeFirstResponder()
        } else {
            pwConfirmTextField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nicknameTextField {
            nicknameImageView.image = UIImage(named: "tabBarIconMy")
            nicknameTextField.textColor = .black
        } else if textField == emailTextField {
            emailImageView.image = UIImage(named: "messageIconBlack")
            emailTextField.textColor = .black
        } else if textField == passwordTextField {
            pwImageView.image = UIImage(named: "passwordIconBlack")
            passwordTextField.textColor = .black
        } else {
            pwConfirmImageView.image = UIImage(named: "passwordIconMelon")
            pwConfirmTextField.textColor = .melon
            pwConfirmLabel.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if nicknameTextField.text?.isEmpty == true {
            nicknameImageView.image = UIImage(named: "tabBarIconMyDisabled")
            nicknameTextField.textColor = .grey
        }
        if emailTextField.text?.isEmpty == true {
            emailImageView.image = UIImage(named: "messageIcon")
            emailTextField.textColor = .grey
        }
        if passwordTextField.text?.isEmpty == true {
            pwImageView.image = UIImage(named: "passwordIcon")
            passwordTextField.textColor = .grey
        }
        if pwConfirmTextField.text?.isEmpty == true {
            pwConfirmImageView.image = UIImage(named: "passwordIcon2")
            pwConfirmTextField.textColor = .grey
        }
        
        if nicknameTextField.text?.isEmpty == false && emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false && pwConfirmTextField.text?.isEmpty == false {
            if nicknameVerifyLabel.isHidden == true && emailVerifyLabel.isHidden == true && pwVerifyLabel.isHidden == true && pwConfirmLabel.isHidden == true {
                joinActivated = true
            } else {
                joinActivated = false
            }
            
        } else {
            joinActivated = false
        }
        
    }
    
    
}

// API 호출 함수
extension JoinViewController {
    private func verifyNickname() {
        print("닉네임 중복검사")
        guard let nickname = self.nicknameTextField.text else { return }
        Network.request(req: NameCheckRequest(name: nickname)) { result in
            switch result {
            case .success(let response):
                if response.code == 1000 {
                    self.presentAlert(title: "사용 가능한 닉네임입니다. ", isCancelActionIncluded: false)
                } else {
                    let message = response.message
                    self.presentAlert(title: message, isCancelActionIncluded: false)
                }
            case .cancel(let cancel):
                print(cancel as Any)
            case .failure(let error):
                print(error?.localizedDescription as Any)
                self.presentAlert(title: "서버와의 연결이 원활하지 않습니다. ")
            }
        }
    }
}
