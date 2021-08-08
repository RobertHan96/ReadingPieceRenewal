//
//  BookDetailViewController.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/03/08.
//

import UIKit
import KeychainSwift

class BookDetailViewController: UIViewController {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    let defaults = UserDefaults.standard
    var initializer: Int?
    var userReview: [UserBookReviewFirstDetail] = []
    var goal: ClientGoal?

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    @IBOutlet weak var totalReviewLabel: UILabel!
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var reviewTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var moreReviewView: UIView!

    var isExpanded : Bool = false
    var observerExist : Bool = false
    var isVaildBook: Bool = false

    var initHeight : NSLayoutConstraint?
    var book : Book?
    var bookId: Int?
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        postBookInfo()
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        reviewTableView.separatorStyle = .none
        reviewTableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "bookReviewCell")
        reviewTableView.rowHeight = 189.5
        reviewTableView.estimatedRowHeight = 189.5
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layer.masksToBounds = false

        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.1
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if observerExist {
            reviewTableView.removeObserver(self, forKeyPath: "contentSize")
            observerExist = false
        }
    }

    func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.moreReviewTapped(_:)))
        self.moreReviewView.addGestureRecognizer(tapGesture)
    }

    @objc func moreReviewTapped(_ gesture: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Goal", bundle: nil)
        guard let reviewListVC = storyboard.instantiateViewController(withIdentifier: "reviewListVC") as? BookReviewViewController else { return }
        reviewListVC.userReview = self.userReview
        self.navigationController?.pushViewController(reviewListVC, animated: true)
    }

