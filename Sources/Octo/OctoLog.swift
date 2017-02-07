//
//  OctoLog.swift
//  Pods
//
//  Created by Maciej Kołek on 2/7/17.
//
//

import Foundation
import Alamofire

public class OctoLog : CustomStringConvertible {
    public var date : Date
    public var logString : String
    public var response : DataResponse<Any>?
    public var error : Error?
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    public var description : String {
        return String(format: "[OctoAPI][%@] %@", self.formatter.string(from: Date()), logString)
    }
    
    init(logString: String, date: Date = Date()) {
        self.date = date
        self.logString = logString
    }
    
    convenience init(error: Error, date: Date = Date()) {
        self.init(logString: error.localizedDescription, date: date)
        self.error = error
    }
    
    convenience init(string: String, error: Error, response: DataResponse<Any>, date: Date = Date()) {
        self.init(logString: string, date: date)
        self.error = error
        self.response = response
    }
    
    convenience init(response: DataResponse<Any>, date: Date = Date()) {
        var logString = "--"
        if let prettyResp = OctoLog.pretty(response: response) {
            logString = prettyResp
        }
        
        self.init(logString: logString, date: date)
        self.response = response
    }
    
    convenience init(data: Any, response: DataResponse<Any>, date: Date = Date()) {
        
        var logString = "--"
        if let resp = response.response {
            logString = "\nHeaders:\n\(OctoLog.printHeaders(resp.allHeaderFields))\nResponse data:\n\(data)"
        }
        
        self.init(logString: logString, date: date)
        self.response = response
    }
    
    static func pretty(response: DataResponse<Any>) -> String? {
        if let resp = response.response, let request = response.request, let httpMethod = request.httpMethod, let url = request.url {
            return "\(resp.statusCode) - \(httpMethod.uppercased()) \(url)"
        }
        return nil
    }
    
    static func printHeaders(_ headers: [AnyHashable : Any]) -> String {
        var headersString = ""
        for (key,value) in headers {
            headersString += "[\(key)]=\(value); "
        }
        return headersString
    }
}
