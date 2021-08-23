//
//  File.swift
//  ReadingPiece
//
//  Created by HanaHan on 2021/04/02.
//

import Foundation

extension Int {
    static func getMinutesTextByTime(_ time: Int) -> String {
        var text = ""
        if time > 60 {
            text = "\(time / 60)분"
        } else {
            text = "\(1)분"
        }
        return text
    }
    
    static func getCakeImageNameByPercent(percent: Int) -> Int {
        var result = 0
        
        if percent > 0 && percent < 20 {
            result = 1
        } else if percent >= 20  && percent < 40 {
            result = 2
        } else if percent >= 40 && percent < 60 {
            result = 3
        } else if percent >= 60 && percent < 80 {
            result = 4
        } else if percent >= 80 {
            result = 5
        }
        return result
    }
    
}
