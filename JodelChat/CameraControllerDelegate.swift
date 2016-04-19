//
//  CameraControllerDelegate.swift
//  Jodel2
//
//  Created by UnniTech on 21/03/16.
//  Copyright © 2016 Christoph Mueller. All rights reserved.
//

import Foundation
protocol CameraControllerDelegate:class
{
    func sendImagePressed(imageBytes:NSData);
}