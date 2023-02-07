//
//  FirmwareTableViewCell.swift
//  Luft
//
//  Created by iMac Augusta on 12/31/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class FirmwareTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitleCell: LTFWCellTitleLabel!
    @IBOutlet weak var lblSubTitleCell: LTFWCellSubTitleLabel!
    @IBOutlet weak var imgViewDisclosureCell: LTCellDisclosureImageView!
    @IBOutlet weak var cellBackView: LTCellView!
    @IBOutlet weak var lblTitleView: LTCellView!
    @IBOutlet weak var cellImageView: LTCellView!
    @IBOutlet weak var lblCellBorder: LTCellBorderLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
