//
//  UIFont.swift
//  ReadingPiece
//
//  Created by 정지현 on 2021/03/07.
//

import Foundation
import UIKit

extension UIFont {
    public enum NotoSansType: String {
        case black = "Black"
        case bold = "Bold"
        case demiLight = "DemiLight"
        case light = "Light"
        case medium = "Medium"
        case regular = "Regular"
        case thin = "Thin"
    }

    // ex. label.font = .NotoSans(.medium, size: 16)
    static func NotoSans(_ type: NotoSansType, size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSansCJKkr-\(type.rawValue)", size: size)!
    }

}
