//
//  PropertyAndLocation.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/30/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class PropertyAndLocation: NSObject {
    // MARK: Properties
    
    var property: Property
    var location: PurchaseLocation
    
    
    // MARK: Initialization
    
    init?(property: Property, location: PurchaseLocation) {
        // Initialize stored properties.
        self.property = property
        self.location = location
        
        super.init()

    }
}

