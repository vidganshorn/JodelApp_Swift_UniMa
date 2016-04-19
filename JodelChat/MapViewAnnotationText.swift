//
//  MapViewAnnotationText.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/10/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import MapKit

class MapViewAnnotationText: NSObject, MKAnnotation {
    
    let title: String?
    let time: String?
    let color: String
    let coordinate: CLLocationCoordinate2D
    // let icon: UIImage
    
    init(title: String, time: String, color: String, coordinate: CLLocationCoordinate2D) {
        
        self.title = title
        self.time = time
        self.color = color
        self.coordinate = coordinate
        // self.icon = icon
        
        super.init()
    }
    
    var subtitle: String? {
        return time
    }
    
    // pinColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    func pinColor() -> MKPinAnnotationColor  {
        switch color {
        case "Red":
            return .Red
        case "Purple":
            return .Purple
        case "Green":
            return .Green
        default:
            return .Green
        }
    }
    
    
}