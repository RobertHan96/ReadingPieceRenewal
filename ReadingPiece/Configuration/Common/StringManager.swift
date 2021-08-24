//
//  StringManager.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/08/15.
//

import Foundation
import UIKit

struct StringManager {
    func getUserNameByLength(_ name: String?) -> String {
        print("LOG - 유저 이름", name as Any)
        var nameString = ""
        if let userName = name {
            if userName.count > 3 {
                let index = (name?.index(name!.startIndex, offsetBy: 3))!
                let subString = name?.substring(to: index)  // Hello
                nameString = subString!
                nameString += "..."
            } else {
                nameString = userName
            }
        } else {
            nameString = "Reader"
        }
        return nameString
    }
    
    func minutesToHoursAndMinutes (_ stringMinutes : String) -> String {
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
    
    func getDateFromPeriod(period: String) -> String {
        switch period {
        case "D": return "한 주"
        case "M": return "한 달"
        default: return "일 년"
        }
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
}
