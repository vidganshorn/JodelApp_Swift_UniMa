//
//  InitialTabBarController.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/10/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

import Parse
import Bolts

class InitialTabBarController: UITabBarController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var users = [[String: AnyObject]]()
    
    var connectedUsers = [JodelUser]()
    
    var configurationOK = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        connectToServer()
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
                }
            })
        })
    }
    
}