//
//  Callable.swift
//  OctoAPI
//
//  Copyright (c) 2016 Maciej Kołek
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
import Gloss
import Alamofire

public protocol Callable : class {
    var manager : Alamofire.SessionManager { get }
    var adapter : Adapter { get }
    var authorizer : Authorizable? { get }
    var callsQueue : [Alamofire.Request] { get set }
    @discardableResult func run(request: OctoRequest, completion: @escaping (_ error: Error?, _ data: Any?, _ paging: Paging?) -> Void) -> Request?
    func send(request: Alamofire.Request) -> Void
    func performOnQueue(action : ActionType) -> Void
    func setup() -> Void
    init()
}

public enum ActionType : String {
    case resume = "resume"
    case cancel = "cancel"
}

extension Callable {
    
    public func setup() {
        manager.startRequestsImmediately = false
    }
    
    public var authorizer : Authorizable? {
        get {
           return adapter.authorizer
        }
    }
    
    public var manager : Alamofire.SessionManager {
        get {
            return Alamofire.SessionManager.default
        }
    }
    
    public func send(request: Alamofire.Request) {
        if let authorizer = adapter.authorizer, authorizer.isReauthorizable, authorizer.isReauthorizing {
            callsQueue.append(request)
        } else {
            if let authorizer = adapter.authorizer, authorizer.isAuthorized() {
                manager.session.configuration.httpAdditionalHeaders = authorizer.authorizationHeader
            }
            request.resume()
        }
    }
    
    @discardableResult
    public func run(request: OctoRequest, completion: @escaping (_ error: Error?, _ data: Any?, _ paging: Paging?) -> Void) -> Request? {
        
        var headers : HTTPHeaders = [:]
        
        let endpoint = adapter.versionedURL.appending(request.endpoint)
        
        
        guard let url = URL(string: endpoint), var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { completion(self.errorOccured(code: 500, localizedDescription: "Could not parse the endpoint URL"), nil, nil); return nil}
        

        if let paging = request.paging, let params = paging.queryParameters() {
            if let queryItems = urlComponents.queryItems {
                urlComponents.queryItems = queryItems + params
            } else {
                urlComponents.queryItems = params
            }
        }
        
        //TODO: Add sorting here
        
        if let authorizer = adapter.authorizer, authorizer.isAuthorized() && !authorizer.isReauthorizing {
            headers = authorizer.authorizationHeader
        }
        
        let alamoRequest = manager.request(urlComponents, method: request.method, parameters: request.parameters, encoding: request.method == .get ? URLEncoding.default : request.encoding, headers: headers)
            .validate()
            .responseJSON { response in
            switch response.result {
            case .success(let data):
                self.authorizer?.logSuccess()
                
                var paging : Paging?
                if let response = response.response, let pager = request.paging {
                    paging = Paging(offset: pager.offset, limit: pager.limit, response: response)
                }
                
                completion(nil, data, paging)
            case .failure(let error):
                if let response = response.response, response.statusCode == 401, var authorizer = self.adapter.authorizer, authorizer.isReauthorizable, authorizer.shouldReauthorize() {
                    authorizer.logFailure()
                    
                    let lockQueue = DispatchQueue(label: "octo.lock.reauth")
                    lockQueue.sync() {
                        if !authorizer.isReauthorizing {
                            authorizer.isReauthorizing = true
                            
                            authorizer.performReauthorization(completion: { (error) in
                                if error == nil {
                                    authorizer.isReauthorizing = false
                                    self.performOnQueue(action: .resume)
                                    self.run(request: request, completion: completion)
                                } else {
                                    self.performOnQueue(action: .cancel)
                                    completion(error, nil, nil)
                                }
                            })
                        } else {
                            self.run(request: request, completion: completion)
                        }
                    }
                } else {
                    completion(error, nil, nil)
                }

            }
        }
        
        send(request: alamoRequest)
        return alamoRequest
    }
    
    func errorOccured(code: Int, localizedDescription: String) -> Error {
        let userInfo = [
             NSLocalizedDescriptionKey :  NSLocalizedString(localizedDescription, comment: "")
        ]
        
        return NSError(domain: adapter.errorDomain, code: code, userInfo: userInfo)
    }
    
    public func performOnQueue(action : ActionType) {
        for (index, request) in callsQueue.enumerated() {
            switch action {
            case .resume:
                request.resume()
            case .cancel:
                request.cancel()
            }
            callsQueue.remove(at: index)
        }
    }
}
