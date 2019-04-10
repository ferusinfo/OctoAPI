//
//  DecodableDataParser.swift
//  OctoAPI
//
//  Created by Maciej Kołek on 4/10/19.
//

import Foundation

public class DecodableParser {
    public static func decode<T: Decodable>(data: Any, type: T.Type, decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = decodingStrategy
        return try decoder.decode(T.self, from: jsonData)
    }
}

