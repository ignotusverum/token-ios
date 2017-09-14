//
//  TMContactInfoCollectionViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 9/28/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import UIKit
import Contacts

import EZSwiftExtensions

protocol TMContactInfoCollectionViewCellDelegate {
    
    // Cross pressed
    func contactCrossButtonPressed(_ contact: CNContact?)
    
    func freeFormRelationTextChanged(_ text: String)
    
    func ageCellPressed(_ ageString: String)
    func relationCellPressed(_ relatoinString: String)
    func genderCellPressed(_ genderString: String)
}

class TMContactInfoCollectionViewCell: UICollectionViewCell {
    
    // Contact Object
    var contact: CNContact? {
        didSet {
            // Safety check
            guard let _contact = contact else {
                return
            }
            
            // Setting contact appearance
            self.contactView.addressBookContact = _contact
            
            self.resetAnimation()
        }
    }
    
    var existingContact: TMContact? {
        didSet {
            guard let _contact = existingContact else {
                return
            }
            
            if _contact.contactAddressBook != nil {
                
                self.contactView.addressBookContact = _contact.contactAddressBook
            }
            else {
                
                self.contactView.contact = _contact
                
                // Temp
                self.contactView.fullNameLabel.textColor = UIColor.black
            }
            
            self.resetAnimation()
        }
    }
    
    var ageScrolled = false
    var relationScrolled = false
    var genderScrolled = false
    
    // Contact info relatoin free form textField
    var relationFreeForm: UITextField? {
        didSet {
            
            if let relationFreeForm = relationFreeForm {
                
                relationFreeForm.addTarget(self, action: #selector(TMContactInfoCollectionViewCell.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            }
        }
    }
    
    var freeFormText: String?
    
    var freeFormCell: TMContactInfoFreeFormCollectionViewCell?
    
    // Contact text
    var contactText: String? {
        didSet {
            // Safety check
            guard let _contactText = contactText else {
                return
            }
            
            // Setting contact text
            var arrayOfNames = _contactText.components(separatedBy: " ")
            
            let contact = CNMutableContact()
            
            if arrayOfNames[0] != "" {
                contact.givenName = arrayOfNames[0]
            }
            
            if arrayOfNames.count > 1 {
                contact.familyName = arrayOfNames[1]
            }
            
            // Setting local contact obj
            self.contactView.addressBookContact = contact
            
            self.resetAnimation()
        }
    }
    
    // Delegate
    var delegate: TMContactInfoCollectionViewCellDelegate?
    
    // Contact View
    @IBOutlet weak var contactView: TMAddressBookContactStatusView!
    
    // Cross button
    @IBOutlet weak var crossButton: UIButton!
    
    // Collections
    @IBOutlet weak var genderCollectionView: TMIndexedCollectionView?
    @IBOutlet weak var ageCollectionView: TMIndexedCollectionView?
    @IBOutlet weak var relationCollectionView: TMIndexedCollectionView?
    
    // Datasources
    var ageDatasource = TMCopy.ageArray
    
    var relationDatasource = TMCopy.relationArray
    
    var genderDatasource = TMCopy.genderArray
    
    // Selected age cell
    fileprivate var selectedAgeIndexPath: IndexPath?
    
    // Selected relation cell
    fileprivate var selectedRelationIndexPath: IndexPath?
    
    fileprivate var selectedGenderIndexPath: IndexPath?
    
    // Actions
    @IBAction func crossButtonPressed() {
        
        self.freeFormText = nil
        
        self.contact = nil
        self.contactText = nil
        self.existingContact = nil
        
        self.delegate?.contactCrossButtonPressed(self.contact)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cellNib = UINib(nibName: "TMContactInfoDataCollectionViewCell", bundle: nil)
        
        self.relationCollectionView?.register(cellNib, forCellWithReuseIdentifier: "TMContactInfoDataCollectionViewCell")
        self.ageCollectionView?.register(cellNib, forCellWithReuseIdentifier: "TMContactInfoDataCollectionViewCell")
        self.genderCollectionView?.register(cellNib, forCellWithReuseIdentifier: "TMContactInfoDataCollectionViewCell")
        
        let freeFormCellNib = UINib(nibName: "TMContactInfoFreeFormCollectionViewCell", bundle: nil)
        self.relationCollectionView?.register(freeFormCellNib, forCellWithReuseIdentifier: "TMContactInfoFreeFormCollectionViewCell")
        
        if DeviceType.IS_IPHONE_6P {
            
            let relationLayout = UICollectionViewFlowLayout()
            relationLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 148.0, bottom: 0.0, right: 137.0)
            relationLayout.scrollDirection = .horizontal
            
            self.relationCollectionView?.collectionViewLayout = relationLayout
            
            let ageLayout = UICollectionViewFlowLayout()
            ageLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 170.0, bottom: 0.0, right: 170.0)
            ageLayout.scrollDirection = .horizontal
            
            self.ageCollectionView?.collectionViewLayout = ageLayout
        }
    }
    
