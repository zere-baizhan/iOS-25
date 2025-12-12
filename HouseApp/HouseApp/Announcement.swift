//
//  Announcement.swift
//  HouseApp
//
//  Created by reqwwiem on 12.12.2025.
//

import Foundation
import FirebaseFirestore

struct Announcement {
    let id: String
    let title: String
    let content: String
    let date: Date
    let author: String
    let isNew: Bool

    init(id: String = UUID().uuidString,
         title: String,
         content: String,
         date: Date = Date(),
         author: String,
         isNew: Bool = true) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.author = author
        self.isNew = isNew
    }

    init?(id: String, data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let content = data["content"] as? String,
            let author = data["author"] as? String
        else { return nil }

        let ts = data["date"] as? Timestamp
        let date = ts?.dateValue() ?? Date()
        let isNew = data["isNew"] as? Bool ?? false

        self.init(id: id, title: title, content: content, date: date, author: author, isNew: isNew)
    }

    var toDict: [String: Any] {
        [
            "title": title,
            "content": content,
            "author": author,
            "date": Timestamp(date: date),
            "isNew": isNew
        ]
    }
}

