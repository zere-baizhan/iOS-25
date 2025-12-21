//
//  TechnicianReportsViewController.swift
//  HouseApp
//
//  Created by reqwwiem on 22.12.2025.
//

import UIKit
import FirebaseFirestore

final class TechnicianReportsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusSegment: UISegmentedControl!

    private var allItems: [MaintenanceReport] = []
    private var filteredItems: [MaintenanceReport] = []
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        statusSegment.selectedSegmentIndex = 0 // All

        // слушаем все репорты
        listener = FirestoreService.shared.listenReports { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self?.allItems = list
                    self?.applyFilterBySegment()
                    self?.tableView.reloadData()
                case .failure(let err):
                    print("🔥 listenReports error:", err)
                }
            }
        }
    }

    deinit { listener?.remove() }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        applyFilterBySegment()
        tableView.reloadData()
    }

    private func applyFilterBySegment() {
        let index = statusSegment.selectedSegmentIndex

        switch index {
        case 1: // Pending
            filteredItems = allItems.filter { $0.status.lowercased() == "pending" }

        case 2: // In Progress
            filteredItems = allItems.filter {
                let s = $0.status.lowercased()
                return s == "in_progress" || s == "in progress"
            }

        case 3: // Resolved
            filteredItems = allItems.filter { $0.status.lowercased() == "resolved" }

        default: // All
            filteredItems = allItems
        }
    }

    private func showEditReportDialog(report: MaintenanceReport) {
        let alert = UIAlertController(title: "Update report", message: nil, preferredStyle: .alert)

        alert.addTextField { tf in
            tf.placeholder = "Resolution text"
            tf.text = report.resolutionText
        }

        let statuses = ["pending", "in_progress", "resolved"]

        for st in statuses {
            alert.addAction(UIAlertAction(title: st, style: .default) { _ in
                let resText = alert.textFields?.first?.text ?? ""
                FirestoreService.shared.updateReport(reportId: report.id,
                                                   data: ["status": st, "resolutionText": resText]) { err in
                    if let err = err { print("🔥 updateReport:", err) }
                }
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func updateStatus(report: MaintenanceReport, status: String) {
        FirestoreService.shared.updateReport(reportId: report.id, data: ["status": status]) { err in
            if let err = err { print("🔥 updateStatus error:", err) }
        }
    }

    private func askResolutionAndResolve(report: MaintenanceReport) {
        let alert = UIAlertController(title: "Resolution", message: "Write what was done", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "e.g., Faucet washer replaced"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let data: [String: Any] = [
                "status": "resolved",
                "resolutionText": text
            ]
            FirestoreService.shared.updateReport(reportId: report.id, data: data) { err in
                if let err = err { print("🔥 resolve error:", err) }
            }
        }))

        present(alert, animated: true)
    }
}

extension TechnicianReportsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let r = filteredItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath)
        cell.textLabel?.text = "\(r.title) — \(r.status)"
        cell.detailTextLabel?.text = r.category
        return cell
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let report = filteredItems[indexPath.row]

        let inProgress = UIContextualAction(style: .normal, title: "In Progress") { [weak self] _, _, done in
            self?.updateStatus(report: report, status: "in_progress")
            done(true)
        }

        let resolved = UIContextualAction(style: .destructive, title: "Resolve") { [weak self] _, _, done in
            self?.askResolutionAndResolve(report: report)
            done(true)
        }

        return UISwipeActionsConfiguration(actions: [resolved, inProgress])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let r = filteredItems[indexPath.row]
        showEditReportDialog(report: r)
    }
}
