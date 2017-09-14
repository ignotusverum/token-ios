//
//  TMProgressViewProtocol.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/9/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import Foundation

protocol TMProgressViewProtocol {
    
    func numberOfItems(_ progressView: TMProgressView)-> Int
    func itemForRow(_ progressView: TMProgressView, row: Int)-> UICollectionViewCell
    
    var dataSource: [TMStatusData] { get set }
    var collectionView: UICollectionView { get set }
}

extension TMProgressViewProtocol: UICollectionViewDataSource {
    
    // MARK: - Private
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return itemForRow(self, row: indexPath.row)
    }
}

extension TMProgressViewProtocol: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // left 65 + 9(circle width)
        let cellW = collectionView.frame.size.width - 65.0 - 9.0
        
        // title + separator
        let descriptionHeight
        let cellH: CGFloat = 200.0
        
        return CGSize(width: cellW, height: cellH)
    }
}
