//
//  ArticleTableViewCell.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol ArticleTableViewCellDelegate: class {
    func actionButtonDidSelect(cell: ArticleTableViewCell)
    func favoriteButtonDidSelect(cell: ArticleTableViewCell)
}

class ArticleTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    static let reuseIdentifier = String(describing: ArticleTableViewCell.self)
    weak var delegate: ArticleTableViewCellDelegate?
    let imageCache = SingletonConstant.shared.imageCache
    var articleVM: ArticleViewModel? {
        didSet { configure() }
    }
    
    var articleStorage: ArticleStorage? {
        didSet {configureArticelStorageCell() }
    }
    
    lazy var isFavorite: Bool = {
        guard let articleStorage = articleStorage else { return false}
        return articleStorage.isFavorite
    }()
    
    private let orderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    let articleImage: UIImageView = {
        let iv = UIImageView()
        iv.setDimensions(height: 85, width: 150)
        iv.backgroundColor = .darkGray
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        iv.layer.borderColor = UIColor.label.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    private let sourceLabel: UILabel = {
       let label = UILabel()
       label.font = UIFont.boldSystemFont(ofSize: 14)
       label.textColor = .label
       return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -60, bottom: 0, right: 0)
        button.tintColor = .label
        button.setDimensions(height: 18, width: 80)
        button.addTarget(self, action: #selector(handleBookmarkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -60, bottom: 0, right: 0)
        button.setDimensions(height: 20, width: 80)
        button.isHidden = true
        button.addTarget(self, action: #selector(handleFavoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Image and info stack
        let infoStack = UIStackView(arrangedSubviews: [sourceLabel, authorLabel, dateLabel, favoriteButton])
        infoStack.spacing = 8
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        
        let imageInfoStack = UIStackView(arrangedSubviews: [articleImage, infoStack])
        imageInfoStack.spacing = 8
        imageInfoStack.axis = .horizontal
        imageInfoStack.alignment = .center
        
        // Action stack
        let actionStack = UIStackView(arrangedSubviews: [orderLabel, actionButton])
        actionStack.spacing = 8
        actionStack.alignment = .leading
        
        // Main stack
        let stack = UIStackView(arrangedSubviews: [actionStack, titleLabel, imageInfoStack, descriptionLabel])
        stack.alignment = .leading
        stack.spacing = 8
        stack.axis = .vertical
        
        addSubview(stack)
        stack.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor,
                     bottom: bottomAnchor, right: safeAreaLayoutGuide.rightAnchor,
                     paddingTop: 8, paddingLeft: 20, paddingBottom: 8, paddingRight: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Selector
    @objc private func handleBookmarkButtonTapped() {
        delegate?.actionButtonDidSelect(cell: self)
    }
    
    @objc private func handleFavoriteButtonTapped() {
        isFavorite.toggle()
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        delegate?.favoriteButtonDidSelect(cell: self)
    }
    
    
    //MARK: - Helpers
    private func configureArticleImage(url: String?) {
        if let imageString = url,
            let url = URL(string: imageString) {

            if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
                //print("Caching...")
                DispatchQueue.main.async {
                    self.articleImage.image = cachedImage
                }

            } else {
                //print("First load")
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in

                    guard let self = self,
                        let data = data,
                        let imageData = UIImage(data: data)?.jpegData(compressionQuality: 0.3)
                        else {
                            return
                    }
                    
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)?.resizeWithWidth(width: 300)
                        self.articleImage.image = image
                        self.imageCache.setObject(image!, forKey: url.absoluteString as NSString)

                    }
                }.resume()

            }
        } else {
            articleImage.image = #imageLiteral(resourceName: "placeholder")
        }
    }
    
    private func configure() {
        guard let articleVM = articleVM else { return }
        if let order = articleVM.order {
            orderLabel.text = "#\(order)"
        }
        titleLabel.text = articleVM.title
        descriptionLabel.text = articleVM.description
        authorLabel.text = articleVM.author
        dateLabel.text = articleVM.publishedAt
        sourceLabel.text = articleVM.sourceName
        configureArticleImage(url: articleVM.urlToImage)
    }
    
    func configureArticelStorageCell() {
        guard let article = articleStorage else { return }
        actionButton.isHidden = true
        favoriteButton.isHidden = false
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        authorLabel.text = article.author
        dateLabel.text = article.publishedAt
        sourceLabel.text = article.sourceName
        
        
        if article.isFavorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        if let data = article.imageData {
            articleImage.image = UIImage(data: data)
        } else {
            articleImage.image = #imageLiteral(resourceName: "placeholder")
        }
        
    }
    
}
