//
//  SocketIOManager.swift
//  SocketChat
//
//  Created by David Ganshorn on 3/22/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import UIKit

import Parse
import Bolts

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://134.155.207.86:3000")!)
    
    
    override init() {
        super.init()
    }
    
    
    func establishConnection() {
        socket.connect()
        
        print("Connection was established")
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToServerWithUserID(deviceID: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {

        socket.emit("connectUser", deviceID)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
            
            print("Successful connected to Server")
        }
        
        listenForOtherMessages()
    }
    

    func createChatRoom(chatID: String, completionHandler: (roomInfo: [String: AnyObject]) -> Void) {

        socket.emit("createRoom", chatID, User.init().deviceID)
        
        socket.on("socketRoomID") { (dataArray, socketAck) -> Void in

        var roomDictionary = [String: AnyObject]()
        roomDictionary["id"] = dataArray[0] as! String

        completionHandler(roomInfo: roomDictionary)
            
        roomDictionary.removeAll()
        }
    }
    
    func joinChatRoom(roomID: String) {

        socket.emit("joinRoom", roomID, User.init().deviceID)
    }
    
    func sendMessage(message: String, chatID: String, socketChatRoomID: String, emitter: String) {
        socket.emit("sendMessage", message, chatID, socketChatRoomID, emitter)
    }
    
    func getChatMessage(completionHandler: (messageInfo: [String: AnyObject]) -> Void) {
        
        socket.on("getChatMessage") { (dataArray, socketAck) -> Void in

            var messageDictionary = [String: AnyObject]()
            messageDictionary["message"] = dataArray[0] as! String
            messageDictionary["emitter"] = dataArray[1] as! String
            messageDictionary["roomID"] = dataArray[2] as! String
            
            completionHandler(messageInfo: messageDictionary)
        }
    }


    func sendStartTypingMessage(roomID: String) {
        socket.emit("startType", User.init().deviceID, roomID)
    }
    
    func sendStopTypingMessage(roomID: String) {
        socket.emit("stopType", User.init().deviceID, roomID)
    }
    
    func getUserStatus(deviceID: String) {
        socket.emit("getUserStatus", deviceID)
        
        listenForOtherMessages()
    }
    
    
    
    private func listenForOtherMessages() {
        
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            print("success")
            
            NSNotificationCenter.defaultCenter().postNotificationName("userWasConnectedNotification", object: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("isTyping") { (dataArray, socketAck) -> Void in
            
            var typingUsersDictionary = [String: AnyObject]()
            
            typingUsersDictionary["isTyping"] = dataArray[0] as! String
            typingUsersDictionary["emitter"] = dataArray[1] as! String
            typingUsersDictionary["roomID"] = dataArray[2] as! String

            NSNotificationCenter.defaultCenter().postNotificationName("isTyping", object: typingUsersDictionary)
        }
        
        socket.on("isUserOnline") { (dataArray, socketAck) -> Void in
            
            var connectedUsersDictionary = [String: AnyObject]()
            
            connectedUsersDictionary["isConnected"] = dataArray[0] as! String
            
            NSNotificationCenter.defaultCenter().postNotificationName("isUserOnline", object: connectedUsersDictionary)
        }
    }
}
