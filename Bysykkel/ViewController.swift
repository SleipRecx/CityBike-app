//
//  ViewController.swift
//  Bysykkel
//
//  Created by Markus Andresen on 03/05/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!

    let locationManager = CLLocationManager()
    var places: [BikePlace] = []
    var currentPlace: [BikePlace] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPlace[0].location.coordinate.latitude
        let location = CLLocationCoordinate2D(latitude: currentPlace[0].location.coordinate.latitude, longitude: currentPlace[0].location.coordinate.longitude )
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        if currentPlace[0].online{
            annotation.title = "Åpen"
        }
        else{
            annotation.title = "Stengt"
        }
        
        annotation.subtitle = "Sykler: " + String(currentPlace[0].availableBikes) + " Låser: " + String(currentPlace[0].availableSlots)
        map.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        let region = MKCoordinateRegion(center: location, span:  span)
        map.setRegion(region, animated: true)
        map.selectAnnotation(map.annotations[0], animated: true)
        self.map.showsUserLocation = true
        self.navigationItem.title = currentPlace[0].adress;
        populateMap()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

   

}
