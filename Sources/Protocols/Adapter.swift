//
//  Adapter.swift
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
import Alamofire

public enum AdapterMode : String {
    case production = "production"
    case sandbox = "sandbox"
}

public protocol Adapter {
    /*
     Production and sandbox URLs
    */
    var productionURL : String { get }
    var productionVersion : String { get }
    var sandboxURL : String { get }
    var sandboxVersion : String { get }
    
    /* Adapter Mode */
    var mode : AdapterMode { get set }
    
    /* Base URL based on adapter mode */
    var baseURL : String { get }
    var versionedURL : String { get }
    
    /* error domain for error mapping */
    var errorDomain : String { get }
    
    /* code to inject to the error object when parser error is occured */
    var parserErrorCode : Int { get }
    
    /* Authorization object - set to nil if your API does not require authorization */
    var authorizer : Authorizable? { get }
    
    var logLevel : DebugMode { get }
}

extension Adapter {
    public var baseURL : String {
        get {
            return mode == .production ? productionURL : sandboxURL
        }
    }
    
    public var versionedURL : String {
        get {
            let url = mode == .production ? productionURL : sandboxURL
            let version = mode == .production ? productionVersion : sandboxVersion
            return url + version + AdapterPathDelimiter
        }
    }
    
    public var parserErrorCode : Int {
        get {
            return 428
        }
    }
    
    public var logLevel : DebugMode {
        get {
            return .none
        }
    }
}
