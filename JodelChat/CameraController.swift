//
//  CameraController.swift
//  Jodel2
//
//  Created by Tea Pasko on 17/03/16.
//  Copyright © 2016 Christoph Mueller. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class CameraController : UIViewController, CameraObjectDelegate {
    
    var camera: CameraObject!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureView: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    var delegate:CameraControllerDelegate!;
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the view where camera will draw its content
        camera = CameraObject(drawView: self.view);
        camera.delegate = self;
        camera.startCameraSession(.BACK);
    }
    
    @IBAction func onCancelPressed(sender: AnyObject) {
        // Close Controller
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        
        // Hide image and let user to change picture
        pictureView.hidden = true;
        downloadButton.enabled = true;
    }

    @IBAction func onCameraChangeClicked(sender: AnyObject) {
       
        if(camera.getOpenedCamera() == .FRONT) {
            camera.setBackCamera();
        }
        else if(camera.getOpenedCamera() == .BACK) {
            camera.setFrontCamera();
        }
        else if(camera.getOpenedCamera() == .NONE) {
            // Back camera is default
            camera.setBackCamera();
        }
    }
    
    @IBAction func sendImage(sender: AnyObject) {
        
        delegate.sendImagePressed(UIImagePNGRepresentation(imageView.image!)!);
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        
        loading.hidden = true;
        camera.getScreenShot();
    }
    
    func getTakenPicture(picture: UIImage!) {
       
        pictureView.hidden = false;
        imageView.image = picture;
    }
    
    @IBAction func onDownloadImagePressed(sender: AnyObject) {
        
        downloadButton.enabled = false;
        UIImageWriteToSavedPhotosAlbum(imageView.image!, nil, nil, nil)
    }
}
