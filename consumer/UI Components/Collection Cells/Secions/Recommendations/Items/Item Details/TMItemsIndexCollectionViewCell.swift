//
//  TMItemsIndexCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/6/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import Spruce
import CoreStore
import Foundation
import EZSwiftExtensions

protocol TMItemsIndexCollectionViewCellDelegate {
    func itemIndexControllerSelectedItem(_ item: TMItem?)
    func feedbackView(_ feedbackView: TMFeedbackContainerRatingView, ratedItem item: TMItem, feedback: TMFeedbackType)
}

class TMItemsIndexCollectionViewCell: UICollectionViewCell, ListSectionObserver {
    
    // Delegate
    var delegate: TMItemsIndexCollectionViewCellDelegate?
    
    // Collection View
    fileprivate lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0, right: 10.0)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.TMGrayBackgroundColor
        collectionView.register(TMItemIndexCollectionViewCell.self, forCellWithReuseIdentifier: "\(TMItemIndexCollectionViewCell.self)")
        
        return collectionView
    }()
    
    // Fetching processing
    var fetchedResultsProcessingOperations = [BlockOperation]()
    
    /// Monitor
    lazy var itemsMonitor: ListMonitor<TMItem>? = {
        
        guard let requestID = self.request.id else {
            return nil
        }
        
        /// Sorting by id, because it's generating ids based on time
        return TMCoreDataManager.defaultStack.monitorSectionedList(From<TMItem>(),
                                                                   SectionBy("\(TMItemAttributes.isRemoved.rawValue)"),
                                                                   Where("\(TMItemRelationships.recommendation.rawValue).\(TMRecommendationRelationships.request.rawValue).\(TMModelAttributes.id.rawValue) == %@", requestID),
                                                                   OrderBy(.ascending("\(TMItemAttributes.isRemoved.rawValue)"), .ascending("id")))
    }()
    
    // Recommendation
    var request: TMRequest! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Analytics
        TMAnalytics.trackScreenWithID(.s8)
        
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints(
            [NSLayoutConstraint(item: collectionView, attribute: .topMargin, relatedBy: .equal, toItem: self, attribute: .topMargin, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint(item: collectionView, attribute: .bottomMargin, relatedBy: .equal, toItem: self, attribute: .bottomMargin, multiplier: 1, constant: 0)]
        )
        
        itemsMonitor?.addObserver(self)
        
        /// Header nib
        let headerNib = UINib(nibName: "TMItemIndexCollectionReusableView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "TMItemIndexCollectionReusableView")
    }
    
    func listMonitor(_ monitor: ListMonitor<TMItem>, didMoveObject object: TMItem, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        
        addFetchedResultsProcessingBlock {
            
            self.collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
            
            if fromIndexPath != toIndexPath {
                self.collectionAnimation()
            }
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<TMItem>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
        addFetchedResultsProcessingBlock {

            self.collectionAnimation()
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<TMItem>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
        addFetchedResultsProcessingBlock {

            self.collectionAnimation()
        }
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<TMItem>) {
    
        collectionView.performBatchUpdates({ () -> Void in
            for operation in self.fetchedResultsProcessingOperations {
                
                operation.start()
            }
        }, completion: { (finished) -> Void in
            
            self.fetchedResultsProcessingOperations = []
        })
    }
    
    func collectionAnimation() {
        
        let animations: [StockAnimation] = [.slide(.up, .slightly)]
        let sortFunction: SortFunction = CorneredSortFunction(corner: .topLeft, interObjectDelay: 0.1)
        let animation = SpringAnimation(duration: 0.7)
        
        self.collectionView.spruce.animate(animations, animationType: animation, sortFunction: sortFunction)
    }
    
    private func addFetchedResultsProcessingBlock(processingBlock:@escaping (Void)->Void) {
        fetchedResultsProcessingOperations.append(BlockOperation(block: processingBlock))
    }
}

extension TMItemsIndexCollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /// Scroll only for 'not removed' section
        if indexPath.section == 0 {
            let item = itemsMonitor?[indexPath]
            delegate?.itemIndexControllerSelectedItem(item)
        }
    }
}

extension TMItemsIndexCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /// Check section count
        if itemsMonitor?.numberOfSections() == 1 && indexPath.section == 1 {
            return .zero
        }
        
        let cellW: CGFloat = collectionView.frame.width - 20.0
        var cellH: CGFloat = 300.0
        
        if DeviceType.IS_IPHONE_5 {
            
            cellH = 280.0
        }
        else if DeviceType.IS_IPHONE_6P {
            
            cellH = 320.0
        }
        
        return CGSize(width: cellW, height: cellH)
    }
}

// MARK: - CollectionView Datasource
extension TMItemsIndexCollectionViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if itemsMonitor?.numberOfSections() == 1 && section == 1 {
            return 0
        }
        
        return itemsMonitor?.numberOfObjectsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let isCheckoutAvaliable = request.cart?.isCheckoutAvaliable, isCheckoutAvaliable == true else {
         
            if section == 1 && collectionView.numberOfSections == 2 {
            
                return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 80, right: 10.0)
            }
            
            return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0, right: 10.0)
        }
        
        if section == 1 {
            
            return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 180, right: 10.0)
        }
        else {
            return UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0, right: 10.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TMItemIndexCollectionViewCell.className, for: indexPath) as? TMItemIndexCollectionViewCell
        
        let item = itemsMonitor?[indexPath]
        
        cell?.item = item
        cell?.delegate = self
        
        cell?.addShadow()
        cell?.clipsToBounds = false
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "TMItemIndexCollectionReusableView",
                                                                         for: indexPath) as! TMItemIndexCollectionReusableView
        headerView.isHidden = indexPath.section == 0
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if itemsMonitor?.numberOfSections() == 1 && section == 1 {
            return .zero
        }
        
        return section == 0 ? CGSize.zero : CGSize(width: collectionView.frameWidth()-20, height: 100)
    }
}

extension TMItemsIndexCollectionViewCell: TMItemIndexCollectionViewCellDelegate {
    func feedbackView(_ feedbackView: TMFeedbackContainerRatingView, ratedItem item: TMItem, feedback: TMFeedbackType) {
        self.delegate?.feedbackView(feedbackView, ratedItem: item, feedback: feedback)
    }
}
