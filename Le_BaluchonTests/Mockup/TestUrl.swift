import Foundation

class TestURLSession: URLSessionProtocol {
    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return TestURLSessionDataTask {
            completionHandler(self.data, self.urlResponse, self.error)
        }
    }
}

class TestURLSessionDataTask: URLSessionDataTaskProtocol {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    func resume() {
        closure()
    }
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
