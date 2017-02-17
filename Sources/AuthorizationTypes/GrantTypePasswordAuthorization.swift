//
//  GrantTypePasswordAuthorization.swift
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
import Gloss

open class GrantTypePasswordAuthorization : Authorizable {
    public var delegate: AuthorizableDelegate?
    
    public var isReauthorizingToken : Bool = false
    var reauthorizingLimit : Int = 20
    var reauthorizingCount : Int = 0
    private var _parameters : AuthorizationParameters
    public var storedLogger : OctoLogger? = nil
    
    required public init(parameters: AuthorizationParameters) {
        _parameters = parameters
    }
    
    public var configParams: AuthorizationParameters {
        get {
            return _parameters
        }
    }
    
    public var logger: OctoLogger? {
        return storedLogger
    }
    
    public func logSuccess() {
        reauthorizingCount = 0
    }
    
    public func logFailure() {
        reauthorizingCount = reauthorizingCount + 1
    }
    
    public func shouldReauthorize() -> Bool {
        return reauthorizingCount <= reauthorizingLimit
    }
    
    public var isReauthorizable: Bool {
        get {
            return true
        }
    }
    
    public var isReauthorizing: Bool {
        get {
            return isReauthorizingToken
        }
        set {
            isReauthorizingToken = newValue
        }
    }
    
    public var token : OAuthToken? {
        get {
            if let creds = credentials.getCredentials(), let tok = OAuthToken(json: creds) {
                return tok
            }
            return nil
        }
    }
    
    public func save(token: OAuthToken) {
        credentials.save(credentials: token.toJSON()!)
    }
    
    public func parse(credentials: Any) -> Parameters? {
        
        if let json = credentials as? JSON, let token = OAuthToken(json: json) {
            
            return token.toJSON()
        }
        return nil
    }
    
    public func authorizationParameters(login: String, password: String) -> Parameters? {
        return OAuthRequest(username: login, password: password, clientID: configParams.clientID).toJSON()
    }
    
    open var reauthorizationModel : OAuthRequest? {
        get {
            if let token = token {
                let refresh = OAuthRequest()
                refresh.grantType = .RefreshToken
                refresh.refreshToken = token.refreshToken
                refresh.clientId = configParams.clientID
                return refresh
            }
            return nil
        }
    }
    
    public var reauthorizationParameters: Parameters? {
        get {
            if let refresh = reauthorizationModel {
                return refresh.toJSON()
            }
            return nil
        }
    }
    
    open var reauthorizationHeader : HTTPHeaders? {
        get {
            if let refresh = reauthorizationModel, let tokenHeader = refresh.refreshTokenHeader {
                return ["Authorization" : tokenHeader ]
            }
            return nil
        }
    }
    
    public var authorizationHeader: HTTPHeaders {
        get {
            if let token = token {
                return token.authorizationHeader()
            }
            return [:]
        }
    }
    
    public func needsNewCredentials() -> Bool {
        if let token = token, let expiresIn = token.expiresIn, let savedAt = credentials.savedAt {
            let tokenExpirationDate = Date(timeInterval: TimeInterval(expiresIn), since: savedAt)
            let diff = tokenExpirationDate.timeIntervalSinceNow
            return diff < 7200
        }
        return true
    }
    
    public func isAuthorized() -> Bool {
        return token != nil
    }
    
}
