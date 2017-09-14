//
//  TMNewAddressViewController.swift
//  consumer
//
//  Created by Gregory Sapienza on 1/12/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import JDStatusBarNotification

/// State for the view controller.
///
/// - normal: Typical state when first loading view controller.
/// - selected: When a text field in a cell is selected.
/// - saving: When a save has been initiated for address.
/// - saved: When address has been saved.
/// - canceled: When address editing has been canceled.
enum AddressViewControllerState {
    case normal
    case selected(AddressField)
    case saving
    case saved
    case canceled
}

/// Theme for the view controller.
///
/// - light: Light theme with light background and dark text.
/// - dark: Dark theme with dark background and light text.
enum AddressViewControllerTheme {
    case light
    case dark
    
    /// Gets the background color for current theme.
    ///
    /// - Returns: Color to use for view controller background.
    func backgroundColor() -> UIColor {
        switch self {
        case .light:
            return UIColor(colorLiteralRed: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        case .dark:
            return UIColor(colorLiteralRed: 29/255, green: 27/255, blue: 31/255, alpha: 1)
        }
    }
    
    /// Gets the title text color to use for cell titles.
    ///
    /// - Returns: Color for cell titles.
    func titleColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.TMGrayColor
        case .dark:
            return UIColor.white
        }
    }
    
    /// Gets the text field text color to use for cell text fields.
    ///
    /// - Returns: Color for cell text fields.
    func textFieldColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.black
        case .dark:
            return UIColor.white
        }
    }
    
    /// Gets the background color to use for cell validation views.
    ///
    /// - Returns: Background color for cell validation views.
    func validationViewColor() -> UIColor {
        switch self {
        case .light:
            return UIColor.TMGrayColor
        case .dark:
            return UIColor.white
        }
    }
    
    /// Gets the keyboard appearance to use for cell text field keyboard.
    ///
    /// - Returns: Keyboard appearance to use for cell.
    func keyboardAppearance() -> UIKeyboardAppearance {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class TMNewAddressViewController: UIViewController {
    
    //MARK: - Public iVars
    
    /// Table view for fields.
    @IBOutlet weak var tableView: UITableView!
    
    /// Height for the footer view for table view.
    var tableViewFooterHeight: CGFloat = 0

    /// State of view controller.
    var state: AddressViewControllerState = .normal
    
    /// Theme of the view controller.
    var style: AddressViewControllerTheme = .light
    
    /// Model for view controller.
    var model = TMNewAddressViewControllerModel()
    
    /// Dictionary containing each address property and a string value representing them to use as backing data for the table view.
    var addressFieldContent: [AddressField : String] = [ : ]
    
    /// Handler for next keyboard button.
    var returnKeyHandler: IQKeyboardReturnKeyHandler?
    
    //MARK: - Public
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addTitleText("ADD ADDRESS", color: UIColor.white)

        tableView.backgroundColor = UIColor.clear
        
        //Table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        
        tableView.sectionFooterHeight = tableViewFooterHeight
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableViewFooterHeight))
        
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)

        //Model
        
        model.delegate = self
        
        //Style
        
        view.backgroundColor = style.backgroundColor()
    }
    
    /// If an address exists in the model. This will add all properties that already exist from the address object to the addressFields dictionary.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Some text fields have default values. Set them here.
        func setDefaults() {
            for addressField in AddressField.addressFields() {
                if let defaultText = addressField.defaultText() { //If there is default text for this field.
                    if addressFieldContent[addressField] == nil { //If the text field is empty.
                        addressFieldContent[addressField] = defaultText
                    }
                    else if addressField == .addressLine2 { //If there is no default text for this field then set it to empty in the dictionary. This way the dictionary has a key for each address field in the form.
                        addressFieldContent[addressField] = ""
                    }
                }
            }
        }
        
        guard let address = model.address else {
            print("Address is nil.")
            setDefaults() //Basically if adding a new address, set the defaults.
            tableView.reloadData() //Reload data to reset fields when reusing the table view.
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false) //Scroll to top when reusing the table view.
            return
        }
        
        for addressField in AddressField.addressFields() {
            addressFieldContent[addressField] = addressField.contactAddressProperty(address: address)
        }
        
        setDefaults() //Set defaults after address fields are loaded while editing an address since it checks for blank fields and won't overwrite existing text in fields.
        
        tableView.reloadData() //Reload data to reset fields when reusing the table view.
        tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }
    
    /// Call after you have changed the state. Updates the UI accordingly to represent state.
    func stateDidChange() {
        
        /// Cleans up table view cells to allow for reuse of this view controller.
        func cleanUp() {
            addressFieldContent = [ : ]
            
            for cell in tableView.visibleCells {
                guard let cell = cell as? TMNewAddressTableViewCell else {
                    print("TMNewAddressTableView cell is not correct cell type.")
                    return
                }
                
                cell.textField.resignFirstResponder()
                cell.textField.text = ""
                cell.setSelected(false, animated: false)
            }
        }
        
        switch state {
        case .normal:
            //Resets table view selection.
            if tableView != nil {
                for cell in tableView.visibleCells {
                    guard let cell = cell as? TMNewAddressTableViewCell else {
                        print("TMNewAddressTableView cell is not correct cell type.")
                        return
                    }
                    
                    cell.setSelected(false, animated: false)
                    cell.textField.resignFirstResponder()
                }
            }
        case let .selected(addressField):
            //Deselects every cell that is not the selected cell and select the cell that the user has selected.
            for cell in tableView.visibleCells {
                guard let cell = cell as? TMNewAddressTableViewCell else {
                    print("TMNewAddressTableView cell is not correct cell type.")
                    return
                }
                
                if cell.addressField != addressField {
                    cell.setSelected(false, animated: false)
                } else {
                    cell.setSelected(true, animated: false)
                }
            }
            
        case .saving:
            //Go through every cell and resign the first responder for the text field and unselect the selected cell.
            for cell in tableView.visibleCells {
                guard let cell = cell as? TMNewAddressTableViewCell else {
                    print("TMNewAddressTableView cell is not correct cell type.")
                    return
                }
                
                cell.textField.resignFirstResponder()
                cell.setSelected(false, animated: false)
            }
        case .saved:
            cleanUp()
        case .canceled:
            cleanUp()
        }
    }
}

