//
//  BookmarksController.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/6/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import SafariServices

protocol BookmarksControllerDelegate: class {
    func favoriteDidSelect(cell: ArticleTableViewCell)
}

class BookmarksController: UITableViewController {

    //MARK: - Properties
    weak var delegate: BookmarksControllerDelegate?
    private let dataFilePath = SingletonConstant.shared.dataFilePath
    private var articles = [ArticleStorage]()
    private var filteredArticles = [ArticleStorage]()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        loadData()
    }
    
    
    //MARK: - Helpers
    private func configureNavigationBar() {
        navigationItem.title = "Bookmarks"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(handleRightBarTapped))
    }
    
    private func configureTableView() {
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    private func saveData() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(articles)
            try data.write(to: dataFilePath!)
            tableView.reloadData()
        } catch {
            print("Error encoding item array, \(error.localizedDescription)")
        }
    }
    
    private func loadData() {
        do {
            if let data = try? Data(contentsOf: dataFilePath!) {
                let decoder = PropertyListDecoder()
                articles = try decoder.decode([ArticleStorage].self, from: data)
                articles = articles.sorted{ $0.createdDate > $1.createdDate }
                tableView.reloadData()
            }
        } catch {
            print("Error encoding item array, \(error.localizedDescription)")
        }
    }
    
    private func navigateToWebView(url: String){
        guard let url = URL(string: url) else { return }
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }
    
    
    //MARK: - Selectors
    @objc private func handleRightBarTapped() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(handleRightBarTapped1))
        articles = articles.filter{ return $0.isFavorite == true }
        tableView.reloadData()
    }
    
    @objc private func handleRightBarTapped1() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(handleRightBarTapped))
        loadData()
    }
}

//MARK: - UITableViewDataSource
extension BookmarksController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if articles.count == 0 {
            tableView.setEmptyMessage("There is no bookmark right now \nPlease come back to check later!")
        } else {
            tableView.restore()
        }
        
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.reuseIdentifier, for: indexPath) as! ArticleTableViewCell
        cell.delegate = self
        let article = articles[indexPath.row]
        cell.articleStorage = article
        return cell
    }
}


//MARK: - UITableViewDelegate
extension BookmarksController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle = articles[indexPath.row]
        navigateToWebView(url: selectedArticle.url)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            articles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let contextMenu = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [unowned self] (actions) -> UIMenu? in
            let selectedArticle = self.articles[indexPath.row]
            
            let goWebViewAction = UIAction(title: "View this content", image: UIImage(systemName: "paperplane")) { (_) in
                self.navigateToWebView(url: selectedArticle.url)
            }
            
            let deleteAction = UIAction(title: "Remove", image: UIImage(systemName: "trash"), attributes: .destructive) { (_) in
                self.articles.remove(at: indexPath.row)
                self.saveData()
            }
            return UIMenu.init(title: "Menu", options: .destructive, children: [goWebViewAction, deleteAction])
        }
        return contextMenu
    }
    
    
}

// MARK: - ArticleTableViewCellDelegate
extension BookmarksController: ArticleTableViewCellDelegate {
    
    func actionButtonDidSelect(cell: ArticleTableViewCell) {
    }
    
    func favoriteButtonDidSelect(cell: ArticleTableViewCell) {
        
        // Update current articles
        for (index, article) in articles.enumerated() {
            if article.publishedAt == cell.articleStorage?.publishedAt {
                articles[index].isFavorite = cell.isFavorite
            }
        }
        delegate?.favoriteDidSelect(cell: cell)
    }
    
    
}
