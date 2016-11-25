//
//  OAuthRequest.swift
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

public class OAuthRequest : Encodable {
    
    //MARK: - Keys
    private let GrantTypeKey = "grant_type"
    private let UsernameKey = "username"
    private let PasswordKey = "password"
    private let RefreshTokenKey = "refresh_token"
    private let ClientIdKey = "client_id"
    
    //MARK: - Properties
    var grantType : GrantType = .Password
    var username : String?
    var password : String?
    var refreshToken : String?
    var clientId : String?
    
    enum GrantType: String {
        case Password = "password"
        case RefreshToken = "refresh_token"
    }
    
    var refreshTokenHeader : String? {
        get {
            if let clientId = clientId {
                return "Basic " + Data(String(format: "%@:", clientId).utf8).base64EncodedString()
            }
            return nil
        }
    }
    
    init() {
        
    }
    
    init(username: String, password: String, clientID: String) {
        self.username = username
        self.password = password
        self.clientId = clientID
    }
    
    // MARK: - Serialization
    public func toJSON() -> JSON? {
        return jsonify([
            GrantTypeKey ~~> self.grantType,
            UsernameKey ~~> self.username,
            PasswordKey ~~> self.password,
            RefreshTokenKey ~~> self.refreshToken,
            ClientIdKey ~~> self.clientId
            ])
    }
}
