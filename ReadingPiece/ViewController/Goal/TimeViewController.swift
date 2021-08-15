//
//  TimeViewController.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/03/05.
//

import UIKit
import KeychainSwift

class TimeViewController: UIViewController {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    // Term VC에서 옵셔널 검사를 하고, 값을 넘겨줄 것 이기 때문에 편의상 논-옵셔널 변수로 생성
    var time: Int = 0
    var period: String = ""
    var amount: Int = 0
    var goal: ClientGoal?
    var goalid: Int = 0

    @IBOutlet weak var readingTimeLabel: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var timeSelectButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var addGoalButton: UIButton!
    let usderDefaults = UserDefaults.standard
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        setupUI()
        print("LOG - 목표 설정 화면 : 신규유저 여부 \(goal?.isNewUser) \(goal)")
    }
    
    // 화면 상단 - 다음 버튼과 연결된 액션
    @IBAction func NetxToAddBookAction(_ sender: UIBarButtonItem) {
        // 신규 유저 : 시간까지 잘 입력한 경우에만 책 추가 화면까지 이동
        if goal?.isNewUser == true && goal?.time != nil  {
            guard let searchVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "searchBookViewController") as? SearchBookViewController else { return }
            searchVC.goal = self.goal
            self.navigationController?.pushViewController(searchVC, animated: true)
            return
        } else if goal?.isValideChallenge == false {
            guard let searchVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "searchBookViewController") as? SearchBookViewController else { return }
            searchVC.goal = self.goal
            self.navigationController?.pushViewController(searchVC, animated: true)
            return
        }
        // 신규 유저 & 시간값을 입력하지 않은 경우
        else if goal?.time == nil {
            self.presentAlert(title: "목표시간을 설정해주세요.", isCancelActionIncluded: false)
            return
        // 기존 유저 : 메인에서 목표 시간만 수정한 경우, 시간만 수정 후 바로 메인으로 이동
        } else {
            patchUserReadingGoal()
        }
    }
    
    // 화면 하단 - 완료 버튼과 연결된 액션
    @IBAction func addGoalAction(_ sender: UIButton) {
        // 신규 유저 : 책 추가 화면까지 이동
        if goal?.isNewUser != false {
            guard let searchVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "searchBookViewController") as? SearchBookViewController else { return }
            searchVC.goal = self.goal
            self.navigationController?.pushViewController(searchVC, animated: true)
        // 기존 유저 : 메인에서 목표 시간만 수정한 경우, 시간만 수정 후 바로 메인으로 이동
        } else if goal?.isValideChallenge == false {
            guard let searchVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "searchBookViewController") as? SearchBookViewController else { return }
            searchVC.goal = self.goal
            self.navigationController?.pushViewController(searchVC, animated: true)
            return
        // 기존 유저 : 메인에서 목표 시간만 수정한 경우, 시간만 수정 후 바로 메인으로 이동
        } else {
            patchUserReadingGoal()
        }
        
        if goal?.isNewUser == false {
            addGoalButton.setImage(UIImage(named: "completeButton"), for: .normal)
        }
        else {
            addGoalButton.setImage(UIImage(named: "selectedNext"), for: .normal)
        }
    }
    
    @objc func popViewController(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    
    @objc func donePressed() {
        let minute = Int(datePicker.countDownDuration/60)
        time = minute
        goal?.time = time
        timeTextField.text = "\(minute)"
        minuteLabel.isHidden = false
        readingTimeLabel.text = """
                                    매일  \(minute) 분
                                    책을 읽을 거에요
                                """
        addGoalButton.setImage(UIImage(named: "selectedNext"), for: .normal)
        self.view.endEditing(true)
    }
    
    @IBAction func timeSelectButtonTapped(_ sender: Any) {
        timeTextField.becomeFirstResponder()
    }
      
    func patchUserReadingGoal() {
        guard let token = keychain.get(Keys.token) else { return }
        let goalId = usderDefaults.integer(forKey: Constants.USERDEFAULT_KEY_GOAL_ID)
        let req = PatchReadingTimeRequest(time, goalId: goalid, token: token)
                                
        _ = Network.request(req: req) { (result) in
                
                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        print("LOG - 목표변경 완료", self.amount, self.period, self.time, userResponse.message)
                        self.navigationController?.popToRootViewController(animated: true)
                    case 2100, 2101:
                        self.presentAlert(title: "입력값을 다시 확인해주세요.", isCancelActionIncluded: false)
                    default:
                        self.presentAlert(title: "서버와의 연결이 원활하지 않습니다.", isCancelActionIncluded: false)
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    debugPrint(error)
                    self.presentAlert(title: "서버와의 연결이 원활하지 않습니다.", isCancelActionIncluded: false)
            }
        }
    }
    
    func setupUI() {
        print("LOG - 신규유저 여부 \(goal?.isNewUser)")
        createDatePicker()
        if goal?.isNewUser == false {
            self.navigationItem.title = "매일 독서 시간"
            addGoalButton.setImage(UIImage(named: "completeButton"), for: .normal)
            setNavBar()
        }
    }

    private func setNavBar() {
        let rightButton = UIBarButtonItem(image: UIImage(named: "XButton"), style: .plain, target: self, action: #selector(popViewController(sender:)))
        navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = .darkgrey
        self.navigationController?.navigationBar.tintColor = .darkgrey
    }

    
    func initTerm(readingPeriod: String, readingAmount: Int) {
        period = readingPeriod
        amount = readingAmount
    }
        
    func createDatePicker() {
        minuteLabel.isHidden = true
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor.lightgrey1
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        doneButton.tintColor = .melon
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let timeLabel = UILabel(frame: .zero)
        timeLabel.text = "매일 독서 시간"
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.NotoSans(.regular, size: 14)
        timeLabel.textColor = #colorLiteral(red: 0.2274509804, green: 0.231372549, blue: 0.2392156863, alpha: 1)
        let textBarButton = UIBarButtonItem(customView: timeLabel)
        toolbar.setItems([flexibleSpace, textBarButton, flexibleSpace, doneButton], animated: true)
        
        timeTextField.inputAccessoryView = toolbar
        timeTextField.inputView = datePicker
        datePicker.datePickerMode = .countDownTimer
        
    }
}
