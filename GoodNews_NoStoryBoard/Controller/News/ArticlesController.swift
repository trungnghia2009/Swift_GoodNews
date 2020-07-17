//
//  NewsListTableViewController.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import SafariServices

protocol ArticlesControllerDelegate: class {
    func navigateToArticleDetail(urlString: String)
    func actionButtonDidSelect(cell: ArticleTableViewCell)
}

class ArticlesController: UITableViewController {
    
    //MARK: - Properties
    weak var delegate: ArticlesControllerDelegate?
    let source: SourceType
    var articleId: String?
    var searchKey: String?
    private var articleListVM: ArticleListViewModel!
    private let refreshController = UIRefreshControl()
    
    //MARK: - Lifecycle
    init(source: SourceType) {
        self.source = source
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticles()
        configureTableView()
    }

    
    //MARK: - APIs
    func fetchArticles() {
        tableView.refreshControl?.beginRefreshing()
        WebService.shared.fetchData(fromSource: source, withArticleId: articleId, withSearchKey: searchKey, expectingReturnType: ArticleList.self) { [weak self] (result) in
            switch result {
                
            case .success(let articleList):
                let articles = articleList.articles.sorted { $0.publishedAt > $1.publishedAt }
                self?.articleListVM = ArticleListViewModel(articles: articles)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.refreshControl?.endRefreshing()
                }
            case .failure(let error):
                print("Error fetching articles, ", error.localizedDescription)
            }
        }
        
    }
    
    //MARK: - Helpers
    private func configureTableView() {
        tableView.estimatedRowHeight = 80
        tableView.rowHeight =  UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 80, right: 0)
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshController
    }
    
    
    //MARK: - Selectors
    @objc private func handleRefresh() {
        print("Pull to Refresh...")
        fetchArticles()
    }
    

}

//MARK: - UITableViewDataSource
extension ArticlesController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return articleListVM == nil ? 0 : articleListVM.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleListVM == nil ? 0 : articleListVM.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.reuseIdentifier, for: indexPath) as! ArticleTableViewCell
        cell.delegate = self
        cell.articleImage.image = nil
        let articleVM = articleListVM.articleAtIndex(indexPath.row)
        cell.articleVM = articleVM
        return cell
    }
    
    
}

//MARK: - UITableViewDelegate
extension ArticlesController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle = articleListVM.articles[indexPath.row]
        delegate?.navigateToArticleDetail(urlString: selectedArticle.url)
    }
}

//MARK: - ArticleTableViewCellDelegate
extension ArticlesController: ArticleTableViewCellDelegate {
    func actionButtonDidSelect(cell: ArticleTableViewCell) {
        delegate?.actionButtonDidSelect(cell: cell)
    }
    
    
    
}
