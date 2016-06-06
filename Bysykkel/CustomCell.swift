//
//  CustomCell.swift
//  Bysykkel
//
//  Created by Markus Andresen on 10/05/16.
//  Copyright © 2016 Markus Andresen. All rights reserved.
//

import UIKit
import KeepBackgroundCell

class CustomCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var two: UILabel!
    @IBOutlet weak var one: UILabel!
    var id = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.keepSubviewBackground = true
        img.layer.cornerRadius = img.frame.size.width/2
        img.clipsToBounds = true
       
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    

}
