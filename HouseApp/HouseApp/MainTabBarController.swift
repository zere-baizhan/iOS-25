//
//  MainTabBarController.swift
//  HouseApp
//
//  Created by reqwwiem on 22.12.2025.
//


import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Если это resident — убираем вкладку техника
        if UserSession.shared.role != "technician" && UserSession.shared.role != "admin" {
            // предположим, что Technician tab — последняя вкладка
            var vcs = viewControllers ?? []
            if vcs.count > 0 { vcs.removeLast() }
            viewControllers = vcs
        }
    }
}