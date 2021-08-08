//
//  SecondIntroViewController.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/08/02.
//

import UIKit

class SecondIntroViewController: UIViewController {
    @IBOutlet weak var skipIntroBtn: UIButton!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.layer.zPosition = 1
        nextBtn.layer.cornerRadius = nextBtn.frame.height / 2
        nextBtn.backgroundColor = .melon
        nextBtn.titleLabel?.font = UIFont.NotoSans(.medium, size: 16)
        skipIntroBtn.setTitleColor(.mainPink, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func didSkipIntroButtonClicked(_ sender: UIButton) {
        if LoginManager().isValidLoginToken() {
            self.pushViewController(storyBoardName: UIViewController.mainStroyBoard, viewControllerId: UIViewController.mainViewControllerId)
        } else {
            let vc = UIViewController().initViewControllerstoryBoardName(storyBoardName: UIViewController.loginStroyBoard, viewControllerId: UIViewController.loginViewControllerId)
            UIApplication.shared.keyWindow?.replaceRootViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func didNextButtonClicked(_ sender: UIButton) {
        self.pushViewController(storyBoardName: UIViewController.walkThroughStroyBoard, viewControllerId: UIViewController.thridWalkThroughtViewControllerId)
    }
}