    func scrollToItems() {
        
        let ageSelection = "25 - 34"
        let relationSelection = "Friend"
        let genderSelection = "Male"
        
        if let ageIndex = self.ageDatasource.index(of: ageSelection) {
            
            let ageIndexPath = IndexPath(item: ageIndex, section: 0)
            
            self.ageCollectionView?.scrollToItem(at: ageIndexPath, at: .centeredHorizontally, animated: false)
            
            self.collectionView(self.ageCollectionView!, didSelectItemAt: ageIndexPath)
            
            ez.runThisAfterDelay(seconds: 0.1, after: {
                self.ageScrolled = true
            })
            
            self.selectedAgeIndexPath = ageIndexPath
        }
        
        if let relationIndex = self.relationDatasource.index(of: relationSelection) {
            
            let relationIndexPath = IndexPath(item: relationIndex, section: 0)
            
            self.relationCollectionView?.scrollToItem(at: relationIndexPath, at: .centeredHorizontally, animated: false)
            
            self.collectionView(self.relationCollectionView!, didSelectItemAt: relationIndexPath)
            
            ez.runThisAfterDelay(seconds: 0.1, after: {
                self.relationScrolled = true
            })
            
            self.selectedRelationIndexPath = relationIndexPath
        }
        
        if let genderIndex = genderDatasource.index(of: genderSelection) {
            let genderIndexPath = IndexPath(item: genderIndex, section: 0)
            genderCollectionView?.scrollToItem(at: genderIndexPath, at: .centeredHorizontally, animated: false)
            collectionView(genderCollectionView!, didSelectItemAt: genderIndexPath)
            
            ez.runThisAfterDelay(seconds: 0.1, after: {
                self.genderScrolled = true
            })
            
            self.selectedGenderIndexPath = genderIndexPath
        }
    }
    
