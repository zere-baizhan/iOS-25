//
//  CreateReportViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//

import UIKit

final class CreateReportViewController: UIViewController {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var detialsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var createLabel: UILabel!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var detailsTextView: UITextField!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    var onCreated: ((String, String, String) -> Void)?

    @IBAction func postTapped(_ sender: UIButton) {
        let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let category = (categoryField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let details = (detailsTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty, !category.isEmpty, !details.isEmpty else { return }

        onCreated?(title, category, details)
        dismiss(animated: true)
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @objc private func applyTexts() {
        createLabel.text = "maintenance_reports".L
        titleLabel.text = "problem_title".L
        detialsLabel.text = "problem_description".L
        categoryLabel.text="problem_category".L
        postButton.setTitle("post_announcement".L, for: .normal)
        cancelButton.setTitle("cancel".L, for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           applyTexts()       }
}
