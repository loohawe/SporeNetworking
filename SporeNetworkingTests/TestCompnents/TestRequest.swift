//
//  TestRequest.swift
//  SporeExample
//
//  Created by luhao on 2017/8/1.
//  Copyright © 2017年 luhao. All rights reserved.
//

import Foundation
import SporeNetworking
@testable import SporeNetworking_Example

struct TestRequest: Request {
    
    var absoluteURL: URL? {
        let urlRequest = try? buildURLRequest()
        return urlRequest?.url
    }
    
    // MARK: Request
    typealias Response = [String : Any]
    
    init(baseURL: String = "https://example.com", path: String = "/", method: HTTPMethod = .get, parameters: Any? = [:], headerFields: [String: String] = [:], interceptURLRequest: @escaping (URLRequest) throws -> URLRequest = { $0 }) {
        self.baseURL = URL(string: baseURL)!
        self.path = path
        self.method = method
        self.param = parameters
        self.headerFields = headerFields
        self.interceptURLRequest = interceptURLRequest
    }
    
    let baseURL: URL
    let method: HTTPMethod
    let path: String
    let param: Any?
    var headerFields: [String: String]
    let bodyParameters: BodySerialization = BodyParameters.init()
    let dataParser: DataParser = JSONDataParser(readingOptions: [])
    let interceptURLRequest: (URLRequest) throws -> URLRequest
    
    var parameters: [String : Any]? {
        return param as? [String : Any]
    }
    
    func verification(request: URLRequest) throws -> URLRequest {
        return try interceptURLRequest(request)
    }
    
    func process(parsedResult: Any, urlResponse: HTTPURLResponse) throws -> Any {
        if urlResponse.statusCode == 400 {
            throw ResponseError.unacceptableStatusCode(400)
        }
        return parsedResult
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let responseDic = object as? [String : Any] else {
            throw SessionTaskError.responseError(TestError.someError)
        }
        return responseDic
    }
}

enum TestError: Error {
    case someError
}
