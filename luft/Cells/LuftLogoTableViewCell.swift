//
//  LuftLogoTableViewCell.swift
//  Luft
//
//  Created by iMac Augusta on 12/16/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class LuftLogoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCellBorderStatusCell: LTCellDashBoardBorderLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
