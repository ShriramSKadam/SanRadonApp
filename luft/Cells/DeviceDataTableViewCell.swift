//
//  DeviceDataTableViewCell.swift
//  luft
//
//  Created by iMac Augusta on 10/14/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class DeviceDataTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCellRadon: UILabel!
    @IBOutlet weak var lblCellVOC: UILabel!
    @IBOutlet weak var lblCelleCo2: UILabel!
    @IBOutlet weak var lblCellValueRadon: UILabel!
    @IBOutlet weak var lblCellValueVOC: UILabel!
    @IBOutlet weak var lblCellValueeCo2: UILabel!
    
    @IBOutlet weak var lblCellTemp: UILabel!
    @IBOutlet weak var lblCellHumidity: UILabel!
    @IBOutlet weak var lblCellAirPressure: UILabel!
    @IBOutlet weak var lblCellValueTemp: UILabel!
    @IBOutlet weak var lblCellValueHumidity: UILabel!
    @IBOutlet weak var lblCellValueAirPressure: UILabel!
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var showDataView: UIView!
    
    var arrCurrentIndexValue:[RealmPollutantValuesTBL] = []
    var strCurrentDeviceID:Int = 0
    var pollutantType:PollutantType = .PollutantAirPressure
    var selectedDropDownType:AppDropDownType? = .DropDownNone
    
    @IBOutlet weak var lblLastSyncHeader: LTCellSyncHeaderLabel!
    @IBOutlet weak var lblLastSync: LTCellSyncLabel!
    @IBOutlet weak var btnSync: LTCellSyncButton!
    
    @IBOutlet weak var lblNodataLastSyncHeader: LTCellSyncHeaderLabel!
    @IBOutlet weak var lblNodataLastSync: LTCellSyncLabel!
    @IBOutlet weak var btnSync1: LTCellSyncButton!
    @IBOutlet weak var imageViewBtnSync: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setMyLabelText()
        self.btnSync.isHidden = false
        
    }
    
    func setMyLabelText() {
        let numberString = NSMutableAttributedString(string: "eCO", attributes: [.font: UIFont.setSystemFontRegular(17)])
        numberString.append(NSAttributedString(string: "2", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: -2]))
        self.lblCelleCo2.attributedText = numberString
    }
    
    func setRadonLabelText() {
        
    }
    
    func applyCellTempDataTheme()  {
        self.lblCellRadon.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblCellVOC.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblCelleCo2.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblCellTemp.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblCellHumidity.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblCellAirPressure.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.noDataView.isHidden = false
        self.showDataView.isHidden = true
        self.lblLastSync.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblLastSyncHeader.textColor = ThemeManager.currentTheme().ltCellTitleColor
        
        self.lblNodataLastSyncHeader.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblNodataLastSync.textColor = ThemeManager.currentTheme().ltCellTitleColor
        
        self.btnSync.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)
        self.btnSync1.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
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
            self.noDataView.isHidden = true
            self.showDataView.isHidden = false
            self.lblCellValueRadon.text = self.updateRadonvalues(values: self.arrCurrentIndexValue[0].Radon)
            self.lblCellValueVOC.text = self.updateVOCvalues(values: self.arrCurrentIndexValue[0].VOC)
            self.lblCellValueeCo2.text = self.updateEco2values(values: self.arrCurrentIndexValue[0].CO2)
            self.lblCellValueTemp.text = self.updateTempraturevalues(values: self.arrCurrentIndexValue[0].Temperature)
            self.lblCellValueHumidity.text = self.updateHumidityvalues(values: self.arrCurrentIndexValue[0].Humidity)
            self.lblCellValueAirPressure.text = self.updateAirPressurevalues(values: self.arrCurrentIndexValue[0].AirPressure)
            if AppSession.shared.getMobileUserMeData()?.radonUnitTypeId == 1{
                let valueStr = String(format: "%@ Bq/m" , self.lblCellValueRadon.text ?? "")
                let numberString = NSMutableAttributedString(string: valueStr, attributes: [.font: UIFont.setAvnierNextAppFontMedium(17)])
                numberString.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setAvnierNextAppFontMedium(14), .baselineOffset: 7]))
                self.lblCellValueRadon.attributedText = numberString
            }
        }else {
            self.noDataView.isHidden = false
            self.showDataView.isHidden = true
            self.lblLastSync.text = String(format: "No data available")
        }
    }
    
    func updateRadonvalues(values:Float = 0.0) -> String  {
        self.lblCellValueRadon.textColor = Helper.shared.getRadonColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        if AppSession.shared.getMobileUserMeData()?.radonUnitTypeId == 2{
            self.selectedDropDownType = .DropDownRadonPCII
            if let myRadonValue = Float(String(format: "%.1f", values)) {
                return String(format: "%.1f pCi/I",myRadonValue)
            }
            return String(format: "%@ pCi/I",values )
        }else {
            return String(format: "%d", String(format:"%f", Helper.shared.convertRadonPCILToBQM3(value: values).rounded()).toInt() ?? 0)
        }
    }
    
    func updateVOCvalues(values:Float = 0.0) -> String  {
        var myVOCValue:Int = 0
        self.lblCellValueVOC.textColor = Helper.shared.getVOCColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        myVOCValue = String(format: "%f",values.rounded()).toInt() ?? 0
        return String(format: "%d ppb",myVOCValue)
    }
    
    func updateEco2values(values:Float = 0.0) -> String  {
        var myECOValue:Int = 0
        self.lblCellValueeCo2.textColor = Helper.shared.getECO2Color(myValue: values, deviceId: self.strCurrentDeviceID).color
        myECOValue = String(format: "%f",values.rounded()).toInt() ?? 0
        return String(format: "%d ppm",myECOValue)
    }
    
    func updateTempraturevalues(values:Float = 0.0) -> String  {
        self.lblCellValueTemp.textColor = Helper.shared.getTempeatureColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        self.selectedDropDownType = .DropDownTEMPERATURE_CELSIUS
        if AppSession.shared.getMobileUserMeData()?.temperatureUnitTypeId == 1{
            self.selectedDropDownType = .DropDownTEMPERATURE_FAHRENHEIT
            return String(format: "%d F",Int((values.rounded())))
        }else {
            return String(format: "%d C",String(format: "%f", Helper.shared.convertTemperatureFahrenheitToCelsius(value:values).rounded()).toInt() ?? 0)
        }
    }
    
    func updateAirPressurevalues(values:Float = 0.0) -> String  {
  
        var airPressureValue:Float = values
        var isLocalAltitudeINHG: Float = 0.0
        if Helper.shared.getDeviceDataAltitude(deviceID: self.strCurrentDeviceID).isAltitude == true {
            isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: self.strCurrentDeviceID).isLocalAltitudeINHG
            airPressureValue = values + isLocalAltitudeINHG
        }
        
        self.lblCellValueAirPressure.textColor = Helper.shared.getAirPressueColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
            var myAirPressureINHGValue:Float = 0.0
            myAirPressureINHGValue = Float(String(format: "%.2f", airPressureValue)) ?? 0.0
            myAirPressureINHGValue = myAirPressureINHGValue + isLocalAltitudeINHG
            return String(format: "%.2f inHg",myAirPressureINHGValue)
        }else {
            self.selectedDropDownType = .DropDownAIRPRESSURE_MBAR
            var myAirPressureMBARValue:Int = 0
            myAirPressureMBARValue = String(format: "%f", Helper.shared.convertAirPressureINHGToMBAR(value: airPressureValue).rounded()).toInt() ?? 0
            return String(format: "%d mbar",myAirPressureMBARValue)
        }
    }
    
    func updateHumidityvalues(values:Float = 0.0) -> String  {
        self.lblCellValueHumidity.textColor = Helper.shared.getHumidityColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        var myHumidityvalue:Int = 0
        myHumidityvalue = String(format: "%f",values.rounded()).toInt() ?? 0
        return String(format: "%d %%",myHumidityvalue)
    }

}

