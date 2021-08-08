//
//  BookReviewViewController.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/03/09.
//

import UIKit

class BookReviewViewController: UIViewController {
    var userReview: [UserBookReviewFirstDetail] = []
    var expandedIndexSet : IndexSet = []
    @IBOutlet weak var reviewTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewTableView.tableFooterView = UIView(frame: CGRect.zero)
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        reviewTableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "bookReviewCell")
        //reviewTableView.rowHeight = 189.5
        
        reviewTableView.rowHeight = UITableView.automaticDimension
        reviewTableView.estimatedRowHeight = 189.5
        
    }
    
}

extension BookReviewViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 유저 리뷰가 있을때만 1개의 리뷰를 먼저 보여주고, 없을 경우 보여주지 않음
        switch userReview.first?.contents {
        case nil:
            //let message = "아직 평가/리뷰가 없어요. \n꾸준히 독서하고 책에 대해 평가해보세요!"
            //reviewTableView.setEmptyView(image: UIImage(named: "recordIcon")!, message: message, buttonType: "none", actionButtonClosure: {
            //    print("none")
            //})
            return 0
        default:
            return userReview.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = reviewTableView.dequeueReusableCell(withIdentifier: "bookReviewCell", for: indexPath) as? ReviewTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(reviewData: userReview[indexPath.row])
        cell.reviewCellDelegate = self
        
        if expandedIndexSet.contains(indexPath.row) {// 더보기 버튼을 누른 셀인 경우
            cell.reviewLabel.numberOfLines = 0
            cell.moreReadButton.isHidden = true
        } else {
            cell.reviewLabel.numberOfLines = 2
            cell.moreReadButton.isHidden = false
        }
 
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height: CGFloat = scrollView.frame.size.height
        let contentYOffset: CGFloat = scrollView.contentOffset.y
        let scrollViewHeight: CGFloat = scrollView.contentSize.height
        let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
                  
        if distanceFromBottom < height {
            addData()
        }
    }
    
    func addData(){
        
    }
    
    
}

extension BookReviewViewController: ReviewTableViewCellDelegate {
    func moreTextButtonTapped(cell: ReviewTableViewCell) {
        if let indexPath = reviewTableView.indexPath(for: cell) {
            print("more button tapped at row-\(String(indexPath.row))")
//            // 다시 줄이기 기능이 있을 경우
//            if(expandedIndexSet.contains(indexPath.row)){
//                expandedIndexSet.remove(indexPath.row)
//            } else {
//                expandedIndexSet.insert(indexPath.row)
//            }
            expandedIndexSet.insert(indexPath.row)
            reviewTableView.reloadRows(at: [indexPath], with: .automatic)
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
            //self.reviewTableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(modify)
        alert.addAction(remove)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

