//
//  LTSettingListTableViewCell.swift
//  luft
//
//  Created by iMac Augusta on 10/8/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class LTSettingListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitleCell: LTCellTitleLabel!
    @IBOutlet weak var lblSubTitleCell: LTCellSubTitleLabel!
    @IBOutlet weak var imgViewDisclosureCell: LTCellDisclosureImageView!
    @IBOutlet weak var cellBackView: LTCellView!
    @IBOutlet weak var lblTitleView: LTCellView!
    @IBOutlet weak var lblSubTitleView: LTCellView!
    @IBOutlet weak var cellImageView: LTCellView!
    @IBOutlet weak var lblCellBorder: LTCellBorderLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    
}
