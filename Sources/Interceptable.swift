// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Interceptable.swift
//  POPAPIKit
//
// Copyright (c) 2017年 Hanguang
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public protocol Interceptable {
    /// Intercepts `URLRequest` which is created by `Request.buildURLRequest()`. If an error is
    /// thrown in this method, the result of `Session.send()` turns `.failure(.requestError(error))`.
    /// - Throws: `Error`
    func intercept(urlRequest: URLRequest) throws -> URLRequest
    
    /// Intercepts response `Any` and `HTTPURLResponse`. If an error is thrown in this method,
    /// the result of `Session.send()` turns `.failure(.responseError(error))`.
    /// The default implementation of this method is provided to throw `RequestError.unacceptableStatusCode`
    /// if the HTTP status code is not in `200..<300`.
    /// - Throws: `Error`
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any
}

public extension Interceptable {
    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard 200..<300 ~= urlResponse.statusCode else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
}
