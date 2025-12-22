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

    @IBOutlet weak var adminLabel: UILabel!
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
        applyTexts()
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(applyTexts),
                name: .languageChanged,
                object: nil)
    }

    deinit { listener?.remove() }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        applyFilterBySegment()
        tableView.reloadData()
    }
    @objc private func applyTexts() {
        adminLabel.text = "admin_label".L
        statusSegment.setTitle("allbutton".L, forSegmentAt: 0)
        statusSegment.setTitle("report_status_pending".L, forSegmentAt: 1)
        statusSegment.setTitle("report_status_in_progress".L, forSegmentAt: 2)
        statusSegment.setTitle("report_status_resolved".L, forSegmentAt: 3)
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
        let alert = UIAlertController(
            title: "update_report_title".L,
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "resolution_placeholder".L
        }

        alert.addAction(UIAlertAction(
            title: "report_status_pending".L,
            style: .default
        ) { [weak self] _ in
            self?.updateStatus(report: report, status: "pending")
        })

        alert.addAction(UIAlertAction(
            title: "report_status_in_progress".L,
            style: .default
        ) { [weak self] _ in
            self?.updateStatus(report: report, status: "in_progress")
        })

        alert.addAction(UIAlertAction(
            title: "report_status_resolved".L,
            style: .default
        ) { [weak self] _ in
            let resText = alert.textFields?.first?.text ?? ""
            FirestoreService.shared.updateReport(
                reportId: report.id,
                data: [
                    "status": "resolved",
                    "resolutionText": resText
                ],
                completion: { err in
                    if let err = err {
                        print("🔥 updateReport error:", err)
                    }
                }
            )
        })

        alert.addAction(UIAlertAction(
            title: "cancel".L,
            style: .cancel
        ))

        present(alert, animated: true)
    }

    private func updateStatus(report: MaintenanceReport, status: String) {
        FirestoreService.shared.updateReport(
            reportId: report.id,
            data: ["status": status],
            completion: { err in
                if let err = err { print("🔥 updateStatus error:", err) }
            }
        )
    }

    private func askResolutionAndResolve(report: MaintenanceReport) {
        let alert = UIAlertController(
            title: "resolution_title".L,
            message: "resolution_message".L,
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "resolution_placeholder".L
        }

        alert.addAction(UIAlertAction(
            title: "cancel".L,
            style: .cancel
        ))

        alert.addAction(UIAlertAction(
            title: "save".L,
            style: .default
        ) { _ in
            let text = alert.textFields?
                .first?
                .text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            let data: [String: Any] = [
                "status": "resolved",
                "resolutionText": text
            ]

            FirestoreService.shared.updateReport(
                reportId: report.id,
                data: data
            ) { err in
                if let err = err {
                    print("🔥 resolve error:", err)
                }
            }
        })

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
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let report = filteredItems[indexPath.row]

        let delete = UIContextualAction(style: .destructive, title: "delete".L) { [weak self] _, _, done in
            FirestoreService.shared.deleteReport(reportId: report.id) { err in
                DispatchQueue.main.async {
                    if let err = err {
                        print("🔥 deleteReport error:", err)
                        done(false)
                        return
                    }

                    // Optimistic UI update (listener will also refresh)
                    self?.filteredItems.remove(at: indexPath.row)
                    if let idx = self?.allItems.firstIndex(where: { $0.id == report.id }) {
                        self?.allItems.remove(at: idx)
                    }
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    done(true)
                }
            }
        }

        // Optional: require confirmation feel
        delete.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let report = filteredItems[indexPath.row]

        let inProgress = UIContextualAction(
            style: .normal,
            title: "report_status_in_progress".L
        ) { [weak self] _, _, done in
            self?.updateStatus(report: report, status: "in_progress")
            done(true)
        }

        let resolved = UIContextualAction(
            style: .destructive,
            title: "report_status_resolved".L
        ) { [weak self] _, _, done in
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
