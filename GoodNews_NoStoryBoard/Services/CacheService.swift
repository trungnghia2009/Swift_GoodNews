//
//  CacheService.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct CacheService {
    
    static let shared = CacheService()
    
    private init() {}
    
    let imageCache = NSCache<NSString, AnyObject>()
    
}
