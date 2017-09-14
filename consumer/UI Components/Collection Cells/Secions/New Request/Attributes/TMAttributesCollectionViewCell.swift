//
//  TMAttributesCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/11/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import EZSwiftExtensions

class TMAttributesCollectionViewCell: UICollectionViewCell, NestedCollectionViewCell {
    
    @IBOutlet internal var collectionView: TMIndexedCollectionView?

    var selectedAttributesArray = [String]()
    var selectedAttributesArrayDict: [[String: String]] {
        
        var resultArray = [[String: String]]()
        
        if selectedAttributesArray.count > 0 {
            for id in selectedAttributesArray {
                resultArray.append(["id": id])
            }
        }
        
        return resultArray
    }
    
    var dataSourceArray: [TMRequestAttribute]?
    
    var freeFormCell: TMFreeFormCollecationViewCell?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 65, left: 10.0, bottom: 0.0, right: 20.0)
        layout.scrollDirection = .horizontal
        
        collectionView?.collectionViewLayout = layout
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView?.frame = contentView.bounds
    }
}

// MARK: - CollectionView

// MARK: - CollectionView Datasource

extension TMAttributesCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let _dataSourceArray = dataSourceArray else {
            
            print("warning datasource is nil")
            return 0
        }
        
        // WARNING - FREE FORM
        return _dataSourceArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        guard let _dataSourceArray = dataSourceArray else {
            
            print("warning datasource is nil")
            return cell
        }
        
        if indexPath.row != _dataSourceArray.count {
            
            let attributeCell = collectionView.dequeueReusableCell(withReuseIdentifier:"\(TMAttributeCollectionViewCell.self)", for: indexPath) as! TMAttributeCollectionViewCell
            
            let model = _dataSourceArray[indexPath.row]
            
            if selectedAttributesArray.contains(model.id) {
                
                attributeCell.attributeSelected = true
            }
            else {
                attributeCell.attributeSelected = false
            }
            
            attributeCell.attribute = model
            
            cell = attributeCell
        }
        else {
            
            let freeFormCell = collectionView.dequeueReusableCell(withReuseIdentifier:"\(TMFreeFormCollecationViewCell.self)", for: indexPath) as! TMFreeFormCollecationViewCell
            freeFormCell.delegate = self
            self.freeFormCell = freeFormCell
            
            cell = freeFormCell
            
            let _ = cell.addGradienBorder(2.0)
        }
        
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        return cell;
    }
}

extension TMAttributesCollectionViewCell: TMFreeFormCollecationViewCellDelegate {
    
    func occasionFormSelected() {
        
    }
    
    func occasionTextDidEndEditing(_ text: String?) {
        
    }
    
    func occasionTextDidChanged(_ textField: UITextField) {
        
    }
}
