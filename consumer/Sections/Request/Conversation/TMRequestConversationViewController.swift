//
//  TMRequestConversationController.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 2/26/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

// JSON parsing extension
import SwiftyJSON

/// Loader
import SVProgressHUD

/// Promise
import PromiseKit

// Keyboard managing
import IQKeyboardManagerSwift

import TwilioChatClient
import JDStatusBarNotification

import EZSwiftExtensions

class TMRequestConversationViewController: NMessengerViewController {
    
    /// Paging size.
    private let pageSize = 20
    
    /// Current page.
    private var currentPage = 1
    
    // Request object
    var request: TMRequest?
    
    // Title label
    @IBOutlet weak var navigationTitleLabel: UILabel!
    
    var requestChannel: TCHChannel?
    var messages: [TCHMessage]?
    
    var showButtonDown = false
    
    @IBOutlet var backBarButtonItem: UIBarButtonItem!
    
    // MARK: - Controller lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Analytics
        TMAnalytics.trackScreenWithID(.s10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async(execute: {
            
            // Register for push
            let appDelegate = TMAppDelegate.appDelegate
            appDelegate?.registerForPushNotificationsAndUpdateToken()
        })
        
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        if showButtonDown {
            
            self.backBarButtonItem.image = UIImage(named: "DownArrow")
        }
        
        // Setting navigation bar color
        self.navigationBarColor = UIColor.TMGrayBackgroundColor
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Mark notifications as seen
        
        TMNotificationAdapter.fetch().then { result-> Promise<[TMNotificationGroup]> in
            
            return TMNotificationAdapter.markAsRead(activities: self.request?.activitiesArray)
            
            }.catch { error in
                print(error)
        }
        
        self.sharedBubbleConfiguration = SimpleBubbleConfiguration()
        
        // Setup UI
        self.setupUI()
        
        messengerView.delegate = self
        messengerView.doesBatchFetch = true
        
        if self.request?.channelID == nil {
            TMRequestAdapter.fetch(requestID: self.request!.id).then { request -> Void in
                SVProgressHUD.show()
                self.synchronizeChannel()
                }.catch { error in
                    
                    JDStatusBarNotification.show(withStatus: error.localizedDescription, dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
            }
        }
        else {
            SVProgressHUD.show()
            self.synchronizeChannel()
        }
        
        self.updateShadow()
    }
    
    func updateShadow() {
        
        let tableView = self.messengerView.messengerNode.view
        let shadowOffset = (tableView.contentOffset.y / 100.0) - 2.0
        
        let shadowRadius = min(max(shadowOffset, 1), 3)
        
        if shadowOffset < 0.2 {
            
            self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: shadowOffset)
            self.navigationController?.navigationBar.layer.shadowRadius = shadowRadius
        }
        else {
            
            self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.2)
            self.navigationController?.navigationBar.layer.shadowRadius = shadowRadius
        }
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
    }
    
    func synchronizeChannel() {
        
        guard let request = self.request else {
            SVProgressHUD.dismiss()
            dismissVC(completion: nil)
            return
        }
        
        let conversationManager = TMConversationManager.shared
        conversationManager?.synchronizeChannelForRequest(self.request).then { channel-> Void in
            
            self.requestChannel = channel
            
            let conversationMan = TMConversationManager.shared
            
            SVProgressHUD.dismiss()
            
            conversationMan?.fetchMessages(request, beginningIndex: self.pageSize * self.currentPage, desiredNumberOfMessagesToLoad: self.pageSize).then { messages-> Void in
                
                self.messages = messages
                
                var messageNodes = [GeneralMessengerCell]()
                
                for (index, message) in messages.enumerated() {
                    if message.body.length > 0 {
                        
                        // Generate text ode
                        let textContentNode = TextContentNode(textMessageString: message.body!, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
                        
                        // Create empty timestamp
                        var messageTimestamp = MessageSentIndicator()
                        
                        // If first message - always show timestamp
                        if index == 0 {
                            
                            messageTimestamp = self.createTimestamp(message, previousMessage: nil)
                        }
                        else if messages.count > index {
                            
                            // Safety check
                            // Create timestamp with time difference
                            let previous = messages[index-1]
                            messageTimestamp = self.createTimestamp(message, previousMessage: previous)
                        }
                        
                        // Check if node is not empty
                        if let text = messageTimestamp.messageSentAttributedText, text.length > 0 {
                            messageNodes.append(messageTimestamp)
                        }
                        
                        // Cell padding update
                        let messageNode = MessageNode(content: textContentNode)
                        
                        messageNode.cellPadding = self.messagePadding
                        messageNode.currentViewController = self
                        
                        // Author check
                        messageNode.isIncomingMessage = message.isReceiver()
                        
                        messageNodes.append(messageNode)
                    }
                }
                
                DispatchQueue.main.async {
                    if self.messengerView.allMessages().isEmpty { //If there are no messages we have to use the add messages function, otherwise to add new chats to the top, we use endBatchFetch (dumb framework) 🙄
                        self.messengerView.addMessages(messageNodes, scrollsToMessage: false)
                        
                        self.messengerView.scrollToLastMessage(animated: false)
                        
                    } else {
                        self.messengerView.endBatchFetchWithMessages(messageNodes)
                    }
                }
                
                }.catch { error in
                    
                    JDStatusBarNotification.show(withStatus: "Whoops, something went wrong, please try again", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                    SVProgressHUD.dismiss()
                    
                    self.popVC()
            }
            }.catch { error in
                
                JDStatusBarNotification.show(withStatus: "Whoops, something went wrong, please try again", dismissAfter: 2.0, styleName: defaultStatusAlertStyle)
                SVProgressHUD.dismiss()
                
                self.popVC()
        }
    }
    
    func createTimestamp(_ message: TCHMessage, previousMessage: TCHMessage?)-> MessageSentIndicator {
        
        // Check for timestamp & add new cell
        // Format date + attributed text
        let messageTimestamp = MessageSentIndicator()
        
        if let previousMessage = previousMessage {
            
            let difference = message.timestampAsDate.minutesFrom(previousMessage.timestampAsDate)
            
            // Difference should be > 15 min
            if difference > 15 {
                
                messageTimestamp.messageSentAttributedText = Date.conversationMessageTimestampFromDate(message.timestampAsDate)
            }
        }
        else {
            
            messageTimestamp.messageSentAttributedText = Date.conversationMessageTimestampFromDate(message.timestampAsDate)
        }
        
        return messageTimestamp
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let conversationManager = TMConversationManager.shared
        conversationManager?.delegate = nil
    }
    
    // MARK: - Setup chat ui
    func setupUI() {
        
        /// Navigation title
        
        let label = UILabel()
        
        label.numberOfLines = 0
        label.attributedText = TMCopy.navigationTitle(title: "GIFT SELECTION", request: request)
        
        label.sizeToFit()
        navigationItem.titleView = label
        
        self.navigationController?.navigationBar.hideBottomHairline()
        
        let config = TMConsumerConfig.shared
        let userID = config.currentUser?.id
        
        if userID == nil {
            
            self.dismissVC(completion: nil)
            return
        }
        
        let conversationManager = TMConversationManager.shared
        conversationManager?.delegate = self
    }
    
    // Overriding back button action
    override func backButtonPressed(_ sender: Any?) {
        
        if !self.showButtonDown {
            
            self.popVC()
        }
        else {
            
            self.dismissVC(completion: nil)
        }
    }
    
    override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
        
        if text.length > 0 {
            let msg = self.requestChannel?.messages.createMessage(withBody: text)
            self.requestChannel?.messages.send(msg) { result in }
        }
        
        //create a new text message
        let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
        
        let newMessage = MessageNode(content: textContent)
        newMessage.cellPadding = messagePadding
        newMessage.currentViewController = self
        newMessage.isIncomingMessage = false
        
        return newMessage
    }
    
    fileprivate func postText(_ message: MessageNode) {
        
        self.messengerView.addMessage(message, scrollsToMessage: true)
    }
    
    
    func batchFetchContent() {
        currentPage += 1
        synchronizeChannel()
        
    }
}


// MARK: - Conversation manager delegate
extension TMRequestConversationViewController: TMConversationManagerDelegate {
    
    internal func messageAddedForChannel(_ channel: TCHChannel, message: TCHMessage) {
        if channel.sid == self.request?.channelID {
            
            // Set all messages as consumed
            channel.messages.setAllMessagesConsumed()
            
            // Text node params
            let textContentNode = TextContentNode(textMessageString: message.body!, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
            
            let messageNode = MessageNode(content: textContentNode)
            messageNode.cellPadding = messagePadding
            messageNode.currentViewController = self
            
            // Checking is author
            messageNode.isIncomingMessage = message.isReceiver()
            
            let lastMessage = self.messages?.last
            
            var messageTimestamp = MessageSentIndicator()
            
            // Safety check
            messageTimestamp = self.createTimestamp(message, previousMessage: lastMessage)
            if let text = messageTimestamp.messageSentText, text.length > 0 {
                
                messengerView.addMessage(messageTimestamp, scrollsToMessage: false)
            }
            
            automaticallyAdjustsScrollViewInsets = false
            
            self.messages?.append(message)
            
            self.postText(messageNode)
        }
    }
}
