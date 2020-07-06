//
//  Source.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/3/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct ActicleSourceList: Decodable {
    let sources: [ArticleSource]
}

struct ArticleSource: Decodable {
    let id: String
    let name: String
    let description: String
    let url: String
}
