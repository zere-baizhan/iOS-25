//
//  UserSession.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//

import Foundation
import FirebaseAuth

final class UserSession {
    static let shared = UserSession()
    private init() {}

    var uid: String = ""
    var email: String = ""
    var name: String = ""
    var role: String = "resident"

    var isLoggedIn: Bool { !uid.isEmpty }

    func updateFromAuth(name: String? = nil) {
        guard let user = Auth.auth().currentUser else { return }
        self.uid = user.uid
        self.email = user.email ?? ""
        if let name { self.name = name }
    }

    func clear() {
        uid = ""
        email = ""
        name = ""
        role = "resident"
    }
}
