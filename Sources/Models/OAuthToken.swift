//
//  OAuthToken.swift
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

public class OAuthToken : NSObject, Decodable, Encodable {
    
    // MARK: - Keys
    private let AccessTokenKey = "access_token"
    private let RefreshTokenKey = "refresh_token"
    private let TokenTypeKey = "token_type"
    private let ExpiresInKey = "expires_in"
    
    // MARK: - Properties
    public var accessToken : String
    public var expiresIn : Int?
    public let refreshToken : String
    public let tokenType : String
    
    // MARK: - Deserialization
    required public init?(json: JSON) {
        
        guard let accessToken: String = AccessTokenKey <~~ json
            else { return nil }
        
        guard let refreshToken: String = RefreshTokenKey <~~ json
            else { return nil }
        
        guard let tokenType: String = TokenTypeKey <~~ json
            else { return nil }
        
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = ExpiresInKey <~~ json
    }
    
    // MARK: - Serialization
    @objc public func toJSON() -> JSON? {
        return jsonify([
            AccessTokenKey ~~> self.accessToken,
            ExpiresInKey ~~> self.expiresIn,
            RefreshTokenKey ~~> self.refreshToken,
            TokenTypeKey ~~> self.tokenType
            ])
    }
    
    // MARK: - Header
    func authorizationHeader() -> Dictionary<String, String> {
        return ["Authorization" : "\(self.tokenType) \(self.accessToken)"]
    }
}
