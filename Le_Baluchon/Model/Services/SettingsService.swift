//
//  SettingsService.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 25/05/2024.
//

import Foundation


class SettingsService {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getUserLanguage() -> String {
        return userDefaults.string(forKey: "userLanguage") ?? "en"
    }

    func setUserLanguage(_ language: String) {
        userDefaults.set(language, forKey: "userLanguage")
        NotificationCenter.default.post(name: .userLanguageChanged, object: nil)
    }

    func getHomeLocation() -> String {
        return userDefaults.string(forKey: "homeLocation") ?? "Lyon"
    }

    func setHomeLocation(_ location: String) {
        userDefaults.set(location, forKey: "homeLocation")
        NotificationCenter.default.post(name: .homeLocationChanged, object: nil)
    }

    func getTravelLocation() -> String {
        return userDefaults.string(forKey: "travelLocation") ?? "New York"
    }

    func setTravelLocation(_ location: String) {
        userDefaults.set(location, forKey: "travelLocation")
        NotificationCenter.default.post(name: .travelLocationChanged, object: nil)
    }
}

extension Notification.Name {
    static let userLanguageChanged = Notification.Name("userLanguageChanged")
    static let homeLocationChanged = Notification.Name("homeLocationChanged")
    static let travelLocationChanged = Notification.Name("travelLocationChanged")
}
