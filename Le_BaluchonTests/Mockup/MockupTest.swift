//
//  MockupTest.swift
//  Le_Baluchon
//
//  Created by younes ouasmi on 25/05/2024.
//

import Foundation

// MockURLProtocol is used to mock network responses
class MockURLProtocol: URLProtocol {
    static var mockResponse: (data: Data?, response: URLResponse?, error: Error?)?

    // Determines if the protocol can handle the given request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // Returns a canonical version of the request
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // Starts loading the request with the mock response
    override func startLoading() {
        if let mockResponse = MockURLProtocol.mockResponse {
            if let data = mockResponse.data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            if let response = mockResponse.response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = mockResponse.error {
                self.client?.urlProtocol(self, didFailWithError: error)
            }
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }

    // Stops loading the request (no-op in this case)
    override func stopLoading() {
        // No-op
    }
}

// MockURLSession is used to create a session with the mock protocol
class MockURLSession {
    static func createMockSession(data: Data?, response: URLResponse?, error: Error?) -> URLSession {
        MockURLProtocol.mockResponse = (data: data, response: response, error: error)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}
