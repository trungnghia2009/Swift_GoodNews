//
//  ArticleStorage.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/8/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct ArticleStorage: Codable {
    var title: String?
    var description: String?
    var author: String?
    let publishedAt: String
    var sourceName: String?
    var imageData: Data?
    let url: String
    
    let createdDate: Date
    var isFavorite: Bool = false
    
    
    
}
