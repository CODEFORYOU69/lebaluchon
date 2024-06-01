//
//  WeatherServiceTests.swift
//  Le_BaluchonTests
//
//  Created by younes ouasmi on 17/05/2024.
//
import XCTest
@testable import Le_Baluchon

class WeatherServiceTests: XCTestCase {

    func testFetchWeather() {
        let jsonData = loadMockData(fileName: "MockWeatherResponse")
        let decoder = JSONDecoder()
        let response = try! decoder.decode(WeatherResponse.self, from: jsonData)
        
        XCTAssertEqual(response.main.temp, 15.0, accuracy: 0.1)
        XCTAssertEqual(response.weather.first?.description, "clear sky")
    }

    // Helper function to load mock JSON data
    func loadMockData(fileName: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: url)
    }

    func testFetchWeather_Success() {
        // Mock JSON response
        let jsonString = """
        {
            "main": {
                "temp": 22.5
            },
            "weather": [
                {
                    "description": "clear sky"
                }
            ]
        }
        """
        let data = jsonString.data(using: .utf8)
        let response = HTTPURLResponse(url: URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Paris&units=metric&appid=\(WeatherService.apiKey)")!,
                                       statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let urlSession = MockURLSession.createMockSession(data: data, response: response, error: nil)
        
        let expectation = self.expectation(description: "Fetch weather success")

        WeatherService.fetchWeather(for: "Paris", urlSession: urlSession) { result in
            switch result {
            case .success(let weatherResponse):
                XCTAssertNotNil(weatherResponse)
                XCTAssertEqual(weatherResponse.main.temp, 22.5)
                XCTAssertEqual(weatherResponse.weather.first?.description, "clear sky")
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchWeather_Failure() {
        let error = NSError(domain: "WeatherServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch"])
        let urlSession = MockURLSession.createMockSession(data: nil, response: nil, error: error)
        
        let expectation = self.expectation(description: "Fetch weather failure")

        WeatherService.fetchWeather(for: "InvalidCity", urlSession: urlSession) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error, WeatherServiceError.customError("Failed to fetch"))
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testInvalidURL() {
        let expectation = self.expectation(description: "Failed to decode data")
        
        
        
        WeatherService.fetchWeather(for: "url", urlSession: URLSession.shared) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error, WeatherServiceError.decodingError)
                
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testNoDataReceived() {
        let urlSession = MockURLSession.createMockSession(data: nil, response: nil, error: nil)
        
        let expectation = self.expectation(description: "No data received")
        
        WeatherService.fetchWeather(for: "Paris", urlSession: urlSession) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error, WeatherServiceError.noData)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testErrorReceived() {
        let error = NSError(domain: "WeatherServiceError", code: 0, userInfo: nil)
        let urlSession = MockURLSession.createMockSession(data: nil, response: nil, error: error)
        
        let expectation = self.expectation(description: "Error received")
        
        WeatherService.fetchWeather(for: "Paris", urlSession: urlSession) { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertEqual(error , WeatherServiceError.customError(error.localizedDescription))
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
