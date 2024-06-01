//
//  SettingsServiceTests.swift
//  Le_BaluchonTests
//
//  Created by younes ouasmi on 25/05/2024.
//

import XCTest
@testable import Le_Baluchon

class SettingsServiceTests: XCTestCase {

    var settingsService: SettingsService!
    var mockUserDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        mockUserDefaults = UserDefaults(suiteName: "TestDefaults")
        settingsService = SettingsService(userDefaults: mockUserDefaults)
        mockUserDefaults.removePersistentDomain(forName: "TestDefaults")
    }

    override func tearDown() {
        settingsService = nil
        mockUserDefaults = nil
        super.tearDown()
    }

    func testGetUserLanguageDefault() {
        let language = settingsService.getUserLanguage()
        XCTAssertEqual(language, "en", "Default user language should be 'en'")
    }

    func testSetUserLanguage() {
        _ = self.expectation(forNotification: .userLanguageChanged, object: nil, handler: nil)
        settingsService.setUserLanguage("fr")
        waitForExpectations(timeout: 1, handler: nil)
        
        let language = mockUserDefaults.string(forKey: "userLanguage")
        XCTAssertEqual(language, "fr", "User language should be 'fr'")
    }

    func testGetHomeLocationDefault() {
        let location = settingsService.getHomeLocation()
        XCTAssertEqual(location, "Lyon", "Default home location should be 'Lyon'")
    }

    func testSetHomeLocation() {
        _ = self.expectation(forNotification: .homeLocationChanged, object: nil, handler: nil)
        settingsService.setHomeLocation("Paris")
        waitForExpectations(timeout: 1, handler: nil)
        
        let location = mockUserDefaults.string(forKey: "homeLocation")
        XCTAssertEqual(location, "Paris", "Home location should be 'Paris'")
    }

    func testGetTravelLocationDefault() {
        let location = settingsService.getTravelLocation()
        XCTAssertEqual(location, "New York", "Default travel location should be 'New York'")
    }

    func testSetTravelLocation() {
        _ = self.expectation(forNotification: .travelLocationChanged, object: nil, handler: nil)
        settingsService.setTravelLocation("Tokyo")
        waitForExpectations(timeout: 1, handler: nil)
        
        let location = mockUserDefaults.string(forKey: "travelLocation")
        XCTAssertEqual(location, "Tokyo", "Travel location should be 'Tokyo'")
    }
}
