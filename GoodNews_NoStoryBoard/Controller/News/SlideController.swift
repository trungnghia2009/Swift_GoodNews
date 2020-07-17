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
    
    private let dataFilePath = SingletonConstant.shared.dataFilePath
    private let imageCache = SingletonConstant.shared.imageCache
    private var articleStorages = [ArticleStorage]()
    
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
        setRotation()
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
    
    private func saveData() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(articleStorages)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding item array, \(error.localizedDescription)")
        }
    }
    
    private func loadData() {
        do {
            if let data = try? Data(contentsOf: dataFilePath!) {
                let decoder = PropertyListDecoder()
                articleStorages = try decoder.decode([ArticleStorage].self, from: data)
            }
        } catch {
            print("Error encoding item array, \(error.localizedDescription)")
        }
    }
    
    private func showSnackBarMessage(text: String) {
        let message = MDCSnackbarMessage()
        message.text = text
        
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
    func actionButtonDidSelect(cell: ArticleTableViewCell) {
        guard let articleVM = cell.articleVM else { return }
        
        didSelectActionButton({ [weak self] (_) in
            guard let this = self else { return }
            
            var isNewArticle = true
            this.loadData()
            
            for article in this.articleStorages {
                if article.publishedAt == articleVM.publishedAt {
                    this.showSnackBarMessage(text: "This article was added to Bookmarks")
                    isNewArticle = false
                    break
                }
            }
            
            if isNewArticle {
                var imageData: Data?
                
                if let urlToImage = articleVM.urlToImage,
                    let cachedImage = this.imageCache.object(forKey: urlToImage as NSString) as? UIImage {
                    imageData = cachedImage.jpegData(compressionQuality: 0.3)
                }
                
                let articleStorage = ArticleStorage(title: articleVM.title,
                                                    description: articleVM.description,
                                                    author: articleVM.author,
                                                    publishedAt: articleVM.publishedAt,
                                                    sourceName: articleVM.sourceName,
                                                    imageData: imageData,
                                                    url: articleVM.url,
                                                    createdDate: Date())
                this.articleStorages.append(articleStorage)
                this.saveData()
                this.showSnackBarMessage(text: "Added the article to Bookmark")
            }
            
        }) { (_) in
            print("Share via...")
            UIApplication.share(articleVM.url)
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
        //CacheService.shared.imageCache.removeAllObjects()
        firstItem.articleId = id
        firstItem.fetchArticles()
    }
    
}
