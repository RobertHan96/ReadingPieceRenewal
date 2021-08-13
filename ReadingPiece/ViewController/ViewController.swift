//
//  ViewController.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/02/22.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import FirebaseAnalytics

class ViewController: UIViewController {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    let defaults = UserDefaults.standard
    let cellId = ReadingBookCollectionViewCell.identifier
    var challengeInfo : ChallengerInfo? { didSet {
        radingBooksCollectionView.reloadData()
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
            let formattedPeriod = getDateFromPeriod(period: period)
            userReadingGoalLabel.text = "\(getUserNameByLength(newName))님은 \(formattedPeriod)동안\n\(targetBookAmount)권 읽기에 도전 중!"
        }
    }


    @IBAction func startReadingAction(_ sender: UIButton) {
        let timerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "timerVC") as! TimerViewController
        timerVC.challengeInfo = self.challengeInfo
        self.navigationController?.pushViewController(timerVC, animated: true)
    }

    @IBAction func modifyReadingGoalAction(_ sender: UIButton) {
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
        let bookSettingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "bookSettingVC") as! BookSettingViewController
        self.navigationController?.pushViewController(bookSettingVC, animated: true)
    }
    
    private func setupUI() {
        setupCollectionView()
        makeDaillyReadingViewShadow()
        userReadingGoalLabel.font = .NotoSans(.medium, size: 24)
        targetTimeLabel.isUserInteractionEnabled = true
        let modifiyTargetTimeGesture = UITapGestureRecognizer(target: self, action: #selector(modifiyTargetTimeAction(_:)))
        targetTimeLabel.addGestureRecognizer(modifiyTargetTimeGesture)
    }
    
    @objc func modifiyTargetTimeAction(_ sender: UITapGestureRecognizer) {
        print("LOG - 목표시간 변경")
        guard let modifyReadingTimeVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "TimeViewController") as? TimeViewController else { return}
        // 목표 독서 시간 변경시 필요한 값들은 임의로 0 할당, 신규 유저 여부만 체크해서 전달
        modifyReadingTimeVC.goal = ClientGoal(period: "", amount: 0, time: 0, isNewUser: false)
        modifyReadingTimeVC.goalid = challengeInfo?.readingBook.first?.goalId ?? 0
        self.navigationController?.pushViewController(modifyReadingTimeVC, animated: true)
    }

    
    func makeDaillyReadingViewShadow() {
        dailyReadingView.layer.shadowRadius = 5
        dailyReadingView.layer.shadowColor = UIColor.black.cgColor
        dailyReadingView.layer.shadowOpacity = 0.2
        dailyReadingView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func setupCollectionView() {
        radingBooksCollectionView.delegate = self
        radingBooksCollectionView.dataSource = self
        self.radingBooksCollectionView.register(UINib.init(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        setupFlowLayout()
        radingBooksCollectionView.layer.borderWidth = 0.5
        radingBooksCollectionView.layer.cornerRadius = 10
        radingBooksCollectionView.layer.borderColor = UIColor.middlegrey2.cgColor
    }
    
    func setupFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: self.radingBooksCollectionView.layer.bounds.width
                                     , height: 138)
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        radingBooksCollectionView.collectionViewLayout = flowLayout
    }
    
    func initMainView() {
        self.getChallengeRequest { (challengeData) in
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
                if self.challengeInfo?.isExpired == true {
                    self.showRestartChallengePopup()
                    // 참여기간내 미션 성공
                } else {
                    self.initVC(isCompletedChallenge: isChallengeIsCompleted)
                }
            }
        }
    }

    func showRestartChallengePopup() {
        print("showRestartChallengePopup() is called")
        let restartChallnegeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "restartChallengeVC") as! RestartChallengeViewController
        let challenge = challengeInfo?.todayChallenge
        let targetBookAmount = challenge?.amount ?? 0// 읽기 목표 권수
        let period = challenge?.period ?? "D"// 읽기 주기
        let formattedPeriod = getDateFromPeriod(period: period)
        let challengeName = "\(formattedPeriod)에 \(targetBookAmount)권 챌린지"
        restartChallnegeVC.delegate = self
        restartChallnegeVC.challengeName = challengeName
        restartChallnegeVC.modalTransitionStyle = .crossDissolve
        restartChallnegeVC.modalPresentationStyle = .overFullScreen
        self.present(restartChallnegeVC, animated: true, completion: nil)
    }
    
    // 목표 설정 화면 진입 전에, 처음 추가한 목표인지 or 기존 목표 수정인지 여부를 판단하고 적용
    // 데이터 파싱 완료 이후, 유저에게 보여줄 데이터를 VC에 적용
    func initVC(isCompletedChallenge: Int?) {
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
            let formattedPeriod = getDateFromPeriod(period: period)
            let todayTime = challenge.todayTime ?? "0" // 오늘 읽은 시간
            let totalReadingDiary = challenge.totalJournal ?? 0// 챌린지 기간동안 읽은 책 권수
            let readBookAmount = challenge.totalReadBook ?? 0
            let dDay = challenge.dDay ?? 0 // 챌린지 남은 기간
            let percent = goal.percent ?? 0 // 챌린지 달성도
            let cgFloatPercent = CGFloat(percent) * 0.01
            print("LOG - 일지 작성 개수",challenge.totalJournal as Any, challenge.amount as Any)
            userReadingGoalLabel.text = "\(getUserNameByLength(userName))님은 \(formattedPeriod)동안\n\(targetBookAmount)권 읽기에 도전 중"
            goalStatusBarWidth.constant = statusBar.frame.width * cgFloatPercent
            daillyReadingTimeLabel.text = minutesToHoursAndMinutes(todayTime)
            daillyReadingDiaryCountLabel.text = "\(totalReadingDiary)개"
            targetReadingBookCountLabel.text = "\(targetBookAmount)"
            targetTimeLabel.text = "목표 \(targetTime)분"
            currentReadingBookCountLabel.text = "\(readBookAmount)권 / "
            dDayLabel.text = "\(dDay)일 남음"
            
            if let challengeCompleted = challengeInfo {
                if challengeCompleted.isCompletedChallenge() {
                    GlobalSettings.challengeCompletionInformation.increaseCompletedCount()
                    if GlobalSettings.challengeCompletionInformation.isValid() == true {
                        print("LOG - 챌린지 만료시점에 목표 달성한 경우, 애니메이션 출력")
                    }
                }
            }
            
            // 작업 완료시 이 부분이 if문 안으로 들어가야 함
            let challengeCompletionVC = UIViewController().initViewControllerstoryBoardName(
                storyBoardName: UIViewController.mainStroyBoard, viewControllerId: "challengeCompletionVC")
            navigationController?.pushViewController(challengeCompletionVC, animated: false)


        }
    }

    private func getUserNameByLength(_ name: String?) -> String {
        print("LOG - 유저 이름", name as Any)
        var nameString = ""
        if let userName = name {
            if userName.count > 3 {
                let index = (name?.index(name!.startIndex, offsetBy: 3))!
                let subString = name?.substring(to: index)  // Hello
                nameString = subString!
                nameString += "..."
            } else {
                nameString = userName
            }
        } else {
            nameString = "Reader"
        }
        return nameString
    }
    
    private func minutesToHoursAndMinutes (_ stringMinutes : String) -> String {
        let minutes = Int(stringMinutes) ?? 0
        var formattedString = "0시간 0분"
        if minutes > 60 {
            formattedString =  "\(minutes / 60)시간 \(minutes % 60)분"
        } else if minutes < 60 {
            formattedString = "0시간 \(minutes)분"
        } else {
            formattedString = "0시간 0분"
        }
        
        return formattedString
    }
    
    private func getDateFromPeriod(period: String) -> String {
        switch period {
        case "D": return "한 주"
        case "M": return "한 달"
        default: return "일 년"
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

// 챌린지 재시작 팝업 종료 이후, 목표설정 화면으로 이동하기 위한 프로토콜
extension ViewController: ViewChangeDelegate {
    func dismissViewController(_ controller: UIViewController) {
        let modifyReadingGaolVC = UIStoryboard(name: "Goal", bundle: nil).instantiateViewController(withIdentifier: "TermViewController") as! TermViewController
        modifyReadingGaolVC.initializer = 1
        self.navigationController?.pushViewController(modifyReadingGaolVC, animated: true)
    }
}

// API 호출 함수
extension ViewController {
    func getChallengeRequest(completion:@escaping (ChallengerInfo?) -> Void) {
        let reqUrl =  "https://prod.maekuswant.shop/challenge"
        guard let token = keychain.get(Keys.token) else { return }
        let tokenHeader = HTTPHeader(name: "x-access-token", value: token)
        let typeHeader = HTTPHeader(name: "Content-Type", value: "application/json")
        let header = HTTPHeaders([typeHeader, tokenHeader])
        
        
        AF.request(reqUrl, method: .get, headers: header).validate(statusCode: 200..<300).responseJSON { response in
            switch(response.result) {
            case .success(_) :
                if let data = response.data {
                    guard let jsonData = try? JSON(data: data) else { return }
                    let isSuccess = jsonData["isSuccess"].boolValue
                    let responseCode = jsonData["code"].intValue
                    let message = jsonData["message"].stringValue
                    let isExpired = jsonData["isExpired"].boolValue

                    if isSuccess == true {
                        switch responseCode {
                        case 1000:
                            print("LOG - 책, 챌린지, 목표 정보 조회 성공")

                            let goalBookInfo = jsonData["getchallenge1Rows"].arrayValue
                            let challengeStatus = jsonData["getchallenge2Rows"].arrayValue
                            guard let todayReadingJson = jsonData["getchallenge3Rows"].arrayValue.first else { return }
                            let books =  goalBookInfo.compactMap{ self.getBookInfoFromJson(json: $0) }
                            let challengeStatusList = challengeStatus.compactMap{ self.getReadingGoalFromJson(json: $0[0])}// 지금 읽는 책 1권으로 고정이라 0번째 인덱스값만 받도록함. 추후 여러권 보여준다면 수정 필요.
                            let todayReading = self.getChallengeFromJson(json: todayReadingJson)
                            let challengerInfo = ChallengerInfo(readingBook: books, readingGoal: challengeStatusList, todayChallenge: todayReading, isExpired: isExpired)
                            completion(challengerInfo)
                        case 2223:
                            self.presentAlert(title: "읽을 책을 먼저 설정해주세요.", isCancelActionIncluded: false)
                        case 2224:
                            self.presentAlert(title: "독서 목표를 먼저 설정해주세요.", isCancelActionIncluded: false)
                        case 4020:
                            self.presentAlert(title: "로그인 정보를 다시 확인해주세요.", isCancelActionIncluded: false)
                        default:
                            print("파싱결과 : 도전하고 있는 책 정보 없음", isSuccess, responseCode, message)
                            completion(nil)
                        }
                    } else {
                        print("파싱결과 : 도전하고 있는 책 정보 없음", isSuccess, responseCode, message)
                        completion(nil)
                    }
                }
                break ;
            case .failure(_):
                print("LOG - 책, 챌린지, 목표 정보 조회 실패")
                completion(nil)
                break;
            }
        }
    }

    private func getBookInfoFromJson(json: JSON) -> ReadingBook {
        let goalId = json["goalId"].intValue
        let bookId = json["bookId"].intValue
        let title = json["title"].stringValue
        let writer = json["writer"].stringValue
        let imageUrl = json["imageURL"].stringValue
        let isbn = json["publishNumber"].stringValue
        let goalBookId = json["goalBookId"].intValue
        let isComplete = json["isComplete"].intValue
        let chllengeReadingBook = ReadingBook(goalId: goalId, bookId: bookId, title: title, writer: writer, imageURL: imageUrl, publishNumber: isbn, goalBookId: goalBookId, isComplete: isComplete)

        return chllengeReadingBook
    }

    private func getReadingGoalFromJson(json: JSON) -> ReadingGoal {
        let goalBookId = json["goalBookId"].intValue
        let page = json["page"].intValue
        let percent = json["percent"].intValue
        let totalReadingTime = json["time"].stringValue
        let isReading = json["isReading"].stringValue

        let readongGoal = ReadingGoal(goalBookId: goalBookId, page: page, percent: percent, totalTime: totalReadingTime, isReading: isReading)

        return readongGoal
    }

    private func getChallengeFromJson(json: JSON) -> Challenge {
        let totalJournal = json["sumJournal"].intValue
        let todayReadingTime = json["todayTime"].string
        let amount = json["amount"].intValue
        let time = json["time"].intValue
        let period = json["period"].stringValue
        let userId = json["userId"].intValue
        let totalReadingBook = json["sumAmount"].intValue
        let name = json["name"].stringValue
        let expriodAt = json["expriodAt"].stringValue
        let dDay = json["Dday"].intValue
        let challengeId = json["challengeId"].intValue

        let challenge = Challenge(totalJournal: totalJournal, todayTime: todayReadingTime, amount: amount, time: time, period: period, userId: userId,
                                  totalReadBook: totalReadingBook, name: name, expriodAt: expriodAt, dDay: dDay, challengeId: challengeId)

        return challenge
    }
}
