//
//  BikePlace.swift
//  Bysykkel
//
//  Created by Markus Andresen on 03/05/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import Foundation

class BikePlace {
    var availableBikes: Int
    var availableSlots: Int
    var adress: String
    var online: Bool
    var description: String
    
    init(availableBikes: Int,  availableSlots: Int, adress: String, online: Bool ){
        self.availableBikes = availableBikes
        self.availableSlots = availableSlots
        self.description = adress.substringFromIndex(adress.startIndex.advancedBy(3))
        self.adress = adress.substringFromIndex(adress.startIndex.advancedBy(3)).componentsSeparatedByString(",")[0]
        self.adress = self.adress.componentsSeparatedByString("/")[0]
        self.adress = self.adress.componentsSeparatedByString("(")[0]
        self.online = online
        
    }
    
    func getDisplayString() -> String{
        let result: String = self.adress
        return result
    }
    
}
