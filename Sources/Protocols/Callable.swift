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
    var logger : OctoLogger? {get}
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
    
    public var logger : OctoLogger? {
        return adapter.logger
    }
    
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
        return self.run(octoRequest: request) { (octoError, data, paging) in
            completion(octoError?.error, data, paging)
        }
    }
    
    @discardableResult
    public func run(octoRequest request: OctoRequest, completion: @escaping (_ error: OctoError?, _ data: Any?, _ paging: Paging?) -> Void) -> Request? {
        
        let endpoint = adapter.versionedURL.appending(request.endpoint)
        
        guard let url = URL(string: endpoint), var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { completion(OctoError(errorCode: 500, errorDomain: adapter.errorDomain, errorDescription: "Could not parse the endpoint URL"), nil, nil); return nil}

        if let paging = request.paging, let params = paging.queryParameters() {
            if let queryItems = urlComponents.queryItems {
                urlComponents.queryItems = queryItems + params
            } else {
                urlComponents.queryItems = params
            }
        }
        
        var headers : HTTPHeaders = [:]
        
        if let requestHeaders = request.headers {
            headers.update(other: requestHeaders)
        }
        
        if let perRequestHeaders = adapter.perRequestHeaders {
            headers.update(other: perRequestHeaders)
        }
        
        if let authorizer = adapter.authorizer, authorizer.isAuthorized() {
            headers.update(other: authorizer.authorizationHeader)
        }
        
        //TODO: Add sorting here
        self.logger?.log(request: request, withEndpoint: urlComponents)
        
        if !headers.isEmpty {
            self.logger?.log(string: "Headers: \(headers)")
        }
        
        let alamoRequest = manager.request(urlComponents, method: request.method, parameters: request.parameters, encoding: request.method == .get ? URLEncoding.default : request.encoding, headers: headers)
            .validate()
            .responseJSON { response in
            
            self.logger?.log(response: response)
                
            switch response.result {
            case .success(let data):
                self.authorizer?.logSuccess()
                var paging : Paging?
                if let response = response.response, let pager = request.paging {
                    pager.parse(fromResponse: response)
                    paging = pager
                }
                
                self.logger?.log(data: data, withResponse: response)
                completion(nil, data, paging)
            case .failure(let error):
                //MEMO: We are forcing a success when the http code is between 201-204 to accept nil-content success
                //See more: https://github.com/Alamofire/Alamofire/pull/889
                
                if let response = response.response, (201...204).contains(response.statusCode) {
                    completion(nil, nil, nil)
                    return
                }
                
                self.logger?.log(error: error, withResponse: response)
                self.authorizer?.logFailure()
                if let response = response.response, response.statusCode == 401, var authorizer = self.adapter.authorizer, authorizer.isReauthorizable {
                    self.logger?.log(string: "Performing token reauthorization")
                    
                    DispatchQueue(label: "octo.reauth.lock").sync {
                        if !authorizer.isReauthorizing {
                            
                            authorizer.isReauthorizing = true
                            
                            authorizer.performReauthorization(completion: { (error) in
                                if error == nil {
                                    self.logger?.log(string: "Token reauthorization successful")
                                    authorizer.isReauthorizing = false
                                    self.run(octoRequest: request, completion: completion)
                                    self.performOnQueue(action: .resume)
                                    
                                } else {
                                    
                                    self.logger?.log(string: "Could not perform token reauthorization")
                                    self.performOnQueue(action: .cancel)
                                    self.logger?.log(error: error!)
                                    authorizer.isReauthorizing = false
                                    authorizer.logout()
                                    let octoError = OctoError(error: error!, errorCode: response.statusCode, errorDomain: self.adapter.errorDomain, errorDescription: "Token reauthorization failed")
                                    completion(octoError, nil, nil)
                                }
                            })
                        } else {
                            self.run(octoRequest: request, completion: completion)
                        }
                    }
                } else {
                    var errCode = 999
                    if let responseCode = response.response?.statusCode {
                        errCode = responseCode
                    }
                    let octoError = OctoError(error: error, errorCode: errCode)
                    completion(octoError, nil, nil)
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
        for (_, request) in callsQueue.enumerated() {
            switch action {
            case .resume:
                request.resume()
            case .cancel:
                request.cancel()
            }
        }
        callsQueue = []
    }
}
