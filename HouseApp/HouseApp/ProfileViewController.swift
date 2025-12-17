//
//  ProfileViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//

import UIKit

final class ProfileViewController: UIViewController {

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var nameTopLabel: UILabel!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emergencyTextField: UITextField!
    @IBOutlet weak var flatTextField: UITextField!
    @IBOutlet weak var floorTextField: UITextField!

    private var isEditingProfile = false
    private var original: ResidentProfile?   //original one then change

    override func viewDidLoad() {
        super.viewDidLoad()
        setEditingUI(false, animated: false)
        loadProfile() // загрузка из Firestore
        fullNameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
    }

    private func setEditingUI(_ editing: Bool, animated: Bool = true) {
        isEditingProfile = editing

        // сразу включаем/выключаем интеракцию
        let fields = [fullNameTextField, phoneTextField, emergencyTextField, flatTextField, floorTextField]
        fields.forEach { tf in
            tf?.isEnabled = editing
        }

        let animations = {
            // кнопки
            self.editButton.alpha = editing ? 0 : 1
            self.saveButton.alpha = editing ? 1 : 0
            self.cancelButton.alpha = editing ? 1 : 0

            // стили полей
            fields.forEach { tf in
                tf?.borderStyle = editing ? .roundedRect : .none
                tf?.backgroundColor = editing ? .secondarySystemBackground : .clear
            }

            self.view.layoutIfNeeded()
        }

        let completion: (Bool) -> Void = { _ in
            self.editButton.isHidden = editing
            self.saveButton.isHidden = !editing
            self.cancelButton.isHidden = !editing
        }

        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: animations,
                           completion: completion)
        } else {
            animations()
            completion(true)
        }

        // email не редактируется
        emailTextField.isEnabled = false
        emailTextField.borderStyle = .none
        emailTextField.backgroundColor = .clear
    }

    @IBAction func editTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        // сохраняем текущие значения, чтобы Cancel мог откатить
        original = currentProfileFromUI()
        setEditingUI(true)
        fullNameTextField.becomeFirstResponder()
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        if let original { applyProfileToUI(original) }
        setEditingUI(false)
        view.endEditing(true)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        view.endEditing(true)

        let updated = currentProfileFromUI()

        // TODO: сохранить в Firestore
        FirestoreService.shared.saveProfile(updated) { [weak self] err in
            DispatchQueue.main.async {
                if let err = err {
                    print("🔥 save error:", err)
                    // показать alert для дебага
                    return
                }
                self?.original = updated
                // обновляем UI
                self?.applyProfileToUI(updated)
                self?.setEditingUI(false)
            }
        }
    }

    // MARK: - Helpers

    @objc private func nameChanged() {
        // менять имя и фулл имя в лейблах
        let text = (fullNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        nameTopLabel.text = text.isEmpty ? "—" : text
    }

    private func currentProfileFromUI() -> ResidentProfile {
        ResidentProfile(
            name: fullNameTextField.text ?? "",
            email: emailTextField.text ?? "",
            phone: phoneTextField.text ?? "",
            emergencyPhone: emergencyTextField.text ?? "",
            flat: flatTextField.text ?? "",
            floor: floorTextField.text ?? ""
        )
    }

    private func applyProfileToUI(_ p: ResidentProfile) {
        nameTopLabel.text = p.name.isEmpty ? "—" : p.name
        fullNameTextField.text = p.name
        emailTextField.text = p.email
        phoneTextField.text = p.phone
        emergencyTextField.text = p.emergencyPhone
        flatTextField.text = p.flat
        floorTextField.text = p.floor
    }

    private func loadProfile() {
        FirestoreService.shared.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.original = profile
                    self?.applyProfileToUI(profile)
                case .failure(let err):
                    print("🔥 fetch profile error:", err)
                }
            }
        }
    }
}
