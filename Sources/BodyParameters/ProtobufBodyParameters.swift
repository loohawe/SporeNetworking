// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// `ProtobufBodyParameters` serializes Protobuf object for HTTP body and states its content type is Protobuf.
public struct ProtobufBodyParameters: BodyParameters {
    /// The Protobuf object to be serialized.
    public let protobufObject: Data
    
    /// Returns `ProtobufBodyParameters`.
    public init(protobufObject: Data) {
        self.protobufObject = protobufObject
    }

    // MARK: - BodyParameters

    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    public var contentType: String {
        return "application/protobuf"
    }

    /// Builds `RequestBodyEntity.data` that represents `ProtobufObject`.
    public func buildEntity() throws -> RequestBodyEntity {
        return .data(protobufObject)
    }
}
