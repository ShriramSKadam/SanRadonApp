//
//  DeviceCollectionViewCell.swift
//  luft
//
//  Created by iMac Augusta on 10/14/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class DeviceCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblSideBorder: UILabel!
    @IBOutlet weak var lblBottomBorder: UILabel!
    @IBOutlet weak var imgViewClosure: UIImageView!
    @IBOutlet weak var imgViewBluWifi: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func applyCellNameDataTheme()  {
        self.lblDeviceName.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblBottomBorder?.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
    }
}
