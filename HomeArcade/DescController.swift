//
//  DescController.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/31/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class DescController: UIViewController {
    
    
    @IBOutlet weak var DoneButton: UIBarButtonItem!
    
    
    @IBOutlet weak var DescPad: UITextView!
    
    var propertyDesc: String? = " "

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Change the navigation bar background color to blue.
        navigationController!.navigationBar.barTintColor = UIColor.orangeColor()
        
        // Change the color of the navigation bar button items to white.
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        navigationItem.title = "Note pad"
        
        DescPad.text = propertyDesc

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if DoneButton === sender {
            
            
            propertyDesc = DescPad.text
            
            let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
            if DescPad.text!.stringByTrimmingCharactersInSet(whitespaceSet) == "" {
                propertyDesc = "Description not available"
            }else{
                propertyDesc = DescPad.text
            }

            
        }
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
