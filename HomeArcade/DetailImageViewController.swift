//
//  DetailImageViewController.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/27/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class DetailImageViewController: UIViewController {
    
    
    @IBOutlet weak var DetailViewBackButton: UIBarButtonItem!
    
    @IBOutlet weak var DetailImage: UIImageView!
    
    @IBOutlet var DismissDetailImageGR: UIPinchGestureRecognizer!
    
    var imagePassed: UIImage?
    
    override func viewDidLoad() {
      super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        DetailImage.image = imagePassed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    @IBAction func DismissDetailImage(sender: UIPinchGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }  */
    
    @IBAction func CancelDetailImage(sender: AnyObject) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddPropMode = presentingViewController is UINavigationController
        
        if isPresentingInAddPropMode {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController!.popViewControllerAnimated(true)
        }

    }
    

    
    @IBAction func DismissDetailImage(sender: UIPinchGestureRecognizer) {
        
        dismissViewControllerAnimated(true, completion: nil)
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
