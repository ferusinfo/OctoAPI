//
//  GetResponseBlogAdapter.swift
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

class GetResponseBlogAdapter : Adapter {
    var mode: AdapterMode = .production
    var authorizer: Authorizable? = nil
    var errorDomain: String = "com.getresponse.GetResponseBlog.error"
    var productionVersion: String = "v2"
    var logLevel: LogLevel = .debug
    
    var logger: OctoLogger? {
        get {
            return storedLogger
        }
    }
    
    var productionURL: String {
        get {
            var domainExt = "com"
            if let prefferedLoc = Bundle.main.preferredLocalizations.first , prefferedLoc == "pl" {
                domainExt = prefferedLoc
            }
            return "https://blog.getresponse.\(domainExt)/wp-json/wp/"
        }
    }
    
    lazy var storedLogger : OctoLogger = {
        let logger = OctoLogger(logLevel: self.logLevel)
        return logger
    }()
    
    var sandboxURL: String {
        get {
            return productionURL
        }
    }
    
    var sandboxVersion: String {
        get {
            return productionVersion
        }
    }
    
    var perRequestHeaders: HTTPHeaders? {
        get {
            return ["Test-Header":"Test-Value"]
        }
    }
    
}
