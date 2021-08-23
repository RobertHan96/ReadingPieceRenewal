//
//  String.swift
//  ReadingPiece
//
//  Created by 정지현 on 2021/03/25.
//

import Foundation

extension String {
    
    var getNewCakeName: String {
        switch self {
        case "cream":
            return "choco"
        default:
            return "berry"
        }
    }
    
    // 유효성검사 타입
    enum ValidityType {
        case email
        case password
    }
    // 유효성검사에 쓰이는 정규표현식
    enum Regex: String {
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0.-]+\\.[A-Za-z]{2,64}"
        case password = "[A-Z0-9a-z._%+-]{6,20}"
    }
    // 유효한지 스트링 검사
    func isValid(_ validityType: ValidityType) -> Bool{
        let format = "SELF MATCHES %@"
        var regex = ""
        
        switch validityType {
        case .email:
            regex = Regex.email.rawValue
        case .password:
            regex = Regex.password.rawValue
        }
        return NSPredicate(format: format, regex).evaluate(with: self)
    }
    
}
