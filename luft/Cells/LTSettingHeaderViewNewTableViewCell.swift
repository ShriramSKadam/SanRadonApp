//
//  LTSettingHeaderViewNewTableViewCell.swift
//  Luft
//
//  Created by Shriram Subash on 19/10/22.
//  Copyright © 2022 iMac. All rights reserved.
//

import UIKit

class LTSettingHeaderViewNewTableViewCell: UITableViewCell {

    @IBOutlet weak var cellHeaderBackView: LTCellHeaderView!
    @IBOutlet weak var lblHeaderTilte: LTCellHeaderTitleLabel!
    @IBOutlet weak var lblHeaderSubTitle: LTCellHeaderTitleLabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
