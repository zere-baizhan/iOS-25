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
    
    @IBOutlet weak var bubbleLeading: NSLayoutConstraint!

    @IBOutlet weak var bubbleTrailing: NSLayoutConstraint!
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    func configure(msg: ChatMessage, isMine: Bool) {
        messageLabel.text = msg.text
        timeLabel.text = Self.timeFormatter.string(from: msg.createdAt)

        // “пузырь” вправо/влево
        bubbleLeading.isActive = !isMine
        bubbleTrailing.isActive = isMine

        messageLabel.textAlignment = isMine ? .right : .left
        bubbleStack.alignment = isMine ? .trailing : .leading
        
        if bubbleLeading == nil || bubbleTrailing == nil {
               print("❌ OUTLETS NIL: bubbleLeading:", bubbleLeading as Any,
                     "bubbleTrailing:", bubbleTrailing as Any,
                     "stack:", bubbleStack as Any)
           }
    }
}


