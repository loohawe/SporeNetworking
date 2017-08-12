// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

/// `CallbackQueue` represents queue where `handler` of `Session.send(_:handler:)` runs.
public enum CallbackQueue {
    /// Dispatches callback closure on main queue asynchronously.
    case main

    /// Dispatches callback closure on the queue where backend adapter callback runs.
    case sessionQueue

    /// Dispatches callback closure on associated operation queue.
    case operationQueue(OperationQueue)

    /// Dispatches callback closure on associated dispatch queue.
    case dispatchQueue(DispatchQueue)

    public func execute(closure: @escaping () -> Void) {
        switch self {
        case .main:
            DispatchQueue.main.async {
                closure()
            }

        case .sessionQueue:
            closure()

        case .operationQueue(let operationQueue):
            operationQueue.addOperation {
                closure()
            }

        case .dispatchQueue(let dispatchQueue):
            dispatchQueue.async {
                closure()
            }
        }
    }
}
