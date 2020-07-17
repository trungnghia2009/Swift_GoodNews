//
//  BookmarksController.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/6/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import SafariServices

class BookmarksController: UITableViewController {

    //MARK: - Properties
    private let dataFilePath = SingletonConstant.shared.dataFilePath
    private var articles = [ArticleStorage]()
    
    
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
    
    //MARK: - Selectors
    private func configureTableView() {
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }
}

//MARK: - UITableViewDataSource
extension BookmarksController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.reuseIdentifier, for: indexPath) as! ArticleTableViewCell
        let article = articles[indexPath.row]
        cell.configureBookmarkCell(article: article)
        return cell
    }
}


//MARK: - UITableViewDelegate
extension BookmarksController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle = articles[indexPath.row]
        guard let url = URL(string: selectedArticle.url) else { return }
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            articles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    
}
