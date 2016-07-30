//
//  PropertyDataManager.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/10/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class PropertyDataManager  {
    
    func PropertyDatabaseSetUp () -> FMDatabase {
        
        var propertyDB: FMDatabase?
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        let docsDir = dirPaths
        
        let databasePath = docsDir.URLByAppendingPathComponent("property.db")
        
        if !filemgr.fileExistsAtPath(databasePath.path!) {
            
            propertyDB = FMDatabase(path: databasePath.path!)
            
            if propertyDB == nil {
                print("Error: \(propertyDB!.lastErrorMessage())")
            }
            
            if propertyDB!.open() {
                
                let sql_stmt = "CREATE TABLE IF NOT EXISTS PROPERTY (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, PHOTOPATH1 TEXT, PHOTOPATH2 TEXT, DESC TEXT)"
                if !propertyDB!.executeStatements(sql_stmt) {
                    print("Error: \(propertyDB!.lastErrorMessage())")
                }
                
                let sql_stmt1 = "CREATE TABLE IF NOT EXISTS PURCHASELOCATION (ID1 INTEGER PRIMARY KEY AUTOINCREMENT, PROPID INTEGER, STREET TEXT, CITY TEXT, STATE TEXT, ZIP TEXT, DATE TEXT)"
                if !propertyDB!.executeStatements(sql_stmt1) {
                    print("Error: \(propertyDB!.lastErrorMessage())")
                }
                
                propertyDB!.close()
                
            } else {
                print("Error: \(propertyDB!.lastErrorMessage())")
            }
        }else{
            propertyDB = FMDatabase(path: databasePath.path!)
        }
        return propertyDB!
        
    }
    
    
    func SavePropData(propertyDB: FMDatabase, property: Property) -> ActionResponse {
        
        //        let mealDB = FMDatabase(path: databasePath.path!)
        
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        
        if propertyDB.open() {
            
      //      let imagename: String = property.propName!
            let imageid: Int = property.propID
            
            var propImage: UIImage
            var receiptImage: UIImage
            
            if property.propPhoto == nil {
                propImage = UIImage(named: "noimage")!
            }else {
                propImage = property.propPhoto!
            }
            
            if property.receiptPhoto == nil {
                receiptImage = UIImage(named: "noimage")!
            }else {
                receiptImage = property.receiptPhoto!
            }

            let imagePath1 = fileInDocumentsDirectory(String(imageid) + ".png")
            let imagePath2 = fileInDocumentsDirectory(String(imageid) + "R" + ".png")
            
            if !saveImage(propImage, path: imagePath1) {
                actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Property Photo not saved successfully")!
                print("Error: Property Photo not saved successfully")
                
            }else if !saveImage(receiptImage, path: imagePath2) {
                    actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Receipt Photo not saved successfully")!
                    print("Error: Receipt Photo not saved successfully")
            
            }else{
                
                let insertSQL = "INSERT INTO PROPERTY (name, photopath1, photopath2, desc) VALUES (?, ?, ?, ?)"
                
                
                let result = propertyDB.executeUpdate(insertSQL, withArgumentsInArray: [property.propName!, imagePath1, imagePath2, property.propDesc!])
                
                if !result {
                    actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Property not saved successfully")!
                    print("Error: \(propertyDB.lastErrorMessage())")
                } else {
                    
                    actionResponse = ActionResponse(responseCode: "n", responseDesc: "Success")!
                    
                }
            }
            
        } else {
            actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Issue with opening database")!
            print("Error: \(propertyDB.lastErrorMessage())")
        }
        
        return actionResponse!
        
    }
    
    
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
        
    }
    
    func saveImage (image: UIImage, path: String ) -> Bool {
        
        let pngImageData = UIImagePNGRepresentation(image)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        let result = pngImageData!.writeToFile(path, atomically: true)
        
        return result
        
    }
    
    func loadPropData(propertyDB: FMDatabase) -> [Property] {
        
        var propertyArray: [Property] = [Property]()
        
        if propertyDB.open() {
            
            let query_lab_test = "SELECT * FROM PROPERTY"
            
            let results_lab_test:FMResultSet? = propertyDB
                .executeQuery(query_lab_test, withArgumentsInArray: nil)
            
            while results_lab_test?.next() == true {
                let propID = results_lab_test?.longForColumn("ID")
                let propName = results_lab_test?.stringForColumn("NAME")
                let image1 = results_lab_test?.stringForColumn("PHOTOPATH1")
                let image2 = results_lab_test?.stringForColumn("PHOTOPATH2")
                var propDesc = results_lab_test?.stringForColumn("DESC")
                
                let propPhoto: UIImage? = loadImage(image1!)!
                let receiptPhoto: UIImage? = loadImage(image2!)!
                
                let property = Property(propID: propID!, propName: propName!, propPhoto: propPhoto!, receiptPhoto :receiptPhoto!, propDesc: propDesc!)
                propertyArray.append(property!)
                
                
            }
            if propertyArray.count == 0 {
                let propPhoto = UIImage(named: "noimage")!
                let receiptPhoto = UIImage(named: "noimage")!
                
                let property = Property(propID: 1, propName: "Add new property", propPhoto: propPhoto, receiptPhoto: receiptPhoto, propDesc: "Add description")!
                
                propertyArray.append(property)
                
            }
            
        }
        
        return propertyArray
    }
    
    
    
    func loadImage(path: String) -> UIImage? {
        
        var image: UIImage? = UIImage(contentsOfFile: path)
        
        if image == nil {
            
            print("missing image at: \(path)")
            
            image = UIImage(named: "noimage")
            
        }
        print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
        
    }
    
    
    func deletePropData(propertyDB: FMDatabase, property: Property) -> ActionResponse
    {
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        if propertyDB.open() {
            
            propertyDB.executeUpdate("DELETE FROM PROPERTY WHERE ID = ?", withArgumentsInArray: [property.propID])
            
            propertyDB.close()
            
            let imagepath1 = fileInDocumentsDirectory(String(property.propID) + ".png")
            deleteImage(imagepath1)
            
            let imagepath2 = fileInDocumentsDirectory(String(property.propID) + "R" + ".png")
            deleteImage(imagepath2)
            
        } else {
            actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Property is not deleted")!
        }
        return actionResponse!
    }
    
    func updatePropData(propertyDB: FMDatabase, property: Property) -> ActionResponse {
        
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        
        if propertyDB.open() {
            
            var filePath1: String
            var filePath2: String
            let propPhoto: UIImage = property.propPhoto!
            let receiptPhoto: UIImage = property.receiptPhoto!
            
            let propName = checkIfPropExists(propertyDB, property: property)
            
            if (propName == "name") {
                actionResponse = ActionResponse(responseCode: "Y", responseDesc: "This is default property. Add new property")!
            }else {
                /*
                if propName == property.propName {
                    
                    //get path pointing to document directory
                    filePath1 = fileInDocumentsDirectory(propName + ".png")
                    updateImage(filePath1, photo: propPhoto)
                    filePath2 = fileInDocumentsDirectory(propName + "R" + ".png")
                    updateImage(filePath2, photo: receiptPhoto)

                }else{
                    filePath1 = fileInDocumentsDirectory(String(property.propID) + ".png")
                    saveImage(propPhoto, path: filePath1)
                    filePath2 = fileInDocumentsDirectory(String(property.propID) + "R" + ".png")
                    saveImage(receiptPhoto, path: filePath2)

                }
                */
                filePath1 = fileInDocumentsDirectory(String(property.propID) + ".png")
                saveImage(propPhoto, path: filePath1)
                filePath2 = fileInDocumentsDirectory(String(property.propID) + "R" + ".png")
                saveImage(receiptPhoto, path: filePath2)

                let result = propertyDB.executeUpdate("UPDATE PROPERTY SET NAME = ?, PHOTOPATH1 = ?, PHOTOPATH2 = ?, DESC = ? WHERE ID = ?", withArgumentsInArray: [property.propName!, filePath1, filePath2, property.propDesc!, property.propID])
                
                if !result {
                    actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Property not saved successfully")!
                    print("Error: \(propertyDB.lastErrorMessage())")
                } else {
                    
                    actionResponse = ActionResponse(responseCode: "n", responseDesc: "Success")!
                    
                }
                
                
            }
        }
        
        return actionResponse!
    }
    
    
    func checkIfPropExists(propertyDB: FMDatabase, property: Property) -> String {
        
        var name: String?
        
        if propertyDB.open() {
            
            let results_lab_test:FMResultSet? = propertyDB.executeQuery("SELECT * FROM PROPERTY WHERE ID = ?", withArgumentsInArray: [property.propID])
            
            while results_lab_test?.next() == true {
                
                name = results_lab_test?.stringForColumn("NAME")
                
            }
            
            
        }
        if (name == nil) {
            name = "name"
        }
        
        return name!
        
    }
    
    
    func updateImage(filePath: String, photo: UIImage) {
        
        
        // We could try if there is file in this path (.fileExistsAtPath())
        // BUT we can also just call delete function, because it checks by itself
        let pngImageData = UIImagePNGRepresentation(photo)
        let fileManager = NSFileManager.defaultManager()
        // Delete 'hello.swift' file
        
        do {
      //      let pngImageData1 = UIImagePNGRepresentation(photo)
            if pngImageData != nil {
                try fileManager.removeItemAtPath(filePath)
            }
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
        
        //    NSFileManager.defaultManager().removeItemAtPath(filePath, error:NULL)
        
        // Resize image as you want
    //    let pngImageData = UIImagePNGRepresentation(photo)
        
        // Write new image
        if pngImageData != nil {
            pngImageData!.writeToFile(filePath, atomically: true)
        }
        /*
         // Save your stuff to
         NSUserDefaults.standardUserDefaults().setObject(stickerName, forKey: self.stickerUsed)
         NSUserDefaults.standardUserDefaults().synchronize()
         */
    }
    
    func deleteImage(imagepath: String) {
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtPath(imagepath)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
    }
    
    
    func SaveLocationData(propertyDB: FMDatabase, loc: PurchaseLocation) -> ActionResponse {
        
        //        let mealDB = FMDatabase(path: databasePath.path!)
        
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        
        if propertyDB.open() {
            
            let lID = loc.lID
            let pID = loc.pID
            let lAddress = loc.lAddress!
            let lCity = loc.lCity!
            let lState = loc.lState!
            let lZip = loc.lZip!
            let lDate = loc.lDate!
            
            let insertSQL1 = "INSERT INTO PURCHASELOCATION (propid, street, city, state, zip, date ) VALUES (?, ?, ?, ?, ?, ?)"
            
            let result = propertyDB.executeUpdate(insertSQL1, withArgumentsInArray: [loc.pID!, loc.lAddress!, loc.lCity!, loc.lState!, loc.lZip!, loc.lDate!])
            
            if !result {
                actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Location data not saved successfully")!
                print("Error: \(propertyDB.lastErrorMessage())")
            } else {
                
                actionResponse = ActionResponse(responseCode: "n", responseDesc: "Success")!
                
            }
            
        } else {
            actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Issue with opening database")!
            print("Error: \(propertyDB.lastErrorMessage())")
        }
        
        return actionResponse!
        
    }
    
    
    func loadLocationData(propertyDB: FMDatabase, pID: Int) -> PurchaseLocation {
        
        var loc: PurchaseLocation = PurchaseLocation(lID: 1, pID: pID, lAddress: "Not found", lCity: "Not found", lState: "Not found", lZip: "Not found", lDate: "Not found")!
        
        if propertyDB.open() {
            
            let results_lab_test:FMResultSet? = propertyDB.executeQuery("SELECT * FROM PURCHASELOCATION WHERE PROPID = ?", withArgumentsInArray: [pID])
            
            while results_lab_test?.next() == true {
                
                let id1 = results_lab_test?.longForColumn("ID1")
                let pid = results_lab_test?.longForColumn("PROPID")
                let address = results_lab_test?.stringForColumn("STREET")
                let city = results_lab_test?.stringForColumn("CITY")
                let state = results_lab_test?.stringForColumn("STATE")
                let zip = results_lab_test?.stringForColumn("ZIP")
                let date = results_lab_test?.stringForColumn("DATE")
                
                loc = PurchaseLocation(lID: id1!, pID: pid!, lAddress: address!, lCity: city!, lState: state!, lZip: zip!, lDate: date!)!
            }
        }
        
        return loc
        
    }
    
    func deleteLocationData(propertyDB: FMDatabase, pID: Int) -> ActionResponse
    {
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        if propertyDB.open() {
            
            propertyDB.executeUpdate("DELETE FROM PURCHASELOCATION WHERE PROPID = ?", withArgumentsInArray: [pID])
            
            propertyDB.close()
            
        } else {
            actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Location is not deleted")!
        }
        return actionResponse!
    }
    
    func updateLocationData(propertyDB: FMDatabase, loc: PurchaseLocation) -> ActionResponse {
        
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        
        if propertyDB.open() {
            
            let result = propertyDB.executeUpdate("UPDATE PURCHASELOCATION SET STREET = ?, CITY = ?, STATE = ?, ZIP = ? WHERE PROPID = ?", withArgumentsInArray: [loc.lAddress!, loc.lCity!, loc.lState!, loc.lZip!, loc.pID!])
            
            if !result {
                actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Location not saved successfully")!
                print("Error: \(propertyDB.lastErrorMessage())")
            } else {
                
                actionResponse = ActionResponse(responseCode: "n", responseDesc: "Success")!
                
            }
            
            
        }
        
        return actionResponse!
    }
    
    func justsavedPropID(propertyDB: FMDatabase) -> Int {
        
        var pID: Int = 1
        
        if propertyDB.open() {
            
            let results_lab_test:FMResultSet? = propertyDB.executeQuery("SELECT * FROM PROPERTY ORDER BY ID DESC LIMIT 1", withArgumentsInArray: nil)
            
            while results_lab_test?.next() == true {
                
                pID = (results_lab_test?.longForColumn("ID"))!
                
            }
        }
        
        
        return pID
    }
    
    
}

