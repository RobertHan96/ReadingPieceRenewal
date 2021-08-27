//
//  DailyDiaryWrittenViewController.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/06.
//

import UIKit
import KeychainSwift
import Kingfisher
import Bond

protocol ReadingStatusDelegate {
    func setReadingPage(_ page: Int)
    func setReadingPercent(_ percent: Int)
}
class DaillyReadingWritenViewController: UIViewController {
    
    let keychain = KeychainSwift(keyPrefix: Keys.keyPrefix)
    let defaults = UserDefaults.standard
    let goalId = UserDefaults.standard.integer(forKey: Constants.USERDEFAULT_KEY_GOAL_ID)
    let goalBookId = UserDefaults.standard.integer(forKey: Constants.USERDEFAULT_KEY_GOAL_BOOK_ID)
    let challengeId = UserDefaults.standard.integer(forKey: Constants.USERDEFAULT_KEY_CHALLENGE_ID)
    let cellId = ReviewImageCell.identifier
    let picker = UIImagePickerController()
    
    var challengeInfo : ChallengerInfo?
    var readingTime : Int = 0
    var pickedImage : UIImage?
    var readingPercent: Int = 0
    var readingPage: Int = 0
    var isPublic: Bool? {
        didSet {
            isValidatePost()
        }
    }

    @IBOutlet weak var postImageButton: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var bookInfoView: UIView!
    @IBOutlet weak var bookThumbnailImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var readingPageInputButton: UIButton!
    @IBOutlet weak var readingPercentInputButton: UIButton!
    @IBOutlet weak var publicPostButton: UIButton!
    @IBOutlet weak var privatePostButton: UIButton!
    @IBOutlet weak var postDairyButton: UIButton!
    @IBOutlet weak var commentLengthLabel: UILabel!
    @IBOutlet weak var reviewImageHeight: NSLayoutConstraint!
    @IBOutlet weak var reviewImageView: UIImageView!
    @IBOutlet weak var reviewImagePopButton: UIButton! {
        didSet {
            reviewImagePopButton.isHidden = !reviewImagePopButton.isHidden
        }
    }
    
    // 구현 편의상 버튼으로 구현, 따로 연결된 Action은 없음
    // UI셋업만 진행하고, 연결된 로직은 없는 컴포넌트
    @IBOutlet weak var readingStatusButton: UIButton!
    @IBOutlet weak var totalReadingTimeButton: UIButton!
    @IBOutlet weak var readingAmountTitleLabel: UILabel!
    @IBOutlet weak var commentTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        picker.delegate = self
        commentTextView.delegate = self
        
        textField.reactive.text.observeNext { text in
            print(text)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = "독서 일지"
    }

    // 상단 완료 버튼
    @objc func postDiary(sender: UIBarButtonItem) {
        writeJournal()
    }
    
    // 하단 완료 버튼
    @IBAction func postDiary(_ sender: UIButton) {
        if isValidatePost() == true {
            // API 호출
            writeJournal()
        }
    }
    
    func writeJournal() {
        // 네트워크 통신 동안 작성 버튼의 중복터치를 막는 코드
        UIApplication.shared.beginIgnoringInteractionEvents()

        guard let token = keychain.get(Keys.token) else { return }
        let isOpen = getIsOpenFromIsJson(isPublic: isPublic ?? true)
        print("LOG TEST", isOpen)
        let journal = JournalWritten(time: readingTime, text: commentTextView.text, open: isOpen, goalBookId: goalBookId,
                                     page: readingPage, percent: readingPercent)
        print("LOG - 일지 입력 정보",journal.time, journal.text, journal.open, journal.goalBookId, journal.page, journal.percent)
        let req = PostJournalRequest(token: token, journal: journal)
        
        _ = Network.request(req: req) { (result) in
                switch result {
                case .success(let userResponse):
                    switch userResponse.code {
                    case 1000:
                        print("LOG - 일지 작성 성공 \(userResponse.code)")
                        NotificationCenter.default.post(name: Notification.Name("FetchJournalData"), object: nil)
                        // 일지 작성 후, 그 날 읽은 결과를 보여주는 화면
                        guard let daillyreadingResultVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "daillyreadingResultVC") as?
                                DaillyDiaryWrittenCompletionViewController else { return }
                        self.navigationController?.pushViewController(daillyreadingResultVC, animated: true)
                    case 2225:
                        let message = userResponse.message
                        print("LOG - message: \(message)")
                        self.presentAlert(title: message, isCancelActionIncluded: false)
                    case 2227:
                        let message = userResponse.message
                        print("LOG - message: \(message)")
                        self.presentAlert(title: message, isCancelActionIncluded: false)
                    case 2228:
                        let message = userResponse.message
                        print("LOG - message: \(message)")
                        self.presentAlert(title: message, isCancelActionIncluded: false)
                    case 3001:
                        let message = userResponse.message
                        print("LOG - message: \(message)")
                        self.presentAlert(title: "일지 작성을 위해 먼저 닉네임을 설정해주세요.", isCancelActionIncluded: false)
                    default:
                        print("LOG 일지 작성 실패 \(userResponse.code)", journal, journal.goalBookId)
                        self.presentAlert(title: "일지 작성에 실패하였습니다. 입력 정보를 다시 확인해주세요.", isCancelActionIncluded: false)
                        
                    }
                case .cancel(let cancelError):
                    print(cancelError!)
                case .failure(let error):
                    debugPrint("LOG", error)
                    self.presentAlert(title: "네트워크 연결 실패 통신 상태를 확인해주세요.", isCancelActionIncluded: false)
            }
        }
        // 버튼 작성 잠금 해제
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    // 일지 작성에 필요한 값이 스트링형태라 Bool -> String으로 변환
    func getIsOpenFromIsJson(isPublic: Bool) -> String {
        switch isPublic {
        case true:
            return "Y"
        default:
            return "N"
        }
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        addImageAlertAction()
    }
    
