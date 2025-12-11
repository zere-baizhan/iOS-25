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
    override func viewDidLoad() {
        super.viewDidLoad()
        styleTopBarButtons()
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
        styleSignInButton()
    }
    private func styleTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.backgroundColor = .systemGray6
        
        // внутренний отступ слева
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        textField.leftView = padding
        textField.leftViewMode = .always
    }

    private func styleSignInButton() {
        signInCardButton.layer.cornerRadius = 14
        signInCardButton.backgroundColor = UIColor.systemIndigo // или твой цвет
        signInCardButton.setTitleColor(.white, for: .normal)
        signInCardButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    private func styleTopBarButtons() {
        let buttons = [signInButton, emergencyButton]

        for button in buttons {
            button?.layer.cornerRadius = 20
            button?.layer.masksToBounds = false
            button?.layer.shadowColor = UIColor.black.cgColor
            button?.layer.shadowOpacity = 0.08
            button?.layer.shadowOffset = CGSize(width: 0, height: 2)
            button?.layer.shadowRadius = 6
            button?.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        }

        // Активная – Sign In
        signInButton.backgroundColor = UIColor(named: "PrimaryBlue")
        signInButton.setTitleColor(.white, for: .normal)

        // Неактивная – Emergency
        emergencyButton.backgroundColor = .clear
        emergencyButton.setTitleColor(UIColor.systemGray, for: .normal)
    }
    @IBAction func signInTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email.isEmpty || password.isEmpty {
            showAlert(title: "Oops", message: "Please enter email and password.")
            return
        }
        
        // Здесь потом будет запрос к серверу
        print("Sign in with email: \(email), password: \(password)")
    }
        
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }



}

