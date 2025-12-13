//
//  LanguageManager.swift
//  HouseApp
//
//  Created by reqwwiem on 13.12.2025.
//

import Foundation

final class LanguageManager {
    static let shared = LanguageManager()
    private init() {}

    private let key = "app_language"

    var current: String {
        get { UserDefaults.standard.string(forKey: key) ?? Locale.current.language.languageCode?.identifier ?? "en" }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }

    func localized(_ key: String) -> String {
        let lang = current
        guard
            let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else { return NSLocalizedString(key, comment: "") }

        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
