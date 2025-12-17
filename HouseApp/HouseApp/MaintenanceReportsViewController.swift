//
//  MaintenanceReportsViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 14.12.2025.
//


import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MaintenanceReportsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newReportButton: UIButton!

    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var pendingButton: UIButton!
    @IBOutlet weak var inProgressButton: UIButton!
    @IBOutlet weak var resolvedButton: UIButton!

    private var listener: ListenerRegistration?
    private var allItems: [MaintenanceReport] = []
    private var filter: ReportFilter = .all

    private var currentUserId: String { Auth.auth().currentUser?.uid ?? "unknown" }
    private var currentUserName: String { Auth.auth().currentUser?.email ?? "User" }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        
        applyTexts()
        styleFilterButtons()
        setSelectedFilter(.all)

        listener = FirestoreService.shared.listenReports { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.allItems = list
                    self?.tableView.reloadData()
                case .failure(let err):
                    print("🔥 listenReports error:", err)
                }
            }
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applyTexts),
                                               name: .languageChanged,
                                               object: nil)
    }

    deinit { listener?.remove() }

    private func styleFilterButtons() {
        [allButton, pendingButton, inProgressButton, resolvedButton].forEach {
            $0?.layer.cornerRadius = 12
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
    @objc private func applyTexts() {
        allButton.setTitle("allbutton".L, for: .normal)
        pendingButton.setTitle("report_status_pending".L, for: .normal)
        inProgressButton.setTitle("report_status_in_progress".L, for: .normal)
        resolvedButton.setTitle("report_status_resolved".L, for: .normal)
        newReportButton.setTitle("new_badge".L, for: .normal)

    }

    private func setSelectedFilter(_ f: ReportFilter) {
        filter = f

        // сброс стиля
        [allButton, pendingButton, inProgressButton, resolvedButton].forEach {
            $0?.backgroundColor = .clear
            $0?.setTitleColor(.label, for: .normal)
        }

        let selected: UIButton = {
            switch f {
            case .all: return allButton
            case .pending: return pendingButton
            case .inProgress: return inProgressButton
            case .resolved: return resolvedButton
            }
        }()

        selected.backgroundColor = UIColor.systemIndigo
        selected.setTitleColor(.white, for: .normal)
        tableView.reloadData()
    }

    private func filteredItems() -> [MaintenanceReport] {
        switch filter {
        case .all:
            return allItems
        case .pending:
            return allItems.filter { $0.status == "pending" }
        case .inProgress:
            return allItems.filter { $0.status == "in_progress" }
        case .resolved:
            return allItems.filter { $0.status == "resolved" }
        }
    }

    // MARK: - Actions

    @IBAction func allTapped(_ sender: UIButton) { setSelectedFilter(.all) }
    @IBAction func pendingTapped(_ sender: UIButton) { setSelectedFilter(.pending) }
    @IBAction func inProgressTapped(_ sender: UIButton) { setSelectedFilter(.inProgress) }
    @IBAction func resolvedTapped(_ sender: UIButton) { setSelectedFilter(.resolved) }

    @IBAction func newReportTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CreateReportViewController") as! CreateReportViewController
        vc.modalPresentationStyle = .overFullScreen

        vc.onCreated = { [weak self] title, category, details in
            guard let self else { return }
            FirestoreService.shared.createReport(
                title: title,
                category: category,
                details: details,
                createdById: self.currentUserId,
                createdByName: self.currentUserName
            ) { err in
                if let err { print("🔥 createReport error:", err) }
            }
        }

        present(vc, animated: true)
    }
}

extension MaintenanceReportsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = filteredItems()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportCell
        cell.configure(item)
        return cell
    }
}
