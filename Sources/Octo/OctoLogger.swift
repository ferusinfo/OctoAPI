//
//  OctoLogger.swift
//  OctoAPI
//
//  Created by Maciej Kołek on 2/7/17.
//
//

import Foundation
import Alamofire

public enum LogLevel : String {
    case none = "none"
    case info = "info"
    case debug = "debug"
    case error = "error"
}

public protocol OctoLoggerDelegate : class {
    func eventLogged(event: OctoLog)
}

public class OctoLogger {
    public weak var delegate : OctoLoggerDelegate?
    public var mode : LogLevel = .debug
    
    public init(logLevel: LogLevel) {
        self.mode = logLevel
    }

    public func log(request: OctoRequest, withEndpoint endpoint: URLComponents) {
        if [.none,.error].contains(self.mode) {
            return
        }
        
        var logString = "\(request.method.rawValue.uppercased()) \(endpoint)"
        if self.mode == .debug, let params = request.parameters {
            logString += "\nParameters:\n\(params)"
        }
        
        self.log(event: OctoLog(logString: logString))
    }
    
    public func log(response: DataResponse<Any>) {
        if [.none,.error].contains(self.mode) {
            return
        }
        
        self.log(event: OctoLog(response: response))
    }
    
    public func log(data: Any, withResponse response: DataResponse<Any>) {
        if self.mode == .debug {
            self.log(event: OctoLog(data: data, response: response))
        }
    }
    
    public func log(error: Error) {
        guard self.mode != .none else {
            return
        }
        
        self.log(event: OctoLog(error: error))
    }
    
    public func log(error: Error, withResponse response: DataResponse<Any>) {

        guard self.mode != .none else {
            return
        }
        
        var logString = ""
        
        if self.mode == .error {
            if let prettyResponse = OctoLog.pretty(response: response) {
               logString += prettyResponse + "\n"
            }
            
            if let request = response.request {
                if let headers = request.allHTTPHeaderFields {
                    logString += "Headers: \(OctoLog.printHeaders(headers))\n"
                }
                
                if let data = request.httpBody, let rawData = String(data: data, encoding: String.Encoding.utf8) {
                    logString += "Body: \(rawData)\n"
                }
                
            }
        }
        
        logString += "Error: \(error.localizedDescription)"
        if let data = response.data, let rawData = String(data: data, encoding: String.Encoding.utf8) {
            logString += "\n\(rawData)"
        }

        self.log(event: OctoLog(string: logString, error: error, response: response))
    }
    
    public func log(string: String) {
        if [.none,.error].contains(self.mode) {
            return
        }
        
        self.log(event: OctoLog(logString: string))
    }
    
    public func log(event: OctoLog) {
        print(event)
        self.delegate?.eventLogged(event: event)
    }
    
    
}
