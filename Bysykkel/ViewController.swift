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
    
    var longitude: Double = 0
    var latitude: Double = 0
    var availableBikes: Int = 0
    var availableSlots: Int = 0
    var adress: String = ""
    var online: Bool = false

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude )
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        if online{
            annotation.title = "Åpen"
        }
        else{
            annotation.title = "Stengt"
        }
        
        annotation.subtitle = "Sykler: " + String(availableBikes) + " Låser: " + String(availableSlots)
        map.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        let region = MKCoordinateRegion(center: location, span:  span)
        map.setRegion(region, animated: true)
        map.selectAnnotation(map.annotations[0], animated: true)
         self.map.showsUserLocation = true
        self.navigationItem.title = adress;
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var dd: UILabel!

   

}
