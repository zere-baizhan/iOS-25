//
//  FirestoreService.swift
//  HouseApp
//
//  Created by reqwwiem on 11.12.2025.
//

import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    func saveResident(_ resident: Resident, completion: @escaping (Error?) -> Void) {
        let data: [String: Any] = [
            "name": resident.name,
            "email": resident.email,
            "flat": resident.flat
        ]

        db.collection("residents")
          .document(resident.id)         // id = email
          .setData(data, completion: completion)
    }
}
