//
//  PurchaseLocation.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/10/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class PurchaseLocation: NSObject, NSCoding {
    // MARK: Properties
    
    var lID: Int?
    var pID: Int?
    var lAddress: String?
    var lCity: String?
    var lState: String?
    var lZip: String?
    var lDate: String?
    
    struct locationKey {
        static let lIDKey = "ID"
        static let pIDKey = "PID"
        static let lAddressKey = "ADDRESS"
        static let lCityKey = "CITY"
        static let lStateKey = "STATE"
        static let lZipKey = "ZIP"
        static let lDateKey = "DATE"
        
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("location")
    
    //Mark NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(lID, forKey: locationKey.lIDKey)
        aCoder.encodeObject(pID, forKey: locationKey.pIDKey)
        aCoder.encodeObject(lAddress, forKey: locationKey.lAddressKey)
        aCoder.encodeObject(lCity, forKey: locationKey.lCityKey)
        aCoder.encodeObject(lState, forKey: locationKey.lStateKey)
        aCoder.encodeObject(lZip, forKey: locationKey.lZipKey)
        aCoder.encodeObject(lDate, forKey: locationKey.lDateKey)
    }
    
    
    //Mark Convenience Init
    required convenience init?(coder aDecoder: NSCoder) {
        
        let lID = aDecoder.decodeObjectForKey(locationKey.lIDKey) as! Int
        
        let pID = aDecoder.decodeObjectForKey(locationKey.pIDKey) as! Int
        
        let lAddress = aDecoder.decodeObjectForKey(locationKey.lAddressKey) as! String
        
        let lCity = aDecoder.decodeObjectForKey(locationKey.lCityKey) as! String
        
        let lState = aDecoder.decodeObjectForKey(locationKey.lStateKey) as! String
        
        let lZip = aDecoder.decodeObjectForKey(locationKey.lZipKey) as! String
        
        let lDate = aDecoder.decodeObjectForKey(locationKey.lDateKey) as! String
        
        // Must call designated initializer.
        self.init(lID: lID, pID: pID, lAddress: lAddress, lCity: lCity, lState: lState, lZip: lZip, lDate: lDate)
    }
    
    
    // MARK: Initialization
    
    init?(lID: Int, pID: Int, lAddress: String?, lCity: String?, lState: String?, lZip: String?, lDate: String) {
        // Initialize stored properties.
        self.lID = lID
        self.pID = pID
        self.lAddress = lAddress
        self.lCity = lCity
        self.lState = lState
        self.lZip = lZip
        self.lDate = lDate
        
        super.init()
        
        // Initialization should fail if any of the below is negative.
        if lAddress!.isEmpty || (lCity?.isEmpty)! || (lState?.isEmpty)! || (lZip?.isEmpty)! {
            return nil
        }
    }
}

