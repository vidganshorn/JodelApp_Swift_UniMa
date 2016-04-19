
//
//  MapViewViewController.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/10/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

import Parse
import Bolts

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var updateLocationBarItem: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var objects = [PFObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        
        
        // self.locationManager.startUpdatingLocation()
        
        if #available(iOS 9.0, *) {
            self.locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
        
        self.mapView.showsUserLocation = true
        
        /*
        // If you want your BarButtonItem to handle touch event and click, use a UIButton as customView
        let customButton = UIButton.init(frame: CGRectMake(0, 0, 30, 25))

        // Customize your button as you want, with an image if you have a pictogram to display for example
        customButton.setImage(UIImage(named: "mapME"), forState: .Normal)

        // Call Action "showRequests" if button was clicked
        customButton.addTarget(self, action: "updateLocation:", forControlEvents: UIControlEvents.TouchDown)
 
        // Then create and add our custom BBBadgeBarButtonItem
        let barButton = BBBadgeBarButtonItem(customUIButton: customButton)
 
        // Add it as the leftBarButtonItem of the navigation bar
        self.updateLocationBarItem.setBackgroundImage(UIImage(named: "mapME"), forState: .Normal, barMetrics: .Default)
        
         self.navigationItem.rightBarButtonItem = updateLocationBarItem
         */
        
        getMessagesNearby()
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("getMessagesNearby"), userInfo: nil, repeats: true)
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation is MKUserLocation) { return nil }
        
        let reuseID = "jodel"
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        
        if pin != nil {
            pin!.annotation = annotation
        }
        else {
            pin = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            
            //v!.image = UIImage(named:"jodel.png")
            
            pin!.canShowCallout = true
            
            // Resize image
            let pinImage = UIImage(named: "panda.png")
            
            let size = CGSize(width: 40, height: 40)
            UIGraphicsBeginImageContext(size)
            
            pinImage!.drawInRect(CGRectMake(0, 0, size.width, size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            pin?.image = resizedImage
            
            let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
            pin?.rightCalloutAccessoryView = rightButton as? UIView
        }
    
        return pin
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Location Delegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    
    @IBAction func updateLocation(sender: AnyObject) {
        
        if #available(iOS 9.0, *) {
            self.locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
    }
    /*
    func updateLocation(sender: AnyObject) {
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blueColor()
        
        if #available(iOS 9.0, *) {
            self.locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
    }
    */
    
    
    /*
     *
     *   Function -  GET messages nearby
     *               based on your current location
     *               synchronous call
     *
     */
    func getMessagesNearby() -> [PFObject] {
        
        var messages = [PFObject]()
        
        // User location
        let userGeoPoint = PFGeoPoint(latitude:self.locationManager.location!.coordinate.latitude, longitude:self.locationManager.location!.coordinate.longitude)
        
        // Create a query for messages
        let query = PFQuery(className:"Message")
        
        // Interested in messages within 10km near to user.
        query.whereKey("location", nearGeoPoint: userGeoPoint, withinKilometers: 10.0)
        
        // GET latest messages at first
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        query.limit = 20
        
        // SEND synchronous request and GET final list of (comment) objects
        do {
            try messages = query.findObjects()
            
            for object in messages {
                objects.append(object)
            }
            
        }
        catch {
            print("error")
        }
        
        // self.tableView?.reloadData()
        
        /*
         *  Location for message
         */
        for object in objects {
            
            let location = object.objectForKey("location") as? PFGeoPoint
            let likes = object.objectForKey("rating") as! Int
            
            // show jodels on map
            let jodel = MapViewAnnotationText(title: object.objectForKey("text") as! String,
                                time: String(likes) + " likes",
                                color: "Red",
                                coordinate: CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude))
            
            self.mapView.addAnnotation(jodel)
            
            mapView.delegate = self
        }
        
        return objects
    }
    
}