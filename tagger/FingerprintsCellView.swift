//
//  FingerprintsCellView.swift
//  tagger
//
//  Created by Paolo Longato on 26/07/2015.
//  Copyright (c) 2015 Paolo Longato. All rights reserved.
//

import UIKit

class FingerprintsCellView: UITableViewCell {

    @IBOutlet weak var des: UILabel!
    @IBOutlet weak var dataPointsNumber: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }    
}
