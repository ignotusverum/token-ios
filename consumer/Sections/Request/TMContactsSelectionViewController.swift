//
//  TMContactsSelectionViewController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/12/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreData

import Contacts
import EZSwiftExtensions

import IQKeyboardManagerSwift

protocol TMContactsSelectionViewControllerCoordinatorDelegate {
    
    /// Tells the coordinator that a local contact from contacts on phone was selected.
    ///
    /// - Parameter contact: Local contact.
    func localContactWasSelected(_ contact: CNContact)
    
    /// Tells the coordinator that a remote, token contact was selected.
    ///
    /// - Parameter contact: Remote contact.
    func tokenContactWasSelected(_ contact: TMContact)
    
    /// Tells the coordinator that a new contact was selected with only a name.
    ///
    /// - Parameter name: Full name of contact.
    func newContactSelectedWithName(_ name: String)
}

protocol TMContactsSelectionViewControllerDelegate {
    
    func contactsSelected(_ contact: CNContact)
    func existingContactSelected(_ contact: TMContact)
    
    func newContactsSelectedWithName(_ name: String)
}

class TMContactsSelectionViewController: UIViewController {
    
    // MARK: - delegate
    var delegate: TMContactsSelectionViewControllerDelegate?
    
    var coordinatorDelegate: TMContactsSelectionViewControllerCoordinatorDelegate?
    
    // MARK: - ivars
    @IBOutlet fileprivate var tableView: UITableView? {
        didSet {
            tableView?.layer.cornerRadius = 2
        }
    }
    
