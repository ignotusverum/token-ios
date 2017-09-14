//
//  TMContactInfoPopUpViewController.swift
//  consumer
//
//  Created by Gregory Sapienza on 4/26/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

/// Struct to be used for table view data source.
fileprivate struct TMContactInfoPopUpData {
    
    /// Image in cell.
    var image: UIImage
    
    /// Text description in cell.
    var text: String
}

@objc protocol TMContactInfoPopUpViewControllerCoordinatorDelegate {
    /// Coordinator action when tapping 'Choose Contact.'
    func onChooseContactButton()
    
    /// Coordinator action when tapping 'Manual Contact.'
    func onManualContactButton()
}

class TMContactInfoPopUpViewController: TMPopUpInfoViewController {

    // MARK: - Public iVars

    var coordinatorDelegate: TMContactInfoPopUpViewControllerCoordinatorDelegate? {
        didSet {
            
            //Adds delegate as target for button actions.
            
            chooseContactButton.addTarget(coordinatorDelegate, action: #selector(self.coordinatorDelegate?.onChooseContactButton), for: .touchUpInside)
            manualContactButton.addTarget(coordinatorDelegate, action: #selector(self.coordinatorDelegate?.onManualContactButton), for: .touchUpInside)

        }
    }
    
    // MARK: - Private iVars
    
    /// Table view with image and text cells.
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.register(TMContactInfoPopUpTableViewCell.self, forCellReuseIdentifier: "\(TMContactInfoPopUpTableViewCell.self)")
        tableView.allowsSelection = false
        
        return tableView
    }()
    
    /// Button to get contact authorization and advance to next view controller.
    private lazy var chooseContactButton: UIButton = {
        let button = UIButton.button(style: .darkPurple)
        
        button.setTitle("Choose A Contact", for: .normal)

        return button
    }()
    
    /// Button to manually enter contact without needing to authorize.
    private lazy var manualContactButton: UIButton = {
       let button = UIButton(type: .system)
        
        button.setTitle("manually enter contact", for: .normal)
        button.setTitleColor(UIColor.TMColorWithRGBFloat(170.0, green: 170.0, blue: 170.0, alpha: 1 ), for: .normal)
        button.titleLabel?.font = UIFont.MalloryBook(15)
        
        return button
    }()
    
    /// Data to use as table view data source.
    fileprivate lazy var contactInfoData: [TMContactInfoPopUpData] = {
        guard
            let image1 = UIImage(named: "ContactInfoImage1"),
            let image2 = UIImage(named: "ContactInfoImage2"),
            let image3 = UIImage(named: "ContactInfoImage3")
        else {
            return []
        }
        
        
        return [
            TMContactInfoPopUpData(image: image1, text: "Choose someone from your contacts."),
            TMContactInfoPopUpData(image: image2, text: "Enter a few details about them."),
            TMContactInfoPopUpData(image: image3, text: "We’ll find gifts just for them. We won’t contact them at all. Surprises are more fun!")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---Manual Contact Button---//
        
        contentView.addSubview(manualContactButton)
        
        manualContactButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints([
            NSLayoutConstraint(item: manualContactButton, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -40),
            NSLayoutConstraint(item: manualContactButton, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: manualContactButton, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: manualContactButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28)
            ])
        
        //---Choose Contact Button---//
        
        contentView.addSubview(chooseContactButton)
        
        chooseContactButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints([
            NSLayoutConstraint(item: chooseContactButton, attribute: .bottom, relatedBy: .equal, toItem: manualContactButton, attribute: .top, multiplier: 1, constant: -15),
            NSLayoutConstraint(item: chooseContactButton, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chooseContactButton, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 130 / 170, constant: 0),
            NSLayoutConstraint(item: chooseContactButton, attribute: .height, relatedBy: .equal, toItem: chooseContactButton, attribute: .width, multiplier: 40 / 130, constant: 0)
            ])
        
        //---Table View---//
        
        contentView.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addConstraints([
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: chooseContactButton, attribute: .top, multiplier: 1, constant: -20)
            ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TMContactInfoPopUpViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactInfoData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(TMContactInfoPopUpTableViewCell.self)") as? TMContactInfoPopUpTableViewCell else {
            print("Cell for identifier is nil.")
            
            return UITableViewCell()
        }
        
        let data = contactInfoData[indexPath.row]
        
        cell.contentImageView.image = data.image
        cell.setContentLabelText(text: data.text)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / CGFloat(contactInfoData.count)
    }
}
