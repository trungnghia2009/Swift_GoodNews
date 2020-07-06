//
//  HeaderCell.swift
//  SlidingTabExample
//
//  Created by trungnghia on 6/24/20.
//  Copyright © 2020 Suprianto Djamalu. All rights reserved.
//

import UIKit

class HeaderCell: UICollectionViewCell {
    
    private let label = UILabel()
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select(didSelect: Bool, activeColor: UIColor, inActiveColor: UIColor){
        if didSelect {
            label.textColor = activeColor
        } else {
            label.textColor = inActiveColor
        }
    }
    
    private func setupUI(){
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.font = UIFont.boldSystemFont(ofSize: 18)

    }
    
}

