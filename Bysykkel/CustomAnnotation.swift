//
//  CustomAnnotation.swift
//  Bysykkel
//
//  Created by Markus Andresen on 07/06/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: MKPointAnnotation {
    var pinCustomImageName:String!
    var pinColor: UIColor!
    
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }

}
