//
//  ArticleTableViewCell.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/1/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

protocol ArticleTableViewCellDelegate: class {
    func actionButtonDidSelect(url: String)
}

class ArticleTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    weak var delegate: ArticleTableViewCellDelegate?
    static let reuseIdentifier = String(describing: ArticleTableViewCell.self)
    let imageCache = CacheService.shared.imageCache
    var articleVM: ArticleViewModel? {
        didSet { configure() }
    }
    
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
        button.setDimensions(height: 20, width: 80)
        button.addTarget(self, action: #selector(handleBookmarkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let infoStack = UIStackView(arrangedSubviews: [sourceLabel, authorLabel, dateLabel, actionButton])
        infoStack.spacing = 8
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        
        let imageInfoStack = UIStackView(arrangedSubviews: [articleImage, infoStack])
        imageInfoStack.spacing = 8
        imageInfoStack.axis = .horizontal
        imageInfoStack.alignment = .center
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, imageInfoStack, descriptionLabel])
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
        guard let articleVM = articleVM else { return }
        delegate?.actionButtonDidSelect(url: articleVM.url)
    }
    
    //MARK: - Helpers
    private func configure() {
        guard let articleVM = articleVM else { return }
        titleLabel.text = articleVM.title
        descriptionLabel.text = articleVM.description
        authorLabel.text = articleVM.author
        dateLabel.text = articleVM.publishedAt
        sourceLabel.text = articleVM.sourceName
        
        if let imageString = articleVM.urlToImage,
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
                        let image = UIImage(data: imageData)
                        self.articleImage.image = image
                        self.imageCache.setObject(image!, forKey: url.absoluteString as NSString)

                    }
                }.resume()

            }
        } else {
            print("Debug: ABC")
            articleImage.image = #imageLiteral(resourceName: "placeholder")
        }
        
    }
    
}
