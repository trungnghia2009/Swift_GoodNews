//
//  ArticleViewModel.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct ArticleListViewModel {
    let articles: [Article]
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return articles.count
    }
    
    func articleAtIndex(_ index: Int) -> ArticleViewModel {
        let article = articles[index]
        return ArticleViewModel(article)
    }
    
}

struct ArticleViewModel {
    private let article: Article
    var order: Int?
    
    init(_ article: Article) {
        self.article = article
    }
    
    
    var title: String {
        return article.title ?? "No Title"
    }
    
    var description: String {
        return article.description ?? "No Description"
    }
    
    var url: String {
        return article.url
    }
    
    var author: String {
        if article.author == "" {
            return "Unknown"
        }
        return article.author ?? "Unknown"
    }
    
    var urlToImage: String? {
        if article.urlToImage == "null" {
            return nil
        }
        return article.urlToImage
    }
    
    var publishedAt: String {
        return article.publishedAt
    }
    
    var content: String {
        return article.content ?? "No Content"
    }
    
    var sourceName: String {
        return article.source.name
    }
}
