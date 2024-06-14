//
//  TestURLSession.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 25/05/2024.
//

import Foundation

// TestURLSession simulates a URLSession for testing purposes
class TestURLSession: URLSessionProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?

    // Creates a data task with the given request and completion handler
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return TestURLSessionDataTask {
            completionHandler(self.data, self.urlResponse, self.error)
        }
    }
}

// TestURLSessionDataTask is a mock implementation of URLSessionDataTaskProtocol
class TestURLSessionDataTask: URLSessionDataTaskProtocol {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    // Calls the closure to simulate the task's resume behavior
    func resume() {
        closure()
    }
}

// Protocol defining the methods required for URLSession
protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

// Protocol defining the methods required for URLSessionDataTask
protocol URLSessionDataTaskProtocol {
    func resume()
}

// Extension to bridge URLSession to URLSessionProtocol
extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

// Extension to bridge URLSessionDataTask to URLSessionDataTaskProtocol
extension URLSessionDataTask: URLSessionDataTaskProtocol {}