// MARK: - UITableViewDataSource
extension TMNewAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AddressField.addressFields().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ADDRESS_CELL", for: indexPath) as? TMNewAddressTableViewCell else {
            fatalError("Address cell is not correct type.")
        }
        
        let cellAddressField = AddressField.addressFields()[indexPath.row] //Essentially a cell identifier.
        cell.titleLabel.text = cellAddressField.rawValue.uppercased()
        cell.textField.text = addressFieldContent[cellAddressField]
        cell.addressField = cellAddressField //The type of field this will be.
        cell.delegate = self
        cell.textField.text = addressFieldContent[cellAddressField] //Fill in any text thats already been filled.
        cell.textField.keyboardAppearance = style.keyboardAppearance()
        cell.setSelected(false, animated: false)
        
        if style != .light {
            cell.isDarkStyle = true
        }
        
        switch state {
        case let .selected(addressField):
            if addressField == cellAddressField {
                cell.setSelected(true, animated: false)
            }
        default:
            break
        }
        
        //Style based on theme.
        
        cell.titleLabel.textColor = style.titleColor()
        cell.textField.textColor = style.textFieldColor()
        cell.validationView.backgroundColor = style.validationViewColor()
        let placeholderTextColor = style.textFieldColor().withAlphaComponent(0.2) //Color of placeholder is the text field color with an alpha value.
        cell.textField.attributedPlaceholder =
            NSAttributedString(string: cellAddressField.placeholderText(), attributes: [NSForegroundColorAttributeName : placeholderTextColor])
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TMNewAddressViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if DeviceType.IS_IPHONE_6P {
            return 120.0
        }
        return 88.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TMNewAddressTableViewCell else {
            print("TMNewAddressTableViewCell is not correct type.")
            return
        }
        
        guard let addressField = cell.addressField else {
            print("Address field not set for cell.")
            return
        }
        
        state = .selected(addressField)
        stateDidChange()
    }
}

// MARK: - TMNewAddressTableViewCellProtocol
extension TMNewAddressViewController: TMNewAddressTableViewCellProtocol {
    func textFieldSelected(cell: TMNewAddressTableViewCell) {
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self) //This is called here because all text fields are not loaded when the view is loaded due to the fact that they are in a table view. Calling this here is better than cellForRow at because that is called while scrolling creating a bit of lag.

        guard let addressField = cell.addressField else {
            print("Address field not set for cell.")
            return
        }
        
        state = .selected(addressField)
        stateDidChange()
    }
    
    func textFieldEndedEditing(cell: TMNewAddressTableViewCell, text: String) {
        guard let addressField = cell.addressField else {
            print("Cell address field is nil.")
            return
        }
        
        state = .normal
        stateDidChange()
        
        addressFieldContent[addressField] = text //When editing is complete set the content to the address field content so it will show up if the user scrolls and the call is reused.
    }
}

// MARK: - TMNewAddressViewControllerModelProtocol
extension TMNewAddressViewController: TMNewAddressViewControllerModelProtocol {
    func showNotificationStatus(status: String) {
        JDStatusBarNotification.show(withStatus: status, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
    }
    
    func checkForValidationError() -> NSError? {
        state = .saving
        stateDidChange()
        
        //For each address field. Check if there are less characters than allowed and if there are then present an error.
        for addressField in AddressField.addressFields() {
            
            if addressField != .addressLine2 {
            
                if let text = addressFieldContent[addressField] {
                    if text.length < addressField.minimumCharacterCount() {
                        let validationError = addressField.validationError()
                        print(AddressField.errorMessage(errorCode: validationError.code)!)
                        return validationError
                    }
                }
                else {
                    
                    return NSError(domain: "yo", code: 1000, userInfo: nil)
                }
            }
        }
        
        model.paramsForRequest = [String: AnyObject]()
        
        //Set up for params.
        
        guard let fullName = addressFieldContent[.fullName],
        let addressLine1 = addressFieldContent[.addressLine1],
        let city = addressFieldContent[.city],
        let state = addressFieldContent[.state],
        let zip = addressFieldContent[.zipCode],
        let placeName = addressFieldContent[.placeName] else {
                print("Some params not set.")
                return nil
        }
        
        let addressLine2 = addressFieldContent[.addressLine2] ?? ""
        
        model.paramsForRequest = TMContactAddress.requestParams(fullName: fullName, addressLine: addressLine1, addressLine2: addressLine2, city: city, state: state, zip: zip, label: placeName)
        
        return nil
    }
    
    func addressSavedForCurrentUser() {
        state = .saved
        stateDidChange()
    }
    
    func addressSavedForContact() {
        state = .saved
        stateDidChange()
    }
}
