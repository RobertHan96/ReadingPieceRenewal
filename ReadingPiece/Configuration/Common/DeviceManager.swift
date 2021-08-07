//
//  File.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/08/08.
//

import Foundation
import UIKit

struct DeviceManager {
    // 디바이스별로 팝업창 최소 높이 확보에 필요한 constraint 값을 반환하는 함수
    func getsPopupViewHeightConstraints() -> Int{
        let screenHeight = UIScreen.main.bounds.size.height
        var extraHeight: Int = 0
        var extraWidth: Int = 0

        if screenHeight == 896 {
            print("iPhone 11, 11proMax, iPhone XR")
            extraHeight = -50
        }
        else if screenHeight == 926 {
            print("iPhone 12proMax")
            extraHeight = -70
        }
        else if screenHeight == 844 {
            print("iPhone 12, 12pro")
        }
        else if screenHeight == 736 {
            print("iPhone 8plus")
        }
        else if screenHeight == 667 {
            print("iPhone 8")
            extraHeight = 30
        }
        else {
            print("iPhone 12 mini, iPhone XS")
        }
        return extraHeight
    }
}
