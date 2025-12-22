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
    
    private var allItems: [Announcement] = []
    private var filteredItems: [Announcement] = []
    private var searchController: UISearchController!

    private lazy var dateFormatters: [DateFormatter] = {
        func make(_ format: String) -> DateFormatter {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = format
            return df
        }
        return [
            make("dd MMM yyyy"),   // 22 Dec 2025
            make("d MMM yyyy"),    // 2 Dec 2025
            make("dd.MM.yyyy"),    // 22.12.2025
            make("d.M.yyyy"),      // 2.12.2025
            make("yyyy-MM-dd"),    // 2025-12-22
            make("dd/MM/yyyy"),    // 22/12/2025
            make("d/M/yyyy")       // 2/12/2025
        ]
    }()

    private func applyFilter(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            filteredItems = allItems
            return
        }

        filteredItems = allItems.filter { a in
            let titleMatch = a.title.lowercased().contains(trimmed)
            let contentMatch = a.content.lowercased().contains(trimmed)

            // Search by date in multiple formats
            let dateStrings = dateFormatters.map { $0.string(from: a.date).lowercased() }
            let dateMatch = dateStrings.contains(where: { $0.contains(trimmed) })

            return titleMatch || contentMatch || dateMatch
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        setupSearch()
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
        searchController?.searchBar.placeholder = "search_announcements".L
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           applyTexts()
           tableView.reloadData()
       }
    
    private func setupSearch() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "search_announcements".L
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func loadAnnouncements() {
        FirestoreService.shared.fetchAnnouncements { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.allItems = list
                    let searchText = self?.searchController.searchBar.text ?? ""
                    if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        self?.filteredItems = list
                    } else {
                        self?.applyFilter(searchText)
                    }
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
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let a = filteredItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnnouncementCell", for: indexPath) as! AnnouncementCell
        cell.configure(with: a)
        return cell
    }
}
extension AnnouncementsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        applyFilter(text)
        tableView.reloadData()
    }
}
extension String {
    var L: String {
        LanguageManager.shared.localized(self)
    }
}
