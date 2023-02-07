//
//  LTSettingHeaderView TableViewCell.swift
//  luft
//
//  Created by iMac Augusta on 10/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class LTSettingHeaderViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellHeaderBackView: LTCellHeaderView!
    @IBOutlet weak var lblHeaderTilte: LTCellHeaderTitleLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension UITableViewCell {
  func separator(hide: Bool) {
    separatorInset.left = hide ? bounds.size.width : 0
  }
}
