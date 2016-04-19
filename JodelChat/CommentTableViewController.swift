//
//  CommentTableViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/18/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

import Parse
import Bolts

class CommentTableViewController: UITableViewController {
    
    // Store comments from the server in this array
    var comments = [String]()
    
    // Store temporary comments from the server in this array
    var commentObjects = [PFObject]()
    
    // Store temporary comments from the server in this array
    var objects = [PFObject]()
    
    // MessageId for comment
    var messageID = String()
    
    var messageIdForComment = String()
    
    let cellGreenColor = UIColor(hexString: "#47C7AEff")
    let cellBlueColor = UIColor(hexString: "#5DAAE3ff")
    let cellPinkColor = UIColor(hexString: "#AE78C4ff")
    let cellOrangeColor = UIColor(hexString: "#EC766Cff")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getComments()
        
        self.refreshControl?.addTarget(self, action: "reloadComments:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // number of cells
        var count = Int()
        
        if(objects.count == 0) {
            count = 1
        }
        else {
            count = objects.count
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // let cell = tableView.dequeueReusableCellWithIdentifier("idCellUser", forIndexPath: indexPath) as! UserCell
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: nil)
        
        cell.contentView.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.contentView.layer.borderWidth = 5.0
        
        cell.textLabel?.font = UIFont.systemFontOfSize(14)
        
        if(objects.isEmpty == false) {

            cell.textLabel?.text = objects[indexPath.row].objectForKey("commentText") as! String!
            cell.textLabel?.textColor = UIColor.whiteColor()
            
            cell.detailTextLabel?.textAlignment = .Center
            cell.detailTextLabel?.textColor = UIColor.whiteColor()
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
            
            /*
             *  GET actual date for message
             */
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let currentDate = NSDate()
            let createdAt = objects[indexPath.row].createdAt!
            
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
            cell.textLabel?.text = "No Comments available 😰"

            cell.textLabel?.textColor = UIColor.whiteColor()
            
            cell.textLabel?.textAlignment = .Center
            
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 75
    }
    
    
    
    /*
     *
     *   Function -  GET messages nearby
     *               based on your current location
     *
     */
    func getComments() -> [PFObject] {
        
        // Create a query for messages
        let query = PFQuery(className:"Comment")
        
        // Interested in messages within 10km near to user.
        query.whereKey("messageID", equalTo: messageID)
        
        // GET latest messages at first
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        query.limit = 20
        
        // SEND synchronous request and GET final list of (comment) objects
        do {
            try objects = query.findObjects()
        }
        catch {
            print("error")
        }

        return self.objects
    }
    
    /*
     *
     *   Function -  GET messages nearby
     *               based on your current location
     *
     */
    func reloadComments(refreshControl: UIRefreshControl) {
        
        objects.removeAll()

        getComments()
        
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
    }
    
}
