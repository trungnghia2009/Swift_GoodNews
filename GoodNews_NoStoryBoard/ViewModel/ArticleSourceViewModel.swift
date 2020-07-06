//
//  SourceViewModel.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/3/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct ArticleSourceListViewModel {
    let sources: [ArticleSource]
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return sources.count
    }
    
    func articleAtIndex(_ index: Int) -> ArticleSourceViewModel {
        let article = sources[index]
        return ArticleSourceViewModel(article)
    }
    
}

struct ArticleSourceViewModel {
    private let articleSource: ArticleSource
    
    init(_ articleSource: ArticleSource) {
        self.articleSource = articleSource
    }
    
    var id: String {
        return articleSource.id
    }
    
    var name: String {
        return articleSource.name
    }
    
    var description: String {
        return articleSource.description
    }
    
    var url: String {
        return articleSource.url
    }
}
