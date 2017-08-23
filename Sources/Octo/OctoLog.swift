//
//  OctoLog.swift
//  Pods
//
//  Created by Maciej Kołek on 2/7/17.
//
//

import Foundation
import Alamofire

open class OctoLog : CustomStringConvertible {
    public var dataProvider = "OctoAPI"
    public var date : Date
    public var logString : String
    public var additionalUserInfo : Any?
    public var httpStatusCode : Int?
    
    public var response : DataResponse<Any>?
    public var error : Error?
    public var data : Any?
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    public var description : String {
        return String(format: "[%@][%@] %@", self.dataProvider, self.formatter.string(from: self.date), self.fullLogDescription)
    }
    
    public var fullLogDescription : String {
        var fullLogString = ""
        fullLogString += "===================\n"
        fullLogString += "Logged at \(self.formatter.string(from: self.date))\n"
        fullLogString += "\nLog Body: \n"
        fullLogString += "\(self.logString)\n\n"
        if let err = self.error {
            fullLogString += "Error: \n"
            fullLogString += "\(err.localizedDescription)\n"
        }
        
        if let additionalData = self.additionalUserInfo {
            fullLogString += "Additional User Info: \n"
            fullLogString += "\(additionalData) \n"
        }
        
        fullLogString += "===================\n"
        return fullLogString
    }
    
    public init(logString: String, date: Date = Date()) {
        self.date = date
        self.logString = logString
    }
    
    public convenience init(error: Error, date: Date = Date()) {
        self.init(logString: error.localizedDescription, date: date)
        self.error = error
    }
    
    public convenience init(string: String, error: Error, response: DataResponse<Any>, date: Date = Date()) {
        self.init(logString: string, date: date)
        self.error = error
        self.response = response
        self.processResponse()
    }
    
    public convenience init(response: DataResponse<Any>, date: Date = Date()) {
        self.init(logString: "", date: date)
        self.response = response
        self.processResponse()
    }
    
    public convenience init(data: Any, response: DataResponse<Any>, date: Date = Date()) {
        self.init(logString: "", date: date)
        self.response = response
        self.data = data
        
        self.processResponse()
        self.processData()
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
    
    func processResponse() {
        var responseLogString = "\nData Response: \n"
        if let resp = self.response {
            
            if let data = resp.data, let stringFromData = String(data: data, encoding: .utf8), self.data == nil {
                self.data = stringFromData
            }
            
            if let prettyResp = OctoLog.pretty(response: resp) {
                responseLogString += "\(prettyResp)\n"
            }
            
            if let headersResponse = resp.response {
                self.httpStatusCode = headersResponse.statusCode
                responseLogString += "Headers:\n[\(OctoLog.printHeaders(headersResponse.allHeaderFields))]\n"
            }
            self.logString += responseLogString
        }
    }
    
    func processData() {
        if let data = self.data {
            self.logString += "\nRaw Data:\n{\(data)}\n"
        }
    }
}
