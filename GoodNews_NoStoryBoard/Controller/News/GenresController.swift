//
//  GenresController.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/5/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GenreCell"

protocol GenresControllerDelegate: class {
    func articleDidSelect(_ id: String)
}

class GenresController: UITableViewController {

    //MARK: - Properties
    weak var delegate: GenresControllerDelegate?
    var sources: [ArticleSource]
    
    private var isSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController()
    
    private var filteredSources = [ArticleSource]()
    
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
        configureSearchController()
    }
    
    
    //MARK: - Helpers
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Genres"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleLeftBarTapped))
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    
    //MARK: - Selectors
    @objc private func handleLeftBarTapped() {
        dismiss(animated: true, completion: nil)
    }

}

//MARK: - UITableViewDataSource
extension GenresController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? filteredSources.count : sources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let articleSource = isSearchMode ? filteredSources[indexPath.row] : sources[indexPath.row]
        cell.textLabel?.text = articleSource.name
        return cell
    }
}

//MARK: - UITableViewDelegate
extension GenresController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let articleSource = isSearchMode ? filteredSources[indexPath.row] : sources[indexPath.row]
        delegate?.articleDidSelect(articleSource.id)
        dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension GenresController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filteredSources = sources.filter({ $0.name.localizedCaseInsensitiveContains(searchText) })
        tableView.reloadData()
    }
    
    
}

