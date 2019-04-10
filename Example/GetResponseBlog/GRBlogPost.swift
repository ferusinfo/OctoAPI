//
//  GRBlogPost.swift
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

enum DateFormat: String {
    case pubDate = "EEEE, dd MMM yyyy"
    case grCreationDate = "YYYY-MM-dd'T'HH:mm:ss"
}

class GRBlogPost : NSObject, Decodable {
    //MARK: - Properties
    let identifier : Int
    let link : String
    var imageURL : String?
    fileprivate let creationDate: String
    fileprivate let title : String
    fileprivate let content : String
    
    lazy var pubDate : String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.grCreationDate.rawValue
        let createdOn = dateFormatter.date(from: creationDate)!
        dateFormatter.dateFormat = DateFormat.pubDate.rawValue
        return dateFormatter.string(from: createdOn)
    }()
    
    var headline : String? {
        get {
            let strippedHtml = content.stripHTML()
            let subIndex = strippedHtml.index(content.startIndex, offsetBy: 349)
            let subcontent = String(strippedHtml[..<subIndex]) + "..."
            let separated = content.components(separatedBy: "<!--more-->")
            if let beforeMore = separated.first, beforeMore.count <= 349 {
                return beforeMore.stripHTML()
            }
            return subcontent
        }
    }
    
    var clearTitle : String {
        get {
            return self.title.stripHTML()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case link
        case title
        case content
        case rendered
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(Int.self, forKey: .id)
        link = try values.decode(String.self, forKey: .link)
        creationDate = try values.decode(String.self, forKey: .date)
        
        let titleContainer = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .title)
        title = try titleContainer.decode(String.self, forKey: .rendered)
        
        let contentContainer = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .content)
        content = try contentContainer.decode(String.self, forKey: .rendered)
    }
}
