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
    
    // Helper function to mock URLSession
       private func mockURLSession(data: Data?, response: HTTPURLResponse?, error: Error?) -> URLSession {
           let configuration = URLSessionConfiguration.ephemeral
           configuration.protocolClasses = [MockURLProtocol.self]
           MockURLProtocol.requestHandler = { request in
               if let response = response {
                   return (response, data)
               } else {
                   throw error ?? NSError(domain: "MockError", code: 0, userInfo: nil)
               }
           }
           return URLSession(configuration: configuration)
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
           let response = HTTPURLResponse(url: URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Paris&units=metric&appid=829a9879a4c00c7941c92290f12eaed6")!,
                                          statusCode: 200, httpVersion: nil, headerFields: nil)
           
           let urlSession = mockURLSession(data: data, response: response, error: nil)
           
           let expectation = self.expectation(description: "Fetch weather success")

           WeatherService.fetchWeather(for: "Paris", urlSession: urlSession) { weatherResponse, error in
               XCTAssertNotNil(weatherResponse)
               XCTAssertNil(error)
               XCTAssertEqual(weatherResponse?.main.temp, 22.5)
               XCTAssertEqual(weatherResponse?.weather.first?.description, "clear sky")
               expectation.fulfill()
           }

           waitForExpectations(timeout: 5, handler: nil)
       }

       func testFetchWeather_Failure() {
           let error = NSError(domain: "WeatherServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch"])
           let urlSession = mockURLSession(data: nil, response: nil, error: error)
           
           let expectation = self.expectation(description: "Fetch weather failure")

           WeatherService.fetchWeather(for: "InvalidCity", urlSession: urlSession) { weatherResponse, error in
               XCTAssertNil(weatherResponse)
               XCTAssertNotNil(error)
               expectation.fulfill()
           }

           waitForExpectations(timeout: 5, handler: nil)
       }
   }

   class MockURLProtocol: URLProtocol {
       static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

       override class func canInit(with request: URLRequest) -> Bool {
           return true
       }

       override class func canonicalRequest(for request: URLRequest) -> URLRequest {
           return request
       }

       override func startLoading() {
           guard let handler = MockURLProtocol.requestHandler else {
               XCTFail("Handler is unavailable.")
               return
           }
           
           do {
               let (response, data) = try handler(request)
               client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
               if let data = data {
                   client?.urlProtocol(self, didLoad: data)
               }
               client?.urlProtocolDidFinishLoading(self)
           } catch {
               client?.urlProtocol(self, didFailWithError: error)
           }
       }

       override func stopLoading() {}
}


   


