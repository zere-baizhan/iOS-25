//
//  ViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 22.11.2025.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var emergencyButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInCardButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var helperLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var signLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    var currentResident: Resident?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTexts()
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(applyTexts),
                name: .languageChanged,
                object: nil)
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Error", message: "Enter email and password.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
                return
            }

            guard let uid = result?.user.uid else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "No user id.")
                }
                return
            }

            // обновим сессию
            UserSession.shared.uid = uid
            UserSession.shared.email = result?.user.email ?? email

            // загрузим профиль из Firestore users{uid}
            FirestoreService.shared.fetchResident(id: uid) { res in
                DispatchQueue.main.async {
                    switch res {
                    case .success(let resident):
                        self.currentResident = resident
                        self.performSegue(withIdentifier: "showMainTabs", sender: self)
                    case .failure(let err):
                        self.showAlert(title: "Error", message: "Profile not found: \(err.localizedDescription)")
                    }
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainTabs",
           let tabBar = segue.destination as? UITabBarController {

            let first = tabBar.viewControllers?.first

            if let nav = first as? UINavigationController,
               let homeVC = nav.viewControllers.first as? HomeViewController {
                homeVC.resident = currentResident
            } else if let homeVC = first as? HomeViewController {
                homeVC.resident = currentResident
            }
        }
    }
    
    @objc private func applyTexts() {
        helperLabel.text = "dont_have_account".L
        emailLabel.text = "email".L
        welcomeLabel.text="welcome_title".L
        signLabel.text="sign_in_to_access".L
        passwordLabel.text="password".L
        signInButton.setTitle("sign_in".L, for: .normal)
        emergencyButton.setTitle("emergency".L, for: .normal)
        signInCardButton.setTitle("sign_in".L, for: .normal)
        signUpButton.setTitle("sign_up".L, for: .normal)


    }
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        print("Sign Up tapped")   // для проверки
        performSegue(withIdentifier: "showSignUp", sender: self)
    }
    @IBAction func ruTapped(_ sender: UIButton) {
        LanguageManager.shared.current = "ru"
        print("Ru button tapped")
    }

    @IBAction func enTapped(_ sender: UIButton) {
        LanguageManager.shared.current = "en"
        print("En button tapped")

    }


}

