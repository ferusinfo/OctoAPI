//
//  OctoDebugger.swift
//  OctoAPI
//
//  Created by Maciej Kołek on 2/7/17.
//
//

import Foundation
import Alamofire

public enum DebugMode : String {
    case none = "none"
    case info = "info"
    case debug = "debug"
    case error = "error"
}

public protocol DebuggerDelegate : class {
    func logEventOccured(logString: String)
}

public class OctoDebugger {
    weak var delegate : DebuggerDelegate?
    var mode : DebugMode = .debug
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    func log(request: OctoRequest, withEndpoint endpoint: URLComponents) {
        if [.none,.error].contains(self.mode) {
            return
        }
        
        var logString = "\(request.method.rawValue.uppercased()) \(endpoint)"
        if self.mode == .debug, let params = request.parameters {
            logString += "\nParameters:\n\(params)"
        }
        self.log(string: logString)
    }
    
    func log(response: DataResponse<Any>) {
        if [.none,.error].contains(self.mode) {
            return
        }
        self.log(string: "\(response.response!.statusCode) - \(response.request!.httpMethod!.uppercased()) \(response.request!.url!)")
    }
    
    func log(response: DataResponse<Any>, data: Any) {
        
        self.log(response: response)
        
        if self.mode == .debug {
            self.log(string: "\nHeaders:\n\(response.response!.allHeaderFields)\nResponse data:\n\(data)")
        }
    }
    
    func log(response: DataResponse<Any>, withError error: Error) {
        
        self.log(response: response)
        
        guard self.mode != .none else {
            return
        }
        
        var logString = "Error: \(error.localizedDescription)"
        if self.mode == .debug, let data = response.data, let rawData = String(data: data, encoding: String.Encoding.utf8) {
            logString += "\n\(rawData)"
        }
        
        self.log(string: logString)
    }
    
    func responseLogString(response: DataResponse<Any>) -> String {
        return "\(response.response!.statusCode) - \(response.request!.httpMethod!.uppercased()) \(response.request!.url!)"
    }
    
    func log(string: String) {
        let logText = String(format: "[OctoAPI][%@] %@", self.formatter.string(from: Date()), string)
        print(logText)
        self.delegate?.logEventOccured(logString: logText)
    }
    
    
}
