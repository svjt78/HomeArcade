//
//  PropertyTableViewController.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/17/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit
import CoreLocation

class PropertyTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    //Mark properties
    
    var properties = [Property]()
    
    var propertyDB: FMDatabase = FMDatabase()
    
    let photo1 = UIImage(named: "noimage")!
    let photo2 = UIImage(named: "noimage")!
    
    var property = Property(propID: 1, propName: "Unknown", propPhoto: (photo: UIImage(named: "noimage")!), receiptPhoto: (photo: UIImage(named: "noimage")!), propDesc: "Unknown")!
    
    var currentSelection: Int = 0
    
    var pm: CLPlacemark?
    
    var locManager: CLLocationManager?
    
    let locationManager = CLLocationManager()


    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Change the navigation bar background color to blue.
        navigationController!.navigationBar.barTintColor = UIColor.cyanColor()
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Load the sample data.
        
        self.tableView.estimatedRowHeight = 100.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        //sentinel
        self.currentSelection = -1;
        
        locationManager.delegate = self
        
        let pdm: PropertyDataManager =  PropertyDataManager()
        propertyDB = pdm.PropertyDatabaseSetUp()
        properties = pdm.loadPropData(propertyDB)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        tableView .reloadData()
        
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return properties.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     // Configure the cell...
     // Table view cells are reused and should be dequeued using a cell identifier.
     
     let cellIdentifier = "PropertyTableViewCell"
     let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PropertyTableViewCell
     
     cell.layer.borderWidth = 2.0
     cell.layer.borderColor = UIColor.blackColor().CGColor
     
     // Fetches the appropriate meal for the data source layout.
     let property = properties[indexPath.row]
     
     cell.PropertyID.text = String(property.propID)
     cell.PropertyID.hidden = true
     cell.PropertyName.text = property.propName
     cell.PropertyPhoto.image = property.propPhoto
     
     return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row: Int = indexPath.row
        currentSelection = row
        
        // animate
        [tableView .beginUpdates()]
        
        [tableView .endUpdates()]
        
        
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // do things with your cell here
        
        // sentinel
        currentSelection = -1;
        
        // animate
        [tableView .beginUpdates()]
        [tableView .endUpdates()]
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.row == currentSelection) {
            return  200;
        }
        else {
            return 100;
        }
        
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? ViewController, property1 = sourceViewController.property {
            
            property = property1
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing property.
                let pdm: PropertyDataManager = PropertyDataManager()
                let response: ActionResponse = pdm.updatePropData(propertyDB, property: property)
                
                if (response.responseCode) == "Y" {
                    
                    let alertController = UIAlertController(title: "Alert!", message: response.responseDesc, preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
                    alertWindow.rootViewController = UIViewController()
                    alertWindow.windowLevel = UIWindowLevelAlert + 1;
                    alertWindow.makeKeyAndVisible()
                    
                    alertWindow.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    
                }else {
                    properties = pdm.loadPropData(propertyDB)
                }
                
            }
            else {
                // Add a new property.
                
                let pdm: PropertyDataManager = PropertyDataManager()
                let response: ActionResponse = pdm.SavePropData(propertyDB, property: property)
                
                if (response.responseCode) == "y" {
                    
                    let alertController = UIAlertController(title: "Alert!", message: "Property is not added", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
                    alertWindow.rootViewController = UIViewController()
                    alertWindow.windowLevel = UIWindowLevelAlert + 1;
                    alertWindow.makeKeyAndVisible()
                    
                    alertWindow.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    
                    
                }else {
                    //check for internet connection
                    
                    if Reachability.isConnectedToNetwork() == true {
                        //start concurrent thread to derive location
                        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                        dispatch_async(queue) { () -> Void in
                            self.locationManager.delegate = self
                            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                            self.locationManager.requestWhenInUseAuthorization()
                            self.locationManager.distanceFilter=kCLDistanceFilterNone;
                            self.locationManager.startUpdatingLocation()
                        }
                    } else {
                        let alertController = UIAlertController(title: "Alert!", message: "Device is not connected to Internet", preferredStyle: .Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
                        alertWindow.rootViewController = UIViewController()
                        alertWindow.windowLevel = UIWindowLevelAlert + 1;
                        alertWindow.makeKeyAndVisible()
                        
                        alertWindow.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                    
                    properties = pdm.loadPropData(propertyDB)
                    
                }
                
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let propertyDetailViewController = segue.destinationViewController as! ViewController
            
            // Get the cell that generated this segue.
            if let selectedPropCell = sender as? PropertyTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedPropCell)!
                let selectedProperty = properties[indexPath.row]
                propertyDetailViewController.property = selectedProperty
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new property.")
        }
    }

    //Delete operation
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let pdm: PropertyDataManager = PropertyDataManager()
            let propertyItem = properties[indexPath.row]
            let response: ActionResponse = pdm.deletePropData(propertyDB, property: propertyItem)
            if (response.responseCode) == "y" {
                
                let alertController = UIAlertController(title: "Alert!", message: "Property is not deleted", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
                alertWindow.rootViewController = UIViewController()
                alertWindow.windowLevel = UIWindowLevelAlert + 1;
                alertWindow.makeKeyAndVisible()
                
                alertWindow.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                
            }else {
                //delete location info for deleted meal
                let pdm: PropertyDataManager =  PropertyDataManager()
                let propertyDB = pdm.PropertyDatabaseSetUp()
                let pID = propertyItem.propID
                let response: ActionResponse = pdm.deleteLocationData(propertyDB, pID: pID)
                
                if (response.responseCode) == "y" {
                    
                    let alertController = UIAlertController(title: "Alert!", message: "Location reference is not deleted", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
                    alertWindow.rootViewController = UIViewController()
                    alertWindow.windowLevel = UIWindowLevelAlert + 1;
                    alertWindow.makeKeyAndVisible()
                    
                    alertWindow.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                }else {
                    
                    //refresh table view
                    properties.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    properties = pdm.loadPropData(propertyDB)
                }
            }
            
            /*
             // Delete the row from the data source
             meals.removeAtIndex(indexPath.row)
             saveMeals()
             tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
             */
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func saveProperties() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(properties, toFile: Property.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save properties...")
        }
    }
    
    func loadProperties() -> [Property]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Property.ArchiveURL.path!) as? [Property]
    }
    
    //Reverse Geo Coding with LocationManager

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [CLLocation]) {
        
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        
        
        //--- CLGeocode to get address of current location ---//
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil)
            {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0
            {
                let pm = placemarks![0] as CLPlacemark
                self.locManager = manager
                self.saveLocationInfo(pm, property: self.property)
                
            }
            else
            {
                print("Problem with the data received from geocoder")
            }
        })
        
    }
    
    func saveLocationInfo(placemark: CLPlacemark?, property: Property) {
        
        if let containsPlacemark = placemark
        {
            //get the mealID just saved
            let pdm: PropertyDataManager =  PropertyDataManager()
            let propertyDB = pdm.PropertyDatabaseSetUp()
            let id: Int = pdm.justsavedPropID(propertyDB)
            
            //get address compoents from geocoder
            let street = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : "Not found"
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : "Not found"
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : "Not found"
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : "Not found"
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : "Not found"
            
            print(street)
            print(locality)
            print(postalCode)
            print(administrativeArea)
            //           print(country)
            
            //get event date and time
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            //           let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitDay, fromDate: date)
            let components = calendar.components([.Hour, .Minute, .Month, .Year, .Day], fromDate: date)
            let hour = components.hour
            let minutes = components.minute
            let month = components.month
            let year = components.year
            let day = components.day
            
            let propertyDate = String(month) + "/" + String(day) + "/" + String(year) + ", " + String(hour) + ":" + String(minutes)
            
            //create restaurant object
            let loc = PurchaseLocation(lID: 1, pID: id, lAddress: street, lCity: locality, lState: administrativeArea, lZip: postalCode, lDate: propertyDate)
            
            //save restaurant object and handle any error
            let response: ActionResponse = pdm.SaveLocationData(propertyDB, loc: loc!)
            
            if (response.responseCode) == "Y" {
                
                let alertController = UIAlertController(title: "Alert!", message: response.responseDesc, preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                let alertWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
                alertWindow.rootViewController = UIViewController()
                alertWindow.windowLevel = UIWindowLevelAlert + 1;
                alertWindow.makeKeyAndVisible()
                
                alertWindow.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                
                
            }
            
            
        }
        
    }

    
}
