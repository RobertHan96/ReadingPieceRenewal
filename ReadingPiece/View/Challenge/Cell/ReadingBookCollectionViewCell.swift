//
//  ReadingBookCollectionViewCell.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/03/15.
//

import UIKit
import Kingfisher

class ReadingBookCollectionViewCell: UICollectionViewCell {
    static var identifier: String = "ReadingBookCollectionViewCell"
    @IBOutlet weak var bookThumbnail: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var currentPageLabel: UILabel!
    @IBOutlet weak var currentPercentLabel: UILabel!
    @IBOutlet weak var radingTimeLabel: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var pageBackgroundView: UIView!
    @IBOutlet weak var percentBackgroundView: UIView!
    @IBOutlet weak var timeBackgroundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    func configure(data: ReadingBook?, readingStatus: ReadingGoal?) {
        if let bookData = data, let readingGoalData = readingStatus {
            // 하단 책 정보에 읽기 상황정보 적용
            if  let page = readingGoalData.page, let percent = readingGoalData.percent, let time = readingGoalData.totalTime {
                currentPageLabel.text = "\(page)p"
                currentPercentLabel.text = "\(percent)%"
                radingTimeLabel.text = "\(minutesToHoursAndMinutes(time))"
            }
            
            // 하단 책 정보에 책관련 기본정보 적용
            bookTitleLabel.text = bookData.title ?? ""
            authorLabel.text = bookData.writer ?? ""
            guard let stringUrl = bookData.imageURL else { return }
            if let imgUrl = URL(string: stringUrl) {
                bookThumbnail.kf.setImage(with: imgUrl)
            }
        }
    }
        
    // 분단위로 오는 시간을 0시간 0분 형태로 변환
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
    
    private func setupUI() {
//        bgView.layer.borderWidth = 0.5
//        bgView.layer.cornerRadius = 10
//        bgView.layer.borderColor = UIColor.middlegrey2.cgColor
//        bookThumbnail.layer.cornerRadius = 4
        pageBackgroundView.layer.cornerRadius = 5
        percentBackgroundView.layer.cornerRadius = 5
        timeBackgroundView.layer.cornerRadius = 5
        bookThumbnail.layer.cornerRadius = 4
        bookThumbnail.layer.borderWidth = 0.4
        bookThumbnail.layer.borderColor = UIColor.darkgrey.cgColor

    }
    
}
