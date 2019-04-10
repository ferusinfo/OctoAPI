//
//  Encodable+ToDictionary.swift
//  OctoAPI
//
//  Created by Maciej Kołek on 4/10/19.
//

import Foundation

extension Encodable {
    public func toDictionary() -> [String: Any] {
        return try! JSONSerialization.jsonObject(with: JSONEncoder().encode(self), options: []) as! [String: Any]
    }
}
