//
//  CreateAnnouncementViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 12.12.2025.
//


import UIKit

final class CreateAnnouncementViewController: UIViewController {

    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var contentTextView: UITextField!
    @IBOutlet weak var titleTextField: UITextField!

    var onPosted: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))

        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true

        // placeholder для TextView (если хочешь)
        contentTextView.layer.cornerRadius = 10
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor
    }

    @IBAction func postTapped(_ sender: UIButton) {
        let title = (titleTextField.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let content = (contentTextView.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty, !content.isEmpty else {
            showAlert(title: "Fill all fields",
                      message: "Title and Content are required.")
            return
        }

        let author = "Admin"

        FirestoreService.shared.addAnnouncement(
            title: title,
            content: content,
            author: author
        ) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "Error",
                                    message: error.localizedDescription)
                } else {
                    self?.dismiss(animated: true) {
                        self?.onPosted?()
                    }
                }
            }
        }
    }


    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

