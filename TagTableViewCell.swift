//
//  TableViewCell.swift
//  getlistble
//
//  Created by admin on 14/08/2016.
//  Copyright © 2016 HITDEV. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {

  
  
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var imageTag: UIImageView!
   
       override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
   
    }
    
 
  

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setCell(name: String, imageName: String)  {
        self.nameLBL.text = name
        self.imageTag.image = UIImage(named: imageName)
    }
}
