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
    
    func addAnnouncement(title: String, content: String, author: String, completion: @escaping (Error?) -> Void) {
            let data: [String: Any] = [
                "title": title,
                "content": content,
                "author": author,
                "date": Timestamp(date: Date()),
                "isNew": true
            ]
            db.collection("announcements").addDocument(data: data) { error in
                completion(error)
            }
        }

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


       func createAnnouncement(_ a: Announcement, completion: @escaping (Error?) -> Void) {
           db.collection("announcements").document(a.id).setData(a.toDict, completion: completion)
       }

    func fetchAnnouncements(completion: @escaping (Result<[Announcement], Error>) -> Void) {
            db.collection("announcements")
                .order(by: "date", descending: true)
                .getDocuments { snap, err in
                    if let err = err { completion(.failure(err)); return }
                    let list: [Announcement] = snap?.documents.compactMap { doc in
                        let d = doc.data()
                        let title = d["title"] as? String ?? ""
                        let content = d["content"] as? String ?? ""
                        let author = d["author"] as? String ?? ""
                        let ts = d["date"] as? Timestamp ?? Timestamp(date: Date())
                        let isNew = d["isNew"] as? Bool ?? false
                        return Announcement(id: doc.documentID, title: title, content: content, date: ts.dateValue(), author: author, isNew: isNew)
                    } ?? []
                    completion(.success(list))
                }
        }
}
