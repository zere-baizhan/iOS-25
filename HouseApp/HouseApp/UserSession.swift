//
//  UserSession.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//

import Foundation

final class UserSession {
    static let shared = UserSession()
    private init() {}

    // Минимально нужные данные
    var userId: String = "test@example.com"   // позже заменим на Firebase Auth
    var name: String = "Admin"
}
