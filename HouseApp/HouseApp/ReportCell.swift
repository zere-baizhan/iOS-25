//
//  ReportCell.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//


import UIKit

final class ReportCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    @IBOutlet weak var resolutionBox: UIView!
    @IBOutlet weak var resolutionLabel: UILabel!

    @IBOutlet weak var submittedLabel: UILabel!
    @IBOutlet weak var resolvedLabel: UILabel!

    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f
    }()
    @objc private func applyTexts() {
        submittedLabel.text = "submitted_report".L
        resolvedLabel.text = "report_status_resolved".L

    }

    func configure(_ r: MaintenanceReport) {
        titleLabel.text = r.title
        categoryLabel.text = r.category
        detailsLabel.text = r.details
        
        applyTexts()

        // badge
        switch r.status {
        case "pending":
            badgeLabel.text = "Pending"
            badgeLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.25)
        case "in_progress":
            badgeLabel.text = "In Progress"
            badgeLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        case "resolved":
            badgeLabel.text = "Resolved"
            badgeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        default:
            badgeLabel.text = r.status
            badgeLabel.backgroundColor = UIColor.systemGray5
        }
        badgeLabel.layer.cornerRadius = 14
        badgeLabel.clipsToBounds = true

        submittedLabel.text = "Submitted: \(df.string(from: r.createdAt))"

        if let resolvedAt = r.resolvedAt {
            resolvedLabel.isHidden = false
            resolvedLabel.text = "Resolved: \(df.string(from: resolvedAt))"
        } else {
            resolvedLabel.isHidden = true
        }

        // resolution box
        if r.status == "resolved", !r.resolutionText.isEmpty {
            resolutionBox.isHidden = false
            resolutionLabel.text = "Resolution: \(r.resolutionText)"
        } else {
            resolutionBox.isHidden = true
        }
    }
}
