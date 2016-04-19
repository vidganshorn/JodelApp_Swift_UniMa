//
//  ChatViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/21/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

import Parse
import Bolts

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let headerTitles = ["Message", "Chat"]
    
    let cellBlueColor = UIColor(hexString: "#45A7E0ff")
    
    @IBOutlet var tblChat: UITableView!
    
    var messageID: String!
    var user1: String!
    var user2: String!
    var socketChatRoomID: String!
    
    // unique chatID
    var chatID: String!
    
    @IBOutlet weak var userDetails: UIBarButtonItem!
    
    @IBOutlet weak var sendTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var typingNotification: UILabel!
    
    // PFObject to store the Jodel message
    var chatTitle: PFObject?
    
    // PFObjects to store all chat messages related to Jodel message
    var chatMessages: [PFObject]?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        sendTextView.delegate = self
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Generate chatID to identify chats combined by
        // chatID = ("" + messageID! + "$" + user1 + "$" + user2 + "") as String
        chatID = "\(messageID)$\(user1)$\(user2)"
 
        getChatTitle(messageID!)
        getChatMessages(chatID!) // instead of messageID user chatID
        
        sendTextView!.layer.borderWidth = 1
        sendTextView!.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.bringSubviewToFront(sendTextView)
        view.bringSubviewToFront(sendButton)
        
        tblChat.delegate = self
        tblChat.dataSource = self
        
        let dismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(dismiss)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: self.view.window)
        
        /*
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleConnectedUserUpdateNotification:", name: "userWasConnectedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDisconnectedUserUpdateNotification:", name: "userWasDisconnectedNotification", object: nil)
         
         */
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleUserTypingNotification:", name: "isTyping", object: nil)
 
        // setNavigationItemBadgeValue()
        
        self.tblChat.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // getChatMessage in ChatViewController
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                print("Something happens")
                
                let newChatMessage = PFObject(className: "Chat")

                newChatMessage["text"] = messageInfo["message"]
                newChatMessage["emitter"] = messageInfo["emitter"]
                newChatMessage["socket_IO_ID"] = messageInfo["roomID"]

                if(newChatMessage["socket_IO_ID"] as! String == self.socketChatRoomID) {
                    self.chatMessages?.append(newChatMessage)
                    
                    print(newChatMessage)
                }
                else {
                    // DO nothing
                }
  
                self.tblChat.reloadData()
                self.scrollToBottom()
            })
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        SocketIOManager.sharedInstance.sendStartTypingMessage(socketChatRoomID)
        
        return true
    }
    
    func handleUserTypingNotification(notification: NSNotification) {

        let typingUsersDictionary = notification.object as! [String: AnyObject]
            
        if(typingUsersDictionary["roomID"] as! String == socketChatRoomID) {
                
            if(typingUsersDictionary["emitter"] as! String != User.init().deviceID) {
                    
                if (typingUsersDictionary["isTyping"] as! String == "true") {
                
                    typingNotification.hidden = false
                }
                else {
                    typingNotification.hidden = true
                }
            }
            else {
                typingNotification.hidden = true
            }
        }
        else {
            typingNotification.hidden = true
        }
 
    }
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
            
            if self.chatMessages!.count > 0 {
                
                let lastRowIndexPath = NSIndexPath(forRow: self.chatMessages!.count - 1, inSection: 1)
                
                self.tblChat.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
    func DismissKeyboard(){
        view.endEditing(true)

        SocketIOManager.sharedInstance.sendStopTypingMessage(socketChatRoomID)
    }
    
    func keyboardWillShow(sender: NSNotification) {

        // 1
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        // 2
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        // 3
        if keyboardSize.height == offset.height {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height - 50
            })
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    
    func keyboardWillHide(sender: NSNotification) {
        
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        self.view.frame.origin.y += keyboardSize.height - 50
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // number of sections
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(section == 0) {
            return 1
        }
        else {
        
            return chatMessages!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {

            let cell = tableView.dequeueReusableCellWithIdentifier("idChatTopicCell", forIndexPath: indexPath) as! ChatTopicCell

            cell.message.text = chatTitle?.objectForKey("text") as! String
            
            /*
             * Test
            */
            var userList = appDelegate.userManager.getUsers()
           
            /*
             *  GET actual date for chatTitle
             */
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let currentDate = NSDate()
            let createdAt = chatTitle!.createdAt!
            
            var diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: createdAt, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
            
            // Date/ Time difference between message and actual time
            if(diffDateComponents.year != 0) {
                
                if(diffDateComponents.year == 1) {
                    cell.createdAt.text = "\(diffDateComponents.year) year ago"
                }
                else {
                    cell.createdAt.text = "\(diffDateComponents.year) years ago"
                }
            }
            else if(diffDateComponents.month != 0) {
                
                if(diffDateComponents.month == 1) {
                    cell.createdAt.text = "\(diffDateComponents.month) month ago"
                }
                else {
                    cell.createdAt.text = "\(diffDateComponents.month) months ago"
                }
            }
            else if(diffDateComponents.day != 0) {
                
                if(diffDateComponents.hour == 1) {
                    cell.createdAt.text = "\(diffDateComponents.day) day ago"
                }
                else {
                    cell.createdAt.text = "\(diffDateComponents.day) days ago"
                }
            }
            else if(diffDateComponents.hour != 0) {
                
                if(diffDateComponents.hour == 1) {
                    cell.createdAt.text = "\(diffDateComponents.hour) hour ago"
                }
                else {
                    cell.createdAt.text = "\(diffDateComponents.hour) hours ago"
                }
            }
            else if(diffDateComponents.minute != 0) {
                
                if(diffDateComponents.minute == 1) {
                    cell.createdAt.text = "\(diffDateComponents.minute) minute ago"
                }
                else {
                    cell.createdAt.text = "\(diffDateComponents.minute) minutes ago"
                }
            }
            else {
                
                if(diffDateComponents.second > 10) {
                    cell.createdAt.text = "\(diffDateComponents.second) seconds ago"
                }
                else {
                    cell.createdAt.text = "now"
                }
            }
            
            
            /*
             *  Location for chatTitle
             */
            let location = chatTitle!.objectForKey("location") as? PFGeoPoint
            
            let geoCoder = CLGeocoder()
            let geoLocation = CLLocation(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
            
            geoCoder.reverseGeocodeLocation(geoLocation) {
                (placemarks, error) -> Void in
                
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                let city = placeMark.addressDictionary?["City"] as? String
                
                cell.location.text = "from " + city!
            }

            
            /*
             *  Rating/Likes for chatTitle
             */
            var likes = chatTitle?.objectForKey("rating") as! Int
            cell.likes.text = String(likes) + " likes"
            
            
            /*
             *  Define cell apperance
             */
            cell.message.textColor = UIColor.whiteColor()
            cell.message.backgroundColor = cellBlueColor
            
            cell.createdAt.textColor = UIColor.whiteColor()
            cell.location.textColor = UIColor.whiteColor()
            cell.likes.textColor = UIColor.whiteColor()
            
            cell.backgroundColor = cellBlueColor
  
            return cell
            
        }
        else {
            
            if(chatMessages![indexPath.row]["emitter"] as! String == User.init().deviceID) {

                let cell2 = tableView.dequeueReusableCellWithIdentifier("myChatMessageCell", forIndexPath: indexPath) as! myChatMessageCell
                
                cell2.myMessage.text = chatMessages![indexPath.row]["text"] as? String
                cell2.myMessage.textAlignment = .Right
                
                return cell2
            }
            else {
                
                let cell2 = tableView.dequeueReusableCellWithIdentifier("yourChatMessageCell", forIndexPath: indexPath) as! yourChatMessageCell
                
                cell2.yourMessage.text = chatMessages![indexPath.row]["text"] as? String
                
                return cell2
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func setNavigationItemBadgeValue() {
        
        // If you want your BarButtonItem to handle touch event and click, use a UIButton as customView
        let customButton = UIButton.init(frame: CGRectMake(0, 0, 40, 30))
        
        // Add your action to your button
        // [customButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        // Customize your button as you want, with an image if you have a pictogram to display for example
        customButton.setImage(UIImage(named: "ic_info_outline_18pt_2x"), forState: .Normal)
        
        // Call Action "showRequests" if button was clicked
        // customButton.addTarget(self, action: "showRequests:", forControlEvents: UIControlEvents.TouchDown)
        
        // Then create and add our custom BBBadgeBarButtonItem
        let barButton = BBBadgeBarButtonItem(customUIButton: customButton)
        
        // Get number of open chat requests
        // openRequests = getOpenRequests().count
        
        // Set a value for the badge
        // barButton.badgeValue = String(openRequests)
        
        // Add it as the leftBarButtonItem of the navigation bar
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "showUserDetailsSegue") {
            
            let nextViewController = (segue.destinationViewController as! ChatUserDetailsViewController)
            
            if(user1 != User.init().deviceID) {
                nextViewController.chatPartnerID = user1
            }
            else {
                nextViewController.chatPartnerID = user2
            }
            
            /*
            nextViewController.user1 = openChatRoom?.objectForKey("user1") as? String
            nextViewController.user2 = openChatRoom?.objectForKey("user2") as? String
            nextViewController.messageID = openChatRoom?.objectForKey("messageID") as? String
            nextViewController.socketChatRoomID = openChatRoom?.objectForKey("socket_IO_ID") as? String
            */
            
        }
    }
    
    
    @IBAction func sendMessage(sender: AnyObject) {
        print("Here Send a Message")
        
        if(self.sendTextView.text?.isEmpty != true) {
            
            let chatMessage = PFObject(className:"Chat")
            
            // emmitter need to be replaced by DeviceID
            chatMessage["chatID"] = chatID
            chatMessage["emitter"] = User.init().deviceID
            chatMessage["text"] = self.sendTextView.text
            chatMessage["socket_IO_ID"] = socketChatRoomID
            
            
            // Send message to Socket.IO
            SocketIOManager.sharedInstance.sendMessage(self.sendTextView.text!, chatID: chatID, socketChatRoomID: socketChatRoomID, emitter: User.init().deviceID as String)
            
            self.sendTextView.text? = ""
            self.sendTextView.resignFirstResponder()
            
            
            // Send message to Parse
            // Deprecated!
            // Messages are now handled by Node.js server
            /*
            chatMessage.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                    print("The object has been saved.")
                    
                    // print("The chatroom ID is " + chatRoom.objectId!)
                    
                    // SocketIOManager.sharedInstance.createChatRoom(chatRoom.objectId!)
                    
                    //self.performSegueWithIdentifier("chatRoomSegue", sender: nil)
                    
                    self.sendTextView.text? = ""
                    self.sendTextView.resignFirstResponder()
                }
                else {
                    // There was a problem, check error.description
                    print(error?.description)
                    
                    self.sendTextView.text? = "Error - please try again"
                }
            }
            */
        }
        else {
            print("Message is empty")
        }
        
    }
    
    func getChatTitle(messageID: String) -> PFObject {
        
        // Create a query for messages
        let query = PFQuery(className:"Message")
        
        // Interested in messages within 10km near to user.
        query.whereKey("objectId", equalTo: messageID)
        
        // Limit what could be a lot of points.
        query.limit = 1
        
        // SEND synchronous request and GET final list of open Chat Requests objects
        do {
            var objects = try query.findObjects()
            
            // Ensure that only one object was found
            if(objects.count > 1) {
                
                print("error")
                
                objects.removeAll()
            }
            else {
                chatTitle = objects.first
            }
        }
        catch {
            print("error")
        }
        
        return chatTitle!
        
    }
    
    func getChatMessages(chatID: String) -> [PFObject] {
        
        // Create a query for messages
        let query = PFQuery(className:"Chat")

        query.whereKey("chatID", equalTo: chatID)

        // Sorted by date
        // GET latest messages at first
        query.orderByAscending("createdAt")

        // SEND synchronous request and GET final list of open Chat Requests objects
        do {
            try chatMessages = query.findObjects()
        }
        catch {
            print("error")
        }
        
        return self.chatMessages!
        
    }
}