//
//  TMOccasionCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/17/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMOccasionCollectionViewDelegate {
    
    func freeFormTextChanged(_ text: String?)
    func occasionSelected(_ occasion: TMRequestAttribute?)
}

class TMOccasionCollectionViewCell: TMAttributesCollectionViewCell {
    
    var delegate: TMOccasionCollectionViewDelegate?
    
    var previouslySelectedCell: TMAttributeCollectionViewCell?
    var selectedOccasion: TMRequestAttribute?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Occasion nib
        let occasionNib = UINib(nibName: "\(TMAttributeCollectionViewCell.self)", bundle: nil)
        collectionView?.register(occasionNib, forCellWithReuseIdentifier: "\(TMAttributeCollectionViewCell.self)")
        
        // Free form nib
        let freeFormNib = UINib(nibName: "\(TMFreeFormCollecationViewCell.self)", bundle: nil)
        collectionView?.register(freeFormNib, forCellWithReuseIdentifier: "\(TMFreeFormCollecationViewCell.self)")
    }
    
    func deselectAllCells() {
        
        for model in self.dataSourceArray! {
            
            model.selected = false
            
            if self.previouslySelectedCell != nil {
                
                self.previouslySelectedCell!.attributeSelected = false
            }
        }
        
        self.freeFormCell?.attributeSelected = false
        freeFormCell?.textField.text = ""
        
        self.selectedAttributesArray = [String]()
    }
    
    override func occasionFormSelected() {
        
        self.deselectAllCells()
        
        let cell = self.collectionView?.cellForItem(at: IndexPath(item: self.dataSourceArray!.count + 1, section: 0)) as? TMAttributeCollectionViewCell
        cell?.attributeSelected = true
        
        self.delegate?.occasionSelected(nil)
    }
    
    override func occasionTextDidChanged(_ textField: UITextField) {
        self.delegate?.freeFormTextChanged(textField.text)
    }
}

extension TMOccasionCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 140, height: 164)
    }
}

extension TMOccasionCollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? TMAttributeCollectionViewCell
        
        if cell != nil {
            
            self.deselectAllCells()
            
            cell?.attributeSelected = true
            
            self.superview?.endEditing(true)
            
            if cell?.attribute != nil {
                
                self.selectedAttributesArray.append((cell?.attribute?.id)!)
                selectedOccasion = cell?.attribute
            }
            
            self.previouslySelectedCell = cell
            
            self.delegate?.occasionSelected(selectedOccasion)
        }
    }
}

extension TMOccasionCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.delegate?.freeFormTextChanged(textField.text)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.deselectAllCells()
        
        self.freeFormCell?.attributeSelected = true
    }
}
