//
//  GetResponseBlogExample.swift
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

class GetResponseBlogExample : BaseExample {
    override func run() {
        let request = OctoRequest(endpoint: "posts")
        request.paging = GetResponseBlogPaging(offset: 1, limit: 10)
        
        GetResponseBlogConnector.sharedInstance.run(request: request) { (error, data, paging) in
            if error == nil {
                if let blogPosts = GlossDataParser.parse(collection: data, withType: GRBlogPost.self), let post = blogPosts.first {
                    self.delegate?.exampleDidEndRunning(result: post.clearTitle)
                }
            } else {
                self.delegate?.exampleDidEndRunning(result: error!.localizedDescription)
            }
        }
        
    }
}
