//
//  SourceController.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/3/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import SafariServices

class SourceController: UITableViewController {

    //MARK: - Properties
    var sources: [ArticleSource]
    private var articleSourceListVM: ArticleSourceListViewModel! {
        return ArticleSourceListViewModel(sources: sources)
    }
    
    //MARK: - Lifecycle
    init(sources: [ArticleSource]) {
        self.sources = sources
        super.init(style: .plain)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        
    }
    
    
    //MARK: - Helpers
    private func configureNavigationBar() {
        navigationItem.title = "Sources"
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(SourceTableViewCell.self, forCellReuseIdentifier: SourceTableViewCell.reuseIdentifier)
    }
    
    //MARK: - Selectors
    

}

//MARK: - UITableViewDataSource
extension SourceController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return articleSourceListVM == nil ? 0 : articleSourceListVM.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleSourceListVM == nil ? 0 : articleSourceListVM.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SourceTableViewCell.reuseIdentifier, for: indexPath) as! SourceTableViewCell
        cell.articleSourceVM = articleSourceListVM.articleAtIndex(indexPath.row)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SourceController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSource = articleSourceListVM.articleAtIndex(indexPath.row)
        guard let url = URL(string: selectedSource.url) else { return }
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }
}
