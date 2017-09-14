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
import Gloss

class GRBlogPost : NSObject, Gloss.Decodable {
    //MARK: - Properties
    let identifier : Int
    let link : String
    var imageURL : String?
    fileprivate let date : Date
    fileprivate let title : String
    fileprivate let content : String
    fileprivate let dateFormatter: DateFormatter
    fileprivate let PubDateFormat = "EEEE, dd MMM yyyy"
    fileprivate let TimezonedDateFormat = "YYYY-MM-dd'T'HH:mm:ss"
    
    var pubDate : String {
        get {
            self.dateFormatter.dateFormat = PubDateFormat
            return self.dateFormatter.string(from: self.date)
        }
    }
    
    var headline : String? {
        get {
            let subcontent = content.stripHTML().substring(to: content.characters.index(content.startIndex, offsetBy: 349)) + "..."
            let separated = content.components(separatedBy: "<!--more-->")
            if var beforeMore = separated.first, beforeMore.characters.count <= 349 {
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
    
    //MARK: - Keys
    fileprivate let IdKey = "id"
    fileprivate let DateKey = "date"
    fileprivate let LinkKey = "link"
    fileprivate let TitleKey = "title.rendered"
    fileprivate let ContentKey = "content.rendered"
    
    //MARK: - Deserialization
    required init?(json: JSON) {
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = TimezonedDateFormat
        
        guard let identifier : Int = IdKey <~~ json
            else { return nil }
        guard let date : Date = Decoder.decode(dateForKey: DateKey, dateFormatter: self.dateFormatter)(json)
            else { return nil }
        guard let link : String = LinkKey <~~ json
            else { return nil }
        guard let title : String = TitleKey <~~ json
            else { return nil }
        guard let content : String = ContentKey <~~ json
            else { return nil }
        
        self.identifier = identifier
        self.date = date
        self.link = link
        self.title = title
        self.content = content
    }
}
