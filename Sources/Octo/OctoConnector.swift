//
//  OctoConnector.swift
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

import Alamofire

open class OctoConnector : NSObject, Callable {
    open var adapter: Adapter {
        get {
            return OctoAdapter()
        }
    }
    
    open var callsQueue: [Request] {
        get {
            return calls
        }
        set {
            calls = newValue
        }
    }
    
    var calls : [Request] = []
    
    required public override init() {
        super.init()
        setup()
    }
    
    lazy var storedDebugger : OctoDebugger = {
        let debugger = OctoDebugger()
        debugger.delegate = self
        debugger.mode = self.adapter.logLevel
        return debugger
    }()
    
    public var debugger: OctoDebugger? {
        return storedDebugger
    }
}

extension OctoConnector : DebuggerDelegate {
    public func logEventOccured(logString: String) {
        //stub, implementation of the delegate should be in subclasses
    }
}
