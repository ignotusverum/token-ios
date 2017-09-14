//
//  TMContactsUserTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/12/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import Contacts

class TMContactsUserTableViewCell: UITableViewCell {
    
    var databaseContact: TMContact? {
        didSet {
            
            self.reuseClear()
            
            guard let contact = databaseContact else {
                
                return
            }
            
            let firstName = (contact.firstName != nil && (contact.firstName?.length)! > 0) ? contact.firstName : ""
            let lastName = (contact.lastName != nil && (contact.lastName?.length)! > 0) ? contact.lastName : ""
            
            _nameLabel?.text = String(format: "%@ %@", firstName!, lastName!)
            
            if contact.localContactImage == nil {
                
                if let firstName = firstName {
                    _pictureImageView.image = generateWaxAvatarImage(from: firstName.uppercased())
                } else if let lastName = lastName {
                    _pictureImageView.image = generateWaxAvatarImage(from: lastName.uppercased())
                }
            }
            else {
                
                self._pictureImageView.image = contact.localContactImage!
            }
        }
    }
    
    fileprivate var _contact: CNContact?
    var contact: CNContact? {
        get {
            return _contact
        }
        set {
            
            self.reuseClear()
            
            _contact = newValue
            
            guard let contact = _contact else {
                
                return
            }
            
            
            let firstName = contact.givenName
            let lastName = contact.familyName
            
            _nameLabel?.text = String(format: "%@ %@", firstName, lastName)
            
            if let thumbnailImageData = contact.thumbnailImageData {
                _pictureImageView?.image = UIImage(data: thumbnailImageData)
                
            } else {
                _pictureImageView.image = generateWaxAvatarImage(from: firstName)
            }
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet fileprivate var _nameLabel: UILabel!
    @IBOutlet fileprivate var _pictureImageView: UIImageView!
    @IBOutlet fileprivate var _selectedImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    
    // MARK: - Cell lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let pictureImageView = _pictureImageView else {
            
            print("error, please set picture image view outlet")
            return
        }
        
        pictureImageView.contentMode = .scaleAspectFill
        pictureImageView.layer.cornerRadius = pictureImageView.frame.size.width / 2.0
        
        _pictureImageView = pictureImageView
        
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 0.0)
        
        _nameLabel?.textColor = UIColor.TMBlackColor
        
        var newImage = _selectedImageView.image?.withRenderingMode(.alwaysOriginal)
        UIGraphicsBeginImageContextWithOptions(newImage!.size, false, newImage!.scale)
        
        newImage?.draw(in: CGRect(x: 0.0, y: 0.0, width: _selectedImageView.frame.size.width, height: _selectedImageView.frame.size.height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        _selectedImageView.image = newImage
        
        self._pictureImageView.makeCircleImage()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cleaning datasource before reusing
        self.contact = nil
        self.databaseContact = nil
        
        self.reuseClear()
        
        _pictureImageView?.image = nil
    }
    
    func reuseClear() {
        
        _nameLabel?.text = ""
    }
    
    // MARK: - Actions
    
    func contactsSelected(_ selected: Bool) {
        
        _selectedImageView?.isHidden = !selected
    }
    
    /// Generates a wax image for contact
    ///
    /// - Parameter fullName: Name of contact. First initial will be used for wax image.
    /// - Returns: Wax image representing contact.
    func generateWaxAvatarImage(from fullName: String) -> UIImage? {
        guard fullName.length != 0 else {
            return nil
        }
        
        let firstNameInitial = fullName[0]
        
        let sealName = "\(firstNameInitial)-wax"
        
        guard let image = UIImage(named: sealName) else {
            return UIImage(named: "default-wax")
        }
        
        return image
    }
}