    @IBAction func popImage(_ sender: UIButton) {
        reviewImageHeight.constant = 0
        reviewImagePopButton.isHidden = true
        pickedImage = nil
    }
    @IBAction func pageSelect(_ sender: UIButton) {
        guard let inputReadingStatusVC = self.storyboard?.instantiateViewController(withIdentifier: InputReadingStatusPopupViewController.storyobardId) as? InputReadingStatusPopupViewController else { return }
        inputReadingStatusVC.readingStatusDelegate = self
        //inputReadingStatusVC.modalTransitionStyle = .crossDissolve
        inputReadingStatusVC.modalPresentationStyle = .overCurrentContext
        self.present(inputReadingStatusVC, animated: true, completion: nil)
    }
    
    @IBAction func percentSelect(_ sender: UIButton) {
        guard let inputReadingPercentVC = self.storyboard?.instantiateViewController(withIdentifier: InputReadingPercentPopupViewController.storyobardId) as? InputReadingPercentPopupViewController else { return }
        inputReadingPercentVC.readingStatusDelegate = self
        //inputReadingPercentVC.modalTransitionStyle = .crossDissolve
        inputReadingPercentVC.modalPresentationStyle = .overCurrentContext
        self.present(inputReadingPercentVC, animated: true, completion: nil)
    }
    
    @IBAction func makePublicPost(_ sender: UIButton) {
        isPublic = true
        DispatchQueue.main.async {
            self.publicPostButton.makeSmallRoundedButtnon("전체 공개", titleColor: .white, borderColor: UIColor.darkgrey.cgColor, backgroundColor: .darkgrey)
            self.privatePostButton.makeSmallRoundedButtnon("나만 보기", titleColor: .darkgrey, borderColor: UIColor.darkgrey.cgColor, backgroundColor: .white)
        }
    }
        
    @IBAction func makePrivatePost(_ sender: UIButton) {
        isPublic = false
        DispatchQueue.main.async {
            self.publicPostButton.makeSmallRoundedButtnon("전체 공개", titleColor: .darkgrey, borderColor: UIColor.darkgrey.cgColor, backgroundColor: .white)
            self.privatePostButton.makeSmallRoundedButtnon("나만 보기", titleColor: .white, borderColor: UIColor.darkgrey.cgColor, backgroundColor: .darkgrey)
        }
    }

    private func setupUI() {
        let readingTimeInt = Int.getMinutesTextByTime(readingTime)
        let readingTimeString = "\(readingTimeInt) 분"
        let author = challengeInfo?.readingBook.first?.writer ?? "저자 정보 로딩 실패"
        let title = challengeInfo?.readingBook.first?.title ?? "제목 정보 로딩 실패"

        bookThumbnailImage.layer.cornerRadius = 4
        bookThumbnailImage.layer.borderWidth = 0.5
        bookThumbnailImage.layer.borderColor = UIColor.darkgrey.cgColor
        bookAuthorLabel.text = author
        bookTitleLabel.text = title
        totalReadingTimeButton.makeRoundedTagButtnon(" \(readingTimeString)", titleColor: .middlegrey1, borderColor: UIColor.lightgrey1.cgColor, backgroundColor: .lightgrey1)
        setNavBar()
        totalReadingTimeButton.setTitle("\(getMinutesTextByTime(readingTime))", for: .normal)
        bookInfoView.layer.addBorder([.bottom], color: .middlegrey2, width: 0.5)
        readingStatusButton.makeRoundedTagButtnon("읽는 중", titleColor: .middlegrey1, borderColor: UIColor.middlegrey1.cgColor, backgroundColor: .white)
        postDairyButton.makeRoundedButtnon("완료", titleColor: .darkgrey, borderColor: UIColor.fillDisabled.cgColor, backgroundColor: .fillDisabled)
        readingPageInputButton.makeSmallRoundedButtnon("00p", titleColor: .white, borderColor: UIColor.main.cgColor, backgroundColor: .main)
        readingPercentInputButton.makeSmallRoundedButtnon("00%", titleColor: .main, borderColor: UIColor.main.cgColor, backgroundColor: .white)
        publicPostButton.makeSmallRoundedButtnon("전체 공개", titleColor: .darkgrey, borderColor: UIColor.darkgrey.cgColor, backgroundColor: .white)
        privatePostButton.makeSmallRoundedButtnon("나만 보기", titleColor: .darkgrey, borderColor: UIColor.darkgrey.cgColor, backgroundColor: .white)
        reviewImagePopButton.isHidden = true
        bookTitleLabel.textColor = .darkgrey
        bookAuthorLabel.textColor = .darkgrey
        commentTextView.textColor = .charcoal
        commentTextView.backgroundColor = .lightgrey1
        commentTextView.layer.cornerRadius = 8
        commentLengthLabel.textColor = .darkgrey
        
        // 일지 이미지 첨부 기능 부활시 제거
        postImageButton.isHidden = true
        // 실패시 리턴 처리 해놔서, 책 이미지 적용은 가장 마지막에 실행
        guard let urlString = challengeInfo?.readingBook.first?.imageURL else { return }
        let imgUrl = URL(string: urlString)
        bookThumbnailImage.kf.setImage(with: imgUrl)
        bookThumbnailImage.layer.cornerRadius = 4
    }
    
