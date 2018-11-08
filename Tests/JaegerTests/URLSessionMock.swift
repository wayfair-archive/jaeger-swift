//
//  URLSessionMock.swift
//  JaegerTests
//
//  Created by Simon-Pierre Roy on 11/7/18.
//

import Foundation

final class URLSessionDataTaskMock: URLSessionDataTask {
    
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    override func resume() {
        closure()
    }
}

final class URLSessionMock: URLSession {
    
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    var data: Data?
    var error: Error?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}
