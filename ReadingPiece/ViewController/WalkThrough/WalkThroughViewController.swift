//
//  ContainerViewController.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/08/02.
//

import UIKit

class WalkThroughViewController: UIViewController {
    @IBOutlet weak var skipIntroBtn: UIButton!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func didSkipIntroButtonClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabController")
        navigationController?.pushViewController(tabBarController, animated: false)
    }
    
    @IBAction func didNextButtonClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "WalkThrough", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "secondWalkThrough")
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
