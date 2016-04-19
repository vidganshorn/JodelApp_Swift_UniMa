//
//  ChatRoom.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/19/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

import UIKit

/*
 *  Attributes & Methods on server
 *
 *  attributes: name, id, owner, people, peopleLimit, status, private
 *  function:   addPerson, removePerson, getPerson, isAvailable, isPrivate
 */

struct ChatRoom {
    
    var name: String
    
    var user1: String
    var user2: String
    
    var messageID: String
    
    /*
    // Initialize ChatRoom with name
    init(name: String) {
        
        self.name = name;
    }
    */
    
}