    func scrollToSelectedItems() {
        
        if let selectedAgeIndexPath = self.selectedAgeIndexPath {
            
            self.ageCollectionView?.scrollToItem(at: selectedAgeIndexPath, at: .centeredHorizontally, animated: true)
        }
        
        if let selectedRelationIndexPath = self.selectedRelationIndexPath {
            
            self.relationCollectionView?.scrollToItem(at: selectedRelationIndexPath, at: .centeredHorizontally, animated: true)
        }
        
        if let selectedGenderIndexPath = selectedGenderIndexPath {
            
            genderCollectionView?.scrollToItem(at: selectedGenderIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func resetAnimation() {
        
        self.ageScrolled = false
        self.relationScrolled = false
        
        self.freeFormText = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !self.ageScrolled && !self.relationScrolled {
            
            self.scrollToItems()
        }
    }
}


// MARK: - CollectionView Datasource
extension TMContactInfoCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? TMContactInfoDataCollectionViewCell
        
        if collectionView == self.ageCollectionView {
            
            if let ageText = cell?.infoLabel.text {
                
                self.delegate?.ageCellPressed(ageText)
            }
            
            self.selectedAgeIndexPath = indexPath
        } else if collectionView == genderCollectionView {
            selectedGenderIndexPath = indexPath
            
            if let genderText = cell?.infoLabel.text {
                delegate?.genderCellPressed(genderText)
            }
        }
        else {
            
            if let relationText = cell?.infoLabel.text {
                
                self.delegate?.relationCellPressed(relationText)
            }
            
            self.selectedRelationIndexPath = indexPath
            
            self.freeFormText = ""
            self.freeFormCell?.infoInput.attributedPlaceholder = self.freeFormCell?.infoInput.placeholder?.setPlaceholder()
        }
        
        var freeFormTextField: UITextField?
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TMContactInfoFreeFormCollectionViewCell {
            
            cell.addCellGradienBorder()
            
            freeFormTextField = cell.infoInput
            
            ez.runThisAfterDelay(seconds: 0.1, after: {
                
                freeFormTextField?.becomeFirstResponder()
                return
            })
        }
        
        collectionView.reloadData()
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension TMContactInfoCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellHeight: CGFloat = 36.0
        var cellWidth: CGFloat = 90.0
        
        if collectionView == self.ageCollectionView {
            
            let string = self.ageDatasource[indexPath.row]
            
            cellWidth = string.size(attributes: [NSFontAttributeName: UIFont.MalloryBook(12.0)]).width
        }
        else if collectionView == self.relationCollectionView && indexPath.row < self.relationDatasource.count {
            
            let string = self.relationDatasource[indexPath.row]
            
            cellWidth = string.size(attributes: [NSFontAttributeName: UIFont.MalloryBook(12.0)]).width
        } else if collectionView == self.genderCollectionView {
            let string = self.genderDatasource[indexPath.row]
            
            cellWidth = string.size(attributes: [NSFontAttributeName: UIFont.MalloryBook(12.0)]).width
        }
        else {
            
            if let freeFormText = freeFormText {
                if freeFormText.length > 0 {
                    
                    let textWidth = freeFormText.size(attributes: [NSFontAttributeName: UIFont.MalloryBook(12.0), NSKernAttributeName: 1.0]).width + 30
                    
                    if textWidth > 90 {
                        
                        cellWidth = textWidth
                    }
                }
            }
        }
        
        return CGSize(width: cellWidth + 50.0, height: cellHeight)
    }

}

extension TMContactInfoCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Age collection view
        if collectionView == self.ageCollectionView {
            
            return ageDatasource.count
        }
            // Relation collection view
        else if collectionView == self.relationCollectionView {
            
            return relationDatasource.count + 1
        } else if collectionView == genderCollectionView {
            return genderDatasource.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TMContactInfoDataCollectionViewCell", for: indexPath) as? TMContactInfoDataCollectionViewCell
        
        cell?.removeGradientLayer()
        cell?.infoLabel.textColor = UIColor.TMLightGrayPlaceholder
        
        if collectionView == self.ageCollectionView {
            
            let ageString = self.ageDatasource[indexPath.row]
            cell?.infoLabel.attributedText = ageString.setCharSpacing(1.0)
            
            if indexPath == self.selectedAgeIndexPath {
                
                cell?.addCellGradienBorder()
                cell?.infoLabel.textColor = UIColor.black
            }
        } else if collectionView == genderCollectionView {
            let genderString = self.genderDatasource[indexPath.row]
            cell?.infoLabel.attributedText = genderString.setCharSpacing(1.0)
            
            
            if indexPath == self.selectedGenderIndexPath {
                
                cell?.addCellGradienBorder()
                cell?.infoLabel.textColor = UIColor.black
            }
        }
        else {
            
            if indexPath.row == self.relationDatasource.count {
                
                let freeFormCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TMContactInfoFreeFormCollectionViewCell", for: indexPath) as? TMContactInfoFreeFormCollectionViewCell
                
                freeFormCell?.infoInput.tintColor = UIColor.black
                
                self.freeFormCell = freeFormCell
                
                freeFormCell?.addShadow()
                
                self.relationFreeForm = freeFormCell?.infoInput
                self.relationFreeForm?.delegate = self
                
                freeFormCell?.infoInput.attributedText = self.freeFormText?.setCharSpacing(1.0)
                
                if let freeFormText = freeFormText, freeFormText.length == 0 {
                    
                    freeFormCell?.pencilIcon.tintColor = UIColor.TMLightGrayPlaceholder
                }
                else {
                    
                    freeFormCell?.pencilIcon.tintColor = UIColor.black
                    freeFormCell?.infoInput.attributedPlaceholder = "Other".setPlaceholder()
                }
                
                if let _ = self.freeFormText {
                    if !self.relationFreeForm!.isFirstResponder {
                        freeFormCell?.infoInput.attributedPlaceholder = "Other".setPlaceholder()
                    }
                }
                
                if indexPath == self.selectedRelationIndexPath {
                    
                    freeFormCell?.addCellGradienBorder()
                }
                else {
                    freeFormCell?.removeGradientLayer()
                }
                
                return freeFormCell!
            }
            
            let relationString = self.relationDatasource[indexPath.row]
            cell?.infoLabel.attributedText = relationString.setCharSpacing(1.0)
            
            if indexPath == self.selectedRelationIndexPath {
                
                cell?.addCellGradienBorder()
                cell?.infoLabel.textColor = UIColor.black
            }
        }
        
        cell?.addShadow()
        
        cell?.layer.shouldRasterize = true
        cell?.layer.rasterizationScale = UIScreen.main.scale
        
        return cell!
    }
}

