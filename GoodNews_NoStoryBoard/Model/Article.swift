//
//  Article.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct ArticleList: Decodable {
    let articles: [Article]
}

struct Article: Decodable {
    let source: Source
    var title: String?
    var description: String?
    let url: String
    
    var author: String?
    var urlToImage: String?
    let publishedAt: String
    var content: String?
}

struct Source: Decodable {
    let name: String
}


