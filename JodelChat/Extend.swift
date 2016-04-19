//
//  Extend.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/17/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

import Parse

extension PFObject
{
    func wrapMessage(message:Message)
    {
        self["text"] = message.text!
        self["deviceID"] = message.deviceID!
        self["username"] = "Louai iPhone"
        self["location"] = PFGeoPoint(latitude: message.latitude!, longitude: message.longitude!);
        self["rating"] = 0
        
        // Make sure the image name is unique just in case Parse overwrite files with the same name.
        let epochTime = NSDate().timeIntervalSince1970
        
        // Example image_1458567886.png
        let imageName = "image_\(epochTime).png";
        
        let image:PFFile = PFFile(name: imageName, data: message.uploadedImage!)!;
        self["uploadedImage"] = image;
    }
}