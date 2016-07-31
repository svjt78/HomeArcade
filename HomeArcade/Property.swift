//
//  Property.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/10/2016.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class Property: NSObject, NSCoding {
    // MARK: Properties
    
    var propID: Int
    var propName: String?
    var propPhoto: UIImage?
    var receiptPhoto: UIImage?
    var propCategory: String?
    var propCost: String?
    var propDesc: String?
    
    struct PropertyKey {
        static let IDKey = "ID"
        static let nameKey = "name"
        static let photoKey1 = "photo1"
        static let photoKey2 = "photo2"
        static let categoryKey = "category"
        static let costKey = "cost"
        static let descKey = "desc"
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("properties")
    
    //Mark NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(propID, forKey: PropertyKey.IDKey)
        aCoder.encodeObject(propName, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(propPhoto, forKey: PropertyKey.photoKey1)
        aCoder.encodeObject(receiptPhoto, forKey: PropertyKey.photoKey2)
        aCoder.encodeObject(propCategory, forKey: PropertyKey.categoryKey)
        aCoder.encodeObject(propCost, forKey: PropertyKey.costKey)
        aCoder.encodeObject(propDesc, forKey: PropertyKey.descKey)
    }
    
    
    //Mark Convenience Init
    required convenience init?(coder aDecoder: NSCoder) {
        
        let propID = aDecoder.decodeObjectForKey(PropertyKey.IDKey) as! Int
        
        let propName = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Property, use conditional cast.
        let propPhoto = aDecoder.decodeObjectForKey(PropertyKey.photoKey1) as? UIImage
        
        let receiptPhoto = aDecoder.decodeObjectForKey(PropertyKey.photoKey2) as? UIImage
        
        let propCategory = aDecoder.decodeObjectForKey(PropertyKey.categoryKey) as? String
        
        let propCost = aDecoder.decodeObjectForKey(PropertyKey.costKey) as? String
        
        let propDesc = aDecoder.decodeObjectForKey(PropertyKey.descKey) as? String
        
        // Must call designated initializer.
        self.init(propID: propID, propName: propName, propPhoto: propPhoto, receiptPhoto: receiptPhoto, propCategory: propCategory!, propCost: propCost, propDesc: propDesc!)
    }
    
    
    // MARK: Initialization
    
    init?(propID: Int, propName: String, propPhoto: UIImage?, receiptPhoto: UIImage?, propCategory: String?, propCost: String?, propDesc: String) {
        // Initialize stored properties.
        self.propID = propID
        self.propName = propName
        self.propPhoto = propPhoto
        self.receiptPhoto = receiptPhoto
        self.propCategory = propCategory
        self.propCost = propCost
        self.propDesc = propDesc
        
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        if propName.isEmpty  {
            return nil
        }
    }
}
