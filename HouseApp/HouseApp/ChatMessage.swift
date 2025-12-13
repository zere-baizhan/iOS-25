//
//  ChatMessage.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//


import Foundation
import FirebaseFirestore

struct ChatMessage {
    let id: String
    let text: String
    let senderId: String
    let senderName: String
    let createdAt: Date

    init(id: String, text: String, senderId: String, senderName: String, createdAt: Date) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.createdAt = createdAt
    }

    init?(doc: DocumentSnapshot) {
        let d = doc.data() ?? [:]
        guard
            let text = d["text"] as? String,
            let senderId = d["senderId"] as? String,
            let senderName = d["senderName"] as? String
        else { return nil }

        let ts = (d["createdAt"] as? Timestamp) ?? Timestamp(date: Date())
        self.init(id: doc.documentID, text: text, senderId: senderId, senderName: senderName, createdAt: ts.dateValue())
    }

    var toDict: [String: Any] {
        [
            "text": text,
            "senderId": senderId,
            "senderName": senderName,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
    var timeString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: createdAt)
        }
}