//    @IBAction func moreReviewTapped(_ sender: Any) {
//
//    }

    @IBAction func addBook(_ sender: Any) {
        // initializer가 0이면 목표 설정에서 호출, 책추가 버튼 누르면 메인 탭 바 컨트롤러로 이동
        // initializer가 1이면 내서재 리뷰쓰기 화면에서 호출, 책추가 버튼 누르면 리뷰 작성 화면으로 이동
        if let initNumber = self.initializer  {
            if initNumber == 0  && isVaildBook == true {
                // 신규유저 : 목표 자체가 설정된게 없으므로, 목표 추가 -> 책 추가 -> 메인으로 이동
                if self.goal?.isNewUser == true {
                    postUserReadingGoal()
                // 기존유저 : 책 추가 후 메인으로 이동
                } else {
                    postChallengeBook(isbn: self.book?.isbn ?? "")
                }
            } else if initNumber == 1 && isVaildBook == true { //카카오 책 API에서 필요한 정보를 다 주는 책만 리뷰 작성화면으로 이동 가능
                let reviewVC = CreateReviewViewController()
                reviewVC.book = self.book
                reviewVC.bookID = self.bookId
                self.navigationController?.pushViewController(reviewVC, animated: true)
            } else if initNumber == 2 && isVaildBook == true { // 책 관리화면에서 호출하는 경우, initializer = 2
                postChallengeBook(isbn: self.book?.isbn ?? "")
            }
        }
    }

    // DB에 사용자가 조회한 책 정보 등록 : 챌린지 진행할 책이 아니더라도, 무조건 호출해서 책 정보 등록
    func postBookInfo() {
        guard let token = keychain.get(Keys.token) else { return }
        if let bookData = book {
            let bookData = GeneralBook(writer: bookData.authors.joined(separator: ",") , publishDate: bookData.datetime, publishNumber: bookData.isbn, contents: bookData.summary, imageURL: bookData.thumbnailPath, title: bookData.title, publisher: bookData.publisher)
            let addBookReq = AddBookRequest(book: bookData, token: token)

            _ = Network.request(req: addBookReq) { (result) in
                    switch result {
                    case .success(let userResponse):
                        let isbn = bookData.publishNumber
                        let bookId = String(userResponse.bookId)
                        self.bookId = userResponse.bookId
                        switch userResponse.code {
                        case 1000:
                            print("LOG - 책 정보 DB추가 완료 : ID\(bookId) - \(bookData.title)" )
                            self.isVaildBook = true
                            self.getUserRewview(isbn: isbn, bookId: bookId)
                        case 2110:
                            print("LOG - 책 정보 DB에 등록된 책, 유저 리뷰내역 조회... 책ID\(bookId) - \(bookData.title)" )
                            self.isVaildBook = true
                            self.getUserRewview(isbn: isbn, bookId: bookId)
                        default:
                            print("LOG 책 정보 DB추가 실패 - \(userResponse.message)")
                            self.getUserRewview(isbn: isbn, bookId: bookId)
                        }
                    case .cancel(let cancelError):
                        print(cancelError!)
                    case .failure(let error):
                        print("LOG", error)
                        self.presentAlert(title: "책 정보 로딩 실패, 다른 책을 선택해주세요.", isCancelActionIncluded: false)
                        self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.presentAlert(title: "책 정보 로딩 실패, 네트워크 연결 상태를 확인해주세요.", isCancelActionIncluded: false)
            navigationController?.popViewController(animated: true)
        }
    }

    // 불러온 유저 리뷰 정보를 바탕으로 하단 테이블뷰 리로드
    func getUserRewview(isbn: String, bookId: String) {
        
        guard let token = keychain.get(Keys.token) else { return }
        let getReviewReq = GetUserBookReviewRequest(isbn: isbn, token: token)
        _ = Network.request(req: getReviewReq) { (result) in
                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        print("LOG - 리뷰 \(userResponse.totalReadingUser)개 조회 완료")
                        if let userReview = userResponse.userBookReview, let totalReader = userResponse.totalReadingUser?.first?.currentRead {
                            self.setTableViewDataSource(review: userReview, totalReader: totalReader)
                        }
                    default:
                        print("LOG 리뷰 정보 조회 실패 \(userResponse.code)")
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    debugPrint("LOG", error, "\(getReviewReq.baseUrl)" + "\(getReviewReq.endpoint)")
                    self.presentAlert(title: "리뷰 정보 로딩 실패, 네트워크 연결 상태를 확인해주세요.", isCancelActionIncluded: false)
                    self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func postUserReadingGoal() {
        guard let token = keychain.get(Keys.token) else { return }
        if let amount =  self.goal?.amount, let period = self.goal?.period, let time = self.goal?.time {
            let req = PostReadingGoalRequest(Goal(period: period, amount: amount, time: time), token: token)
            var goalId: Int?
            
            _ = Network.request(req: req) { (result) in
                    switch result {
                    case .success(let userResponse):
                        switch userResponse.code {
                        case 1000:
                            if let userGoalId = userResponse.goalId {
                                print("LOG - 목표설정 완료", userGoalId, amount, period, time, userResponse.message)
                                self.defaults.setValue(userGoalId, forKey: Constants.USERDEFAULT_KEY_GOAL_ID)
                                // 책 추가 API 호출
                                self.postChallengeBook(isbn: self.book?.isbn ?? "")
                                
                            // 신규 유저 : goalId 추가 실패한 경우
                            } else {
                                self.presentAlert(title: "입력값을 다시 확인해주세요.", isCancelActionIncluded: false)
                            }
                        case 2100, 2101:
                            self.presentAlert(title: "입력값을 다시 확인해주세요.", isCancelActionIncluded: false)
                        case 2122:
                            self.presentAlert(title: "해당 기간에 이미 설정한 목표가 있습니다.", isCancelActionIncluded: false)
                        default:
                            self.presentAlert(title: "서버와의 연결이 원활하지 않습니다.", isCancelActionIncluded: false)
                        }
                    case .cancel(let cancelError):
                        print(cancelError!)
                    case .failure(let error):
                        self.presentAlert(title: "서버와의 연결이 원활하지 않습니다.", isCancelActionIncluded: false)
                }
            }
        }
    }


    // 사용자가 챌린지 목표로 설정한 책 등록
    func postChallengeBook(isbn: String) {
        let goalId = userDefaults.integer(forKey: Constants.USERDEFAULT_KEY_GOAL_ID)
        guard let token = keychain.get(Keys.token) else { return }
        guard let bookId = bookId else { return }
        let addChallengeBookReq = PostChallengeBookRequest(goalId: goalId, isbn: isbn, bookId: bookId, token: token)

        _ = Network.request(req: addChallengeBookReq) { (result) in

                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        print("LOG - 챌린지할 책 추가 완료", userResponse.code, userResponse.message)
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabController") as! UITabBarController
                        vc.modalPresentationStyle = .overFullScreen
                        self.present(vc, animated: true, completion: nil)
                    case 2110:
                        self.presentAlert(title: "이미 읽고 있는 책입니다.", isCancelActionIncluded: false)
                    case 2111: // 책 중복 추가
                        self.presentAlert(title: userResponse.message, isCancelActionIncluded: false)
                    case 2112: // 본인 목표치보다 더 많은 책을 추가하려고 하는 경우
                        self.presentAlert(title: userResponse.message, isCancelActionIncluded: false)
                    default:
                        print("LOGG", userResponse.code, userResponse.message)
                        self.presentAlert(title: "입력 정보를 다시 확인 해주세요.", isCancelActionIncluded: false)
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    debugPrint(error)
                    self.presentAlert(title: "서버와의 연결이 원활하지 않습니다.", isCancelActionIncluded: false)
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if object is UITableView {
                if let newValue = change?[.newKey]{
                    let newSize = newValue as! CGSize
                    reviewTableViewHeight.constant = newSize.width

                }
            }
        }
    }

    func setUI(){
        if book?.thumbnailPath != "" {
            let url = URL(string: book!.thumbnailPath)
            bookImageView.kf.setImage(with: url, placeholder: UIImage(named: "defaultBookCoverImage"), completionHandler: nil)
        }
        if book?.summary != "" {
            summaryLabel.text = book?.summary
        }
        titleLabel.text = book?.title
        authorsLabel.text = book?.authors.joined(separator: ",")
        publisherLabel.text = book?.publisher
    }
    
    func setTableViewDataSource(review: [UserBookReviewFirstDetail], totalReader: Int) {
        self.userReview = review
        self.reviewTableView.reloadData()
        self.totalReviewLabel.text = "\(totalReader)"
    }
}

extension BookDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 유저 리뷰가 있을때만 1개의 리뷰를 먼저 보여주고, 없을 경우 보여주지 않음
        switch userReview.first?.contents {
        case nil:
            return 0
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewTableView.dequeueReusableCell(withIdentifier: "bookReviewCell", for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }

        if let review = userReview.first {
            // 리뷰데이터를 받아서, cell에 적용하는 함수
            cell.configure(reviewData: review)
        }

        cell.reviewCellDelegate = self

        if isExpanded {// 더보기 버튼을 누른 셀인 경우
            print("is Expand")
            cell.reviewLabel.numberOfLines = 0
            cell.moreReadButton.isHidden = true
        } else {
            cell.reviewLabel.numberOfLines = 2
            cell.moreReadButton.isHidden = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension BookDetailViewController: ReviewTableViewCellDelegate {
    func moreTextButtonTapped(cell: ReviewTableViewCell) {
        if let indexPath = reviewTableView.indexPath(for: cell) {
            print("more button tapped at row-\(String(indexPath.row))")
            isExpanded = true
            reviewTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)//테이블 뷰 높이 바꾸기 위해서
            observerExist = true
            reviewTableView.reloadData()
        }
    }

    func editReviewButtonTapped(cell: ReviewTableViewCell) {
        if let indexPath = reviewTableView.indexPath(for: cell){
            showAlert(indexPath: indexPath)
        }
    }

    func likeButtonTapped(cell: ReviewTableViewCell) {
        if let indexPath = reviewTableView.indexPath(for: cell) {
            print("like button tapped at row-\(String(indexPath.row))")
            if let cell = reviewTableView.cellForRow(at: indexPath) as? ReviewTableViewCell {
                if cell.likeButton.isSelected { // 좋아요 누른 경우

                } else { // 좋아요 안누른 경우

                }
                cell.likeButton.isSelected = !cell.likeButton.isSelected
            }
        }
    }

    func commentButtonTapped(cell: ReviewTableViewCell) {
        if let indexPath = reviewTableView.indexPath(for: cell) {
            print("comment button tapped at row-\(String(indexPath.row))")
            let storyboard = UIStoryboard(name: "Goal", bundle: nil)
            if let myViewController = storyboard.instantiateViewController(withIdentifier: "CommentController") as? CommentViewController {
                presentPanModal(myViewController)
            }
        }
    }

    func showAlert(indexPath: IndexPath) { // alert 보여줄 때 breaking constraint는 버그라고 한다.
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let modify = UIAlertAction(title: "수정", style: .default) { (action) in
            print("리뷰 수정 row-\(indexPath.row)")
        }
        let remove = UIAlertAction(title: "삭제", style: .destructive) { (action) in
            print("리뷰 삭제 row-\(indexPath.row)")
            //TODO : 데이터 삭제
            //self.reviewTableView.deleteRows(at: [indexPath], with: .automatic)//삭제 후 다른 사람의 리뷰로 대체??

        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(modify)
        alert.addAction(remove)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }

}
