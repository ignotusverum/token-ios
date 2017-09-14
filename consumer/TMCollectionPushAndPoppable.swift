//
//  TMCollectionPushAndPoppable.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Foundation
import UIKit

protocol TMCollectionPushAndPoppable {
    var sourceCell: UICollectionViewCell? { get }
    var collectionView: UICollectionView { get }
    var view: UIView! { get }
}
