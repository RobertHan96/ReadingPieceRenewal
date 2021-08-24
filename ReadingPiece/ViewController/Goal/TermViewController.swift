//
//  TermViewController.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/03/02.
//

import UIKit

class TermViewController: UIViewController {
    var period: String?
    var amount: Int?
    var initializer: Int = 0 // 0이면 신규유저, 1이면 기존유저
    var isValidChallenge: Bool = true // 0이면 아직안 끝난 챌린지, 1이면 끝나서 목표 재설정이 필요한 챌린지
    
    @IBOutlet weak var bookQuantityTextField: UITextField!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
        amount = Int(bookQuantityTextField.text ?? "0")
        changeNextButtonColorByValidcation()
    }
    
    @IBAction func termButtonTapped(_ sender: UIButton) {
        let buttons = [weekButton,monthButton,yearButton]

        buttons.forEach{ (button) in
            if button == sender {
                button?.isSelected = true
                guard let btnTag =  button?.tag else { return }
                setReadingTermByBtnClicked(tag: btnTag)
            }else {
                button?.isSelected = false
            }
        }
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        if changeNextButtonColorByValidcation() == true {
            if let readingAmount = amount, let readingPeriod = period {
                guard let timeVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "TimeViewController") as? TimeViewController else { return }
                if initializer == 1 {
                    // 시간 보내기 전에 여기서 신규, 기존 유저여부 판단 후 다음 화면으로 보내야함
                    // 1이면 기존 유저이므로 false, 아니면 true 할당
                    timeVC.goal = ClientGoal(period: period, amount: amount, isNewUser: false, isValideChallenge: isValidChallenge)
                } else {
                    timeVC.goal = ClientGoal(period: period, amount: amount, isNewUser: true, isValideChallenge: isValidChallenge)
                }
                timeVC.initTerm(readingPeriod: readingPeriod, readingAmount: readingAmount) // 다음 VC에서 쓰일 목표관련 시간, 기간 정보 초기화
                self.navigationController?.pushViewController(timeVC, animated: true)
            }
        }
    }
    
    func setupUI() {
        createToolbar()
        initButtonTag()
        self.navigationController?.navigationBar.tintColor = .darkgrey
    }
    
    func createToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor.lightgrey1
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        doneButton.tintColor = .melon
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        bookQuantityTextField.inputAccessoryView = toolbar
    }
    
    func initButtonTag() {
        weekButton.tag = 1
        monthButton.tag = 2
        yearButton.tag = 3
    }
    
    func setReadingTermByBtnClicked(tag: Int) {
        switch tag {
        case 1:
            period = "D"
        case 2:
            period = "M"
        case 3:
            period = "Y"
        default:
            period = nil
        }
    }
    
    func changeNextButtonColorByValidcation() -> Bool {
        var result = false
        if period != nil && amount != nil {
            nextButton.setImage(UIImage(named: "selectedNext"), for: .normal)
            result = true
        } else {
            nextButton.setImage(UIImage(named: "next"), for: .normal)
        }
        return result
    }
}
