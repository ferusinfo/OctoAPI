//
//  Authorizable.swift
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
import Alamofire
import KeychainAccess
import Gloss

public enum AuthorizationMode : String {
    case authorization = "auth"
    case reauthorization = "re_auth"
}

public protocol Authorizable {
    var configParams : AuthorizationParameters { get }
    var credentials : Credentials { get }
    var authorizationHeader : HTTPHeaders { get }
    var reauthorizationHeader : HTTPHeaders? { get }
    var reauthorizationParameters : Parameters? { get }
    var isReauthorizing : Bool { get set }
    var isReauthorizable : Bool { get }
    
    func authorizationParameters(login: String, password: String) -> Parameters?
    func performAuthorization(login: String, password: String, completion: @escaping (_ error: Error?) -> Void) -> Void
    func performReauthorization(completion: @escaping (_ error: Error?) -> Void) -> Void
    func performOperationOnAuthorization(mode: AuthorizationMode, parameters: Parameters?, completion: @escaping (_ error: Error?) -> Void) -> Void
    
    func isAuthorized() -> Bool
    func needsNewCredentials() -> Bool
    func shouldReauthorize() -> Bool
    
    func logout()
    
    func logSuccess()
    func logFailure()
    func parse(credentials: Any) -> Parameters?
    
    init(parameters: AuthorizationParameters)
}

extension Authorizable {
    
    var isReauthorizable : Bool {
        get {
            return false
        }
    }
    
    var isReauthorizing : Bool {
        get {
            return false
        }
    }
    
    func logFailure() {
        //stub
    }
    
    func logSuccess() {
        //stub
    }
    
    func needsNewCredentials() -> Bool {
        return false
    }
    
    public func logout() {
        credentials.removeCredentials()
    }
    
    public var credentials : Credentials {
        get {
            return Credentials(keychainService: configParams.serviceName)
        }
    }
    
    public func performAuthorization(login: String, password: String, completion: @escaping (Error?) -> Void) {
        performOperationOnAuthorization(mode: .authorization, parameters: authorizationParameters(login: login, password: password), completion: completion)
    }
    
    public func performReauthorization(completion: @escaping (Error?) -> Void) {
        performOperationOnAuthorization(mode: .reauthorization, parameters: reauthorizationParameters, completion: completion)
    }
    
    public func performOperationOnAuthorization(mode: AuthorizationMode, parameters: Parameters?, completion: @escaping (_ error: Error?) -> Void) -> Void {
        var headers : HTTPHeaders = [:]
        
        if mode == .reauthorization, let reauthHeader = reauthorizationHeader {
            headers = reauthHeader
        }
        
        let authorizationEndpoint = configParams.baseURL + configParams.endpoint
        
        let req = Alamofire.request(authorizationEndpoint, method: .post, parameters: parameters, headers: headers).validate()
            .responseJSON {  response in
                switch response.result {
                case .success(let data):
                    
                    if let parsed = self.parse(credentials: data) {
                        self.credentials.save(credentials: parsed)
                        completion(nil)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    
                    if let data = response.data {
                        print("Response data: \(String(data: data, encoding: String.Encoding.utf8)!)")
                    }
                    completion(error)
                }
        }
        if !Alamofire.SessionManager.default.startRequestsImmediately {
            req.resume()
        }
    }

}