    func getMinutesTextByTime(_ time: Int) -> String {
        var text = ""
        if time > 60 {
            text = "\(time / 60)분"
        } else {
            text = "\(1)분"
        }
        return text
    }

    private func setNavBar() {
        self.navigationItem.title = "독서 일지"
        self.navigationController?.navigationBar.topItem?.title = ""
        let rightButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(postDiary(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = .main
        self.navigationController?.navigationBar.tintColor = .darkgrey
    }
    
    func isValidatePost() -> Bool {
        var validationResult = false
        if self.commentTextView.text.count > 1 && self.readingPage > 1 && self.readingPercent > 1 && isPublic != nil {
            validationResult = true
            DispatchQueue.main.async {
                self.postDairyButton.makeRoundedButtnon("완료", titleColor: .white, borderColor: UIColor.main.cgColor, backgroundColor: .main)
            }
        } else {
            DispatchQueue.main.async {
                self.postDairyButton.makeRoundedButtnon("완료", titleColor: .darkgrey, borderColor: UIColor.fillDisabled.cgColor, backgroundColor: .fillDisabled)
            }
        }
        
        return validationResult
    }
}

extension DaillyReadingWritenViewController: ReadingStatusDelegate {
    func setReadingPage(_ page: Int) {
        print("LOG - 읽은 페이지 수 저장 완료")
        readingPage = page
        readingPageInputButton.setTitle("\(page) p", for: .normal)
    }
    
    func setReadingPercent(_ percent: Int) {
        print("LOG - 읽은 % 저장 완료")
        readingPercent = percent
        readingPercentInputButton.setTitle("\(percent) %", for: .normal)
    }
}

extension DaillyReadingWritenViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        commentTextView.reactive.text.observeNext { text in
            let textLength = text._unbox?.count ?? 0
            DispatchQueue.main.async {
                self.commentLengthLabel.text = "\(textLength) / 100"
            }
        }

        guard textView.text!.count < 100 else { return false }
        return true

    }
    
    // UITextView Placeholder 설정
    func textViewSetupView() {
        if commentTextView.text == "기억에 남는 문구, 소감을 기록하세요!" {
            commentTextView.text = ""
            commentTextView.textColor = UIColor.black
        } else if commentTextView.text == "" {
            commentTextView.text = "기억에 남는 문구, 소감을 기록하세요!"
            commentTextView.textColor = .middlegrey1
        } else {
            commentTextView.textColor = UIColor.black
        }
    }
    
    // 편집이 시작될때
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetupView()
    }
    // 편집이 종료될때
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text == "" {
            textViewSetupView()
        }
    }
}

extension DaillyReadingWritenViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            setSelectedImage(image)
         }
        dismiss(animated: true, completion: nil)
     }
    
    func setSelectedImage(_ img: UIImage) {
        DispatchQueue.main.async {
            self.reviewImageHeight.constant = 75
            self.pickedImage = img
//            let resizedImage = self.pickedImage?.imageResized(to: CGSize(width: 100, height: 100)).jpegData(compressionQuality: 0.1)
//            print("LOG - Image String", imgBase64String)
            self.reviewImagePopButton.isHidden = false
            self.reviewImageView.image = img
        }
    }
    

    
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// 카메라, 갤러리 이미지 관련 함수 모음
extension DaillyReadingWritenViewController {
    func openLibrary(){
      picker.sourceType = .photoLibrary
      present(picker, animated: false, completion: nil)
    }

    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            present(picker, animated: false, completion: nil)
            }else{
            print("LOG - 카메라 로드 실패")
        }
    }
    
    @objc func open() {
        addImageAlertAction()
    }
    
    func addImageAlertAction() {
        let alert =  UIAlertController(title: "이미지 선택", message: "일지에 첨부할 이미지를 선택해주세요.", preferredStyle: .actionSheet)
        let library =  UIAlertAction(title: "갤러리 선택", style: .default) { (action) in
            self.openLibrary()
        }
        let camera =  UIAlertAction(title: "사진 촬영", style: .default) { (action) in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
