//
//  RoomViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/16/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

import Parse
import Bolts

class UserTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var users = [[String: AnyObject]]()
    
    var connectedUsers = [JodelUser]()
    
    @IBOutlet weak var tblUserList: UITableView!
    
    var configurationOK = false

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    func refresh() {
        tblUserList.reloadData()
    }
    
    @IBAction func createRoom(sender: AnyObject) {

    }
   
    @IBAction func connect(sender: AnyObject) {
        
        connectToServer()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !configurationOK {
            configureNavigationBar()
            configureTableView()
            configurationOK = true
        }
        
        
    }
    
    func connectToServer() {
        
        SocketIOManager.sharedInstance.connectToServerWithUserID(User.init().deviceID, completionHandler: { (userList) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.appDelegate.userManager.userList.removeAll()
                
                if userList.count != 0 {

                    for object in userList {
                        
                        let user = JodelUser(deviceID: object["deviceID"] as! String, isConnected: object["isConnected"] as! Bool)
                        
                        print(object["deviceID"] as! String)
                        
                        self.appDelegate.userManager.addNewUser(user) 
                    }
                    
                    self.connectedUsers = self.appDelegate.userManager.getUsers()
                    
                    self.tblUserList.reloadData()
                    self.tblUserList.hidden = false
                }
            })
        })
    }
    
    func configureNavigationBar() {
        navigationItem.title = "JodelChat"
    }
    
    func configureTableView() {
        
        tblUserList.delegate = self
        tblUserList.dataSource = self
        tblUserList.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "idCellUser")
        tblUserList.hidden = true
        tblUserList.tableFooterView = UIView(frame: CGRectZero)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // number if sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        // number of cells
        return connectedUsers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellUser", forIndexPath: indexPath) as! UserCell
    
        if(!connectedUsers.isEmpty) {

            cell.textLabel?.text = self.connectedUsers[indexPath.row].deviceID

            cell.detailTextLabel?.text = (self.connectedUsers[indexPath.row].isConnected ) ? "Online" : "Offline"
            cell.detailTextLabel?.textColor = (self.connectedUsers[indexPath.row].isConnected ) ? UIColor.greenColor() : UIColor.redColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let alertController = UIAlertController(title: "Hey Jodler 😎", message: "What do you want to do?", preferredStyle: .ActionSheet)
        
        let callAction = UIAlertAction(title: "Start Chat 💬", style: .Default, handler: {
            action in
                self.createChatRequest((self.users[indexPath.row]["nickname"] as? String)!)
            }
        )
        alertController.addAction(callAction)
        
        let defaultAction = UIAlertAction(title: "Better not 🚫🤔", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func createChatRequest(user2: String) {

        let chatRoom = PFObject(className:"ChatRoom")
        
        // User1 is requestor
        chatRoom["user1"] = User.init().deviceID
        
        // User2 is receiver
        chatRoom["user2"] = user2
        
        // ChatRoom is closed
        chatRoom["isOpen"] = false
        
        chatRoom.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                // The object has been saved.
                print("The object has been saved.")
                
                print("The chatroom ID is " + chatRoom.objectId!)
                
                // SocketIOManager.sharedInstance.createChatRoom(chatRoom.objectId!)
                
                // self.performSegueWithIdentifier("chatRoomSegue", sender: nil)
                
                //TODO
                // ADD Alert for Success message
            }
            else {
                // There was a problem, check error.description
                print(error?.description)
            }
        }
    }
}