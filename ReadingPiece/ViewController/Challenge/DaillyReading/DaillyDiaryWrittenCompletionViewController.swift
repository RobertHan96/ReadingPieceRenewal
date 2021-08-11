//
//  DaillyDiaryWrittenCompletionViewController.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/08.
//

import UIKit
import KeychainSwift
import SpriteKit

// 일지 작성 완료시, 그날 읽은 독서정보를 정산해서 보여주는 화면
class DaillyDiaryWrittenCompletionViewController: UIViewController {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    let goalId = UserDefaults.standard.string(forKey: Constants.USERDEFAULT_KEY_GOAL_ID)
    @IBOutlet weak var daillyDiaryWrittenTableView: UITableView!
    @IBOutlet weak var gotomainButton: UIButton!
    
    
    var readingContinuity: ReadingContinuity?

    var todayReadingStatus: TodayReadingStatus? {
        didSet {
            daillyDiaryWrittenTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getDaillyReadingInfo()
    }
    
    @objc func shareDaillyReadingResult(sender: UIBarButtonItem){
        shareResult()
    }

    @objc func closeDaillyReadingResult(sender: UIBarButtonItem){
        // 메인화면으로 이동
        print("test")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func gotomainTapped(_ sender: Any) {
        print("test")
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    func getDaillyReadingInfo() {
        guard let token = keychain.get(Keys.token) else { return }
        guard let goalId = self.goalId else { return }
        let req = GetTodayChallengeRequest(token: token, goalId: goalId)
        
        _ = Network.request(req: req) { [self] (result) in
                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        print("LOG - 일일 독서정보 조회 성공 \(userResponse.code)")
                        self.readingContinuity = userResponse.getcontinuityRows?.first
                        self.todayReadingStatus = userResponse.getcontinuity2Rows?.first
                        print("LOG - readingContinuity: \(String(describing: self.readingContinuity))")
                        print("LOG - todayReadingStatus: \(String(describing: self.todayReadingStatus))")
                        // 챌린지 달성시, 축하 애니메이션 보여주는 화면으로 이동 (추후 구현)
                    default:
                        print("LOG 일일 독서정보 조회 실패 \(userResponse.code), \(userResponse.message)")
                        self.presentAlert(title: "일일 독서 정보 조회 실패", isCancelActionIncluded: false)
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    debugPrint("LOG", error)
                    self.presentAlert(title: "네트워크 연결 실패 통신 상태를 확인해주세요.", isCancelActionIncluded: false)
            }
        }

    }
    
    private func setupUI() {
        UIApplication.shared.endIgnoringInteractionEvents()
        setNavBar()
        setupTableView()
        gotomainButton.makeRoundedButtnon("메인으로 돌아가기", titleColor: .white, borderColor: UIColor.melon.cgColor, backgroundColor: .melon)
        gotomainButton.titleLabel?.font = UIFont.NotoSans(.medium, size: 17)
    }
        
    private func setNavBar() {
        self.navigationController?.navigationBar.topItem?.title = "인증 완료"
        self.navigationController?.navigationBar.tintColor = .darkgrey
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "shareIconLine"), style: .plain, target: self, action: #selector(shareDaillyReadingResult(sender:)))
        let leftButton = UIBarButtonItem(image: UIImage(named: "navBack"), style: .plain, target: self, action: #selector(closeDaillyReadingResult(sender:)))

        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem = leftButton
    }

    private func setupTableView() {
        daillyDiaryWrittenTableView.delegate = self
        daillyDiaryWrittenTableView.dataSource = self
        daillyDiaryWrittenTableView.register(UINib(nibName: ChallengeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ChallengeTableViewCell.identifier)
        daillyDiaryWrittenTableView.register(UINib(nibName: DaillyReadingTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: DaillyReadingTableViewCell.identifier)
    }
        
    func shareResult() {
        let image = daillyDiaryWrittenTableView.visibleCells.first?.captureScreenToImage()
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]

        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension DaillyDiaryWrittenCompletionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let challengeCell = tableView.dequeueReusableCell(withIdentifier: ChallengeTableViewCell.identifier, for: indexPath) as? ChallengeTableViewCell
            else { return UITableViewCell() }
        if let continuity = readingContinuity, let readingStatus = todayReadingStatus {
            challengeCell.configure(readingContinuity: continuity, todayReadingStatus: readingStatus)
        }
        return challengeCell

//    switch indexPath.section {
        // 챌린지 결과도 보여줄 경우, 추후 구현 예정 항목
//        case 0:
            // 이름 반대로 적용, challengeCell에 DaillyReading 관련 내용이 있고, DaillyReadingCell에 Challenge Cake 관련 내용이 있음
//            guard let challengeCell = tableView.dequeueReusableCell(withIdentifier: ChallengeTableViewCell.identifier, for: indexPath) as? ChallengeTableViewCell
//                else { return UITableViewCell() }
//            if let continuity = readingContinuity, let readingStatus = todayReadingStatus {
//                challengeCell.configure(readingContinuity: continuity, todayReadingStatus: readingStatus)
//            }
//            return challengeCell
//        default:
//            guard let daillyReadingCell = tableView.dequeueReusableCell(withIdentifier: DaillyReadingTableViewCell.identifier, for: indexPath) as? DaillyReadingTableViewCell
//                else { return UITableViewCell() }
//            return daillyReadingCell
//        }
    }
}

extension DaillyDiaryWrittenCompletionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.backgroundColor = .systemGray6
    }
}
