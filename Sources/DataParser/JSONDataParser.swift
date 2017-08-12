// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// `JSONDataParser` response JSON data.
public class JSONDataParser: DataParser {
    /// Options for reading the JSON data and creating the objects.
    public let readingOptions: JSONSerialization.ReadingOptions
    
    /// Returns `JSONDataParser` with the reading options.
    public init(readingOptions: JSONSerialization.ReadingOptions) {
        self.readingOptions = readingOptions
    }
    
    // MARK: - DataParser
    
    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/json"
    }
    
    /// Return `Any` that expresses structure of JSON response.
    /// - Throws: `NSError` when `JSONSerialization` fails to deserialize `Data` into `Any`.
    public func parse(data: Data) throws -> Any {
        guard data.count > 0 else {
            return [:]
        }
        
        return try JSONSerialization.jsonObject(with: data, options: readingOptions)
    }
}
