//
//  TMAddressTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 5/17/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

protocol TMAddressTableViewCellDelegate {
    func editingSelectedForAddress(_ address: TMContactAddress?, cell: TMAddressTableViewCell)
}

class TMAddressTableViewCell: UITableViewCell {

    // Address
    var address: TMContactAddress? {
        didSet {
            // Safety check
            guard let _address = address else {
                return
            }
            
            // Title label
            self.titleLabel.text = _address.label?.uppercased()
            
            // Address label
            let addressString = TMContactAddress.getAddressDetailsStringFromAddress(_address)
            
            self.addressLabel.attributedText = NSMutableAttributedString.initWithString(addressString.uppercased(), lineSpacing: 7.0, aligntment: .left)
        }
    }
    
    // Delegate
    var delegate: TMAddressTableViewCellDelegate?
    
    // Address Title Label
    @IBOutlet var titleLabel: UILabel!
    
    // Full Address Label
    @IBOutlet var addressLabel: UILabel!
    
    // Selection Button
    @IBOutlet var selectionImageView: UIImageView!
    
    // Editing Button
    @IBOutlet var editingButton: UIButton!
    
    // Selected cell
    var selectedCell = false {
        didSet {
            if selectedCell {
                
                self.selectionImageView.image = UIImage(named: "Address_selected")
                self.editingButton.isHidden = false
            }
            else {
                self.selectionImageView.image = UIImage(named: "Address_unselected")
                self.editingButton.isHidden = true
            }
        }
    }
    
    // Editing button pressed
    @IBAction func editAddressButtonPressed(_ sender: AnyObject) {
        // Calling delegate method
        self.delegate?.editingSelectedForAddress(self.address, cell: self)
    } 
 }
