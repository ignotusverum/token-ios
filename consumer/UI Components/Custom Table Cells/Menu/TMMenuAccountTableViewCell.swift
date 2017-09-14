//
//  TMMenuAccountTableViewCell.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 4/14/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

class TMMenuAccountTableViewCell: UITableViewCell {

    var profileView: TMProfileContactView!
    
    @IBOutlet var fulltNameLabel: UILabel!
    
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layoutIfNeeded()
        
        let config = TMConsumerConfig.shared
        let currentUser = config.currentUser
        
        self.profileView.user = currentUser
        
        self.fulltNameLabel.text = currentUser?.fullName
        self.emailLabel.text = currentUser?.email
        
        let format1 = currentUser?.phoneNumberFormatted?.replacingOccurrences(of: "(", with: "")
        let format2 = format1?.replacingOccurrences(of: ") ", with: ".")
        let format3 = format2?.replacingOccurrences(of: "-", with: ".")
        
        if format3 != nil {
            self.phoneLabel.text = format3
        }
        else {
            
            self.phoneLabel.text = currentUser?.phoneNumberFormatted
        }
    }
}
