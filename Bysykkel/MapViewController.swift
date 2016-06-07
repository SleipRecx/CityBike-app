//
//  MapViewController.swift
//  Bysykkel
//
//  Created by Markus Andresen on 03/05/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON


class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    var places: [BikePlace] = []
    var currentPlace: [BikePlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appdelegate.shouldSupportAllOrientation = true
        
        map.delegate = self
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        populateMap()
        if(currentPlace.count > 0){
            selectAnnotation()
        }
        else{
            let location = CLLocationCoordinate2D(latitude:  63.426637, longitude: 10.392981)
            let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            let region = MKCoordinateRegion(center: location, span:  span)
            map.setRegion(region, animated: true)

        }
        self.map.showsUserLocation = true
    }
    
    
    
    func selectAnnotation(){
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        let region = MKCoordinateRegion(center: currentPlace[0].location.coordinate, span:  span)
        map.setRegion(region, animated: true)
        
        for annotation in map.annotations{
            if(annotation.coordinate.latitude == currentPlace[0].location.coordinate.latitude){
                map.selectAnnotation(annotation, animated: true)
            }
        }
        
        self.navigationItem.title = currentPlace[0].adress

    }
    

    @IBAction func refreshPressed(sender: AnyObject) {
        let annotationsToRemove = map.annotations
        map.removeAnnotations(annotationsToRemove)
        fetchJSON()
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        let colorPointAnnotation = annotation as! CustomAnnotation
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else {
            pinView?.annotation = annotation
        }

        pinView!.canShowCallout = true
        pinView?.animatesDrop = true
        pinView?.pinTintColor = colorPointAnnotation.pinColor
        return pinView
    }
    
    
    
    
    
    /* Custom annotation image
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
 
        
        let reuseIdentifier = "pin"
      
        
        var v = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        if v == nil {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            v!.canShowCallout = true
            
        }
        else {
            v!.annotation = annotation
        }
        
        if(annotation.isKindOfClass(MKUserLocation)){
          return nil
        }
        let customPointAnnotation = annotation as! CustomAnnotation
        v!.image = UIImage(named:customPointAnnotation.pinCustomImageName)

        
        return v
    }
 */
    
    
  
  

    func populateMap(){
        var annotationView:MKPinAnnotationView!
        for place in places{
            let location = place.location
            let annotation = CustomAnnotation(pinColor: place.getColorCode())
            //annotation.pinCustomImageName = "test"
            annotation.coordinate = location.coordinate
            annotation.title = place.adress
            annotation.subtitle = "Sykler: " + String(place.availableBikes) + " Låser: " + String(place.availableSlots)
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            self.map.addAnnotation(annotationView.annotation!)
           
        }
     
    }
    func fetchJSON(){
        self.places.removeAll()
        let API_URL: String = "http://map.webservice.sharebike.com:8888/json/MapService/LiveStationData?APIKey=" +
        "3EFC0CF3-4E99-40E2-9E42-B95C2EDE6C3C&SystemID=citytrondheim"
        let myLocation = locationManager.location!
        Alamofire.request(.GET, API_URL).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let array = json["result"]["LiveStationData"].arrayValue
                    for place in array{
                        var online:Bool =  place["Online"].boolValue
                        let longitude: Double = place["Longitude"].doubleValue
                        let latitude: Double = place["Latitude"].doubleValue
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        let distance = Int((myLocation.distanceFromLocation(location)))
                        var adress = place["Address"].stringValue
                        let bikes = place["AvailableBikeCount"].intValue
                        let slots = place["AvailableSlotCount"].intValue
                        if(adress.containsString("[Offline]")){
                            online = false
                            adress = adress.componentsSeparatedByString(" ")[1]
                        }
                        let object = BikePlace(availableBikes: bikes,availableSlots: slots, adress: adress,online: online,location: location, distance: distance)
                        self.places.append(object)
                       
                    }
                    
                    self.populateMap()
                    if(self.currentPlace.count > 0){
                        self.selectAnnotation()
                    }
                }
            case
            .Failure(let error):
                print(error)
            }
        }
        
    }

    
    
  



}
