//
//  ChatUserDetailsViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/5/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

import Parse
import Bolts

class ChatUserDetailsViewController: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var deviceID: UILabel!
    @IBOutlet weak var status: UILabel!
    
    var chatPartnerID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // var userList = appDelegate.userManager.getUsers()
        
        SocketIOManager.sharedInstance.getUserStatus(chatPartnerID)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleConnectedUserStatusNotification:", name: "isUserOnline", object: nil)
        
        
        /*
        for user in userList {
            
            if(user.deviceID == "533CAAF2-DF67-460F-AFE0-C5F19C52A92F") {
                
                deviceID.text = user.deviceID
                status.text = user.isConnected ? "Online" : "Offline"
                status.textColor = user.isConnected ? UIColor.greenColor() : UIColor.redColor()
            }
        }
         */
        
        
    }
    
    func handleConnectedUserStatusNotification(notification: NSNotification) {
    
        let connectedUsersDictionary = notification.object as! [String: AnyObject]
        
        if(connectedUsersDictionary["isConnected"] as! Bool == true) {
            
            status.text = "Online"
            status.textColor = UIColor.greenColor()
        }
        else {
            status.text = "Online"
            status.textColor = UIColor.greenColor()
        }
    }
   
}
