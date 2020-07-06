//
//  SourceTableViewCell.swift
//  GoodNews_NoStoryBoard
//
//  Created by trungnghia on 7/3/20.
//  Copyright © 2020 trungnghia. All rights reserved.
//

import UIKit

class SourceTableViewCell: UITableViewCell {

    //MARK: - Properties
    static let reuseIdentifier = String(describing: SourceTableViewCell.self)
    var articleSourceVM: ArticleSourceViewModel? {
        didSet { configure() }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, urlLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        
        addSubview(stack)
        stack.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor,
                     bottom: bottomAnchor, right: safeAreaLayoutGuide.rightAnchor,
                     paddingTop: 8, paddingLeft: 20, paddingBottom: 8, paddingRight: 20)
        
        addSubview(idLabel)
        idLabel.centerY(inView: nameLabel, leftAnchor: nameLabel.rightAnchor, paddingLeft: 10)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Helpers
    private func configure() {
        guard let articleSourceVM = articleSourceVM else { return }
        nameLabel.text = articleSourceVM.name
        descriptionLabel.text = articleSourceVM.description
        urlLabel.text = articleSourceVM.url
        idLabel.text = "[\(articleSourceVM.id)]"
    }

}
