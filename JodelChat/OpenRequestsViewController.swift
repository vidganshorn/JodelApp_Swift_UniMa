//
//  ChatRoomViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/19/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

import Bolts
import Parse

class OpenRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var requests: [PFObject]?
    var openRequests = 0
    
    var currentRequest: [PFObject]?
    
    var roomID: String!
    
    // unique chatID to identify the chats
    var chatID: String!
    
    @IBOutlet var tblOpenRequests: UITableView!
    
    let cellGreenColor = UIColor(hexString: "#47C7AEff")
    let cellBlueColor = UIColor(hexString: "#5DAAE3ff")
    let cellPinkColor = UIColor(hexString: "#AE78C4ff")
    let cellOrangeColor = UIColor(hexString: "#EC766Cff")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblOpenRequests.delegate = self
        self.tblOpenRequests.dataSource = self
        
        tblOpenRequests.registerClass(UITableViewCell.self, forCellReuseIdentifier: "subtitleCell")
        
        tblOpenRequests.tableFooterView = UIView()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(requests!.isEmpty) {
            return 1
        }

        return requests!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // let cell = tableView.dequeueReusableCellWithIdentifier("idCellUser", forIndexPath: indexPath) as! UserCell
        
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        
        cell.contentView.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.contentView.layer.borderWidth = 5.0
        
        cell.textLabel?.font = UIFont.systemFontOfSize(10)
        
        if(requests!.isEmpty == false) {
            
            let message = getJodelMessages(requests![indexPath.row])
            
            cell.textLabel?.text = message.objectForKey("text") as! String!
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.font = UIFont.systemFontOfSize(14)

            cell.detailTextLabel?.textAlignment = .Center
            cell.detailTextLabel?.textColor = UIColor.whiteColor()
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
            
            /*
             *  GET actual date for message
             */
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let currentDate = NSDate()
            let createdAt = message.createdAt!
            
            let diffDateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: createdAt, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
            
            // Date/ Time difference between message and actual time
            if(diffDateComponents.year != 0) {
                
                if(diffDateComponents.year == 1) {
                    cell.detailTextLabel?.text = "\(diffDateComponents.year) year ago"
                }
                else {
                    cell.detailTextLabel?.text = "\(diffDateComponents.year) years ago"
                }
            }
            else if(diffDateComponents.month != 0) {
                
                if(diffDateComponents.month == 1) {
                    cell.detailTextLabel?.text = "\(diffDateComponents.month) month ago"
                }
                else {
                    cell.detailTextLabel?.text = "\(diffDateComponents.month) months ago"
                }
            }
            else if(diffDateComponents.hour != 0) {
                
                if(diffDateComponents.hour == 1) {
                    cell.detailTextLabel?.text = "\(diffDateComponents.hour) hour ago"
                }
                else {
                    cell.detailTextLabel?.text = "\(diffDateComponents.hour) hours ago"
                }
            }
            else if(diffDateComponents.minute != 0) {
                
                if(diffDateComponents.minute == 1) {
                    cell.detailTextLabel?.text = "\(diffDateComponents.minute) minute ago"
                }
                else {
                    cell.detailTextLabel?.text = "\(diffDateComponents.minute) minutes ago"
                }
            }
            else {
                
                if(diffDateComponents.second > 10) {
                    cell.detailTextLabel?.text = "\(diffDateComponents.second) seconds ago"
                }
                else {
                    cell.detailTextLabel?.text = "now"
                }
            }
        }
        else {
            cell.textLabel?.text = "No Open Requests available 😰"
            print("No Open Requests")
            
            cell.textLabel?.textColor = UIColor.whiteColor()
            
            cell.contentView.layer.borderColor = UIColor.whiteColor().CGColor;
            cell.contentView.layer.borderWidth = 5.0

        }
        
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    
        let decline = UITableViewRowAction(style: .Normal, title: "Decline") { action, index in
            
            // either change nothing
            // or delete request from server
            if(self.requests!.count == 1) {
                
                self.requests!.removeAll()
                
                tableView.reloadData()
                //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            }
            else {
                
                self.requests!.removeAtIndex(indexPath.row)
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
            }
        }
        decline.backgroundColor = UIColor.redColor()
        
        let accept = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
            
            // generated chatID based on messageID, deviceID of user1, and deviceID of user2
            // chatID = "\(messageID)$\(user1)$\(user2)"
            self.chatID = "\(self.requests![indexPath.row]["messageID"])$\(self.requests![indexPath.row]["user1"])$\(self.requests![indexPath.row]["user2"])"

            SocketIOManager.sharedInstance.createChatRoom(self.chatID, completionHandler: { (roomInfo) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if roomInfo.isEmpty != true {
                        
                        var request = PFObject(className: "ChatRoom")
   
                        request = self.requests![indexPath.row]
                        
                        print(request)
      
                        request["socket_IO_ID"] = roomInfo["id"]
                        request["isOpen"] = true
                        
                        request.saveInBackground()
                        
                        if(self.requests!.count == 0) {
                            // Do Nothing
                            tableView.reloadData()
                        }
                        else if(self.requests!.count == 1) {
                            
                            self.requests?.removeAtIndex(indexPath.row)
                            
                            // tableView.beginUpdates()
                            // tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                            // tableView.endUpdates()
                        
                            tableView.reloadData()
                        }
                        else {
                            
                            self.requests?.removeAtIndex(indexPath.row)
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                            // tableView.reloadData()
                        }
                        
                    }
                    else {
                        print("Room ID is empty")
                    }
                })
            })
        }
        accept.backgroundColor = UIColor.lightGrayColor()
        
        return [accept, decline]

   }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions

    }
    
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        
        super.willMoveToParentViewController(parent)
        
        if parent == nil {
            
            // requests?.removeAll()
        }
    }
    
    func getOpenRequests() -> [PFObject] {
        
        //self.requests?.removeAll()
        
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
            let objects = try query.findObjects()
            
            self.requests = objects
        }
        catch {
            print("error")
        }
        
        return self.requests!
    }
    
    func getJodelMessages(jodel: PFObject) -> PFObject{
        
        var messages: [PFObject]?
        
        // Create a query for messages
        let query = PFQuery(className:"Message")
        print("jodel.objectId")
        print(jodel.objectId)
        // Interested in messages within 10km near to user.
        query.whereKey("objectId", equalTo: jodel.objectForKey("messageID")!)
        
        // GET latest messages at first
        // query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        // query.limit = 20
        
        // SEND synchronous request and GET final list of open Chat Requests objects
        do {
            try messages = query.findObjects()
            
            print(messages)
        }
        catch {
            print("error")
        }
        
        return messages![0]
    }
 
}
