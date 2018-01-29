//
//  OctoError.swift
//  OctoAPI
//
//  Copyright (c) 2018 Maciej Kołek
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

open class OctoError {
    public var error : Error
    public var errorDescription : String?
    public var errorCode : Int
    public var errorDomain : String?
    
    init(error: Error, errorCode: Int, errorDomain: String? = nil, errorDescription: String? = nil) {
        self.error = error
        self.errorCode = errorCode
        self.errorDescription = errorDescription
        self.errorDomain = errorDomain
    }
    
    convenience init(errorCode: Int, errorDomain: String, errorDescription: String) {
        let err = OctoError.createError(code: errorCode, domain: errorDomain, description: errorDescription)
        self.init(error: err, errorCode: errorCode, errorDomain: errorDomain, errorDescription: errorDescription)
    }
    
    static func createError(code: Int, domain: String, description: String) -> Error {
        let userInfo = [
            NSLocalizedDescriptionKey :  NSLocalizedString(description, comment: "")
        ]
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
}
