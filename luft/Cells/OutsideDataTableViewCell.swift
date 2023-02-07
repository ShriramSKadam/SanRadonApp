//
//  OutsideDataTableViewCell.swift
//  Luft
//
//  Created by iMac Augusta on 12/16/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class OutsideDataTableViewCell: UITableViewCell {

    @IBOutlet weak var imgeAirQualitytriangle1: UIImageView!
    @IBOutlet weak var imgeAirQualitytriangle2: UIImageView!
    @IBOutlet weak var imgeAirQualitytriangle3: UIImageView!
    @IBOutlet weak var imgeAirQualitytriangle4: UIImageView!
    @IBOutlet weak var imgeAirQualitytriangle5: UIImageView!
    @IBOutlet weak var lblAirQuality: UILabel!
    @IBOutlet weak var lblOutsideTempValue: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblOutsideTemp: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblOutsideHumidityValue: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblOutsideHumidity: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblHeaderName: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblLocationName: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblOutSideCellBorderStatusCell: LTCellDashBoardBorderLabel!
    @IBOutlet weak var imgViewSeason: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
