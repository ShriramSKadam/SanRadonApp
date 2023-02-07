//
//  DeviceStatusTableViewCell.swift
//  luft
//
//  Created by iMac Augusta on 10/14/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class DeviceStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var lblLastSyncHeader: LTCellSyncHeaderLabel!
    @IBOutlet weak var lblLastSync: LTCellSyncLabel!
    @IBOutlet weak var btnSync: LTCellSyncButton!
    @IBOutlet weak var viewLastSync: UIView!
    @IBOutlet weak var btnSelectedDevice: ViewBorderButton!
    @IBOutlet weak var statusSelectedDeviceName: LTCellSyncHeaderLabel!
    @IBOutlet weak var imgViewBluWifi: UIImageView!
    @IBOutlet weak var lblDeviceConnectStatus: LTCellSyncHeaderLabel!
    @IBOutlet weak var imgViewStatus: UIImageView!
    @IBOutlet weak var lblBorderStatusCell: LTCellDashBoardBorderLabel!
    
    var arrCurrentIndexValue:[RealmPollutantValuesTBL] = []
    var strCurrentDeviceID:Int = 0
    var arrPollutantVOCData:[RealmThresHoldSetting] = []
    var selectedDropDownType:AppDropDownType? = .DropDownNone
    var arrColorCodeData:[RealmColorSetting] = []

    var colorRadonType:ColorType = .ColorNone
    var colorTempType:ColorType = .ColorNone
    var colorHumidityType:ColorType = .ColorNone
    var colorAirpressureType:ColorType = .ColorNone
    var colorVocType:ColorType = .ColorNone
    var colorEco2Type:ColorType = .ColorNone
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        //self.btnSync.isHidden = false
    }
    
    func applyDeviceCellTheme()  {
        self.lblLastSync.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblLastSyncHeader.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.btnSync.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)
        
//        self.lblLastSync.isHidden = true
//        self.lblLastSyncHeader.isHidden = true
//        self.btnSync.isHidden = true
        
        self.statusSelectedDeviceName.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblDeviceConnectStatus.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.statusSelectedDeviceName.textColor = UIColor.white
        self.lblBorderStatusCell?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
        self.statusSelectedDeviceName?.font = UIFont.setSystemFontMedium(17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

extension DeviceStatusTableViewCell {
    
    func readDataCurrentIndex() {
        self.arrCurrentIndexValue.removeAll()
        self.arrCurrentIndexValue = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: self.strCurrentDeviceID)
        if self.arrCurrentIndexValue.count != 0 {
            var timeValue:Int = 0
            var timeDiff:Int = 0
            timeDiff = RealmDataManager.shared.getDeviceData(deviceID: self.strCurrentDeviceID)[0].timeDiffrence.toInt() ?? 0
            timeValue = (self.arrCurrentIndexValue[0].timeStamp / 1000) + timeDiff
            
            let date1 = Date(timeIntervalSince1970: TimeInterval(timeValue))
            let dateFormatter1 = DateFormatter()
            dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter1.locale = NSLocale.current
            dateFormatter1.dateFormat = "MM/dd/yyyy"
            let dateValue = dateFormatter1.string(from: date1)
            
            let date = Date(timeIntervalSince1970: TimeInterval(timeValue))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "h:mm a"
            let strTimeValue = dateFormatter.string(from: date)
            
            self.lblLastSync.text = String(format: "%@ at %@", dateValue,strTimeValue)
            
            self.arrCurrentIndexValue.removeAll()
            self.arrCurrentIndexValue = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: self.strCurrentDeviceID)
            if self.arrCurrentIndexValue.count != 0 {
                
                self.colorRadonType = Helper.shared.getRadonColor(myValue: self.arrCurrentIndexValue[0].Radon, deviceId: self.strCurrentDeviceID).type
                self.colorVocType = Helper.shared.getVOCColor(myValue: self.arrCurrentIndexValue[0].VOC, deviceId: self.strCurrentDeviceID).type
                self.colorEco2Type = Helper.shared.getECO2Color(myValue: self.arrCurrentIndexValue[0].CO2, deviceId: self.strCurrentDeviceID).type
                self.colorTempType = Helper.shared.getTempeatureColor(myValue: self.arrCurrentIndexValue[0].Temperature, deviceId: self.strCurrentDeviceID).type
                self.colorAirpressureType = Helper.shared.getAirPressueColor(myValue: self.arrCurrentIndexValue[0].AirPressure, deviceId: self.strCurrentDeviceID).type
                self.colorHumidityType = Helper.shared.getHumidityColor(myValue: self.arrCurrentIndexValue[0].Humidity, deviceId: self.strCurrentDeviceID).type
                
                if self.colorRadonType == ColorType.ColorAlert || self.colorVocType == ColorType.ColorAlert || self.colorEco2Type == ColorType.ColorAlert || self.colorTempType == ColorType.ColorAlert || self.colorAirpressureType == ColorType.ColorAlert || self.colorHumidityType == ColorType.ColorAlert {
                    self.btnSelectedDevice.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorAlert))
                    self.imgViewStatus.image = UIImage.init(named: "dissatisfied")
                    
                }else if self.colorRadonType == ColorType.ColorWarning || self.colorVocType == ColorType.ColorWarning || self.colorEco2Type == ColorType.ColorWarning || self.colorTempType == ColorType.ColorWarning || self.colorAirpressureType == ColorType.ColorWarning || self.colorHumidityType == ColorType.ColorWarning {
                    self.btnSelectedDevice.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorWarning))
                    self.imgViewStatus.image = UIImage.init(named: "warning")
                }else {
                    self.btnSelectedDevice.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
                    self.imgViewStatus.image = UIImage.init(named: "smile")
                }
            }else {
                self.btnSelectedDevice.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
                self.imgViewStatus.image = UIImage.init(named: "smile")
            }
        }else {
            self.btnSelectedDevice.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
            self.imgViewStatus.image = UIImage.init(named: "smile")
            self.lblLastSync.text = String(format: "No data available")
        }
    }
    
    private func getUNIXTime(timeResult: Date) -> String {
        // let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone =  TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.string(from: timeResult)
        return localDate
    }

}
