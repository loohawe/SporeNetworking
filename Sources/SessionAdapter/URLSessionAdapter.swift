// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

extension URLSessionTask: SessionTask {}

private var dataTaskResponseBufferKey = 0
private var taskAssociatedObjectCompletionHandlerKey = 0

/// `URLSessionClient` connects `URLSession` with `Session`.
///
/// If you want to add custom behavior of `URLSession` by implementing delegate methods defined in
/// `URLSessionDelegate` and related protocols, define a subclass of `URLSessionClient` and implement
/// delegate methods that you want to implement. Since `URLSessionClient` also implements delegate methods
/// `URLSession(_:task: didCompleteWithError:)` and `URLSession(_:dataTask:didReceiveData:)`, you have to call
/// `super` in these methods if you implement them.
open class URLSessionClient: NSObject, SessionClient, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    /// The undelying `URLSession` instance.
    open var urlSession: URLSession!
    
    /// Returns `URLSessionClient` initialized with `URLSessionConfiguration`.
    public init(configuration: URLSessionConfiguration) {
        super.init()
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    /// Creates `URLSessionDataTask` instance using `dataTaskWithRequest(_:completionHandler:)`.
    open func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionTask {
        let task = urlSession.dataTask(with: URLRequest)
        
        setBuffer(NSMutableData(), forTask: task)
        setHandler(handler, forTask: task)
        
        return task
    }
    
    /// Aggregates `URLSessionTask` instances in `URLSession` using `getTasksWithCompletionHandler(_:)`.
    open func getTasks(with handler: @escaping ([SessionTask]) -> Void) {
        urlSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let allTasks = dataTasks as [URLSessionTask]
                + uploadTasks as [URLSessionTask]
                + downloadTasks as [URLSessionTask]
            
            handler(allTasks.map { $0 })
        }
    }
    
    private func setBuffer(_ buffer: NSMutableData, forTask task: URLSessionTask) {
        objc_setAssociatedObject(task, &dataTaskResponseBufferKey, buffer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func buffer(for task: URLSessionTask) -> NSMutableData? {
        return objc_getAssociatedObject(task, &dataTaskResponseBufferKey) as? NSMutableData
    }
    
    private func setHandler(_ handler: @escaping (Data?, URLResponse?, Error?) -> Void, forTask task: URLSessionTask) {
        objc_setAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey, handler as Any, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func handler(for task: URLSessionTask) -> ((Data?, URLResponse?, Error?) -> Void)? {
        return objc_getAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey) as? (Data?, URLResponse?, Error?) -> Void
    }
    
    // MARK: URLSessionTaskDelegate
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        handler(for: task)?(buffer(for: task) as Data?, task.response, error)
    }
    
    // MARK: URLSessionDataDelegate
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer(for: dataTask)?.append(data)
    }
}

