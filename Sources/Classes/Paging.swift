//
//  Paging.swift
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

open class Paging : PagingParameters {
    
    public var offset : Int
    public var limit : Int
    public var resultsCount : Int?
    public var totalPages : Int?
    
    public var currentOffset: Int? {
        return offset
    }
    
    public var currentLimit: Int? {
        return limit
    }
    
    open var queryLimitParameter: String {
        get {
            return "limit"
        }
    }
    
    open var queryPageParameter: String {
        get {
            return "page"
        }
    }
    
    open var resultsTotalCountParameter : String {
        get {
            return "TotalCount"
        }
    }
    
    open var resultsTotalPagesParameter : String {
        get {
            return "TotalPages"
        }
    }
    
    open var mode: PagingMode? {
        get {
            return nil
        }
    }
    
    public init(offset: Int, limit: Int) {
        self.offset = offset
        self.limit = limit
    }
    
    public init(offset: Int, limit: Int, response: HTTPURLResponse?) {
        self.offset = offset
        self.limit = limit
        self.parse(fromResponse: response)
    }
    
    open func parse(fromResponse: HTTPURLResponse?) {
        if let response = fromResponse, let mode = self.mode, mode == .headers {
            self.parseHeaders(headers: response.allHeaderFields)
        }
    }
    
    //We set it to open to allow overriding the method
    open func parseHeaders(headers: [AnyHashable : Any]) {
        
        if let total = headers[resultsTotalCountParameter] as? String, let totalInt = Int(total) {
            self.resultsCount = totalInt
        }
        
        if let pages = headers[resultsTotalPagesParameter] as? String, let pagesInt = Int(pages) {
            self.totalPages = pagesInt
        }
        
    }
    
}




