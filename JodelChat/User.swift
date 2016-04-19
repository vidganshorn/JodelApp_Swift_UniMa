//
//  User.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/18/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

struct User {
    
    var deviceID: String
    
    // Initialize User with Device ID
    init() {
        
        self.deviceID = (UIDevice.currentDevice().identifierForVendor?.UUIDString)!
    }
    
    /*
    func getDeviceID() -> String {
        
        return deviceID
    }
    */
}