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
        
        var propertyDB1: FMDatabase?
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        let docsDir = dirPaths
        
        let databasePath = docsDir.URLByAppendingPathComponent("property.db")
        
        if !filemgr.fileExistsAtPath(databasePath.path!) {
            
            propertyDB1 = FMDatabase(path: databasePath.path!)
            
            if propertyDB1 == nil {
                print("Error: \(propertyDB1!.lastErrorMessage())")
            }
            
            if propertyDB1!.open() {
                
                let sql_stmt = "CREATE TABLE IF NOT EXISTS PROPERTYTABLE (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, PHOTOPATH1 TEXT, PHOTOPATH2 TEXT, CATEGORY TEXT, COST TEXT, DESC TEXT)"
                if !propertyDB1!.executeStatements(sql_stmt) {
                    print("Error: \(propertyDB1!.lastErrorMessage())")
                }
                
                let sql_stmt1 = "CREATE TABLE IF NOT EXISTS PURCHASELOCATION (ID1 INTEGER PRIMARY KEY AUTOINCREMENT, PROPID INTEGER, STREET TEXT, CITY TEXT, STATE TEXT, ZIP TEXT, DATE TEXT)"
                if !propertyDB1!.executeStatements(sql_stmt1) {
                    print("Error: \(propertyDB1!.lastErrorMessage())")
                }
                
                propertyDB1!.close()
                
            } else {
                print("Error: \(propertyDB1!.lastErrorMessage())")
            }
        }else{
            propertyDB1 = FMDatabase(path: databasePath.path!)
        }
        return propertyDB1!
        
    }
    
    
    func SavePropData(propertyDB1: FMDatabase, property: Property) -> ActionResponse {
        
        //        let mealDB = FMDatabase(path: databasePath.path!)
        
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        
        if propertyDB1.open() {
            
      //      let imagename: String = property.propName!
            
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
            
            let lastImageID: Int = getJustSavedPropID(propertyDB1)
            let currImageID: Int = lastImageID + 1

            let imagePath1 = fileInDocumentsDirectory("I" + String(currImageID) + ".png")
            let imagePath2 = fileInDocumentsDirectory("I" +  String(currImageID) + "R" + ".png")
            
            if !saveImage(propImage, path: imagePath1) {
                actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Property Photo not saved successfully")!
                print("Error: Property Photo not saved successfully")
                
            }else if !saveImage(receiptImage, path: imagePath2) {
                    actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Receipt Photo not saved successfully")!
                    print("Error: Receipt Photo not saved successfully")
            
            }else{
                
                let insertSQL = "INSERT INTO PROPERTYTABLE (name, photopath1, photopath2, category, cost, desc) VALUES (?, ?, ?, ?, ?, ?)"
                
                
                let result = propertyDB1.executeUpdate(insertSQL, withArgumentsInArray: [property.propName!, imagePath1, imagePath2, property.propCategory!, property.propCost!, property.propDesc!])
                
                
                if !result {
                    actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Property not saved successfully")!
                    print("Error: \(propertyDB1.lastErrorMessage())")
                } else {
                    
                    actionResponse = ActionResponse(responseCode: "n", responseDesc: "Success")!
                    
                }
                
            }
            
        } else {
            actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Issue with opening database")!
            print("Error: \(propertyDB1.lastErrorMessage())")
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
    
    func loadPropData(propertyDB1: FMDatabase) -> [Property] {
        
        var propertyArray: [Property] = [Property]()
        
        if propertyDB1.open() {
            
            let query_lab_test = "SELECT * FROM PROPERTYTABLE"
            
            let results_lab_test:FMResultSet? = propertyDB1
                .executeQuery(query_lab_test, withArgumentsInArray: nil)
            
            
            while results_lab_test?.next() == true {
                let propID = results_lab_test?.longForColumn("ID")
                let propName = results_lab_test?.stringForColumn("NAME")
                let image1 = results_lab_test?.stringForColumn("PHOTOPATH1")
                let image2 = results_lab_test?.stringForColumn("PHOTOPATH2")
                var propCategory = results_lab_test?.stringForColumn("CATEGORY")
                var propCost = results_lab_test?.stringForColumn("COST")
                var propDesc = results_lab_test?.stringForColumn("DESC")
                
                let propPhoto: UIImage? = loadImage(image1!)!
                let receiptPhoto: UIImage? = loadImage(image2!)!
                
                let property = Property(propID: propID!, propName: propName!, propPhoto: propPhoto!, receiptPhoto :receiptPhoto!, propCategory: propCategory, propCost: propCost, propDesc: propDesc!)
                propertyArray.append(property!)
                
                
            }
            if propertyArray.count == 0 {
                let propPhoto = UIImage(named: "noimage")!
                let receiptPhoto = UIImage(named: "noimage")!
                
                let property = Property(propID: 1, propName: "Add new property", propPhoto: propPhoto, receiptPhoto: receiptPhoto, propCategory: "None", propCost: "$0.00",  propDesc: "Add description")!
                
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
    
    
    func deletePropData(propertyDB1: FMDatabase, property: Property) -> ActionResponse
    {
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        if propertyDB1.open() {
            
            let path1 = getpath1(propertyDB1, property: property)
            let path2 = getpath2(propertyDB1, property: property)
            
            propertyDB1.executeUpdate("DELETE FROM PROPERTYTABLE WHERE ID = ?", withArgumentsInArray: [property.propID])
            
            propertyDB1.close()
            
 //           let imagepath1 = fileInDocumentsDirectory(String(property.propID) + ".png")
            deleteImage(path1)
            
//            let imagepath2 = fileInDocumentsDirectory(String(property.propID) + "R" + ".png")
            deleteImage(path2)
            
        } else {
            actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Property is not deleted")!
        }
        return actionResponse!
    }
    
    func updatePropData(propertyDB1: FMDatabase, property: Property) -> ActionResponse {
        
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        
        
 //       if propertyDB1.open() {
            
            var filePath1: String
            var filePath2: String
            let propPhoto: UIImage = property.propPhoto!
            let receiptPhoto: UIImage = property.receiptPhoto!
            
            let propName = checkIfPropExists(propertyDB1, property: property)
            
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
                
                filePath1 = fileInDocumentsDirectory("I" + String(property.propID) + ".png")
                
                saveImage(propPhoto, path: filePath1)
                filePath2 = fileInDocumentsDirectory("I" + String(property.propID) + "R" + ".png")
                saveImage(receiptPhoto, path: filePath2)
                
                if propertyDB1.open() {

                let result = propertyDB1.executeUpdate("UPDATE PROPERTYTABLE SET NAME = ?, PHOTOPATH1 = ?, PHOTOPATH2 = ?, CATEGORY = ?, COST = ?, DESC = ? WHERE ID = ?", withArgumentsInArray: [property.propName!, filePath1, filePath2, property.propCategory!, property.propCost!, property.propDesc!, property.propID])
                
                
                
                if !result {
                    actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Property not saved successfully")!
                    print("Error: \(propertyDB1.lastErrorMessage())")
                } else {
                    
                    actionResponse = ActionResponse(responseCode: "n", responseDesc: "Success")!
                    
                }
                }
            }
    //    }
        
        return actionResponse!
    }
    
    
    func checkIfPropExists(propertyDB1: FMDatabase, property: Property) -> String {
        
        var name: String?
        
        if propertyDB1.open() {
            
            let results_lab_test:FMResultSet? = propertyDB1.executeQuery("SELECT * FROM PROPERTYTABLE WHERE ID = ?", withArgumentsInArray: [property.propID])
            
            
            while results_lab_test?.next() == true {
                
                name = results_lab_test?.stringForColumn("NAME")
                
            }
            
            
        }
        if (name == nil) {
            name = "name"
        }
        
        return name!
        
    }
    
    func getpath1(propertyDB1: FMDatabase, property: Property) -> String {
        
        var path1: String?
        
        if propertyDB1.open() {
            
            let results_lab_test:FMResultSet? = propertyDB1.executeQuery("SELECT PHOTOPATH1 FROM PROPERTYTABLE WHERE ID = ?", withArgumentsInArray: [property.propID])
            
            
            while results_lab_test?.next() == true {
                
                path1 = results_lab_test?.stringForColumn("PHOTOPATH1")
                
            }
            
            
        }
        
        return path1!
        
    }

    func getpath2(propertyDB1: FMDatabase, property: Property) -> String {
        
        var path2: String?
        
        if propertyDB1.open() {
            
            let results_lab_test:FMResultSet? = propertyDB1.executeQuery("SELECT PHOTOPATH2 FROM PROPERTYTABLE WHERE ID = ?", withArgumentsInArray: [property.propID])
            
            
            while results_lab_test?.next() == true {
                
                path2 = results_lab_test?.stringForColumn("PHOTOPATH2")
                
            }
            
            
        }
        
        return path2!
        
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
    
        
    func StoreLocationData (propertyDB1: FMDatabase, loc: PurchaseLocation) -> ActionResponse {
        
        var actionResponse: ActionResponse? = ActionResponse(responseCode: "n", responseDesc: "")
        
        if LocationExists(propertyDB1, loc: loc) {
            
            actionResponse = updateLocationData(propertyDB1, loc: loc)
        }else{
            actionResponse =  SaveLocationData(propertyDB1, loc: loc)
        }
        
        return actionResponse!
    }
    
    func LocationExists(propertyDB1: FMDatabase, loc: PurchaseLocation) -> Bool {
    
        
        if propertyDB1.open() {
            
            let results_lab_test:FMResultSet? = propertyDB1.executeQuery("SELECT * FROM PURCHASELOCATION WHERE PROPID = ?", withArgumentsInArray: [loc.pID!])
            
            while results_lab_test?.next() == true {
                
                return true
                
            }
            
            
        }
        return false
    }

    
    func SaveLocationData(propertyDB1: FMDatabase, loc: PurchaseLocation) -> ActionResponse {
        
        //        let mealDB = FMDatabase(path: databasePath.path!)
        
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        
        if propertyDB1.open() {
            
            let lID = loc.lID
            let pID = loc.pID
            let lAddress = loc.lAddress!
            let lCity = loc.lCity!
            let lState = loc.lState!
            let lZip = loc.lZip!
            let lDate = loc.lDate!
            
            let insertSQL1 = "INSERT INTO PURCHASELOCATION (propid, street, city, state, zip, date ) VALUES (?, ?, ?, ?, ?, ?)"
            
            let result = propertyDB1.executeUpdate(insertSQL1, withArgumentsInArray: [loc.pID!, loc.lAddress!, loc.lCity!, loc.lState!, loc.lZip!, loc.lDate!])
            
            if !result {
                actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Location data not saved successfully")!
                print("Error: \(propertyDB1.lastErrorMessage())")
            } else {
                
                actionResponse = ActionResponse(responseCode: "n", responseDesc: "Success")!
                
            }
            
        } else {
            actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Issue with opening database")!
            print("Error: \(propertyDB1.lastErrorMessage())")
        }
        
        return actionResponse!
        
    }
    
    
    func loadLocationData(propertyDB1: FMDatabase, pID: Int) -> PurchaseLocation {
        
        var loc: PurchaseLocation = PurchaseLocation(lID: 1, pID: pID, lAddress: "Not found", lCity: "Not found", lState: "Not found", lZip: "Not found", lDate: "Not found")!
        
        if propertyDB1.open() {
            
            let results_lab_test:FMResultSet? = propertyDB1.executeQuery("SELECT * FROM PURCHASELOCATION WHERE PROPID = ?", withArgumentsInArray: [pID])
            
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
    
    func deleteLocationData(propertyDB1: FMDatabase, pID: Int) -> ActionResponse
    {
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        if propertyDB1.open() {
            
            propertyDB1.executeUpdate("DELETE FROM PURCHASELOCATION WHERE PROPID = ?", withArgumentsInArray: [pID])
            
            propertyDB1.close()
            
        } else {
            actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Location is not deleted")!
        }
        return actionResponse!
    }
    
    func updateLocationData(propertyDB1: FMDatabase, loc: PurchaseLocation) -> ActionResponse {
        
        var actionResponse = ActionResponse(responseCode: "n", responseDesc: "")
        
        if propertyDB1.open() {
            
            let result = propertyDB1.executeUpdate("UPDATE PURCHASELOCATION SET STREET = ?, CITY = ?, STATE = ?, ZIP = ?, DATE = ? WHERE PROPID = ?", withArgumentsInArray: [loc.lAddress!, loc.lCity!, loc.lState!, loc.lZip!, loc.lDate!, loc.pID!])
            
            if !result {
                actionResponse = ActionResponse(responseCode: "Y", responseDesc: "Location not saved successfully")!
                print("Error: \(propertyDB1.lastErrorMessage())")
            } else {
                
                actionResponse = ActionResponse(responseCode: "n", responseDesc: "Success")!
                
            }
            
        }
        
        return actionResponse!
    }
    
    func getJustSavedPropID(propertyDB1: FMDatabase) -> Int {
        
        var pID: Int = 0
        
        if propertyDB1.open() {
            
            let results_lab_test:FMResultSet? = propertyDB1.executeQuery("SELECT * FROM PROPERTYTABLE ORDER BY ID DESC LIMIT 1", withArgumentsInArray: nil)
            
            while results_lab_test?.next() == true {
                
                pID = (results_lab_test?.longForColumn("ID"))!
                
            }
        }
        
        
        return pID
    }
    
    func getDateStamp() -> String {
        
        //get event date and time
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        //           let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay, fromDate: date)
        let components = calendar.components([.Hour, .Minute, .Month, .Year, .Day], fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        let seconds = components.second
        let month = components.month
        let year = components.year
        let day = components.day
        
        let datestamp = String(month) + ":" + String(day) + ":" + String(year) + ":" + String(hour) + ":" + String(minutes) + ":" + String(seconds)
        
        return datestamp

    }
    
    func getStoredDesc(propertyDB1: FMDatabase, itemid: Int) -> String {
        
        var desc: String?
        
        if propertyDB1.open() {
            
            let results_lab_test:FMResultSet? = propertyDB1.executeQuery("SELECT * FROM PROPERTYTABLE WHERE ID = ?", withArgumentsInArray: [itemid])
            
            
            while results_lab_test?.next() == true {
                
                desc = results_lab_test?.stringForColumn("DESC")
                
            }

        }
        
        return desc!
    }
    
}

