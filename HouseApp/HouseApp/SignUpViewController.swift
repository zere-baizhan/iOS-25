//
//  SignUpViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 11.12.2025.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var flatTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBAction func signUpTapped(_ sender: UIButton) {
        print("👉 signUpTapped called")

        // get text from fields
        let name  = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let flat  = flatTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirm  = confirmPasswordTextField.text ?? ""

        // validation
        guard !name.isEmpty,
              !flat.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !confirm.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        guard password == confirm else {
            showAlert(title: "Error", message: "Passwords do not match.")
            return
        }

        // again us defs
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(password, forKey: "userPassword")
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(flat, forKey: "userFlat")

        print("✅ Saved to UserDefaults: \(name), \(flat), \(email)")

        // get model and push to dashboard database
        let resident = Resident(id: email, name: name, email: email, flat: flat)

        FirestoreService.shared.saveResident(resident) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("🔥 Firestore error:", error)
                    self?.showAlert(
                        title: "Warning",
                        message: "Saved locally, but Firestore error: \(error.localizedDescription)"
                    )
                } else {
                    print("✅ Firestore saved for", email)
                    self?.showAlert(
                        title: "Success",
                        message: "Account created. Now you can Sign In."
                    ) {
                        // return to signin
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    private func showAlert(title: String,
                           message: String,
                           completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
