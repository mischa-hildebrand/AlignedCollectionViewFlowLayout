//
//  CollectionViewController.swift
//  AlignedCollectionViewFlowLayout
//
//  Created by Mischa Hildebrand on 04/15/2017.
//  Copyright (c) 2017 Mischa Hildebrand. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

private let reuseIdentifier = "blueCell"

class CollectionViewController: UICollectionViewController {
    
    let tags1 = ["When you", "eliminate", "the impossible,", "whatever remains,", "however improbable,", "must be", "the truth."]
    let tags2 = ["Of all the souls", "I have", "encountered", "in my travels,", "his", "was the most…", "human."]
    
    var dataSource: [[String]] = [[]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = [tags1, tags2]
        
        // Set up the flow layout's cell alignment:
        let flowLayout = collectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        flowLayout?.horizontalAlignment = .right
        
        // Enable automatic cell-sizing with Auto Layout:
        flowLayout?.estimatedItemSize = .init(width: 100, height: 40)
    }

    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        cell.label.text = dataSource[indexPath.section][indexPath.item]
        
        return cell
    }

}
