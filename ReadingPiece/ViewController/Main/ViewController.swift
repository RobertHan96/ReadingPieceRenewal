//
//  ViewController.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/02/22.
//

import UIKit
import KeychainSwift

class ViewController: UIViewController {
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    let defaults = UserDefaults.standard
    let cellId = ReadingBookCollectionViewCell.identifier
    let stringManager = StringManager()
    var challengeInfo : ChallengerInfo? { didSet {
        radingBooksCollectionView.reloadData()
        getChallengeImageFileName()
    }}
    var goalInitializer = 0

    // 데이터 파싱 결과에 따라 변경할 이미지
    @IBOutlet weak var userReadingGoalLabel: UILabel!
    @IBOutlet weak var dDayLabel: UILabel!
    @IBOutlet weak var goalStatusBarWidth: NSLayoutConstraint! // 목표 진행 현황(%) 에 따라 width 변경
    @IBOutlet weak var statusBarWidth: NSLayoutConstraint! // 목표 진행 현황(%) 에 따라 width 변경
    @IBOutlet weak var targetReadingBookCountLabel: UILabel!
    @IBOutlet weak var targetTimeLabel: UILabel!
    @IBOutlet weak var currentReadingBookCountLabel: UILabel!
    @IBOutlet weak var daillyReadingTimeLabel: UILabel!
    @IBOutlet weak var daillyReadingDiaryCountLabel: UILabel!
    @IBOutlet weak var challengeImageView: UIImageView!

    
    // 데이터 변경 없는 Outlet
    @IBOutlet weak var statusBar: UIView!
    @IBOutlet weak var dailyReadingView: UIView!
    @IBOutlet weak var radingBooksCollectionView: UICollectionView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        spinner.backgroundColor = .white
        spinner.startAnimating()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveNameChangeNotification(_:)), name: DidReceiveNameChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initMainView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = "리딩피스"
    }
    
    @objc func didReceiveNameChangeNotification(_ noti: Notification){
        guard let newName: String = noti.userInfo?["userName"] as? String else { return }
        defaults.setValue(newName, forKey: Constants.USERDEFAULT_KEY_GOAL_USER_NAME)
        if let challenge = challengeInfo?.todayChallenge {
            let targetBookAmount = challenge.amount ?? 0// 읽기 목표 권수
            let period = challenge.period ?? "D"// 읽기 주기
            let formattedPeriod = stringManager.getDateFromPeriod(period: period)
            userReadingGoalLabel.text = "\(stringManager.getUserNameByLength(newName))님은 \(formattedPeriod)동안\n\(targetBookAmount)권 읽기에 도전 중!"
        }
    }

    @IBAction func startReadingAction(_ sender: UIButton) {
        if challengeInfo?.isExpired == true {
            showRestartChallengePopup()
            return
        }

        let timerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "timerVC") as! TimerViewController
        timerVC.challengeInfo = self.challengeInfo
        self.navigationController?.pushViewController(timerVC, animated: true)
    }

    @IBAction func modifyReadingGoalAction(_ sender: UIButton) {
        if challengeInfo?.isExpired == true {
            showRestartChallengePopup()
            return
        }

        // 챌린지 현황 정보가 있다면 기존 유저이므로, initializer를 기준으로 목표 추가/수정 여부 구분
        // 신규유저-목표 추가 : 0, 기존유저-목표 변경 : 1
        if self.challengeInfo != nil {
            let modifyReadingGaolVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "TermViewController") as! TermViewController
            modifyReadingGaolVC.initializer = 1
            self.navigationController?.pushViewController(modifyReadingGaolVC, animated: true)
        } else {
            let modifyReadingGaolVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "TermViewController") as! TermViewController
            modifyReadingGaolVC.initializer = 0
            self.navigationController?.pushViewController(modifyReadingGaolVC, animated: true)
        }
    }
    
    @IBAction func addReadingBookAction(_ sender: UIButton) {
        if challengeInfo?.isExpired == true {
            showRestartChallengePopup()
            return
        }

        let bookSettingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "bookSettingVC") as! BookSettingViewController
        self.navigationController?.pushViewController(bookSettingVC, animated: true)
    }
    
    @objc func modifiyTargetTimeAction(_ sender: UITapGestureRecognizer) {
        if challengeInfo?.isExpired == true {
            showRestartChallengePopup()
            return
        }

        guard let modifyReadingTimeVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "TimeViewController") as? TimeViewController else { return}
        // 목표 독서 시간 변경시 필요한 값들은 임의로 0 할당, 신규 유저 여부만 체크해서 전달
        modifyReadingTimeVC.goal = ClientGoal(period: "", amount: 0, time: 0, isNewUser: false)
        modifyReadingTimeVC.goalid = challengeInfo?.readingBook.first?.goalId ?? 0
        self.navigationController?.pushViewController(modifyReadingTimeVC, animated: true)
    }
    
    private func setupUI() {
        setupCollectionView()
        makeDaillyReadingViewShadow()
        userReadingGoalLabel.font = .NotoSans(.medium, size: 24)
        targetTimeLabel.isUserInteractionEnabled = true
        let modifiyTargetTimeGesture = UITapGestureRecognizer(target: self, action: #selector(modifiyTargetTimeAction(_:)))
        targetTimeLabel.addGestureRecognizer(modifiyTargetTimeGesture)
    }
    
    private func getChallengeImageFileName() {
        guard let percent = challengeInfo?.readingGoal.first?.percent?.getCakeImageNameByPercent else { return }
        guard  let cakeName = challengeInfo?.todayChallenge.cake else { return }
        defaults.setValue(cakeName, forKey: Constants.USERDEFAULT_KEY_CURRENT_CAKE_NAME)

        DispatchQueue.main.async {
            self.challengeImageView.image = UIImage(named: "\(cakeName)\(percent)Cake")
        }
    }
    
    private func makeDaillyReadingViewShadow() {
        dailyReadingView.layer.shadowRadius = 5
        dailyReadingView.layer.shadowColor = UIColor.black.cgColor
        dailyReadingView.layer.shadowOpacity = 0.2
        dailyReadingView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    private func setupCollectionView() {
        radingBooksCollectionView.delegate = self
        radingBooksCollectionView.dataSource = self
        self.radingBooksCollectionView.register(UINib.init(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        setupFlowLayout()
        radingBooksCollectionView.layer.borderWidth = 0.5
        radingBooksCollectionView.layer.cornerRadius = 10
        radingBooksCollectionView.layer.borderColor = UIColor.middlegrey2.cgColor
    }
    
    private func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: self.radingBooksCollectionView.layer.bounds.width
                                     , height: 138)
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        radingBooksCollectionView.collectionViewLayout = flowLayout
    }
    
    private func initMainView() {
        getChallengeRequest(currentView: self) { (challengeData) in
            print("LOG - 유저 정보 개요", challengeData as Any)
            switch challengeData {
            case nil :
                self.presentAlert(title: "목표나 책정보를 추가해주세요.", isCancelActionIncluded: false)
                print("LOG - 유저 챌린지 정보 조회 실패")
                self.spinner.stopAnimating()
                self.challengeInfo = challengeData
            // 챌린지 진행 중, 챌린지 조기 달성, 챌린지 기간 만료에 따른 화면 처리 먼저 진행
            default :
                print("LOG 챌린지 목표 정보 조회 성공")
                self.spinner.stopAnimating()
                self.challengeInfo = challengeData
                let isChallengeIsCompleted =  challengeData?.readingBook.first?.isComplete

                // 챌린지 정보 조회 결과, 참여 기간이 만료된 경우 + 미션 성공 실패
                if self.challengeInfo?.isExpiredChallenge() == true {
//                    self.showRestartChallengePopup()
                    guard let challengeCompletionVC = UIViewController().initViewControllerstoryBoardName(
                            storyBoardName: UIViewController.mainStroyBoard, viewControllerId: "challengeCompletionVC") as? ChallengeCompletionViewController else{ return }
                    challengeCompletionVC.challengeInfo = self.challengeInfo
                    self.navigationController?.pushViewController(challengeCompletionVC, animated: false)

                    // 참여기간내 미션 성공
                } else {
                    self.initVC(isCompletedChallenge: isChallengeIsCompleted)
                }
            }
        }
    }

    private func showRestartChallengePopup() {
        guard let restartChallnegeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "restartChallengeVC") as?
            RestartChallengeViewController else { return }
        let challenge = challengeInfo?.todayChallenge
        let targetBookAmount = challenge?.amount ?? 0// 읽기 목표 권수
        let period = challenge?.period ?? "D"// 읽기 주기
        let formattedPeriod = stringManager.getDateFromPeriod(period: period)
        let challengeName = "\(formattedPeriod)에 \(targetBookAmount)권 챌린지"
        restartChallnegeVC.buttonsDelegate = self
        restartChallnegeVC.challengeName = challengeName
        restartChallnegeVC.modalTransitionStyle = .crossDissolve
        restartChallnegeVC.modalPresentationStyle = .overFullScreen
        self.present(restartChallnegeVC , animated: true, completion: nil)
    }
    
    // 목표 설정 화면 진입 전에, 처음 추가한 목표인지 or 기존 목표 수정인지 여부를 판단하고 적용
    // 데이터 파싱 완료 이후, 유저에게 보여줄 데이터를 VC에 적용
    private func initVC(isCompletedChallenge: Int?) {
        if let challenge = self.challengeInfo?.todayChallenge, let goal = self.challengeInfo?.readingGoal.first, let challengingBook = challengeInfo?.readingBook.first {
            // 다른 VC에서 재사용을 위해 UserDefaults에 저장하는 값들
            let goalBookId = challengingBook.goalBookId
            let userName = challenge.name ?? "Reader"// 닉네임이 아직 없을 경우 리더로 기본 할당
            let targetTime = challenge.time ?? 0
            let challengeId = challenge.challengeId ?? 0
            let goaldId = challengingBook.goalId
            defaults.setValue(goaldId, forKey: Constants.USERDEFAULT_KEY_GOAL_ID)
            defaults.setValue(goalBookId, forKey: Constants.USERDEFAULT_KEY_GOAL_BOOK_ID)
            defaults.setValue(userName, forKey: Constants.USERDEFAULT_KEY_GOAL_USER_NAME)
            // 클라에서는 초단위로 처리하지만, 서버는 분단위로 저장하기 때문 60 곱함
            defaults.setValue(targetTime * 60, forKey: Constants.USERDEFAULT_KEY_GOAL_TARGET_TIME)
            defaults.setValue(challengeId, forKey: Constants.USERDEFAULT_KEY_CHALLENGE_ID)
            
            let targetBookAmount = challenge.amount ?? 0// 읽기 목표 권수
            let period = challenge.period ?? "D"// 읽기 주기
            let formattedPeriod = stringManager.getDateFromPeriod(period: period)
            let todayTime = challenge.todayTime ?? "0" // 오늘 읽은 시간
            let totalReadingDiary = challenge.totalJournal ?? 0// 챌린지 기간동안 읽은 책 권수
            let readBookAmount = challenge.totalReadBook ?? 0
            let dDay = challenge.dDay ?? 0 // 챌린지 남은 기간
            let percent = goal.percent ?? 0 // 챌린지 달성도
            let cgFloatPercent = CGFloat(percent) * 0.01
            print("LOG - 일지 작성 개수",challenge.totalJournal as Any, challenge.amount as Any)
            
            userReadingGoalLabel.text = challengeInfo?.getChallengeStatusText(name: userName, time: formattedPeriod, bookAmount: readBookAmount)
            goalStatusBarWidth.constant = statusBar.frame.width * cgFloatPercent
            daillyReadingTimeLabel.text = stringManager.minutesToHoursAndMinutes(todayTime)
            daillyReadingDiaryCountLabel.text = "\(totalReadingDiary)개"
            targetReadingBookCountLabel.text = "\(targetBookAmount)"
            targetTimeLabel.text = "목표 \(targetTime)분"
            currentReadingBookCountLabel.text = "\(readBookAmount)권 / "
            dDayLabel.text = "\(dDay)일 남음"
            
            if let challengeCompleted = challengeInfo {
                if challengeCompleted.isCompletedChallenge() {
                    guard let challengeCompletionVC = UIViewController().initViewControllerstoryBoardName(
                            storyBoardName: UIViewController.mainStroyBoard, viewControllerId: "challengeCompletionVC") as? ChallengeCompletionViewController else{ return }
                    challengeCompletionVC.challengeInfo = challengeInfo
                    navigationController?.pushViewController(challengeCompletionVC, animated: false)
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as? ReadingBookCollectionViewCell else { return UICollectionViewCell() }
        let book = self.challengeInfo?.readingBook.first
        let goal = self.challengeInfo?.readingGoal.first
        cell.configure(data: book, readingStatus: goal)
        
        return cell
    }
    
}

// 챌린지 재시작 팝업에서 선택한 버튼에 따른 동작을 처리하는 protocol
extension ViewController: RestartChallengePopupButtonsActionDelegate {
    func reTryChallengeButtonClicked() {
        // 다음번 챌린지 완료시 축하 애니메이션을 보여주기 위해 userDefault값 초기화
        UserDefaults().setValue(false, forKey: Constants.IS_SHOWN_CHALLENGE_COMPLETION_EFFECT)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.initMainView()
        }
    }
    
    func closeButtonClicked() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showRestartChallengePopup()
        }
    }
    
    func reStartButtonClicked() {
        // 다음번 챌린지 완료시 축하 애니메이션을 보여주기 위해 userDefault값 초기화
        UserDefaults().setValue(false, forKey: Constants.IS_SHOWN_CHALLENGE_COMPLETION_EFFECT)
        guard let modifyReadingGaolVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "TermViewController") as? TermViewController
        else { return }
        modifyReadingGaolVC.initializer = 1
        modifyReadingGaolVC.isValidChallenge = false
        self.navigationController?.pushViewController(modifyReadingGaolVC, animated: true)
    }
}
