//
//  CreateReportViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//

import UIKit

final class CreateReportViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var detailsTextView: UITextField!

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
}
