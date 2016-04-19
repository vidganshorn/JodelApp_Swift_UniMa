//
//  Message.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/17/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

import Parse
import Bolts

class Message {
    
    var objectID: String?
    var deviceID: String?
    
    var text: String?
    var username: String?
 
    var longitude: Double?
    var latitude: Double?
    
    var rating: Int?
    
    var createdAt: String?
    var updatedAt: String?
    
    var uploadedImage: NSData?;
}
