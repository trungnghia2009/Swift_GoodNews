//
//  WebService.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

//private let urlTopHeadlines = "https://newsapi.org/v2/top-headlines?country=us&apiKey=e12760add60345c49742e5d7dc550779"
private let urlTopHeadlines = "https://newsapi.org/v2/top-headlines?apiKey=e12760add60345c49742e5d7dc550779&sortBy=publishedAt&sources="
private let urlEverything = "https://newsapi.org/v2/everything?apiKey=e12760add60345c49742e5d7dc550779&q="
private let urlSource = "https://newsapi.org/v2/sources?apiKey=e12760add60345c49742e5d7dc550779"

enum SourceType: CustomStringConvertible {
    var description: String {
        switch self {
            
        case .topHeadlines:
            return urlTopHeadlines
        case .everything:
            return urlEverything
        case .source:
            return urlSource
        }
    }
    
    case topHeadlines
    case everything
    case source
}

enum ErrorList: Error {
    case urlError
    case unknownError
}

struct WebService {
    
    static let shared = WebService()
    
    private init() {}
    
    func fetchData<T: Decodable>(fromSource source: SourceType,
                                 withArticleId articleId: String? = nil,
                                 withSearchKey searchKey: String? = nil,
                                 expectingReturnType: T.Type,
                                 completion: @escaping ((Result<T, Error>) -> Void )){
        var sourceQuery: String
        
        
        switch source {
            
        case .topHeadlines:
            // If articleId = all
            if let articleId = articleId,
                articleId == "all" {
                sourceQuery = source.description.components(separatedBy: "sources=")[0] + "country=us"
                break
            }
            
            sourceQuery = articleId != nil ?
                (source.description + articleId!) :
                (source.description.components(separatedBy: "sources=")[0] + "country=us")
        
        case .everything:
            sourceQuery = searchKey != nil ?
                (source.description + searchKey!) :
                (source.description + "vietnam")
        case .source:
            sourceQuery = source.description
        }
        
        guard let url = URL(string: sourceQuery) else {
            completion(.failure(ErrorList.urlError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
        
        }
        
        task.resume()
    }
    
}
