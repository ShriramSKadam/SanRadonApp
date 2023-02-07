//
//  HeaderViewCollectionViewCell.swift
//  Luft
//
//  Created by iMac Augusta on 11/12/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class HeaderViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgViewFliter: LTCellDisclosureImageView!
    @IBOutlet weak var btnFliter: UIButton!
    @IBOutlet weak var viewHeaderFliter: UIView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewHeaderLbl: LTCellHeaderTitleLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.applyHeaderTheme()
    }

    func applyHeaderTheme() {
        self.viewHeaderFliter?.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        self.viewHeaderLbl?.textColor = ThemeManager.currentTheme().ltCellHeaderTitleColor
        self.imgViewFliter.image = nil
        let sortFilterType: Int = AppSession.shared.getUserSortFilterType()
        switch sortFilterType {
        case SortFilterTypeEnum.SortDeviceNameAscending.rawValue:
            self.imgViewFliter.image = ThemeManager.currentTheme().sortOrderDeviceNameAsecendingIconImage
        case SortFilterTypeEnum.SortDeviceNameDescending.rawValue:
            self.imgViewFliter.image = ThemeManager.currentTheme().sortOrderDeviceNameDesecendingIconImage
        case SortFilterTypeEnum.SortUpdateByNameAscending.rawValue:
            self.imgViewFliter.image = ThemeManager.currentTheme().sortByTimerAsecendingIconImage
        case SortFilterTypeEnum.SortUpdateByNameDescending.rawValue:
            self.imgViewFliter.image = ThemeManager.currentTheme().sortByTimerDesecendingIconImage
        default:
            print("")
        }
    }
}
