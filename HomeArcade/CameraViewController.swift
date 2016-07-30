//
//  CameraViewController.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/29/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit
import MobileCoreServices

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var CancelCameraView: UIBarButtonItem!
    
    @IBOutlet weak var SaveCameraView: UIBarButtonItem!
    
    @IBOutlet weak var CameraImageView: UIImageView!
    
    @IBOutlet var CaptureImageGR: UITapGestureRecognizer!
    
    var newMedia: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Change the navigation bar background color to blue.
        navigationController!.navigationBar.barTintColor = UIColor.orangeColor()
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        //hide Accept button
        SaveCameraView.enabled=false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func CaptureImage(sender: UITapGestureRecognizer) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
            newMedia = true
        }
    }
    
        
    // This method lets you configure a view controller before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if SaveCameraView === sender {
            
            //Create Property object
            let PropertyImage = CameraImageView.image
        }

    }
    
    
    @IBAction func CancelCameraView(sender: AnyObject) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddPropMode = presentingViewController is UINavigationController
        
        if isPresentingInAddPropMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }

        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            CameraImageView.image = image
        
        if CameraImageView.image != "iphone_camera_icon2" {
            SaveCameraView.enabled = true
        }
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
