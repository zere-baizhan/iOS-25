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
    
    func fetchProfile(completion: @escaping (Result<ResidentProfile, Error>) -> Void) {
            let id = UserSession.shared.uid

            db.collection("users").document(id).getDocument { snap, err in
                if let err = err { completion(.failure(err)); return }
                let d = snap?.data() ?? [:]
                let p = ResidentProfile(
                    name: d["name"] as? String ?? "",
                    email: d["email"] as? String ?? id,
                    phone: d["phone"] as? String ?? "",
                    emergencyPhone: (d["emergencyPhone"] as? String) ?? (d["emergencyContact"] as? String) ?? "",
                    flat: d["flat"] as? String ?? "",
                    floor: d["floor"] as? String ?? ""
                )
                completion(.success(p))
            }
        }

        func saveProfile(_ p: ResidentProfile, completion: @escaping (Error?) -> Void) {
            let id = UserSession.shared.uid

            let data: [String: Any] = [
                "name": p.name,
                "email": p.email,
                "phone": p.phone,
                "emergencyPhone": p.emergencyPhone,
                "flat": p.flat,
                "floor": p.floor
            ]

            db.collection("users").document(id).setData(data, merge: true, completion: completion)
        }
    
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
        var data: [String: Any] = [
            "name": resident.name,
            "email": resident.email,
            "flat": resident.flat
        ]

        data["phone"] = resident.phone ?? ""
        data["emergencyPhone"] = resident.emergencyContact ?? ""
        data["floor"] = resident.floor ?? ""

        db.collection("users")
            .document(resident.id)
            .setData(data, merge: true, completion: completion) // merge важно!
    }
    func fetchResident(id: String, completion: @escaping (Result<Resident, Error>) -> Void) {
        db.collection("users").document(id).getDocument { snap, err in
            if let err = err { completion(.failure(err)); return }
            guard let d = snap?.data() else {
                completion(.failure(NSError(domain: "no_data", code: 0)))
                return
            }

            let r = Resident(
                id: id,
                name: d["name"] as? String ?? "",
                email: d["email"] as? String ?? id,
                flat: d["flat"] as? String ?? "",
                phone: (d["phone"] as? String).flatMap { $0.isEmpty ? nil : $0 },
                emergencyContact: ((d["emergencyPhone"] as? String) ?? (d["emergencyContact"] as? String)).flatMap { $0.isEmpty ? nil : $0 },
                floor: (d["floor"] as? String).flatMap { $0.isEmpty ? nil : $0 }
            )
            completion(.success(r))
        }
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
    
    func sendCommunityMessage(text: String, senderId: String, senderName: String, completion: @escaping (Error?) -> Void) {
            let data: [String: Any] = [
                "text": text,
                "senderId": senderId,
                "senderName": senderName,
                "createdAt": FieldValue.serverTimestamp()
            ]

            db.collection("community_messages").addDocument(data: data, completion: completion)
        }

        func listenCommunityMessages(onChange: @escaping (Result<[ChatMessage], Error>) -> Void) -> ListenerRegistration {
            return db.collection("community_messages")
                .order(by: "createdAt", descending: false)
                .addSnapshotListener { snap, err in
                    if let err = err { onChange(.failure(err)); return }
                    let list = snap?.documents.compactMap { ChatMessage(doc: $0) } ?? []
                    onChange(.success(list))
                }
        }
    func listenReports(completion: @escaping (Result<[MaintenanceReport], Error>) -> Void) -> ListenerRegistration {
            db.collection("maintenance_reports")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snap, err in
                    if let err = err { completion(.failure(err)); return }
                    let list: [MaintenanceReport] = snap?.documents.map {
                        MaintenanceReport(id: $0.documentID, data: $0.data())
                    } ?? []
                    completion(.success(list))
                }
        }
    func createReport(title: String,
                          category: String,
                          details: String,
                          createdById: String,
                          createdByName: String,
                          completion: @escaping (Error?) -> Void) {

            let data: [String: Any] = [
                "title": title,
                "category": category,
                "details": details,
                "status": "pending",
                "resolutionText": "",
                "createdAt": Timestamp(date: Date()),
                "createdById": createdById,
                "createdByName": createdByName
            ]

            db.collection("maintenance_reports").addDocument(data: data, completion: completion)
        }
}
