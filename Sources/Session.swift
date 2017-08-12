// Copyright (c) 2015 - 2016 Yosuke Ishikawa
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import Result

private var taskRequestKey: Void?

/// `Session` manages tasks for HTTP/HTTPS requests.
open class Session {
    /// The client that connects `Session` instance and lower level backend.
    public let client: SessionClient
    
    /// The default callback queue for `send(_:handler:)`.
    public let callbackQueue: CallbackQueue
    
    /// Returns `Session` instance that is initialized with `client`.
    /// - parameter client: The client that connects lower level backend with Session interface.
    /// - parameter callbackQueue: The default callback queue for `send(_:handler:)`.
    public init(client: SessionClient, callbackQueue: CallbackQueue = .main) {
        self.client = client
        self.callbackQueue = callbackQueue
    }
    
    /// Returns a default `Session`. A global constant `APIKit` is a shortcut of `Session.default`.
    open static let `default` = Session()
    
    // Shared session for class methods
    private convenience init() {
        let configuration = URLSessionConfiguration.default
        let client = URLSessionClient(configuration: configuration)
        self.init(client: client)
    }
    
    /// Sends a request and receives the result as the argument of `handler` closure. This method takes
    /// a type parameter `Request` that conforms to `Request` protocol. The result of passed request is
    /// expressed as `Result<Request.Response, SessionTaskError>`. Since the response type
    /// `Request.Response` is inferred from `Request` type parameter, the it changes depending on the request type.
    /// - parameter request: The request to be sent.
    /// - parameter callbackQueue: The queue where the handler runs. If this parameters is `nil`, default `callbackQueue` of `Session` will be used.
    /// - parameter handler: The closure that receives result of the request.
    /// - returns: The new session task.
    @discardableResult
    open func send<Request: SporeNetworking.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil, handler: @escaping (Result<Request.Response, SessionTaskError>) -> Void = { _ in }) -> SessionTask? {
        let callbackQueue = callbackQueue ?? self.callbackQueue
        
        let urlRequest: URLRequest
        do {
            urlRequest = try request.buildURLRequest()
        } catch {
            callbackQueue.execute {
                let e = SessionTaskError.requestError(error)
                request.handle(error: e)
                handler(.failure(e))
            }
            return nil
        }
        
        let task = client.createTask(with: urlRequest) { data, urlResponse, error in
            let result: Result<Request.Response, SessionTaskError>
            
            switch (data, urlResponse, error) {
            case (_, _, let error?):
                result = .failure(.connectionError(error))
            case (let data?, let urlResponse as HTTPURLResponse, _):
                do {
                    result = .success(try request.parse(data: data as Data, urlResponse: urlResponse))
                } catch {
                    result = .failure(.responseError(error))
                }
            default:
                result = .failure(.responseError(ResponseError.nonHTTPURLResponse(urlResponse)))
            }
            
            callbackQueue.execute {
                switch result {
                case .failure(let e):
                    request.handle(error: e)
                default: break
                }
                handler(result)
            }
        }
        
        setRequest(request, forTask: task)
        task.resume()
        
        return task
    }
    
    /// Cancels requests that passes the test.
    /// - parameter requestType: The request type to cancel.
    /// - parameter test: The test closure that determines if a request should be cancelled or not.
    open func cancelRequests<Request: SporeNetworking.Request>(with requestType: Request.Type, passingTest test: @escaping (Request) -> Bool = { _ in true }) {
        client.getTasks { [weak self] tasks in
            return tasks
                .filter { task in
                    if let request = self?.requestForTask(task) as Request? {
                        return test(request)
                    } else {
                        return false
                    }
                }
                .forEach { $0.cancel() }
        }
    }
    
    private func setRequest<Request: SporeNetworking.Request>(_ request: Request, forTask task: SessionTask) {
        objc_setAssociatedObject(task, &taskRequestKey, request, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func requestForTask<Request: SporeNetworking.Request>(_ task: SessionTask) -> Request? {
        return objc_getAssociatedObject(task, &taskRequestKey) as? Request
    }
    
    open func multipleSend<T: Request>(_ requests: T..., callbackQueue: CallbackQueue? = nil, handle: @escaping (Result<[Any?], [Any?]>) -> Void ) -> [SessionTask?] {
        
        let callbackQueue: CallbackQueue = callbackQueue ?? self.callbackQueue
        
        let group: DispatchGroup = DispatchGroup.init()
        
        var models: [Any?] = Array.init(repeating: nil, count: requests.count)
        var errors: [Error?] = Array.init(repeating: nil, count: requests.count)
        var sessionTasks: [SessionTask?] = Array.init(repeating: nil, count: requests.count)
        
        var allSuccess: Bool = true
        
        for i in 0..<requests.count {
            
            group.enter()
            let req: T = requests[i]
            
            let index: Int = i
            let session = self.send(req, callbackQueue: callbackQueue, handler: {
                (result: Result<T.Response, SessionTaskError>) in
                switch result {
                case .success(let resultModel):
                    models.replaceSubrange(index..<index+1, with: [resultModel])
                case .failure(let sessionError):
                    allSuccess = false
                    errors.replaceSubrange(index..<index+1, with: [sessionError])
                }
                group.leave()
            })
            
            sessionTasks.append(session)
        }
        
        group.notify(queue: DispatchQueue.main) { 
            callbackQueue.execute {
                if allSuccess {
                    handle(.success(models))
                } else {
                    handle(.failure(errors))
                }
            }
        }
        
        return sessionTasks
    }
}

extension Array: Error {}

// MARK: - Default SporeNetworking instance

public let Spore = Session.default
