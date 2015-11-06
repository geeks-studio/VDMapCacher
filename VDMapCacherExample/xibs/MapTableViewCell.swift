//
//  MapTableViewCell.swift
//  AitaOfflineMapWidgetExample
//
//  Created by Vadim Drobinin on 5/10/15.
//  Copyright © 2015 Vadim Drobinin. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
