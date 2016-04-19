//
//  RequestViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/19/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

import Parse
import Bolts

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let headerTitles = ["My Chats 💬", "Chats for Me 💬"]
    
    let cellGreenColor = UIColor(hexString: "#47C7AEff")
    let cellBlueColor = UIColor(hexString: "#5DAAE3ff")
    let cellPinkColor = UIColor(hexString: "#AE78C4ff")
    let cellOrangeColor = UIColor(hexString: "#EC766Cff")
    
    var myChats = [PFObject]()
    var chats4Me = [PFObject]()
    
    var currentJodel: PFObject?
    
    var chats: [PFObject]?
    
    var requests: [PFObject]?
    var openRequests = 0
    
    var openChatRoom: PFObject?
    
    @IBOutlet var tblChats: UITableView!
    
    var refreshControl = UIRefreshControl()
    
    //var jodelMessages: [PFObject]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        getMyOpenChatRooms()
        getOpenChatRooms4Me()
        setNavigationItemBadgeValue()
        
        // Refresh TableView when pulling down
        // set up the refresh control
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "reloadOpenChatRooms:", forControlEvents: UIControlEvents.ValueChanged)
        tblChats!.addSubview(refreshControl)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // number of sections
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // number of sections
        if(section == 0) {
            
            if(myChats.isEmpty != true) {
                
                return myChats.count
            }
            else {
                return 1
            }
            
        }
        else {
            
            if(chats4Me.isEmpty != true) {
                
                return chats4Me.count
            }
            else {
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
        
            if(myChats.isEmpty == true) {
                return 75
            }
            else {
                return 150
            }
        }
        else {
            if(chats4Me.isEmpty == true) {
                return 75
            }
            else {
                return 150
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("chatRoomCell", forIndexPath: indexPath) as! ChatRoomCell
            
            /*
             * Setting for cell separator
             */
            cell.contentView.layer.borderColor = UIColor.whiteColor().CGColor;
            cell.contentView.layer.borderWidth = 5.0
            
            if(myChats.isEmpty == true) {
                
                // cell.accessoryType = UITableViewCellAccessoryType.None
                
                cell.backgroundColor = cellBlueColor
                
                cell.textLabel?.hidden = false
                
                cell.textLabel?.text = "You haven't started any Chat yet 😰"
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.textLabel?.font = UIFont.systemFontOfSize(14)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            else {
                // If a chat is available
                // show DisclosureIndicator
                // cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.accessoryType = UITableViewCellAccessoryType.None
                
                cell.textLabel?.hidden = true
                
                let currentJodel = getJodelMessage(myChats[indexPath.row].objectForKey("messageID") as! String)
                
                cell.jodelTextView.text = currentJodel.objectForKey("text") as! String
                cell.jodelTextView.textColor = UIColor.whiteColor()
                cell.jodelTextView.font = UIFont.systemFontOfSize(14)
                
                /*
                 *  GET actual date for message
                 */
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let currentDate = NSDate()
                let createdAt = currentJodel.createdAt!
                
                let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: createdAt, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
                
                // Date/ Time difference between message and actual time
                if(diffDateComponents.year != 0) {
                    
                    if(diffDateComponents.year == 1) {
                        cell.createdAtLabel.text = "\(diffDateComponents.year) year ago"
                    }
                    else {
                        cell.createdAtLabel.text = "\(diffDateComponents.year) years ago"
                    }
                }
                else if(diffDateComponents.month != 0) {
                    
                    if(diffDateComponents.month == 1) {
                        cell.createdAtLabel.text = "\(diffDateComponents.month) month ago"
                    }
                    else {
                        cell.createdAtLabel.text = "\(diffDateComponents.month) months ago"
                    }
                }
                else if(diffDateComponents.hour != 0) {
                    
                    if(diffDateComponents.hour == 1) {
                        cell.createdAtLabel.text = "\(diffDateComponents.hour) hour ago"
                    }
                    else {
                        cell.createdAtLabel.text = "\(diffDateComponents.hour) hours ago"
                    }
                }
                else if(diffDateComponents.minute != 0) {
                    
                    if(diffDateComponents.minute == 1) {
                        cell.createdAtLabel.text = "\(diffDateComponents.minute) minute ago"
                    }
                    else {
                        cell.createdAtLabel.text = "\(diffDateComponents.minute) minutes ago"
                    }
                }
                else {
                    
                    if(diffDateComponents.second > 10) {
                        cell.createdAtLabel.text = "\(diffDateComponents.second) seconds ago"
                    }
                    else {
                        cell.createdAtLabel.text = "now"
                    }
                }
                
                cell.createdAtLabel.textColor = UIColor.whiteColor()
                
                
                /*
                 *  Location for message
                 */
                let location = currentJodel.objectForKey("location") as? PFGeoPoint
                
                let geoCoder = CLGeocoder()
                let geoLocation = CLLocation(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
                
                geoCoder.reverseGeocodeLocation(geoLocation) {
                    (placemarks, error) -> Void in
                    
                    let placeArray = placemarks as [CLPlacemark]!
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    cell.locationLabel.text = placeMark.addressDictionary?["City"] as? String
                }
                
                cell.locationLabel.textColor = UIColor.whiteColor()
            
            
            /*
             * Color cells
             */
            if(indexPath.row % 3 == 0) {
                
                cell.backgroundColor = cellBlueColor
                // cell.jodelTextView.backgroundColor = cellBlueColor
            }
            else if (indexPath.row % 2 == 0) {
                
                cell.backgroundColor = cellOrangeColor
                // cell.jodelTextView.backgroundColor = cellOrangeColor
            }
            else {
                
                cell.backgroundColor = cellGreenColor
                // cell.jodelTextView.backgroundColor = cellGreenColor
            }
            }
            
            return cell
        }
        else {
            
            let cell2 = tableView.dequeueReusableCellWithIdentifier("chatRoomCell", forIndexPath: indexPath) as! ChatRoomCell
            
            /*
             * Setting for cell separator
             */
            // cell.backgroundColor = UIColor.lightGrayColor()
            cell2.contentView.layer.borderColor = UIColor.whiteColor().CGColor;
            cell2.contentView.layer.borderWidth = 5.0
            
            if(chats4Me.isEmpty == true) {
                
                // cell2.accessoryType = UITableViewCellAccessoryType.None
                
                cell2.backgroundColor = cellOrangeColor
                
                cell2.textLabel?.hidden = false
                
                cell2.textLabel?.text = "There are no Chats available 📵😵"
                cell2.textLabel?.textColor = UIColor.whiteColor()
                cell2.textLabel?.font = UIFont.systemFontOfSize(14)
                cell2.selectionStyle = UITableViewCellSelectionStyle.None
            }
            else {
                // If a chat is available
                // show DisclosureIndicator
                // cell2.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
                cell2.textLabel?.hidden = true
                
                currentJodel = getJodelMessage(chats4Me[indexPath.row].objectForKey("messageID") as! String)
                
                cell2.jodelTextView.text = currentJodel!.objectForKey("text") as! String
                cell2.jodelTextView.textColor = UIColor.whiteColor()
                cell2.jodelTextView.font = UIFont.systemFontOfSize(14)
                
                /*
                 *  GET actual date for message
                 */
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let currentDate = NSDate()
                let createdAt = currentJodel!.createdAt!
                
                let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: createdAt, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
                
                // Date/ Time difference between message and actual time
                if(diffDateComponents.year != 0) {
                    
                    if(diffDateComponents.year == 1) {
                        cell2.createdAtLabel.text = "\(diffDateComponents.year) year ago"
                    }
                    else {
                        cell2.createdAtLabel.text = "\(diffDateComponents.year) years ago"
                    }
                }
                else if(diffDateComponents.month != 0) {
                    
                    if(diffDateComponents.month == 1) {
                        cell2.createdAtLabel.text = "\(diffDateComponents.month) month ago"
                    }
                    else {
                        cell2.createdAtLabel.text = "\(diffDateComponents.month) months ago"
                    }
                }
                else if(diffDateComponents.hour != 0) {
                    
                    if(diffDateComponents.hour == 1) {
                        cell2.createdAtLabel.text = "\(diffDateComponents.hour) hour ago"
                    }
                    else {
                        cell2.createdAtLabel.text = "\(diffDateComponents.hour) hours ago"
                    }
                }
                else if(diffDateComponents.minute != 0) {
                    
                    if(diffDateComponents.minute == 1) {
                        cell2.createdAtLabel.text = "\(diffDateComponents.minute) minute ago"
                    }
                    else {
                        cell2.createdAtLabel.text = "\(diffDateComponents.minute) minutes ago"
                    }
                }
                else {
                    
                    if(diffDateComponents.second > 10) {
                        cell2.createdAtLabel.text = "\(diffDateComponents.second) seconds ago"
                    }
                    else {
                        cell2.createdAtLabel.text = "now"
                    }
                }
                
                cell2.createdAtLabel.textColor = UIColor.whiteColor()
                
                
                /*
                 *  Location for message
                 */
                let location = currentJodel!.objectForKey("location") as? PFGeoPoint
                
                let geoCoder = CLGeocoder()
                let geoLocation = CLLocation(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
                
                geoCoder.reverseGeocodeLocation(geoLocation) {
                    (placemarks, error) -> Void in
                    
                    let placeArray = placemarks as [CLPlacemark]!
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    cell2.locationLabel.text = placeMark.addressDictionary?["City"] as? String
                }
                
                cell2.locationLabel.textColor = UIColor.whiteColor()
            
            
            /*
             * Color cells
             */
            if(indexPath.row % 3 == 0) {
                
                cell2.backgroundColor = cellBlueColor
                // cell.jodelTextView.backgroundColor = cellBlueColor
            }
            else if (indexPath.row % 2 == 0) {
                
                cell2.backgroundColor = cellOrangeColor
                // cell.jodelTextView.backgroundColor = cellOrangeColor
            }
            else {
                
                cell2.backgroundColor = cellGreenColor
                // cell.jodelTextView.backgroundColor = cellGreenColor
            }
            }
            
            return cell2

        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            
            if(myChats.isEmpty != true) {
                openChatRoom = myChats[indexPath.row]
            }
        }
        else {
            if(chats4Me.isEmpty != true) {
                openChatRoom = chats4Me[indexPath.row]
            }
        }

        // Send Request to Node.JS server
        // to join Node.JS Chat Room
        SocketIOManager.sharedInstance.joinChatRoom(openChatRoom!["socket_IO_ID"] as! String)
        
        performSegueWithIdentifier("chatSegue", sender: nil)
    }
    
    func showRequests(sender:UIButton!) {
        
        performSegueWithIdentifier("showRequestsSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "showRequestsSegue") {
            
            let nextViewController = (segue.destinationViewController as! OpenRequestsViewController)
            nextViewController.requests = requests
        }
        if(segue.identifier == "chatSegue") {
            
            let nextViewController = (segue.destinationViewController as! ChatViewController)

            nextViewController.user1 = openChatRoom?.objectForKey("user1") as? String
            nextViewController.user2 = openChatRoom?.objectForKey("user2") as? String
            nextViewController.messageID = openChatRoom?.objectForKey("messageID") as? String
            nextViewController.socketChatRoomID = openChatRoom?.objectForKey("socket_IO_ID") as? String
            
        }
    }
    
    func setNavigationItemBadgeValue() {
        
        // If you want your BarButtonItem to handle touch event and click, use a UIButton as customView
        let customButton = UIButton.init(frame: CGRectMake(0, 0, 50, 25))
        
        // Add your action to your button
        // [customButton addTarget:self action:@selector(barButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        // Customize your button as you want, with an image if you have a pictogram to display for example
        customButton.setImage(UIImage(named: "notifications"), forState: .Normal)
        
        // Call Action "showRequests" if button was clicked
        customButton.addTarget(self, action: "showRequests:", forControlEvents: UIControlEvents.TouchDown)
        
        // Then create and add our custom BBBadgeBarButtonItem
        let barButton = BBBadgeBarButtonItem(customUIButton: customButton)
        
        // Get number of open chat requests
        openRequests = getOpenRequests().count
        
        // Set a value for the badge
        barButton.badgeValue = String(openRequests)
        
        // Add it as the leftBarButtonItem of the navigation bar
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    func getMyOpenChatRooms() -> [PFObject]{
        
        // Create a query for messages
        // let query = PFQuery(className:"ChatRoom")
        
        // Interested in messages within 10km near to user.
        // query.whereKey("user1", equalTo: (User.init().deviceID as String))
        // query.whereKey("isOpen", equalTo: true)
        
        let query = PFQuery(className:"ChatRoom")
        query.whereKey("user1", equalTo: User.init().deviceID as String)
        
       // let getUser2 = PFQuery(className:"ChatRoom")
       // getUser2.whereKey("user2", equalTo: User.init().deviceID as String)
        
        // let chatIsOpen = PFQuery(className:"ChatRoom")
        // chatIsOpen.whereKey("isOpen", equalTo: true)
        
        //let query = PFQuery.orQueryWithSubqueries([getUser1, getUser2])
        
        query.whereKey("isOpen", equalTo: true)
        
        // GET latest messages at first
        query.orderByDescending("updatedAt")
        
        // Limit what could be a lot of points.
        query.limit = 20
        
        // SEND synchronous request and GET final list of open Chat Requests objects
        do {
            try myChats = query.findObjects()
        }
        catch {
            print("error")
        }
        
        return self.myChats
    }
    
    func getOpenChatRooms4Me() -> [PFObject]{
        
        // Create a query for messages
        // let query = PFQuery(className:"ChatRoom")
        
        // Interested in messages within 10km near to user.
        // query.whereKey("user1", equalTo: (User.init().deviceID as String))
        // query.whereKey("isOpen", equalTo: true)
        
        let query = PFQuery(className:"ChatRoom")
        query.whereKey("user2", equalTo: User.init().deviceID as String)
        
        // let getUser2 = PFQuery(className:"ChatRoom")
        // getUser2.whereKey("user2", equalTo: User.init().deviceID as String)
        
        // let chatIsOpen = PFQuery(className:"ChatRoom")
        // chatIsOpen.whereKey("isOpen", equalTo: true)
        
        //let query = PFQuery.orQueryWithSubqueries([getUser1, getUser2])
        
        query.whereKey("isOpen", equalTo: true)
        
        // GET latest messages at first
        query.orderByDescending("updatedAt")
        
        // Limit what could be a lot of points.
        query.limit = 20
        
        // SEND synchronous request and GET final list of open Chat Requests objects
        do {
            try chats4Me = query.findObjects()
        }
        catch {
            print("error")
        }
        
        return self.chats4Me
    }
    
    func reloadOpenChatRooms(refreshControl: UIRefreshControl) {
        
        myChats.removeAll()
        chats4Me.removeAll()
        
        currentJodel = nil
        
        getMyOpenChatRooms()
        getOpenChatRooms4Me()
        
        tblChats.reloadData()
        refreshControl.endRefreshing()
        
        getOpenRequests()
        setNavigationItemBadgeValue()
        
    }
    
    func getOpenRequests() -> [PFObject] {
        
        // Create a query for messages
        let query = PFQuery(className:"ChatRoom")
        
        // Interested in messages within 10km near to user.
        query.whereKey("user2", equalTo: (User.init().deviceID as String))
        query.whereKey("isOpen", equalTo: false)
        
        // GET latest messages at first
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        // query.limit = 20
        
        // SEND synchronous request and GET final list of open Chat Requests objects
        do {
            try requests = query.findObjects()
        }
        catch {
            print("error")
        }
        
        return self.requests!
    }
    
    
    func getJodelMessage(jodelID: String) -> PFObject{
        
        currentJodel = nil
        
        var messages: [PFObject]?
        
        // Create a query for messages
        let query = PFQuery(className:"Message")
        
        // Interested in messages within 10km near to user.
        query.whereKey("objectId", equalTo: jodelID)
        
        // GET latest messages at first
        // query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        query.limit = 1
        
        // SEND synchronous request and GET final list of open Chat Requests objects
        do {
            try messages = query.findObjects()
            
            currentJodel = messages![0]

        }
        catch {
            print("error")
        }
        
        return currentJodel!
    }

}
