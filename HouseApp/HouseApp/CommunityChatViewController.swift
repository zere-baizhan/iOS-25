//
//  CommunityChatViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//
import Foundation
import UIKit
import FirebaseFirestore

final class CommunityChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!

    private var items: [ChatMessage] = []
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80

        listener = FirestoreService.shared.listenCommunityMessages { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.items = list
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
                case .failure(let err):
                    print("🔥 listen error:", err)
                }
            }
        }
    }

    deinit {
        listener?.remove()
    }

    @IBAction func sendTapped(_ sender: UIButton) {
        let text = (messageTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // ⚠️ тут возьми данные текущего пользователя
        let senderId = UserSession.shared.userId   // например email
        let senderName = UserSession.shared.name

        FirestoreService.shared.sendCommunityMessage(text: text, senderId: senderId, senderName: senderName) { [weak self] err in
            DispatchQueue.main.async {
                if let err = err { print("🔥 send error:", err) }
                else { self?.messageTextField.text = "" }
            }
        }
    }

    private func scrollToBottom() {
        guard items.count > 0 else { return }
        let indexPath = IndexPath(row: items.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension CommunityChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        cell.configure(msg: msg, isMine: msg.senderId == UserSession.shared.userId)
        return cell
    }
}
