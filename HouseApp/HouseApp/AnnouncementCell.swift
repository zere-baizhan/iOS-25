//
//  AnnouncementCell.swift
//  HouseApp
//
//  Created by reqwwiem on 12.12.2025.
//


import UIKit

final class AnnouncementCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newBadgeLabel: UILabel!

    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var calendarImageView: UIImageView!
    func configure(with a: Announcement) {
        titleLabel.text = a.title
        contentLabel.text = a.content
        authorLabel.text = a.author
        newBadgeLabel.isHidden = !a.isNew
        dateLabel.text = DateFormatter.localizedString(from: a.date, dateStyle: .medium, timeStyle: .none)
        calendarImageView.image = UIImage(systemName: "calendar")
        authorImageView.image = UIImage(systemName: "person")
        calendarImageView.tintColor = .systemGray
        authorImageView.tintColor = .systemGray
        newBadgeLabel.text = "New"
        newBadgeLabel.isHidden = !a.isNew
        newBadgeLabel.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.35)
        newBadgeLabel.textColor = .systemBlue
        newBadgeLabel.textAlignment = .center
        newBadgeLabel.layer.cornerRadius = 16
        newBadgeLabel.clipsToBounds = true

    }
}