//  Text Field handler
extension TMContactInfoCollectionViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
   
        if textField.text!.length == 0 {
            
            self.freeFormCell?.infoInput.attributedPlaceholder = "Other".setPlaceholder()
            self.freeFormCell?.pencilIcon.tintColor = UIColor.TMLightGrayPlaceholder
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        let freeFormIndexPath = IndexPath(row: self.relationDatasource.count, section: 0)
        
        UIView.performWithoutAnimation {
            
            self.freeFormText = textField.text
            
            self.delegate?.freeFormRelationTextChanged(self.freeFormText!)
            
            self.relationCollectionView?.reloadItems(at: [freeFormIndexPath])
            
            textField.becomeFirstResponder()
            
            if freeFormText!.length == 0 {
                
                textField.placeholder = nil
                self.relationFreeForm?.placeholder = nil
            }
            
            self.freeFormCell?.removeGradientLayer()
            self.freeFormCell?.addCellGradienBorder()
        }
        
        self.relationCollectionView?.scrollToItem(at: freeFormIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text!.length > 20 && string != "" {
            
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.placeholder = nil
 
        let freeFormIndexPath = IndexPath(row: self.relationDatasource.count, section: 0)
        
        self.freeFormText = textField.text
        
        if let selectedIndexPath = self.selectedRelationIndexPath {
            
            let selectedCell = self.relationCollectionView?.cellForItem(at: selectedIndexPath) as? TMContactInfoDataCollectionViewCell
            
            selectedCell?.infoLabel.textColor = UIColor.TMLightGrayPlaceholder
            selectedCell?.removeGradientLayer()
            
            self.selectedRelationIndexPath = freeFormIndexPath
        }
        
        self.freeFormCell?.removeGradientLayer()
        self.freeFormCell?.addCellGradienBorder()
        
        self.freeFormCell?.pencilIcon.tintColor = UIColor.black
        
        self.relationCollectionView?.scrollToItem(at: freeFormIndexPath, at: .centeredHorizontally, animated: false)
    }
}
