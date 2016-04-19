//
//  CameraObjectDelegate.swift
//  Jodel2
//
//  Created by Tea Pasko on 17/03/16.
//  Copyright © 2016 Christoph Mueller. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CameraObjectDelegate:class
{
    func getTakenPicture(picture: UIImage!);
    
    // Mark not implemented, save old camera reference in CameraObject
    optional func cameraIsChanging(toCamera:Int,fromCamera:Int);
    
    // Mark delegate is commented
    optional func cameraHasChanged(toCamera:Int,wasSuccessful:Bool);
}