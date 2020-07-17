//
//  CacheService.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import Foundation

struct SingletonConstant {
    
    static let shared = SingletonConstant()
    
    private init() {}
    
    let imageCache = NSCache<NSString, AnyObject>()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Articles.plist")
    
}
