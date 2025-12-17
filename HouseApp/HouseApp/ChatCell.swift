//
//  ChatCell.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//

import UIKit

final class ChatCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var bubbleStack: UIStackView!
    private var leadingC: NSLayoutConstraint!
       private var trailingC: NSLayoutConstraint!

       private static let timeFormatter: DateFormatter = {
           let f = DateFormatter()
           f.dateFormat = "HH:mm"
           return f
       }()

       override func awakeFromNib() {
           super.awakeFromNib()

           selectionStyle = .none

           // стиль пузыря
           bubbleStack.layer.cornerRadius = 14
           bubbleStack.clipsToBounds = true

           messageLabel.numberOfLines = 0

           // создание констрейнтов в коде
           bubbleStack.translatesAutoresizingMaskIntoConstraints = false

           leadingC = bubbleStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
           trailingC = bubbleStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

           // вертикально
           NSLayoutConstraint.activate([
            bubbleStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
               bubbleStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

               // ограничение ширины пузыря
               bubbleStack.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
           ])
       }

       override func prepareForReuse() {
           super.prepareForReuse()
           leadingC?.isActive = false
           trailingC?.isActive = false
       }

       func configure(msg: ChatMessage, currentUserId: String) {
           let isMine = (msg.senderId == UserSession.shared.uid)

           messageLabel.text = msg.text
           timeLabel.text = Self.timeFormatter.string(from: msg.createdAt)

           // включаем только одну сторону
           leadingC.isActive = !isMine
           trailingC.isActive = isMine

           // мое справа/чужое слева
           if isMine {
               bubbleStack.backgroundColor = UIColor.systemBlue
               messageLabel.textColor = .white
               timeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
               messageLabel.textAlignment = .left
               timeLabel.textAlignment = .right
           } else {
               bubbleStack.backgroundColor = UIColor.systemGray6
               messageLabel.textColor = .label
               timeLabel.textColor = .secondaryLabel
               messageLabel.textAlignment = .left
               timeLabel.textAlignment = .left
           }
       }
   }
