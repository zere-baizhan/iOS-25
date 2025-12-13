//
//  AnnouncementsViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 12.12.2025.
//

import UIKit

final class AnnouncementsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var newAnnouncementButton: UIButton!
    private var items: [Announcement] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        
        print("✅ AnnouncementsViewController loaded")

        applyTexts()

        NotificationCenter.default.addObserver(
                   self,
                   selector: #selector(applyTexts),
                   name: .languageChanged,
                   object: nil
               )
        loadAnnouncements()
    }
    @objc private func applyTexts() {
        titleLabel.text = "community_announcements".L
        newAnnouncementButton.setTitle("new_announcement".L, for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           applyTexts()
           tableView.reloadData()
       }

    private func loadAnnouncements() {
        FirestoreService.shared.fetchAnnouncements { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.items = list
                    self?.tableView.reloadData()
                case .failure(let err):
                    print("🔥 fetchAnnouncements error:", err)
                }
            }
        }
    }

    @IBAction func newAnnouncementTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CreateAnnouncementViewController") as! CreateAnnouncementViewController
        vc.modalPresentationStyle = .overFullScreen

        vc.onPosted = { [weak self] in
            self?.loadAnnouncements()
        }

        present(vc, animated: true)
    }

    
}
extension AnnouncementsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let a = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementCell", for: indexPath) as! AnnouncementCell
        cell.configure(with: a)
        return cell
    }
}
extension String {
    var L: String {
        LanguageManager.shared.localized(self)
    }
}

