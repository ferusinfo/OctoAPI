//
//  Credentials.swift
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
import KeychainAccess
import Alamofire

open class Credentials {
    let keychain : Keychain
    let keychainCredentialsKey : String
    open var savedAt : Date? {
        get {
            if let attrs = self.keychain[attributes: keychainCredentialsKey] {
                return attrs.creationDate
            }
            return nil
        }
    }
    
    open var hasCredentials: Bool {
        return self.getCredentials() != nil
    }
    
    required public init(keychainService: String, accessGroup: String? = nil) {
        if let accessGroup = accessGroup {
            self.keychain = Keychain(service: keychainService, accessGroup: accessGroup)
        } else {
            self.keychain = Keychain(service: keychainService)
        }
        self.keychainCredentialsKey = keychainService + ".credentials"
    }
    
    open func save(credentials: Parameters) {
        self.removeCredentials()
        self.keychain[data: keychainCredentialsKey] = NSKeyedArchiver.archivedData(withRootObject: credentials)
    }
    
    open func getCredentials() -> Parameters? {
        if let data = self.keychain[data: keychainCredentialsKey], let credentials = NSKeyedUnarchiver.unarchiveObject(with: data) as? Parameters {
            return credentials
        }
        return nil
    }
    
    open func removeCredentials() {
        self.keychain[keychainCredentialsKey] = nil
    }
}
