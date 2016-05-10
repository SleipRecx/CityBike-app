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


class MapViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    let locationManager = CLLocationManager()
    var places: [BikePlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateMap()
        let location = CLLocationCoordinate2D(latitude:  63.426637, longitude: 10.392981)
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: location, span:  span)
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
    }
    

    @IBAction func refreshPressed(sender: AnyObject) {
        let annotationsToRemove = map.annotations
        map.removeAnnotations( annotationsToRemove )
        fetchJSON()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func populateMap(){
        for place in places{
            let location = place.location
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = place.adress
            annotation.subtitle = "Sykler: " + String(place.availableBikes) + " Låser: " + String(place.availableSlots)
            map.addAnnotation(annotation)
        }
     
    }
    
    
    func fetchJSON(){
        self.places.removeAll()
        let API_URL: String = "http://map.webservice.sharebike.com:8888/json/MapService/LiveStationData?APIKey=3EFC0CF3-4E99-40E2-9E42-B95C2EDE6C3C&SystemID=citytrondheim"
        Alamofire.request(.GET, API_URL).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let array = json["result"]["LiveStationData"].arrayValue
                    for place in array{
                        let online:Bool =  place["Online"].boolValue
                        let longitude: Double = place["Longitude"].doubleValue
                        let latitude: Double = place["Latitude"].doubleValue
                        let location = CLLocation(latitude: latitude, longitude: longitude)
                        self.places.append(BikePlace(availableBikes: place["AvailableBikeCount"].intValue,availableSlots: place["AvailableSlotCount"].intValue,adress: place["Address"].stringValue,online: online, location: location, distance: 0))
                    }
                    self.populateMap()
                    
                }
            case .Failure(let error):
                print(error)
            }
        }
     
        
        
    }



}
