//
//  NewJodelViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/5/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import CoreLocation

import Parse
import Bolts

class NewJodelViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, CameraControllerDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet var sendTextView: UITextView!
    
    var msgs = [String]() //stores only all messages sent inside a local array
    //var messagesArray = [Message]() //stores the messages sent as well as the device ID
    
    @IBOutlet weak var sendMessageBarButton: UIBarButtonItem!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        
        sendTextView.delegate = self
        sendTextView.textColor = UIColor.whiteColor()
        sendTextView.font = UIFont.systemFontOfSize(17)
        
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        (self.childViewControllers[0] as! CameraController).delegate = self;
        
        // Add swipe gesture
        let swipeRight = UISwipeGestureRecognizer();
        swipeRight.addTarget(self, action: "swipeRight:")
        swipeRight.direction = .Right;
        view.addGestureRecognizer(swipeRight);
        
        let swipeLeft = UISwipeGestureRecognizer();
        swipeLeft.addTarget(self, action: "swipeLeft:")
        swipeLeft.direction = .Left;
        view.addGestureRecognizer(swipeLeft);
    }
    
    override func viewDidLayoutSubviews() {
        // Hide camera view
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        contentView.frame.origin.x = screenWidth;
    }

    @IBAction func sendMessage(sender: UIBarButtonItem) {
        
        /*
         *
         *   SEND -  SEND messages with
         *           text, your deviceID, initial rating = 0 and
         *           your current location
         *
         */
        let message = PFObject(className:"Message")
        
        message["text"] = sendTextView.text
        message["deviceID"] = User.init().deviceID
        
        let point = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        
        message["location"] = point
        
        message["rating"] = 0
        
        message.saveInBackgroundWithBlock {
            
            (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                
                let alertController = UIAlertController(title: "My Jodel", message:
                    "May the force be with you!", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Success", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                // clear Field should come after succesfull sending
                self.sendTextView.text = "Tell us another Story...."

            } else {
                let alertController = UIAlertController(title: "My Jodel", message:
                    "An error occured!", preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        //close Keyboard to enable further use of the app
        self.view.endEditing(true)
        
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        sendTextView.text = ""
    }
    
    @IBOutlet weak var sendPhoto: UIBarButtonItem!
    
    // This is callback function from CameraControllerDelegate triggered from CameraController
    func sendImagePressed(imageBytes:NSData) {
        
        var cameraController:CameraController = self.childViewControllers[0] as! CameraController;
        
        cameraController.loading.hidden = false;
        cameraController.loading.startAnimating();
        
        let locationManager = CLLocationManager();
        
        //Sending needs to happen
        //store text in variable
        let inputMsg = self.sendTextView.text;
        
        //store DeviceID in variable
        let localDeviceID = UIDevice.currentDevice().identifierForVendor?.UUIDString
        
        // Initialize message
        let currentSending = Message()
        
        currentSending.deviceID = localDeviceID
        currentSending.text = inputMsg
        currentSending.username = "Louai iPhone"
        
        let point = PFGeoPoint(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude)
        currentSending.latitude = point.latitude;
        currentSending.longitude = point.longitude;
        currentSending.rating = 0;
        
        // Add image bytes to message object.
        currentSending.uploadedImage = imageBytes;
        
        var message = PFObject(className:"Message")
        
        // The implementation of this method you can find it in Extension/Extend
        // This method add message parameters to PFObject which behaves as a Dictionary
        message.wrapMessage(currentSending);
        
        message.saveInBackgroundWithBlock
            {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    cameraController.loading.hidden = true;
                    cameraController.loading.stopAnimating();
                    print("success")
                    
                    let alertController = UIAlertController(title: "My Jodel", message:
                        "May the force be with you!", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Success", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else
                {
                    cameraController.loading.hidden = true;
                    cameraController.loading.stopAnimating();
                    let alertController = UIAlertController(title: "My Jodel", message:
                        "An error occured!", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
        }
    }
    
    func swipeRight(sender: UISwipeGestureRecognizer)
    {
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        
        if(contentView.frame.origin.x == 0)
        {
            // Camera is swiped
            UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {
                self.contentView.frame.origin.x = screenWidth;
                }, completion: { finished in
            })
        }
    }
    
    func swipeLeft(sender: UISwipeGestureRecognizer)
    {
        let screenWidth = UIScreen.mainScreen().bounds.size.width;
        
        sendTextView.resignFirstResponder();
        if(contentView.frame.origin.x == screenWidth)
        {
            // Camera is swiped
            UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {
                self.contentView.frame.origin.x = 0;
                }, completion: { finished in
            })
        }
    }
    
}