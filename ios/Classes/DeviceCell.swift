//
//  DeviceTableViewCell.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/11.
//  Copyright © 2019 szabh. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelIdentifier: UILabel!
    @IBOutlet weak var labelRssi: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
