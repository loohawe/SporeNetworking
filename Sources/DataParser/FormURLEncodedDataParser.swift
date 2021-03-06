// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// `FormURLEncodedDataParser` parses form URL encoded response data.
public class FormURLEncodedDataParser: DataParser {
    public enum Error: Swift.Error {
        case cannotGetStringFromData(Data)
    }
    
    /// The string encoding of the data.
    public let encoding: String.Encoding
    
    /// Returns `FormURLEncodedDataParser` with the string encoding.
    public init(encoding: String.Encoding) {
        self.encoding = encoding
    }
    
    // MARK: - DataParser
    
    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/x-www-form-urlencoded"
    }
    
    /// Return `Any` that expresses structure of response.
    /// - Throws: `FormURLEncodedDataParser.Error` when the parser fails to initialize `String` from `Data`.
    public func parse(data: Data) throws -> Any {
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.cannotGetStringFromData(data)
        }
        
        var components = URLComponents()
        components.percentEncodedQuery = string
        
        let queryItems = components.queryItems ?? []
        var dictionary = [String: Any]()
        
        for queryItem in queryItems {
            dictionary[queryItem.name] = queryItem.value
        }
        
        return dictionary
    }
}
