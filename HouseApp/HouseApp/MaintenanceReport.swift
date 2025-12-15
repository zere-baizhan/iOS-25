//
//  MaintenanceReport.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//

import Foundation
import FirebaseFirestore

struct MaintenanceReport {
    let id: String
    let title: String
    let category: String
    let details: String
    let status: String
    let resolutionText: String
    let createdAt: Date
    let resolvedAt: Date?
    let createdById: String
    let createdByName: String

    init(id: String, data: [String: Any]) {
        self.id = id
        self.title = data["title"] as? String ?? ""
        self.category = data["category"] as? String ?? ""
        self.details = data["details"] as? String ?? ""
        self.status = data["status"] as? String ?? "pending"
        self.resolutionText = data["resolutionText"] as? String ?? ""
        self.createdById = data["createdById"] as? String ?? ""
        self.createdByName = data["createdByName"] as? String ?? ""

        let createdTS = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
        self.createdAt = createdTS.dateValue()

        if let resolvedTS = data["resolvedAt"] as? Timestamp {
            self.resolvedAt = resolvedTS.dateValue()
        } else {
            self.resolvedAt = nil
        }
    }
}
