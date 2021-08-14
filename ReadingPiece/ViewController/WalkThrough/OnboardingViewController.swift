//
//  OnboardingViewController.swift
//  ReadingPiece
//
//  Created by 정지현 on 2021/08/14.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    var currentPage: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage > 1 {
                nextButton.setTitle("시작하기", for: .normal)
            } else {
                nextButton.setTitle("다음", for: .normal)
            }
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
        
        pageControl.numberOfPages = 3
        pageControl.currentPage = currentPage
        pageControl.isUserInteractionEnabled = false
        //pageControl.addTarget(self, action: #selector(pageControlTapHandler(sender:)), for: .touchUpInside)
    }
    
    private func setupUI() {
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
        nextButton.backgroundColor = .melon
        skipButton.tintColor = .melon
        
    }
    
    @objc func pageControlTapHandler(sender: UIPageControl) {
        print("sender.currentPage : ", sender.currentPage)
        currentPage = sender.currentPage
        collectionView.scrollTo(horizontalPage: currentPage, animated: true)
        
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentPage < 2 {
            currentPage += 1
            collectionView.scrollTo(horizontalPage: currentPage, animated: true)
        } else {
            finishOnboarding()
        }
    }
    @IBAction func skipButtonTapped(_ sender: Any) {
        finishOnboarding()
    }
    
    private func finishOnboarding() {
        if LoginManager().isValidLoginToken() {
            self.pushViewController(storyBoardName: UIViewController.mainStroyBoard, viewControllerId: UIViewController.mainViewControllerId)
        } else {
            let vc = UIViewController().initViewControllerstoryBoardName(storyBoardName: UIViewController.loginStroyBoard, viewControllerId: UIViewController.loginViewControllerId)
            UIApplication.shared.keyWindow?.replaceRootViewController(vc, animated: true, completion: nil)
        }
    }
    
}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as? OnboardingCollectionViewCell
        cell?.configure(index: indexPath.item + 1)
        return cell ?? UICollectionViewCell()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        currentPage = Int(pageIndex)
        //pageControl.currentPage = Int(pageIndex)
    }
    
    
}
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        return size
    }
}
