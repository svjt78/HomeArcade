//
//  PropertyTableViewCell.swift
//  HomeArcade
//
//  Created by Suvojit Dutta on 7/18/16.
//  Copyright © 2016 Suvojit Dutta. All rights reserved.
//

import UIKit

class PropertyTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var PropertyPhoto: UIImageView!

    @IBOutlet weak var PropertyName: UILabel!
    
    
    @IBOutlet weak var PropertyID: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

