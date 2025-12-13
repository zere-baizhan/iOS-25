//
//  ViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 22.11.2025.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var emergencyButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInCardButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    var currentResident: Resident?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        let inputEmail = emailTextField.text ?? ""
        let inputPassword = passwordTextField.text ?? ""

        guard !inputEmail.isEmpty, !inputPassword.isEmpty else {
            showAlert(title: "Error", message: "Enter email and password.")
            return
        }

        let savedEmail = UserDefaults.standard.string(forKey: "userEmail")
        let savedPassword = UserDefaults.standard.string(forKey: "userPassword")
        let savedName = UserDefaults.standard.string(forKey: "userName")
        let savedFlat = UserDefaults.standard.string(forKey: "userFlat")

        guard inputEmail == savedEmail,
              inputPassword == savedPassword,
              let name = savedName,
              let flat = savedFlat else {
            showAlert(title: "Error", message: "Wrong email or password.")
            return
        }

        currentResident = Resident(id: inputEmail, name: name, email: inputEmail, flat: flat)
        performSegue(withIdentifier: "showMainTabs", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainTabs",
           let tabBar = segue.destination as? UITabBarController,
           let homeVC = tabBar.viewControllers?.first as? HomeViewController {
            homeVC.resident = currentResident
        }
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

