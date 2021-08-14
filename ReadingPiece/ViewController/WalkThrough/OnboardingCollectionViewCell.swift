//
//  OnboardingCollectionViewCell.swift
//  ReadingPiece
//
//  Created by 정지현 on 2021/08/14.
//

import UIKit
import SnapKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "OnboardingCollectionViewCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NotoSans(.bold, size: 30)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.NotoSans(.regular, size: 16)
        label.textColor = .charcoal
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        print("OnboardingCollectionViewCell awake! ")
        setupLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.52).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        
        
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: imageView.frame.height * 0.19)
        ])
        
        
        
        NSLayoutConstraint.activate([
            descLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(index: Int) {
        
        imageView.image = UIImage(named: "\(index)Graphic")
        
        switch index {
        case 1:
            titleLabel.text = "목표 세우기"
            descLabel.text = "목표를 세우고 차근차근 책을 읽어보세요! \n책을 읽을수록 케이크가 한 조각씩 채워져요."
        case 2:
            titleLabel.text = "즉각적인 성과"
            descLabel.text = "독서 인증 후에 오늘 독서량, \n오늘 독서 시간 등을 빠르게 알려줘요."
        case 3:
            titleLabel.text = "책에 대한 생각 공유"
            descLabel.text = "나의 일지를 저장, 공유하고 다른 사람들이 \n공개한 일지를 볼 수 있어요."
        default:
            titleLabel.text = "목표 세우기"
            descLabel.text = "목표를 세우고 차근차근 책을 읽어보세요! \n책을 읽을수록 케이크가 한 조각씩 채워져요."
        }
    }
}
