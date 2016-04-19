//
//  JodelFeedViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/4/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import CoreLocation

import Parse
import Bolts

class JodelFeedTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    // Store temporary messages from the server in this array
    var objects = [PFObject]()
    
    // Store messages: String from the server in this array
    var jodels = [String]()
    
    var objectIdForChat = String()
    
    let cellGreenColor = UIColor(hexString: "#47C7AEff")
    let cellBlueColor = UIColor(hexString: "#5DAAE3ff")
    let cellPinkColor = UIColor(hexString: "#AE78C4ff")
    let cellOrangeColor = UIColor(hexString: "#EC766Cff")
    
    var refreshControl = UIRefreshControl()
    
    var showStatusBar = true
    
    var fullScreenImage: UIImageView!;
    var blackBackgroundFrame: UIImageView!
    
    @IBOutlet var tblJodelFeed: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // Get messages when loading view
        getMessagesNearby()
        
        //Problem: TableView is underneath the StatusBar
        //Quickfix is done here but has to be better in Future
        self.tblJodelFeed.contentInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Refresh TableView when pulling down
        // set up the refresh control
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh new jodels 📬")
        self.refreshControl.addTarget(self, action: "reloadMessagesNearby:", forControlEvents: UIControlEvents.ValueChanged)
        
        tblJodelFeed!.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        //self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // number of cells
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("newsFeedCell", forIndexPath: indexPath) as! NewsFeedCell
        
        /*
         * Setting for cell separator
        */
        // cell.backgroundColor = UIColor.lightGrayColor()
        cell.contentView.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.contentView.layer.borderWidth = 5.0
        
        
        // Handle long pressed gesture
        let longPressed = UILongPressGestureRecognizer(target: self, action: "onLongPressed:");
        
        cell.jodelTextView.text = objects[indexPath.row].objectForKey("text") as! String
        cell.jodelTextView.textColor = UIColor.whiteColor()
        cell.jodelTextView.font = UIFont.systemFontOfSize(14)
        // cell.jodelTextView.backgroundColor = UIColor.clearColor()
        
        let likes = objects[indexPath.row].objectForKey("rating") as! Int
        cell.likeLabel.text = String(likes)
        
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
        let location = objects[indexPath.row].objectForKey("location") as? PFGeoPoint
        
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
         *  Create Chat Request for message
         */
        cell.onchatButtonTapped = {
            
            let alertController = UIAlertController(title: "Hey Jodler 😎", message: "What do you want to do?", preferredStyle: .ActionSheet)
            
            let callAction = UIAlertAction(title: "Start Chat 💬", style: .Default, handler: {
                action in
                
                let messageID = self.objects[indexPath.row].objectId!
                let user2 = self.objects[indexPath.row].objectForKey("deviceID") as! String
                
                self.createChatRequest(messageID, user2: user2)
                }
            )
            alertController.addAction(callAction)
            
            let defaultAction = UIAlertAction(title: "Better not 🚫🤔", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    
        
        /*
         *  Section for Images
        */
        // In case the message has an image, show the image not the color
        
        if(objects[indexPath.row].objectForKey("uploadedImage") as? PFFile != nil) {
            
            var file = objects[indexPath.row].objectForKey("uploadedImage") as? PFFile
            
            print(objects[indexPath.row])
            
            // Get NSData from PFFile
            file!.getDataInBackgroundWithBlock ({ (data, error) -> Void in
                
                if let data = data where error == nil {
                    
                    let image = UIImage(data: data)

                    cell.uploadedImage.image = image
                    cell.jodelTextView.text = "Hold to view"
                    
                    cell.jodelTextView.textColor = UIColor.whiteColor()
                    cell.jodelTextView.font = UIFont.systemFontOfSize(14)
                    
                    cell.addGestureRecognizer(longPressed);
                }
            })
        }
        else {
            cell.uploadedImage.image = nil
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(indexPath.row)
        
        print(objects[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destination = segue.destinationViewController as? CommentTableViewController,
            cell = sender as? NewsFeedCell,
            indexpath = tblJodelFeed.indexPathForCell(cell) {
            
            let object = objects[indexpath.row]
            
            let commentID = object.objectId
            
            destination.messageID = commentID as String!
            
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        
        if showStatusBar {
            return false
        }
        return true
    }
    
    private func showStatusBar(enabled: Bool) {
        
        showStatusBar = enabled
        prefersStatusBarHidden()
        self.navigationController?.setNeedsStatusBarAppearanceUpdate();
    }
    
    
    func onLongPressed(gesture:UILongPressGestureRecognizer) {
        
        // Ignore state Changed
        if(gesture.state == .Changed)
        {
            return;
        }
        
        let cellView = gesture.view as! NewsFeedCell;
        
        // Set image to fullscreen
        if(fullScreenImage == nil) {
            
            fullScreenImage = UIImageView(frame: UIScreen.mainScreen().bounds);
            blackBackgroundFrame = UIImageView(frame: UIScreen.mainScreen().bounds);
            
            // Set transparancy to 0, we are going to animate this view
            fullScreenImage.alpha = 0.0;
            blackBackgroundFrame.alpha = 0.0;
        }
        
        // If long pressed began show full image
        if(gesture.state == .Began) {
            
            let screenHeight = UIScreen.mainScreen().bounds.height + 20
            let screnWidth = UIScreen.mainScreen().bounds.width
            
            /*
            let backgroundFrame = CGRectMake(0, (self.tblJodelFeed.contentOffset.y + (self.navigationController?.navigationBar.frame.size.height)!), screnWidth, screenHeight)
            let blackFrame = UIView(frame: backgroundFrame)
            blackFrame.backgroundColor = UIColor.blackColor()
            
            self.view.addSubview(blackFrame)
            self.view.bringSubviewToFront(blackFrame);
            
            
            let photoFrame = CGRectMake(0, (self.tblJodelFeed.contentOffset.y + (self.navigationController?.navigationBar.frame.size.height)! + (screenHeight / 2) - 125), screnWidth, 250)
            
            let fullScreenImage = UIImageView(frame: photoFrame)
            fullScreenImage.image = cellView.uploadedImage.image
            
            self.view.addSubview(fullScreenImage)
            self.view.bringSubviewToFront(fullScreenImage);
            */
            
            let sizeOfBackground = CGSize(width: screnWidth, height: screenHeight)
            
            blackBackgroundFrame.frame = CGRect(origin: CGPoint(x: 0, y: self.tblJodelFeed.contentOffset.y + (self.navigationController?.navigationBar.frame.size.height)!), size: sizeOfBackground)
            blackBackgroundFrame.backgroundColor = UIColor.blackColor()
            
            self.view.addSubview(blackBackgroundFrame);
            self.view.bringSubviewToFront(blackBackgroundFrame);
            
            fullScreenImage.image = cellView.uploadedImage.image
            
            let sizeOfImage = CGSize(width: screnWidth, height: 250)
            
            fullScreenImage.frame = CGRect(origin: CGPoint(x: 0, y: self.tblJodelFeed.contentOffset.y + (self.navigationController?.navigationBar.frame.size.height)! + (screenHeight / 2) - 125), size: sizeOfImage)
            
            self.view.addSubview(fullScreenImage);
            self.view.bringSubviewToFront(fullScreenImage);
            
            // Hide Navigation bar
            self.navigationController?.setNavigationBarHidden(true, animated: true);
            
            // Hide Toolbar
            self.tabBarController?.tabBar.hidden = true;

            // Hide status bar
            showStatusBar(false)
            
            // Animate full screen image
            // change transparency from 0.0 to 1.0 in 0.1 seconds gradualy
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                self.fullScreenImage.alpha = 1.0;
                }, completion: { finished in
                    
            })
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                self.blackBackgroundFrame.alpha = 1.0;
                }, completion: { finished in
                    
            })
        }
            // Gesture has ended, dismiss the full screen image
        else {
            // Show Navigation Bar
            self.navigationController?.setNavigationBarHidden(false, animated: true);
            
            // Show Toolbar
            self.tabBarController?.tabBar.hidden = false;
            
            // Show Status bar
            showStatusBar(true)
            
            // Animate full screen image
            // change transparency from 0.0 to 1.0 in 0.2 seconds gradualy
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                self.fullScreenImage.alpha = 0.0;
                }, completion: { finished in
                    //After view alpha 0.0 do
                    
                    // Remove the view from view hierarchy
                    self.fullScreenImage.removeFromSuperview();

            })
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
                self.blackBackgroundFrame.alpha = 0.0;
                }, completion: { finished in
                    //After view alpha 0.0 do
                    
                    // Remove the view from view hierarchy
                    self.blackBackgroundFrame.removeFromSuperview()
            })
        }
    }
    
    /*
     * TODO
     *
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    */

    /*
     *
     *   Function -  GET messages nearby
     *               based on your current location
     *               synchronous call
     *
     */
    func getMessagesNearby() -> [PFObject] {
        
        // User location
        let userGeoPoint = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        
        // Create a query for messages
        let query = PFQuery(className:"Message")
        
        // Interested in messages within 10km near to user.
        query.whereKey("location", nearGeoPoint: userGeoPoint, withinKilometers: 10.0)
        
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
        
        // self.tableView?.reloadData()
        
        return self.objects
    }
    
    /*
     * Create Chat Request on Parse Server
     * before being able to chat
     * both users have to accept the request
    */
    func createChatRequest(messageID: String, user2: String) {

        let chatRoom = PFObject(className:"ChatRoom")
        
        // User1 is requestor
        chatRoom["user1"] = User.init().deviceID
        
        // User2 is receiver
        chatRoom["user2"] = user2
        
        // Jodel message which is the chat topic
        chatRoom["messageID"] = messageID
        
        // ChatRoom is closed
        chatRoom["isOpen"] = false
        
        chatRoom.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("The object has been saved.")
                
                print("The chatroom ID is " + chatRoom.objectId!)

                // TODO
                // ADD Alert for Success message
            }
            else {
                // There was a problem, check error.description
                print(error?.description)
            }
        }
    }
    
    func reloadMessagesNearby(refreshControl: UIRefreshControl) {
        
        objects.removeAll()
        
        getMessagesNearby()
        
        self.tblJodelFeed.reloadData()
        refreshControl.endRefreshing()
    }
    
}