//
//  UserList.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/5/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

class JodelUser: NSObject {
    
    var deviceID: String
    var isConnected: Bool
    
    // Initialize User with Device ID
    init(deviceID: String, isConnected: Bool) {
        
        self.deviceID = deviceID
        self.isConnected = isConnected

    }
    
    
}
