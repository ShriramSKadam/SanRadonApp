//
//  InfoCollectionViewCell.swift
//  Luft
//
//  Created by iMac Augusta on 3/10/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lblInfoCellTitle: UILabel!
    @IBOutlet weak var lblInfoCellSubTitle: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var imgViewCenter: UIImageView!
    @IBOutlet weak var imgViewBacKLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
