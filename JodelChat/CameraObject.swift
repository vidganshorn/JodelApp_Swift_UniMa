//
//  CameraObject.swift
//  Jodel2
//
//  Created by Tea Pasko on 17/03/16.
//  Copyright © 2016 Christoph Mueller. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public class CameraObject
{
    var delegate:CameraObjectDelegate!;
    
    let captureSession = AVCaptureSession()
    
    var currentCamera:CameraType!;
    
    var backCamera:AVCaptureDevice!;
    var frontCamera:AVCaptureDevice!;
    
    var supportedCamera:SupportedCamera!;
    
    var displayViewLayer:UIView;
    
    let imageOutput = AVCaptureStillImageOutput()

    init(drawView:UIView)
    {
        // Set current camera to none.
        currentCamera = CameraType.NONE;
        
        // View where the camera will be draw
        displayViewLayer = drawView;
        
        // Capture available devices
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices
        {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo))
            {
                // Get back camera reference
                if(device.position == AVCaptureDevicePosition.Back)
                {
                    backCamera = (device as? AVCaptureDevice)!
                }
                    // Get front camera reference
                else if(device.position == AVCaptureDevicePosition.Front)
                {
                    frontCamera = (device as? AVCaptureDevice)!
                }
            }
        }
        
        // Set supported camera
        if(frontCamera != nil && backCamera != nil)
        {
            supportedCamera = SupportedCamera.BOTH;
        }
        else if(frontCamera == nil && backCamera == nil)
        {
            supportedCamera = SupportedCamera.NONE;
        }
        else if(frontCamera == nil)
        {
            supportedCamera = SupportedCamera.BACK;
        }
        else if(backCamera == nil)
        {
            supportedCamera = SupportedCamera.FRONT;
        }
    }
    
    /********************************************************************/
    /*Private methods                                                   */
    /********************************************************************/

    private func setCameraSession(camera:AVCaptureDevice)->Bool
    {
        do
        {
            // Multy input not supported
            if(captureSession.inputs.count > 0)
            {
                // If there is already an input, remove it.
                let input = captureSession.inputs[0] as! AVCaptureInput;
                captureSession.stopRunning();
                captureSession.removeInput(input);
            }
            
            var newInput = try AVCaptureDeviceInput(device: camera);
            captureSession.addInput(newInput);
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            previewLayer?.frame = displayViewLayer.frame
            displayViewLayer.layer.insertSublayer(previewLayer, atIndex: 0);
            captureSession.startRunning();
            
            imageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(imageOutput) {
                captureSession.addOutput(imageOutput)
            }
            
            //self.delegate.cameraHasChanged!(supportedCamera.hashValue, wasSuccessful: true);
            
            return true;
        }
        catch
        {
            //self.delegate.cameraHasChanged!(supportedCamera.hashValue, wasSuccessful: false);
            return false;
        }
    }
    
    /********************************************************************/
    /*Public methods                                                   */
    /********************************************************************/
    
    public func getDeviceSupportedCamera()->SupportedCamera
    {
        return supportedCamera;
    }
    
    public func getOpenedCamera()->CameraType
    {
        return currentCamera;
    }
    
    public func setFrontCamera()->Bool
    {
        // If front camera is requested, check if device supports it.
        if(supportedCamera == .FRONT || supportedCamera == .BOTH)
        {
            currentCamera = CameraType.FRONT;
            return setCameraSession(frontCamera);
        }
        else
        {
            return false;
        }
    }
    
    public func setBackCamera()->Bool
    {
        // If back camera is requested, check if device supports it.
        if(supportedCamera == .BACK || supportedCamera == .BOTH)
        {
            currentCamera = CameraType.BACK;
            return setCameraSession(backCamera);
        }
        else
        {
            return false;
        }
    }
    
    public func getScreenShot()
    {
        var imageData:NSData!;
        if let videoConnection = imageOutput.connectionWithMediaType(AVMediaTypeVideo)
        {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait;
            imageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection)
            {(imageDataSampleBuffer, error) -> Void in
                imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                let image = UIImage(data: imageData)
                if(self.currentCamera == .FRONT)
                {
                    let flippedImage = UIImage(CGImage: image!.CGImage!, scale: image!.scale, orientation: UIImageOrientation.LeftMirrored)
                    self.delegate.getTakenPicture(flippedImage);
                }
                else if(UIDevice.currentDevice().orientation == UIDeviceOrientation.FaceUp)
                {
                    let flippedImage = UIImage(CGImage: image!.CGImage!, scale: image!.scale, orientation: UIImageOrientation.LeftMirrored)
                    self.delegate.getTakenPicture(flippedImage);
                }
                else
                {
                    self.delegate.getTakenPicture(image);
                }
            }
        }
    }
    
    public func saveScreenShotToAlbum()
    {
        if let videoConnection = imageOutput.connectionWithMediaType(AVMediaTypeVideo)
        {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait;
            imageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection)
            {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                let image = UIImage(data: imageData)
                if(UIDevice.currentDevice().orientation == UIDeviceOrientation.FaceUp)
                {
                    let flippedImage = UIImage(CGImage: image!.CGImage!, scale: image!.scale, orientation: UIImageOrientation.LeftMirrored)
                    self.delegate.getTakenPicture(flippedImage);
                    UIImageWriteToSavedPhotosAlbum(flippedImage, nil, nil, nil)
                }
                else
                {
                    self.delegate.getTakenPicture(image);
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                }
            }
        }
    }
    
    public func startCameraSession()->Bool
    {
        return startCameraSession(.BACK);
    }
    
    public func startCameraSession(camera:CameraType)->Bool
    {
        if(camera == CameraType.BACK)
        {
            // If back camera is requested, check if device supports it.
            if(supportedCamera == .BACK || supportedCamera == .BOTH)
            {
                currentCamera = CameraType.BACK;
                return setCameraSession(backCamera);
            }
        }
        else if(camera == CameraType.FRONT)
        {
            // If front camera is requested, check if device supports it.
            if(supportedCamera == .FRONT || supportedCamera == .BOTH)
            {
                currentCamera = CameraType.FRONT;
                return setCameraSession(frontCamera);
            }
        }
        
        currentCamera == .NONE;
        return false;
    }
    
    public enum SupportedCamera
    {
        case BOTH
        case FRONT
        case BACK
        case NONE
    }
    
    public enum CameraType
    {
        case FRONT
        case BACK
        case NONE
    };
    
}