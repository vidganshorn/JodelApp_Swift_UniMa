//
//  ConnectionManager.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/5/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

class ConnectedUserManager {
    
    var userList = [JodelUser]()
    
    func getUsers() -> [JodelUser] {
        
        return self.userList
    }
    
    func updateUser(user: JodelUser) {
        
        var int = 0
        
        for object in userList {
            
            if(object.deviceID == user.deviceID) {
                
                userList[int].isConnected = object.isConnected
            }
        }
    }

    func addNewUser(user: JodelUser) {
        
            userList.append(user)
    }
}