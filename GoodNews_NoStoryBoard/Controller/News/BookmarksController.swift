//
//  BookmarksController.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/6/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class BookmarksController: UITableViewController {

    //MARK: - Properties
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
    }
    
    
    //MARK: - Helpers
    private func configureNavigationBar() {
        navigationItem.title = "Bookmarks"
    }
    
    //MARK: - Selectors
    private func configureTableView() {
        
    }
}

//MARK: - UITableViewDataSource
extension BookmarksController {
    
}


//MARK: - UITableViewDelegate
extension BookmarksController {
    
}
