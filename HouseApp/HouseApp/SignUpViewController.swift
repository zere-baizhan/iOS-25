//
//  SignUpViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 11.12.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var flatTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emergencyTextField: UITextField!
    @IBOutlet weak var floorTextField: UITextField!
    
    @IBAction func signUpTapped(_ sender: UIButton) {

        let name  = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let flat  = flatTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let phone = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let emergency = emergencyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let floor = floorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirm  = confirmPasswordTextField.text ?? ""

        guard !name.isEmpty, !flat.isEmpty, !phone.isEmpty, !emergency.isEmpty, !floor.isEmpty,
              !email.isEmpty, !password.isEmpty, !confirm.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        guard password == confirm else {
            showAlert(title: "Error", message: "Passwords do not match.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                print("🔥 AUTH ERROR:", error)
                print("🔥 AUTH DESC:", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
                return
            }

            guard let uid = result?.user.uid else {
                print("🔥 AUTH: uid is nil")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Could not get user id.")
                }
                return
            }

            // ✅ пишем в users/{uid}
            let data: [String: Any] = [
                "name": name,
                "email": email,
                "flat": flat,
                "phone": phone,
                "emergencyPhone": emergency,
                "floor": floor,
                "createdAt": Timestamp(date: Date())
            ]

            Firestore.firestore().collection("users").document(uid).setData(data, merge: true) { err in
                if let err = err {
                    print("🔥 FIRESTORE ERROR:", err)
                    print("🔥 FIRESTORE DESC:", err.localizedDescription)
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: err.localizedDescription)
                    }
                    return
                }

                print("✅ Firestore saved users/\(uid)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Success", message: "Account created. Now you can Sign In.") {
                        self.navigationController?.popViewController(animated: true)
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

