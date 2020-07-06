//
//  UISimpleSlidingTabController.swift
//  SlidingTabExample
//
//  Created by Suprianto Djamalu on 03/08/19.
//  Copyright © 2019 Suprianto Djamalu. All rights reserved.
//

import UIKit

class UISimpleSlidingTabController: UIViewController {
    
    private let collectionHeader = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    private let collectionPage = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
    private let collectionHeaderIdentifier = "COLLECTION_HEADER_IDENTIFIER"
    private let collectionPageIdentifier = "COLLECTION_PAGE_IDENTIFIER"
    private var items = [UIViewController]()
    private var titles = [String]()
    private var colorHeaderActive = UIColor.blue
    private var colorHeaderInActive = UIColor.gray
    private var colorHeaderBackground = UIColor.white
    private var currentPosition = 0
    private let heightHeader: CGFloat = 40
    
    private let headerUnderlineView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        return view
    }()
    
    func addItem(item: UIViewController, title: String){
        items.append(item)
        titles.append(title)
    }
    
    func setHeaderBackgroundColor(color: UIColor){
        colorHeaderBackground = color
    }
    
    func setHeaderActiveColor(color: UIColor){
        colorHeaderActive = color
    }
    
    func setHeaderInActiveColor(color: UIColor){
        colorHeaderInActive = color
    }
    
    func setCurrentPosition(position: Int){
        currentPosition = position
        let path = IndexPath(item: currentPosition, section: 0)
        
        // Scroll Header
        DispatchQueue.main.async {
            self.collectionHeader.reloadData()
        }
        
        // Scroll Page
        DispatchQueue.main.async {
           self.collectionPage.scrollToItem(at: path, at: .centeredHorizontally, animated: true)
        }
    }
    
    func getCurrentPosition() -> Int {
        return currentPosition
    }
    
    func build(){

        // collectionHeader
        view.addSubview(collectionHeader)
        collectionHeader.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        collectionHeader.setHeight(height: heightHeader)
        (collectionHeader.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        collectionHeader.showsHorizontalScrollIndicator = false
        collectionHeader.backgroundColor = colorHeaderBackground
        collectionHeader.register(HeaderCell.self, forCellWithReuseIdentifier: collectionHeaderIdentifier)
        collectionHeader.delegate = self
        collectionHeader.dataSource = self
        
        // underlineView
        view.addSubview(underlineView)
        underlineView.anchor(left: collectionHeader.leftAnchor, bottom: collectionHeader.bottomAnchor)
        underlineView.setDimensions(height: 1.5, width: view.frame.width)
        underlineView.backgroundColor = .tertiaryLabel
        
        // headerUnderlineView
        view.addSubview(headerUnderlineView)
        headerUnderlineView.anchor(left: collectionHeader.leftAnchor, bottom: collectionHeader.bottomAnchor)
        headerUnderlineView.setHeight(height: 3)
        headerUnderlineView.setWidth(width:  view.frame.width / CGFloat(items.count))
        headerUnderlineView.backgroundColor = colorHeaderActive
        DispatchQueue.main.async {
            let xPosition = self.view.frame.width - (self.view.frame.width / CGFloat(self.currentPosition + 1))
            self.headerUnderlineView.frame.origin.x = xPosition
        }
        collectionHeader.reloadData()
        
        // collectionPage
        view.addSubview(collectionPage)
        collectionPage.anchor(top: collectionHeader.bottomAnchor, left: view.leftAnchor,
                              bottom: view.bottomAnchor, right: view.rightAnchor)
        collectionPage.backgroundColor = .white
        collectionPage.showsHorizontalScrollIndicator = false
        (collectionPage.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        collectionPage.isPagingEnabled = true
        collectionPage.register(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionPageIdentifier)
        collectionPage.delegate = self
        collectionPage.dataSource = self
        collectionPage.reloadData()
    }
    
}

//MARK: - UICollectionViewDelegate
extension UISimpleSlidingTabController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setCurrentPosition(position: indexPath.row)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionPage {
            let currentIndex = Int(self.collectionPage.contentOffset.x / collectionPage.frame.size.width)
            setCurrentPosition(position: currentIndex)
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = self.collectionPage.contentOffset.x / collectionPage.frame.size.width
        
        if currentIndex >= 0 && currentIndex <= CGFloat(items.count - 1)  {
            headerUnderlineView.frame.origin.x = (currentIndex * view.frame.width) / CGFloat((items.count))
//            currentPosition = Int(currentIndex.rounded())
//            collectionHeader.reloadData()
        }
        
    }
    
}

//MARK: - UICollectionViewDataSource
extension UISimpleSlidingTabController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionHeader {
            return titles.count
        }
        
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionHeader {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionHeaderIdentifier, for: indexPath) as! HeaderCell
            cell.text = titles[indexPath.row]
            
            var didSelect = false
            
            if currentPosition == indexPath.row {
                didSelect = true
            }
            
            cell.select(didSelect: didSelect, activeColor: colorHeaderActive, inActiveColor: colorHeaderInActive)
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionPageIdentifier, for: indexPath)
        let vc = items[indexPath.row]
        
        cell.addSubview(vc.view)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.topAnchor.constraint(equalTo: cell.topAnchor, constant: 28).isActive = true
        vc.view.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        return cell
    }
}
//MARK: - UICollectionViewDelegateFlowLayout
extension UISimpleSlidingTabController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionHeader {
            let spacer = CGFloat(titles.count)
            return CGSize(width: view.frame.width / spacer, height: CGFloat(heightHeader))
        }
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
