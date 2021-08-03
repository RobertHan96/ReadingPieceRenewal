//
//  JoinResponse.swift
//  ReadingPiece
//
//  Created by 정지현 on 2021/03/28.
//

import Foundation

// 회원가입 API 응답구조
public struct JoinResponse: Codable {
    public let isSuccess: Bool
    public let code: Int
    public let message: String
    public let jwt: String?
}
