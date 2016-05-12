//
//  BikePlace.swift
//  Bysykkel
//
//  Created by Markus Andresen on 03/05/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import Foundation
import CoreLocation

class BikePlace : Equatable {
    var availableBikes: Int
    var availableSlots: Int
    var adress: String
    var online: Bool
    var description: String
    var distance: Int
    var location: CLLocation
    var id: Int
    
    init(availableBikes: Int,  availableSlots: Int, adress: String, online: Bool, location: CLLocation, distance: Int ){
        self.id = Int(adress.componentsSeparatedByString("-")[0])!
        self.availableBikes = availableBikes
        self.availableSlots = availableSlots
        self.description = adress.substringFromIndex(adress.startIndex.advancedBy(3))
        self.adress = adress.substringFromIndex(adress.startIndex.advancedBy(3)).componentsSeparatedByString(",")[0]
        self.adress = self.adress.componentsSeparatedByString("/")[0]
        self.adress = self.adress.componentsSeparatedByString("(")[0]
        self.online = online
        self.distance = distance
        self.location = location
    }
    
    func getDisplayString() -> String{
        return self.adress
    }
    
    func getID()->Int{
        return self.id
    }
    
}

func ==(lhs: BikePlace, rhs: BikePlace) -> Bool{
    return lhs.getID() == rhs.getID()
}
