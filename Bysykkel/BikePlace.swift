//
//  Bikeself.swift
//  Bysykkel
//
//  Created by Markus Andresen on 03/05/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
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
        self.id = Int(adress.components(separatedBy: "-")[0])!
        self.availableBikes = availableBikes
        self.availableSlots = availableSlots
        self.description = adress.substring(from: adress.characters.index(adress.startIndex, offsetBy: 3))
        self.adress = adress.substring(from: adress.characters.index(adress.startIndex, offsetBy: 3)).components(separatedBy: ",")[0]
        self.adress = self.adress.components(separatedBy: "/")[0]
        self.adress = self.adress.components(separatedBy: "(")[0]
        self.online = online
        self.distance = distance
        self.location = location
        if(self.adress == "Trondheim Sentralstasjon"){
            self.adress = "Trondheim Stasjon"
        }
        if(self.adress == "Bakke bro"){
            self.adress = "Bakke Bro"
        }
    }
    
    func getDisplayString() -> String{
        return self.adress
    }
    
    func getID()->Int{
        return self.id
    }
    
    func getColorCode() -> UIColor {
        if(self.availableBikes == 0){
            return UIColor(red: 234/255, green: 67/255, blue: 53/255, alpha: 1)
        }
        else if(self.availableSlots == 0){
            return UIColor.gray
        }
        else if (self.availableBikes < 5){
            return UIColor(red: 251/255, green: 188/255, blue: 5/255, alpha: 1)
        }
        else{
            return UIColor(red: 52/255, green: 168/255, blue: 83/255, alpha: 1)
        }
    }
    
}

func ==(lhs: BikePlace, rhs: BikePlace) -> Bool{
    return lhs.getID() == rhs.getID()
}
