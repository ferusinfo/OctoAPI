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

import Foundation

public class OAuthRequest: Encodable {
    
    //MARK: - Properties
    var grantType : GrantType = .Password
    var username : String?
    var password : String?
    var refreshToken : String?
    var clientId : String?
    
    enum GrantType: String, Encodable {
        case Password = "password"
        case RefreshToken = "refresh_token"
    }
    
    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case username
        case password
        case refreshToken = "refresh_token"
        case clientId = "client_id"
    }
    
    public var refreshTokenHeader : String? {
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(grantType, forKey: .grantType)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(clientId, forKey: .clientId)
    }
}
