//
//  HomeViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 11.12.2025.
//
import UIKit

final class HomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var flatLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    var resident: Resident?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: .languageChanged,
            object: nil
        )
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        applyStaticTexts()

        guard UserSession.shared.isLoggedIn else {
            resident = nil
            refreshUI()
            return
        }

        let uid = UserSession.shared.uid
        FirestoreService.shared.fetchResident(id: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let r):
                    self?.resident = r
                    self?.refreshUI()
                case .failure:
                    // fallback если нет дока 
                    self?.resident = Resident(
                        id: uid,
                        name: UserSession.shared.name,
                        email: UserSession.shared.email,
                        flat: ""
                    )
                    self?.refreshUI()
                }
            }
        }
    }

    @objc private func languageChanged() {
        applyStaticTexts()
        refreshUI() // перерисовать с новым языком
    }

    private func applyStaticTexts() {
        selectionLabel.text = "selection".L
        descriptionLabel.text = "description".L
    }

    private func refreshUI() {
        let dash = "dash".L

        let name = (resident?.name.isEmpty == false) ? resident!.name : (UserSession.shared.name.isEmpty ? dash : UserSession.shared.name)
        let flat = (resident?.flat.isEmpty == false) ? resident!.flat : dash
        let email = (resident?.email.isEmpty == false) ? resident!.email : (UserSession.shared.email.isEmpty ? dash : UserSession.shared.email)

        welcomeLabel.text = "welcome_user".Lf(name)
        flatLabel.text = "your_flat_fmt".Lf(flat)
        emailLabel.text = "email_fmt".Lf(email)
    }

    @IBAction func ruTapped(_ sender: UIButton) {
        LanguageManager.shared.current = "ru"
    }

    @IBAction func enTapped(_ sender: UIButton) {
        LanguageManager.shared.current = "en"
    }
}

extension String {


    func Lf(_ args: CVarArg...) -> String {
        String(format: self.L, arguments: args)
    }
}
