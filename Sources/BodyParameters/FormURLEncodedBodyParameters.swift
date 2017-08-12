// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// `FormURLEncodedBodyParameters` serializes form object for HTTP body and states its content type is form.
public struct FormURLEncodedBodyParameters: BodyParameters {
    /// The form object to be serialized.
    public let form: [String: Any]

    /// The string encoding of the serialized form.
    public let encoding: String.Encoding

    /// Returns `FormURLEncodedBodyParameters` that is initialized with form object and encoding.
    public init(formObject: [String: Any], encoding: String.Encoding = .utf8) {
        self.form = formObject
        self.encoding = encoding
    }

    // MARK: - BodyParameters

    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    public var contentType: String {
        return "application/x-www-form-urlencoded"
    }

    /// Builds `RequestBodyEntity.data` that represents `form`.
    /// - Throws: `URLEncodedSerialization.Error` if `URLEncodedSerialization` fails to serialize form object.
    public func buildEntity() throws -> RequestBodyEntity {
        return .data(try URLEncodedSerialization.data(from: form, encoding: encoding))
    }
}
