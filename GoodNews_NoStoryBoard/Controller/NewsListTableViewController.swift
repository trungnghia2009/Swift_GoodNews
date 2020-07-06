//
//  NewsListTableViewController.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import SafariServices

class TopHeadlinesController: UITableViewController {
    
    //MARK: - Properties
    private var articleListVM: ArticleListViewModel!
    private var refreshController = UIRefreshControl()
    
    private let goToTopButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = #colorLiteral(red: 0.1628837585, green: 0.1629138589, blue: 0.1866516471, alpha: 1)
        button.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        button.addShadow()
        button.addTarget(self, action: #selector(handleGoToTop), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(goToTopButton)
        goToTopButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor,
                             paddingBottom: 20, paddingRight: 20)
        goToTopButton.setDimensions(height: 56, width: 56)
        goToTopButton.layer.cornerRadius = 28
        
        configureNavigationBar()
        fetchArticles()
        configureTableView()
    }

    
    //MARK: - APIs
    private func fetchArticles() {
        tableView.refreshControl?.beginRefreshing()
        WebService.shared.fetchTopHeadlines { (result) in
            switch result {
                
            case .success(let articles):
                self.articleListVM = ArticleListViewModel(articles: articles)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                    print("Refreshing...")
                }
            case .failure(let error):
                print("Error fetching articles, ", error.localizedDescription)
            }
        }
    }
    
    //MARK: - Helpers
    private func configureNavigationBar() {
        navigationItem.title = "GoodNews"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: nil)
    }
    
    private func configureTableView() {
        tableView.estimatedRowHeight = 80
        tableView.rowHeight =  UITableView.automaticDimension
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseIdentifier)
        
        refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshController.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshController
    }
    
    
    //MARK: - Selectors
    @objc private func handleRefresh() {
        fetchArticles()
    }
    
    @objc private func handleGoToTop() {
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }

}

//MARK: - UITableViewDataSource
extension TopHeadlinesController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return articleListVM == nil ? 0 : articleListVM.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleListVM == nil ? 0 : articleListVM.numberOfRowsInSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.reuseIdentifier, for: indexPath) as! ArticleTableViewCell
        let articleVM = articleListVM.articleAtIndex(indexPath.row)
        cell.articleVM = articleVM
        return cell
    }
}

//MARK: - UITableViewDelegate
extension TopHeadlinesController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle = articleListVM.articles[indexPath.row]
        print("url: \(selectedArticle.url)")
        
        guard let url = URL(string: selectedArticle.url) else { return }
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }
}
