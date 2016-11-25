//
//  PagingAdapter.swift
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

public enum PagingMode : String {
    case headers = "headers"
    case custom = "custom"
}

public protocol PagingParameters {
    var mode : PagingMode? { get }
    var currentOffset : Int? { get }
    var currentLimit : Int? { get }
    var queryLimitParameter : String {get}
    var queryPageParameter : String {get}
    
    var resultsTotalCountParameter : String {get}
    var resultsTotalPagesParameter : String {get}
    
    func queryParameters() -> [URLQueryItem]?
    
    func parse(fromResponse: HTTPURLResponse?)
    func parseHeaders(headers: [AnyHashable : Any])
}

extension PagingParameters {
    public func queryParameters() -> [URLQueryItem]? {
        if let currentOffset = currentOffset, let currentLimit = currentLimit{
            return [
                URLQueryItem(name: queryPageParameter, value: currentOffset.description),
                URLQueryItem(name: queryLimitParameter, value: currentLimit.description)
            ]
        }
        return nil
    }
}
