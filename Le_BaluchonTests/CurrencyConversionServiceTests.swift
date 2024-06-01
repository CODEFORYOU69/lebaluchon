//
//  CurrencyConversionServiceTests.swift
//  Le_BaluchonTests
//
//  Created by younes ouasmi on 17/05/2024.
//
import XCTest
@testable import Le_Baluchon

class CurrencyConversionServiceTests: XCTestCase {

    var conversionService: CurrencyConversionService!
    let mockUserDefaults = UserDefaults(suiteName: "TestDefaults")!

    override func setUp() {
        super.setUp()
        conversionService = CurrencyConversionService(userDefaults: mockUserDefaults)
        mockUserDefaults.removePersistentDomain(forName: "TestDefaults")
    }

    override func tearDown() {
        conversionService = nil
        super.tearDown()
    }

    func testCurrenciesList() {
        let currencies = conversionService.currencies
        XCTAssertGreaterThan(currencies.count, 0, "Currencies list should not be empty")
    }

    func testFetchExchangeRatesWithCachedData() {
        let rates = ["USD": 1.0, "EUR": 0.85]
        let lastUpdate = Date()
        mockUserDefaults.set(try? JSONEncoder().encode(rates), forKey: "exchangeRates")
        mockUserDefaults.set(lastUpdate, forKey: "lastUpdate")

        let expectation = self.expectation(description: "FetchExchangeRatesWithCachedData")
        let requiredCurrencies = ["USD", "EUR"]
        
        conversionService.fetchExchangeRates(for: requiredCurrencies) { result in
            switch result {
            case .success(let fetchedRates):
                XCTAssertEqual(fetchedRates, rates, "Fetched rates should match cached rates")
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchExchangeRatesWithError() {
        let expectation = self.expectation(description: "FetchExchangeRatesWithError")
        let requiredCurrencies = ["USD", "EUR"]
        
        // Simulate an error by setting an invalid API key or base URL
        let urlSession = MockURLSession.createMockSession(data: nil, response: nil, error: NSError(domain: "TestError", code: 0, userInfo: nil))
        conversionService = CurrencyConversionService(apiKey: "invalid_key", baseUrl: "http://invalid_url", userDefaults: mockUserDefaults, urlSession: urlSession)
        
        conversionService.fetchExchangeRates(for: requiredCurrencies) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchExchangeRatesWithInvalidData() {
        let expectation = self.expectation(description: "FetchExchangeRatesWithInvalidData")
        let requiredCurrencies = ["USD", "EUR"]
        
        // Simulate invalid JSON response
        let invalidJSONData = "Invalid JSON".data(using: .utf8)
        let urlSession = MockURLSession.createMockSession(data: invalidJSONData, response: nil, error: nil)
        conversionService = CurrencyConversionService(apiKey: "test_key", baseUrl: "http://test_url", userDefaults: mockUserDefaults, urlSession: urlSession)
        
        conversionService.fetchExchangeRates(for: requiredCurrencies) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchExchangeRatesWithMissingData() {
        mockUserDefaults.removeObject(forKey: "exchangeRates")
        mockUserDefaults.removeObject(forKey: "lastUpdate")
        
        let expectation = self.expectation(description: "FetchExchangeRatesWithMissingData")
        let requiredCurrencies = ["USD", "EUR"]
        
        // Simulate an empty network response
        let urlSession = MockURLSession.createMockSession(data: nil, response: nil, error: nil)
        conversionService = CurrencyConversionService(apiKey: "invalid_key", baseUrl: "http://invalid_url", userDefaults: mockUserDefaults, urlSession: urlSession)
        
        conversionService.fetchExchangeRates(for: requiredCurrencies) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchExchangeRatesNoDataReceived() {
        let expectation = self.expectation(description: "FetchExchangeRatesNoDataReceived")
        let requiredCurrencies = ["USD", "EUR"]
        
        // Simulate no data received
        let urlSession = MockURLSession.createMockSession(data: nil, response: nil, error: nil)
        conversionService = CurrencyConversionService(apiKey: "test_key", baseUrl: "http://test_url", userDefaults: mockUserDefaults, urlSession: urlSession)
        
        conversionService.fetchExchangeRates(for: requiredCurrencies) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchExchangeRatesNewDataStored() {
        let expectation = self.expectation(description: "FetchExchangeRatesNewDataStored")
        let requiredCurrencies = ["USD", "EUR"]
        
        // Simulate a valid response
        let validJSONData = """
        {
            "success": true,
            "timestamp": 1622486400,
            "base": "EUR",
            "date": "2024-05-20",
            "rates": {
                "USD": 1.2,
                "EUR": 1.0
            }
        }
        """.data(using: .utf8)
        let urlSession = MockURLSession.createMockSession(data: validJSONData, response: nil, error: nil)
        conversionService = CurrencyConversionService(apiKey: "test_key", baseUrl: "http://test_url", userDefaults: mockUserDefaults, urlSession: urlSession)
        
        conversionService.fetchExchangeRates(for: requiredCurrencies) { result in
            switch result {
            case .success(let rates):
                XCTAssertEqual(rates["USD"], 1.2, "USD rate should be 1.2")
                XCTAssertEqual(rates["EUR"], 1.0, "EUR rate should be 1.0")
                
                // Verify that the rates are stored in UserDefaults
                if let storedData = self.mockUserDefaults.data(forKey: "exchangeRates") {
                    let storedRates = try? JSONDecoder().decode([String: Double].self, from: storedData)
                    XCTAssertEqual(storedRates?["USD"], 1.2, "Stored USD rate should be 1.2")
                    XCTAssertEqual(storedRates?["EUR"], 1.0, "Stored EUR rate should be 1.0")
                } else {
                    XCTFail("Rates should be stored in UserDefaults")
                }
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testConversion() {
        let rates = ["USD": 1.0, "EUR": 0.85]
        let amount: Double = 100
        let convertedAmount = conversionService.convert(amount: amount, from: "USD", to: "EUR", rates: rates)
        XCTAssertEqual(convertedAmount!, 85, accuracy: 0.01, "Conversion result should be 85 EUR")
    }

    func testConversionWithMissingRates() {
        let rates = ["USD": 1.0]
        let amount: Double = 100
        let convertedAmount = conversionService.convert(amount: amount, from: "USD", to: "EUR", rates: rates)
        XCTAssertNil(convertedAmount, "Conversion should fail due to missing rates")
    }
}
