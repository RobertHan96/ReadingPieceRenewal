//
//  TimerViewController.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/06.
//

import UIKit

class TimerViewController: UIViewController {
    let defaults = UserDefaults.standard
    let targetTime = UserDefaults.standard.integer(forKey: Constants.USERDEFAULT_KEY_GOAL_TARGET_TIME)
    let timerTime = UserDefaults.standard.integer(forKey: Constants.USERDEFAULT_KEY_CURRENT_TIMER_TIME)
    var isReading: Bool = true
    var readingTime : Int = 0
    var challengeInfo : ChallengerInfo?
    
    @IBOutlet weak var timerBackgroundView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var targetRadingTimeLabel: UILabel!
    @IBOutlet weak var stopReadingButton: UIButton!
    @IBOutlet weak var startPauseRadingButton: UIButton!
    
    private lazy var stopwatch = Stopwatch(timeUpdated: { timeInterval in
        // 매초마다 타이머 시간을 저장하고, 화면 갱신
        self.defaults.setValue(Int(timeInterval), forKey: Constants.USERDEFAULT_KEY_CURRENT_TIMER_TIME)
        self.readingTime += 1
        self.currentTimeLabel.text = self.timeString(from: timeInterval)
    })
    
    deinit {
        stopwatch.stop()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getUserBookReadingTime()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopwatch.toggle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = "시간 기록"
    }

    
    @objc func skipTimeRecoding(sender: UIBarButtonItem) {
        // 목표시간 미달 안내 씬으로 이동
        stopwatch.stop()
        startPauseRadingButton.isSelected = false
        let timerStopVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "timerStopVC") as! TimerStopViewController
        self.navigationController?.pushViewController(timerStopVC, animated: true)
    }

    @objc func popViewController(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pauseTimer(_ sender: UIButton) {
        changeReadingStatus()
        sender.isSelected = !sender.isSelected
        stopwatch.toggle()
        print("LOG - Timer is Paused", currentTimeLabel.text, readingTime)
    }
    
    @IBAction func stopTimer(_ sender: UIButton) {
        stopwatch.stop()
        startPauseRadingButton.isSelected = false
        print("LOG - Timer is Stooped", currentTimeLabel.text, readingTime)
//        getUserBookReadingTime()
    }
    
    func getUserBookReadingTime() {
        let req = GetBookReadingTimeRequest(goalBookId: 25)
        _ = Network.request(req: req) { (result) in
                
                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        // 책 제목 화면 표시, 남은 시간 저장해서 추후 일지 작성시 전달 필요
                        print("LOG - 이전 독서시간", userResponse.message, userResponse.result?.sumtime)
                        let prevReadingTimeString = userResponse.result?.sumtime ?? "0" // 서버에서 오는 값이 string이라 변환 진행
                        let pervReadingTime = Int(prevReadingTimeString)
                        let totalReadingTime = pervReadingTime ?? 0 + self.readingTime // 클라에서 지금 읽은 시간, 서버에서 받은 오늘 읽었던 시간 합산
                        
                        // 합산 시간이 데일리 목표시간보다 많으면, 일일목표 완료 화면, 적으면 중간 포기 화면으로 이동
                        if totalReadingTime > self.targetTime {
                            let dailyReadingCompletionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dailyReadingCompletionVC") as! DailyGoalCompletionViewController
                            self.navigationController?.pushViewController(dailyReadingCompletionVC, animated: true)
                        } else {
                            let timerStopVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "timerStopVC") as! TimerStopViewController
                            self.navigationController?.pushViewController(timerStopVC, animated: true)
                        }
                    default:
                        print("LOG - 오늘 독서시간 정보 없음")
                        self.presentAlert(title: "이전 시간 정보를 불러오지 못했습니다.", isCancelActionIncluded: false)
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    self.presentAlert(title: "서버와의 연결이 원활하지 않습니다.", isCancelActionIncluded: false)
            }
        }
    }

    private func setupUI() {
        setNavBar()
        timerBackgroundView.layer.borderWidth = 5
        timerBackgroundView.layer.borderColor = UIColor.sub2.cgColor
        timerBackgroundView.makeCircle()
        currentTimeLabel.textColor = .charcoal
        bookTitleLabel.textColor = .black
        let attributedString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "timer")
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: " 목표 20분" ))
        targetRadingTimeLabel.attributedText = attributedString
        targetRadingTimeLabel.textColor = .darkgrey
        
        startPauseRadingButton.contentEdgeInsets = UIEdgeInsets(top: 11, left: 20, bottom: 15, right: 20)
        startPauseRadingButton.setTitleColor(.main, for: .normal)
        startPauseRadingButton.backgroundColor = .none
        startPauseRadingButton.layer.borderWidth = 1
        startPauseRadingButton.layer.borderColor = UIColor.main.cgColor
        startPauseRadingButton.layer.cornerRadius = 24
        
        stopReadingButton.contentEdgeInsets = UIEdgeInsets(top: 11, left: 20, bottom: 15, right: 20)
        stopReadingButton.setTitleColor(.white, for: .normal)
        stopReadingButton.layer.borderWidth = 1
        stopReadingButton.layer.borderColor = UIColor.main.cgColor
        stopReadingButton.backgroundColor = .main
        stopReadingButton.layer.cornerRadius = 24
    }
    
    private func setNavBar() {
        // extension으로 타이틀, 왼쪽 이름 없애기, 오른쪽 버튼 생성
        self.navigationItem.title = "시간 기록"
        self.navigationController?.navigationBar.topItem?.title = ""
        let rightButton = UIBarButtonItem(title: "건너뛰기", style: .plain, target: self, action: #selector(skipTimeRecoding(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = .main
        self.navigationController?.navigationBar.tintColor = .darkgrey
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        // 추후 재사용을 위해 타이머 시간은 초 단위로 유저디폴트에 저장
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 60 * 60) / 60)
        let hours = Int(timeInterval / 3600)
        return String(format: "%.2d:%.2d:%.2d", hours, minutes, seconds)
    }

    private func changeReadingStatus() {
        // 읽기 여부, 읽은 시간 저장, 읽기 버튼 UI변경
        if isReading == true {
            startPauseRadingButton.setImage(UIImage(named: "playicon"), for: .normal)
            startPauseRadingButton.setTitle(" 계속 읽기", for: .normal)
            isReading = false
        } else {
            startPauseRadingButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
            startPauseRadingButton.setTitle(" 잠시 멈춤", for: .normal)
            isReading = true
        }
    }
    
}

extension UIView {
    func makeCircle() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
}