    // MARK: - contacts picker
    @IBOutlet fileprivate var contactsSeachView: TMContactsSeachView! {
        didSet {
            contactsSeachView.layer.cornerRadius = 2
        }
    }
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.layer.cornerRadius = 2
            backgroundView.layer.shadowColor = UIColor.black.cgColor
            backgroundView.layer.shadowRadius = 2
            backgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
            backgroundView.layer.shadowOpacity = 0.1
        }
    }
    @IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
    
    // MARK: - datasource
    
    fileprivate var contactsArray = [Any]()
    fileprivate var filteredContactsArray = [Any]()
    
    fileprivate var tokenContacts = [TMContact]()
    
    fileprivate var localContacts = [CNContact]()
    
    fileprivate var tokenContactsExist : Bool {
        
        return self.tokenContacts.count > 0
    }
    
    fileprivate var searchStarted = false
    
    // MARK: - Selected datasource
    var selectedContactsArray: [Any]?
    
    // MARK: - Controller lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView?.reloadData()
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TMAnalytics.trackScreenWithID(.s26)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleText("Find A Gift", color: UIColor.black)
        
        // Contacts search
        self.contactsSeachView.delegate = self
        
        // Keyboard notifications
        self.addKeyboardWillShowNotification()
        self.addKeyboardWillHideNotification()
        
        let headerNib = UINib(nibName: "TMTokenContactsCellHeader", bundle: nil)
        self.tableView?.register(headerNib, forHeaderFooterViewReuseIdentifier: "TMTokenContactsCellHeader")
        
        let addContactCell = UINib(nibName: "TMAddContactTableViewCell", bundle: nil)
        self.tableView?.register(addContactCell, forCellReuseIdentifier: "TMAddContactTableViewCell")
        
        // Setup contacts datasource
        ez.runThisAfterDelay(seconds: 0.2) {
            self.setupDatasource()
            
            self.bottomLayoutConstraint.isActive = true
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShownNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHiddenNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        contactsSeachView.contactNameInput.becomeFirstResponder()
    }
    
    func setupDatasource() {
        
        let contactManager = TMAddressBookManager.sharedManager
        
        // Get token contacts
        self.tokenContacts = contactManager.tokenContacts
        
        // Get local contacts
        self.localContacts = contactManager.localContacts
        
        // No access
        if contactManager.localContacts.count == 0 {
            
            TMAddressBookManager.loadAndMergeContacts(tokenContacts).then { (tokenContacts: [TMContact]?, localContacts: [CNContact]?) -> Void in
                
                if let tokenContacts = tokenContacts {
                    
                    contactManager.tokenContacts = tokenContacts
                }
                
                if let localContacts = localContacts {
                    
                    contactManager.localContacts = localContacts
                }
                
                if let tokenContacts = tokenContacts {
                    
                    self.contactsArray = tokenContacts
                }
                
                if let localContacts = localContacts {
                    
                    self.contactsArray = self.contactsArray + localContacts
                }
                
                self.filteredContactsArray = self.contactsArray
                
                self.tableView?.reloadData()
                }.catch { error in
                    print(error)
            }
        }
        else {
            
            self.contactsArray = tokenContacts
            
            self.contactsArray = self.contactsArray + localContacts
            
            self.filteredContactsArray = self.contactsArray
            
            self.tableView?.reloadData()
        }
        
        // No access
        if contactManager.localContacts.count == 0 {
            
            TMAddressBookManager.loadAndMergeContacts(tokenContacts).then { (tokenContacts: [TMContact]?, localContacts: [CNContact]?) -> Void in
                
                if let tokenContacts = tokenContacts {
                    
                    contactManager.tokenContacts = tokenContacts
                }
                
                if let localContacts = localContacts {
                    
                    self.localContacts = localContacts
                    contactManager.localContacts = localContacts
                }
                
                if let tokenContacts = tokenContacts {
                    
                    self.contactsArray = tokenContacts
                }
                
                if let localContacts = localContacts {
                    
                    self.contactsArray = self.contactsArray + localContacts
                }
                
                self.filteredContactsArray = self.contactsArray
                
                self.tableView?.reloadData()
                }.catch { error in
                    print(error)
            }
        }
        else {
            
            self.contactsArray = tokenContacts
            
            self.contactsArray = self.contactsArray + localContacts
            
            self.filteredContactsArray = self.contactsArray
            
            self.tableView?.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        
        self.view.endEditing(true)
    }
    
    // MARK: - Notifications
    
    /// Notification called when keyboard appears.
    ///
    /// - Parameter notification: Notification object.
    func keyboardShownNotification(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {
            return
        }
        
        if let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomLayoutConstraint.constant = endFrame.height + 20
        }
        
        if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    /// Notification called when keyboard hides.
    ///
    /// - Parameter notification: Notification object.
    func keyboardHiddenNotification(_ notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {
            return
        }
        
        bottomLayoutConstraint.constant = 20
        
        if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Utilities
    
    func lastRowForSection(_ section: Int)-> Int {
        
        var result = 0
        
        if self.tokenContactsExist && section == 0 {
            
            result = self.tokenContacts.count - 1
        }
        else {
            
            result = self.localContacts.count - 1
        }
        
        return result
    }
    
    func addAndSaveContact(_ contact: Any?) {
        if let contact = contact as? CNContact {
            coordinatorDelegate?.localContactWasSelected(contact)
        } else if let contact = contact as? TMContact {
            coordinatorDelegate?.tokenContactWasSelected(contact)
        } else if let newContactName = contact as? String {
            coordinatorDelegate?.newContactSelectedWithName(newContactName)
        }
    }
}

// MARK: - TableView delegate

extension TMContactsSelectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as? TMContactsUserTableViewCell
        
        cell?.contactsSelected(true)
        
        var contact: Any?
        
        if self.filteredContactsArray.count > indexPath.row && self.searchStarted && self.filteredContactsArray.count != indexPath.row {
            
            contact = self.filteredContactsArray[indexPath.row]
        }
        else if self.filteredContactsArray.count == indexPath.row && self.searchStarted {
            
            contact = self.contactsSeachView.contactName
        }
        else if self.tokenContactsExist && indexPath.section == 0 {
            
            contact = self.tokenContacts[indexPath.row]
        }
        else {
            
            contact = self.localContacts[indexPath.row]
        }
        
        self.view.endEditing(true)
        
        
        //The following removes spacing from the beginning of a new contact name.
        if var contact = contact as? String {
            while contact.hasPrefix(" ") {
                contact.remove(at: contact.startIndex)
            }
            
            addAndSaveContact(contact)
        } else {
            addAndSaveContact(contact)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

// MARK: - TableView Datasource

extension TMContactsSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSections = 0
        
        if self.tokenContactsExist && self.localContacts.count > 0 {
            
            numberOfSections = 2
        }
        else if self.localContacts.count > 0 || self.tokenContactsExist {
            
            numberOfSections = 1
        }
        
        // Search - conbining in one section
        if self.searchStarted {
            
            numberOfSections = 1
        }
        
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = 0
        
        // local contacts
        if self.localContacts.count > 0 {
            
            numberOfRows = self.localContacts.count
        }
        
        // token contacts
        if self.tokenContactsExist && section == 0 {
            
            numberOfRows = self.tokenContacts.count
        }
        
        // Combining results
        if self.searchStarted {
            
            // Adding "add contact" button
            numberOfRows = self.filteredContactsArray.count + 1
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Add contact button
        if indexPath.row == self.filteredContactsArray.count && self.searchStarted {
            
            let addContactCell = tableView.dequeueReusableCell(withIdentifier: "TMAddContactTableViewCell", for: indexPath) as? TMAddContactTableViewCell
            
            addContactCell?.nameLabel.text = self.contactsSeachView.contactName
            
            return addContactCell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsUserCell", for: indexPath) as! TMContactsUserTableViewCell
        
        cell.separatorView.isHidden = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        cell.contactsSelected(false)
        // Searching
        if self.searchStarted && self.filteredContactsArray.count > 0 {
            
            // Contact search cell
            let contact = self.filteredContactsArray[indexPath.row]
            
            if contact is TMContact {
                
                cell.databaseContact = contact as? TMContact
                cell.backgroundColor = UIColor.clear
                
            }
            else if contact is CNContact {
                
                cell.contact = contact as? CNContact
                cell.backgroundColor = UIColor.TMPinkColor
            }
        }
        else {
            // token contacts
            if indexPath.section == 0 && self.tokenContacts.count > 0 {
                
                let contact = self.tokenContacts[indexPath.row]
                
                cell.databaseContact = contact
            }
            else {
                // local contacts
                let contact = self.localContacts[indexPath.row]
                
                cell.contact = contact
            }
        }
        
        cell.contactsSelected(false)
        
        return cell
    }
    
    // Sections Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)-> UIView? {
        
        let headerView = UIView(x: 0.0, y: 0.0, w: tableView.frameWidth(), h: 24.0)
        headerView.backgroundColor = UIColor.white
        
        let seperatorMargin: CGFloat = 30
        let seperatorLine = UIView(x: seperatorMargin, y: 0.0, w: tableView.frameWidth() - seperatorMargin, h: 0.5)
        seperatorLine.alpha = 0.1
        seperatorLine.center = headerView.center
        seperatorLine.backgroundColor = .black
        
        headerView.addSubviewWithCheck(seperatorLine)
        
        let titleLabel = UILabel(x: 0.0, y: 0.0, w: tableView.frameWidth() / 3, h: headerView.bounds.height)
        titleLabel.center = headerView.center
        titleLabel.font = UIFont.MalloryBook(10.0)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .white
        
        headerView.addSubviewWithCheck(titleLabel)
        
        if section == 0 && !tokenContacts.isEmpty {
            titleLabel.text = "RECENT CONTACTS"
        } else {
            titleLabel.text = "ALL CONTACTS"
        }
        
        if searchStarted {
            titleLabel.isHidden = true
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)-> CGFloat {
        
        return 24.0
    }
}

// MARK: - TMContact search delegates
extension TMContactsSelectionViewController: TMContactsSeachViewDelegate {
    
    // Return
    func textFieldShouldReturn(_ textField: UITextField) {
        
        textField.resignFirstResponder()
    }
    
    // Text Changed
    func changedToEmptySearch(_ textField: UITextField) {
        
        // Empty
        self.filteredContactsArray = self.contactsArray
        self.searchStarted = false
        
        tableView?.reloadData()
    }
    
    // Search
    func searchWithText(_ text: String, shouldReset: Bool) {
        
        self.searchStarted = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        filteredContactsArray = contactsArray
        
        // Separating with space
        let components = text.components(separatedBy: " ")
        // Checking if there's anything
        if components.count > 0 {
            
            let firstString = components.first
            var filteredArray = [Any]()
            
            // Searching first component
            if let firstString = firstString {
                
                filteredArray = self.filteredContactsArray.filter() {
                    
                    var fNameResult = false
                    var lNameresult = false
                    
                    // sorting localContact
                    if $0 is CNContact {
                        
                        if let localContact = $0 as? CNContact {
                            // Sorting by first name
                            fNameResult = localContact.givenName.contains(firstString)
                            lNameresult = localContact.familyName.contains(firstString)
                        }
                    }
                        // Sorting TMContact
                    else if $0 is TMContact {
                        
                        let localContact = $0 as? TMContact
                        
                        if let firstName = localContact?.firstName {
                            
                            fNameResult = firstName.contains(firstString)
                        }
                        
                        if let lastName = localContact?.lastName {
                            
                            lNameresult = lastName.contains(firstString)
                        }
                    }
                    
                    return fNameResult || lNameresult
                }
            }
            
            self.filteredContactsArray = filteredArray
        }
        
        tableView?.reloadData()
    }
    
    // Selection
    func contactNameSelected(_ name: String) {
        
        delegate?.newContactsSelectedWithName(name)
    }
}
