//
//  HomeViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 11.12.2025.
//
import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var flatLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    var resident: Resident?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeViewController viewDidLoad")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // get from us def
        let defaults = UserDefaults.standard
        let name  = defaults.string(forKey: "userName")
        let email = defaults.string(forKey: "userEmail")
        let flat  = defaults.string(forKey: "userFlat")

        if let name = name,
           let email = email,
           let flat = flat {

            // create resident and save
            resident = Resident(id: email, name: name, email: email, flat: flat)
            print("HomeViewController loaded resident from UserDefaults:", resident!)

            // 3. Обновляем UI
            updateUI(with: resident!)
        } else {
            // default data ne dai bog
            print("HomeViewController: no user in UserDefaults")
            welcomeLabel.text = "Welcome, user!"
            flatLabel.text = "Your Flat: —"
            emailLabel.text = "Email: —"
        }
    }

    private func updateUI(with r: Resident) {
        welcomeLabel.text = "Welcome, \(r.name)!"
        flatLabel.text = "Your Flat: \(r.flat)"
        emailLabel.text = "Email: \(r.email)"
    }
}
