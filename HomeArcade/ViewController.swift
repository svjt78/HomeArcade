//
//  ViewController.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/5/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource,UIPickerViewDelegate, UITextViewDelegate , UIViewControllerTransitioningDelegate {

    @IBOutlet weak var PropertyName: UITextField!
    
    @IBOutlet weak var ItemID: UILabel!
    
    @IBOutlet weak var PropertyImage: UIImageView!
    
    @IBOutlet weak var ReceiptImage: UIImageView!
    
    @IBOutlet weak var PropertyDesc: UITextView!
    
    @IBOutlet weak var PurchaseStreet: UITextField!
    
    @IBOutlet weak var PurchaseCity: UITextField!
    
    @IBOutlet weak var PurchaseState: UITextField!
    
    @IBOutlet weak var PurchaseZip: UITextField!
    
    @IBOutlet weak var PurchaseDateTime: UITextField!
    
    
    @IBOutlet weak var SaveProp: UIBarButtonItem!
    
    
    @IBOutlet weak var CancelProp: UIBarButtonItem!
    
    var pickerView = UIPickerView()
    
    @IBOutlet var PropTapGR: UITapGestureRecognizer!
    
    @IBOutlet var ReceiptTapGR: UITapGestureRecognizer!
    
    @IBOutlet var PropPanGesture: UIPanGestureRecognizer!
    
    @IBOutlet var ReceiptPanGesture: UIPanGestureRecognizer!
    
    @IBOutlet var PropertyImageCaptureGR: UILongPressGestureRecognizer!
    
    @IBOutlet var ReceiptImageCaptureGR: UILongPressGestureRecognizer!
    
    var property: Property?
    var location: PurchaseLocation?
    var imageInd: Int = 0
    var imageDetailInd = 0
    var imageCaptureInd = 0
    
    //Instanciate nimation controllers
    let customPresentAnimationController = CustomPresentViewController()
    let customDismissAnimationController = CustomDismissAnimationController()
    let customNavigationAnimationController = CustomNavigationAnimationController()
    
    
    var pickOption = ["one", "two", "three", "seven", "fifteen"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Change the navigation bar background color to blue.
        navigationController!.navigationBar.barTintColor = UIColor.orangeColor()
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        /*
         // Change the color of the navigation bar title text to yellow.
         navigationController!.navigationBar.titleTextAttributes =
         [NSForegroundColorAttributeName: UIColor.yellowColor()]
         */
        PropertyName.delegate=self
        PurchaseStreet.delegate = self
        PurchaseCity.delegate = self
        PurchaseState.delegate = self
        PurchaseZip.delegate = self
        PurchaseDateTime.delegate = self
        self.navigationController?.delegate = self
        
        //Setup Pickerview attached to the Purchase State textfield
        
        pickerView.delegate = self
        
        PurchaseState.inputView = pickerView
        
        // Set up views if editing an existing Meal.
        ItemID.hidden = true
        if let property = property {
            ItemID.text = String(property.propID)
            navigationItem.title = property.propName
            PropertyName.text   = property.propName
            PropertyImage.image = property.propPhoto
            ReceiptImage.image = property.receiptPhoto
            PropertyDesc.text = property.propDesc
            
            
            let pdm: PropertyDataManager = PropertyDataManager()
            let pID = property.propID
            let propertyDB = pdm.PropertyDatabaseSetUp()
            let loc: PurchaseLocation = pdm.loadLocationData(propertyDB, pID: pID)
            
            PurchaseStreet.text = loc.lAddress
            PurchaseCity.text = loc.lCity
            PurchaseState.text = loc.lState
            PurchaseZip.text = loc.lZip
            PurchaseDateTime.text = loc.lDate
            /*
            if PurchaseStreet.text == "Not found" {
                PurchaseStreet.hidden = true
            }
            
            if PurchaseCity.text == "Not found" {
                PurchaseCity.hidden = true
            }
            
            if PurchaseState.text == "Not found" {
                PurchaseState.hidden = true
            }
            
            if PurchaseZip.text == "Not found" {
                PurchaseZip.hidden = true
            }
            
            if PurchaseDateTime.text == "Not found" {
                PurchaseDateTime.hidden = true
            }
            */
            if PurchaseStreet.text == "Not found" {
                PurchaseStreet.text = ""
            }
            
            if PurchaseCity.text == "Not found" {
                PurchaseCity.text = ""
            }
            
            if PurchaseState.text == "Not found" {
                PurchaseState.text = ""
            }
            
            if PurchaseZip.text == "Not found" {
                PurchaseZip.text = ""
            }
            
            if PurchaseDateTime.text == "Not found" {
                PurchaseDateTime.text = ""
            }

            
        }else{
            ItemID.text = "1"
        }
        
        checkValidPropertyName()
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //       doneButton.userInteractionEnabled = true
        // Disable the Save button while editing.
        if textField == PropertyName {
            SaveProp.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //        mealLabel.text = textField.text
        if textField == PropertyName {
            checkValidPropertyName()
            navigationItem.title = textField.text
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        // text hasn't changed yet, you have to compute the text AFTER the edit yourself
        /*     let updatedString = (textField.text as NSString?)?.stringByReplacingCharactersInRange(range, withString: string)  */
        
        // do whatever you need with this updated string (your code)
        
        //       doneButton.userInteractionEnabled = true
        
        checkValidPropertyName()
        
        if textField == PropertyName {
        
            navigationItem.title = textField.text! + string
            
            if (string == "") {
                if let selectedRange = textField.selectedTextRange {
                    
                    let cursorPosition = textField.offsetFromPosition(textField.beginningOfDocument, toPosition: selectedRange.start)
                    if cursorPosition == 1 {
                        SaveProp.enabled = false
                        navigationItem.title = "New Property"
                        
                    }
                }
            }
        }
        
        // always return true so that changes propagate
        return true
    }
    
    
    
    
    @IBAction func performStateSelection(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(ViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        PurchaseState.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    
    
    @IBAction func CancelDetailView(sender: AnyObject) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddPropMode = presentingViewController is UINavigationController
        
        if isPresentingInAddPropMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    
    
    
    
    @IBAction func PropertyTapGR(sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        PropertyName.resignFirstResponder()
        
        //Check which image is clicked 
        
        imageInd = 1
        
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func ReceiptTapGR(sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        PropertyName.resignFirstResponder()
        
        //Check which image is clicked
        
        imageInd = 2
        
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController1 = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController1.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController1.delegate = self
        
        presentViewController(imagePickerController1, animated: true, completion: nil)
        
    }
    
    
    @IBAction func PropPanGesture(sender: UIPanGestureRecognizer) {
        imageDetailInd = 1
        performSegueWithIdentifier("imageDetailSegue", sender: nil)
    }
    
    
    @IBAction func ReceiptPanGesture(sender: UIPanGestureRecognizer) {
        imageDetailInd = 2
        performSegueWithIdentifier("imageDetailSegue", sender: nil)
    }
    
   /*
    @IBAction func touchPhoto(sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        PropertyName.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .PhotoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
        
    }  */
    
    //Mark imagepicker delegates
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        
        if imageInd == 1 {
            PropertyImage.image = selectedImage
        } else {
            ReceiptImage.image = selectedImage
        }
        
        
        // Dismiss the picker.
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if SaveProp === sender {
            
            //Create Property object
            let PropID = Int(ItemID.text!)!
            let PropName = PropertyName.text
            let PropPhoto = PropertyImage.image
            let ReceiptPhoto = ReceiptImage.image
            var PropDesc = PropertyDesc.text ?? ""
            
            let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
            if PropertyDesc.text!.stringByTrimmingCharactersInSet(whitespaceSet) == "" {
                PropDesc = "Description not available"
            }else{
                PropDesc = PropertyDesc.text
            }
            
            // Set the meal to be passed to MealTableViewController after the unwind segue.
            property = Property(propID: PropID, propName: PropName!, propPhoto: PropPhoto, receiptPhoto: ReceiptPhoto, propDesc: PropDesc)
            
            //Save Location object
            if (PurchaseStreet.text  != nil) && (PurchaseStreet.text != "") {
            let lcID = 1
            let prID = PropID
            let lcAddress = (PurchaseStreet.text != nil) ? PurchaseStreet.text : "Not found"
            let lcCity = (PurchaseCity.text != nil) ? PurchaseCity.text : "Not found"
            let lcState = (PurchaseState.text != nil) ? PurchaseState.text : "Not found"
            let lcZip = (PurchaseZip.text != nil) ? PurchaseZip.text : "Not found"
            let lcDate = (PurchaseDateTime.text != nil) ? PurchaseDateTime.text : "Not found"
            
            let location = PurchaseLocation(lID: lcID, pID: prID, lAddress: lcAddress, lCity: lcCity, lState: lcState, lZip: lcZip, lDate: lcDate!)
            
            let pdm: PropertyDataManager = PropertyDataManager()
            let propertyDB = pdm.PropertyDatabaseSetUp()
            let response: ActionResponse = pdm.updateLocationData(propertyDB, loc: location!)
            
            if (response.responseCode) == "Y" {
                
                let alertController = UIAlertController(title: "Alert!", message: response.responseDesc, preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                presentViewController(alertController, animated: true, completion: nil)
            }
            }
            
        }else{
            if segue.identifier! == "imageDetailSegue" {
                
               let toViewController = segue.destinationViewController as! DetailImageViewController
                
      //          let nav = segue.destinationViewController as! UINavigationController
      //          let toViewController = nav.topViewController as! DetailImageViewController
                
                toViewController.transitioningDelegate = self
                
                let selectedImage: UIImage?
                
                // Get the cell that generated this segue.
                if imageDetailInd == 1 {
                    selectedImage = PropertyImage.image
                }else{
                    selectedImage = ReceiptImage.image
                }
                
                toViewController.imagePassed = selectedImage
                
                
            }else{
                if segue.identifier! == "CameraViewSegue" {
                    
                    let nav = segue.destinationViewController as! UINavigationController
                    let toViewController = nav.topViewController as! CameraViewController
                    
                    toViewController.transitioningDelegate = self

            
                }
            }
        }
        
    }
    
    @IBAction func unwindToDetailView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? CameraViewController, image1 = sourceViewController.CameraImageView.image {
            
            if imageCaptureInd == 1 {
                PropertyImage.image = image1
            }else{
                ReceiptImage.image = image1
            }
        }
    }
    
    
    @IBAction func PropertyImageCapture(sender: UILongPressGestureRecognizer) {
        imageCaptureInd = 1
        performSegueWithIdentifier("CameraViewSegue", sender: nil)

    }
    
    
    @IBAction func ReceiptImageCapture(sender: UILongPressGestureRecognizer) {
        imageCaptureInd = 2
        performSegueWithIdentifier("CameraViewSegue", sender: nil)

    }
    
    
    //Return animation controller objects - start
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customPresentAnimationController
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        customNavigationAnimationController.reverse = operation == .Pop
        return customNavigationAnimationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customDismissAnimationController
    }
        //Return animation controller objects - end
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        if PropertyName.text!.stringByTrimmingCharactersInSet(whitespaceSet) == "" {
            
            let alertController = UIAlertController(title: "Alert!", message: "Enter valid property name", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
            
            return false
        }
            
        else {
            return true
        }
        
        
        // by default, transition
        return true
    }
    
    //Set number of components in picker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Set number of rows in components
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    
    //Set title for each row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    //Update textfield text when row is selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        PurchaseState.text = pickOption[row]
    }


func checkValidPropertyName() {
    // Disable the Save button if the text field is empty.
    let text = PropertyName.text ?? ""
    SaveProp.enabled = !text.isEmpty
}


}



