//
//  PlayerCell.swift
//  LOL-helper
//
//  Created by Bill Yu on 1/17/16.
//  Copyright © 2016 Bill Yu. All rights reserved.
//

import UIKit
import Alamofire

class PlayerCell: UITableViewCell {
    
    @IBOutlet weak var championImageView: UIImageView!
    @IBOutlet weak var summonerNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    func initialize(name: String, levelLabelText: String, winsLabelText: String) {
        summonerNameLabel.text = name
        levelLabel.text = levelLabelText
        winsLabel.text = winsLabelText
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
