//
//  CurrencyTests.swift
//  Le_BaluchonTests
//
//  Created by younes ouasmi on 17/05/2024.
//

import XCTest
@testable import Le_Baluchon

final class CurrencyTests: XCTestCase {

    func testCurrencyInitialization() {
            let currency = Currency(code: "USD", country: "United States", flag: "us")
            XCTAssertEqual(currency.code, "USD")
            XCTAssertEqual(currency.country, "United States")
            XCTAssertEqual(currency.flag, "us")
        }

}
