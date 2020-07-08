//
//  SlideController.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/3/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit
import SafariServices
import MaterialComponents.MaterialSnackbar

class SlideController: UISimpleSlidingTabController {
    
    //MARK: - Properties
    let firstItem = ArticlesController(source: .topHeadlines)
    let secondItem = ArticlesController(source: .everything)
    var sources = [ArticleSource]()
    var sourceFilter = [ArticleSource(id: "all", name: "All", description: "", url: "")]
    
    private let bookmarksButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setDimensions(height: 50, width: 50)
        button.layer.cornerRadius = 25
        button.addShadow()
        button.addTarget(self, action: #selector(handleBookmarksTapped), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchSources()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        build()
        view.addSubview(bookmarksButton)
        bookmarksButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor,
                             paddingBottom: 60, paddingRight: 20)
        
        print("Subview...")
    }
    
    
    //MARK: - API
    private func fetchSources() {
        WebService.shared.fetchData(fromSource: .source, expectingReturnType: ActicleSourceList.self) { [weak self] (result) in
            switch result {
                
            case .success(let articleSources):
                self?.sources = articleSources.sources
                self?.sourceFilter += articleSources.sources
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    //MARK: - Helpers
    private func setupUI() {
        view.backgroundColor = .white
        firstItem.delegate = self
        secondItem.delegate = self
        
        // Navigation
        navigationItem.title = "News"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "globe"), style: .plain, target: self, action: #selector(handleLeftBarTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sources", style: .plain, target: self, action: #selector(handleRightBarTapped))
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // SlideTap
        addItem(item: firstItem, title: "Top Headlines")
        addItem(item: secondItem, title: "Everything")
        setHeaderActiveColor(color: .label)
        setHeaderInActiveColor(color: .secondaryLabel)
        setHeaderBackgroundColor(color: .systemBackground)
        setCurrentPosition(position: 0)
    }
    
    private func showSnackBarMessage() {
        let message = MDCSnackbarMessage()
        message.text = "Added the article to Bookmark"
        
        let action = MDCSnackbarMessageAction()
        action.title = "OK"
        message.action = action
        MDCSnackbarManager.show(message)
    }
    
    
    //MARK: - Selectors
    @objc private func handleBookmarksTapped() {
        let controller = BookmarksController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func handleRightBarTapped() {
        let controller = SourceController(sources: sources)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func handleLeftBarTapped() {
        switch getCurrentPosition() {
        case 0:
            print("Show genres 0")
            let controller = GenresController(sources: sourceFilter)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            present(nav, animated: true, completion: nil)
        default:
            print("Show genres 1")
            var textField = UITextField()
            let alert = UIAlertController(title: "", message: "Please enter keyword", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "CANCEL", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.secondItem.searchKey = textField.text
                self.secondItem.fetchArticles()
            }))
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Search..."
                textField = alertTextField
            }
            
            present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - ArticlesControllerDelegate
extension SlideController: ArticlesControllerDelegate {
    func actionButtonDidSelect(url: String) {
        didSelectActionButton({ [weak self] (_) in
            print("Add to bookmarks...")
            self?.showSnackBarMessage()
            
        }) { (_) in
            print("Share via...")
            UIApplication.share(url)
        }
    }
    
    
    func navigateToArticleDetail(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }
    
}

//MARK: - GenresControllerDelegate
extension SlideController: GenresControllerDelegate {
    func articleDidSelect(_ id: String) {
        print("Debug: \(id)")
        //CacheService.shared.imageCache.removeAllObjects()
        firstItem.articleId = id
        firstItem.fetchArticles()
    }
    
    
}
