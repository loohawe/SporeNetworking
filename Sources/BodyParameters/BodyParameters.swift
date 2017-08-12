// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// `RequestBodyEntity` represents entity of HTTP body.
public enum RequestBodyEntity {
    /// Expresses entity as `Data`. The associated value will be set to `URLRequest.httpBody`.
    case data(Data)
    
    /// Expresses entity as `InputStream`. The associated value will be set to `URLRequest.httpBodyStream`.
    case inputStream(InputStream)
}

/// `BodyParameters` provides interface to parse HTTP response body and to state `Content-Type` to accept.
public protocol BodyParameters {
    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    var contentType: String { get }
    
    /// Builds `RequestBodyEntity`.
    /// Throws: `Error`
    func buildEntity() throws -> RequestBodyEntity
}

