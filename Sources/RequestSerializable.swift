// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

public protocol RequestSerializable {
    /// Builds `URLRequest` from `POPAPIKit.Request`.
    /// - Throws: `RequestError`, `Error`
    func buildURLRequest() throws -> URLRequest
}

public extension RequestSerializable where Self: SporeNetworking.Request {
    func buildURLRequest() throws -> URLRequest {
        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw RequestError.invalidBaseURL(baseURL)
        }
        
        var urlRequest = URLRequest(url: url)
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components.percentEncodedQuery = URLEncoding.default.query(from: queryParameters)
        }
        
        if let bodyParameters = bodyParameters {
            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")
            
            switch try bodyParameters.buildEntity() {
            case .data(let data):
                urlRequest.httpBody = data
                
            case .inputStream(let inputStream):
                urlRequest.httpBodyStream = inputStream
            }
        }
        
        urlRequest.url = components.url
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
        
        headerFields.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return (try intercept(urlRequest: urlRequest) as URLRequest)
    }
}
