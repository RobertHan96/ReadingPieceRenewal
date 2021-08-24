//
//  ReviewTableViewCell.swift
//  ReadingPiece
//
//  Created by SYEON on 2021/03/08.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var bookImageView: UIImageView!
    
    @IBOutlet weak var star1ImageView: UIImageView!
    @IBOutlet weak var star2ImageView: UIImageView!
    @IBOutlet weak var star3ImageView: UIImageView!
    @IBOutlet weak var star4ImageView: UIImageView!
    @IBOutlet weak var star5ImageView: UIImageView!
    @IBOutlet weak var isCompletedImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var moreReadButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var reviewCellDelegate : ReviewTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        bookImageView.layer.cornerRadius = bookImageView.frame.height/2
        bookImageView.clipsToBounds = true
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupUI() {
        likeLabel.isHidden = true
        likeButton.isHidden = true
        commentButton.isHidden = true
        commentLabel.isHidden = true
        editButton.isHidden = true
        isCompletedImage.isHidden = true
    }
    
    // 전체 리뷰리스트 표시용 레이아웃
    func configure(reviewListData: UserBookReviewListInfo) {
        nameLabel.text = reviewListData.name
        dateLabel.text = reviewListData.postAt
        reviewLabel.text = reviewListData.text
        guard let stringUrl = reviewListData.profilePictureURL else { return}
        let imgUrl = URL(string: stringUrl)
        guard let star = reviewListData.star else { return }
        bookImageView.kf.setImage(with: imgUrl)
        drawStars(rating: star)
    }
    
    // 책 정보 하단에 보여지는 리뷰 1개 상세 레이아웃
    func configure(reviewData: UserBookReviewFirstDetail) {
        nameLabel.text = reviewData.name
        dateLabel.text = reviewData.postAt
        reviewLabel.text = reviewData.text
        guard let stringUrl = reviewData.profilePictureURL else { return}
        let imgUrl = URL(string: stringUrl)
        guard let star = reviewData.star else { return }
        bookImageView.kf.setImage(with: imgUrl)
        drawStars(rating: star)
        checkReadingCompleted(status: reviewData.status)
    }
    
    func checkReadingCompleted(status: String?) {
        guard let readingStatus = status else { return }
        if readingStatus == "Y" {
            isCompletedImage.image = UIImage(named: "readingCompeleted")
        }
    }
    
    
    @IBAction func textExpandButtonTapped(_ sender: Any) {
        reviewCellDelegate?.moreTextButtonTapped(cell: self)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        reviewCellDelegate?.editReviewButtonTapped(cell: self)
    }
    @IBAction func likeButtonTapped(_ sender: Any) {
        reviewCellDelegate?.likeButtonTapped(cell: self)
    }

    @IBAction func commentButtonTapped(_ sender: Any) {
        reviewCellDelegate?.commentButtonTapped(cell: self)
    }
    
    func drawStars(rating: Int) {
        let stars = [star1ImageView,star2ImageView,star3ImageView,star4ImageView,star5ImageView]
        stars.enumerated().forEach{ (index,star) in
            if rating < (index+1) {
                star?.isHidden = true
            }
        }
    }
    
}

protocol ReviewTableViewCellDelegate {
    func moreTextButtonTapped(cell: ReviewTableViewCell)
    func editReviewButtonTapped(cell: ReviewTableViewCell)
    func likeButtonTapped(cell: ReviewTableViewCell)
    func commentButtonTapped(cell: ReviewTableViewCell)
}
