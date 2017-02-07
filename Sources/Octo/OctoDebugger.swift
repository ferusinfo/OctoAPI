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
        
        switch self.mode {
        case .none:
            return
        case .error:
            if let resp = response.response, resp.statusCode == 200 {
                return
            }
            break
        default:
            break
        }
        
        if let resp = response.response, let request = response.request, let httpMethod = request.httpMethod, let url = request.url {
            self.log(string: "\(resp.statusCode) - \(httpMethod.uppercased()) \(url)")
        }
    }
    
    func log(data: Any, withResponse response: DataResponse<Any>) {
        if self.mode == .debug, let resp = response.response {
            self.log(string: "\nHeaders:\n\(self.printHeaders(resp.allHeaderFields))\nResponse data:\n\(data)")
        }
    }
    
    func printHeaders(_ headers: [AnyHashable : Any]) -> String {
        var headersString = ""
        for (key,value) in headers {
            headersString += "[\(key)]=\(value); "
        }
        return headersString
    }
    
    func log(error: Error) {
        self.log(string: error.localizedDescription)
    }
    
    func log(error: Error, withResponse response: DataResponse<Any>) {

        guard self.mode != .none else {
            return
        }
        
        var logString = "Error: \(error.localizedDescription)"
        if self.mode == .debug, let data = response.data, let rawData = String(data: data, encoding: String.Encoding.utf8) {
            logString += "\n\(rawData)"
        }
        
        self.log(string: logString)
    }
    
    func log(string: String) {
        let logText = String(format: "[OctoAPI][%@] %@", self.formatter.string(from: Date()), string)
        print(logText)
        self.delegate?.logEventOccured(logString: logText)
    }
    
    
}
