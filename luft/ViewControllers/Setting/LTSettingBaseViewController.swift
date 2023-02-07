//
//  LTSettingBaseViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/12/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData

class LTSettingBaseViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var settingDeviceSerialID:String = ""
    var settingDeviceID:Int = 0
    var isWriteCompleted:Int = 0
    
    var isOkLEDBrightNess:String = "1"
    var isWarningLEDBrightNess:String = "1"
    var isAlertLEDBrightNess:String = "1"
    var isNightlightLEDBrightNess:String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //UIApplication.shared.statusBarView?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.setLatestStatusBar()
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarTextColor
    }
    
    func readColorValueData(colorCodeValue:String) -> String  {
        
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_COLORS)
        let predicate = NSPredicate(format: "colorcode = %@", String(format: "%@", colorCodeValue))
        fetch.predicate = predicate
        do {
            let result = try context.fetch(fetch)
            for data in result as! [NSManagedObject] {
                return data.value(forKey: "colorname") as! String
            }
        } catch {
            print("Failed")
        }
        return ""
    }
    
    func getOptionalString(first: String, last: String)-> String?{
        return  String(format: "%@:%@", first,last)
    }
    
    func readIntToSecondsValueData(timeValue:Int) -> String  {
        
        let seconds = timeValue % 60
        let minutes = (timeValue / 60) % 60
        let hours = timeValue / 3600
        let strHours = hours > 9 ? String(hours) : "0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        
       
        if hours > 0 {
            if let strValue:String = getOptionalString(first: strHours, last: strMinutes) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                
                let inFormatter = DateFormatter()
                inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                inFormatter.dateFormat = "HH:mm"
                
                let outFormatter = DateFormatter()
                outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                outFormatter.dateFormat = "hh:mm a"
                
                
                if let date = inFormatter.date(from: strValue) {
                   let outStr = outFormatter.string(from: date)
                    return outStr
                }
                
            }
            return ""
        }
        else {
            if let strValue:String = getOptionalString(first: strMinutes, last: strSeconds) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                
                let inFormatter = DateFormatter()
                inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                inFormatter.dateFormat = "HH:mm"
                
                let outFormatter = DateFormatter()
                outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                outFormatter.dateFormat = "hh:mm a"
                
                if let date = inFormatter.date(from: strValue) {
                    let outStr = outFormatter.string(from: date)
                    return outStr
                }
            }
            return ""
        }
    }
    
    
    func convertRadonBQM3ToPCIL(value : Float) -> Float{
        return value/37
    }
    
    func convertRadonPCILToBQM3(value : Float) -> Float{
        return value*37
    }
    
    func convertTemperatureCelsiusToFahrenheit(value: Float) -> Float{
        return ((value * 9) / 5) + 32
    }
    
    func convertTemperatureFahrenheitToCelsius(value: Float) -> Float{
        return ((value - 32) * 5 / 9)
    }
    
    func convertAirPressureINHGToKPA(value: Float) -> Double{
        return Double(value/0.295300)
    }
    
    func convertAirPressureKPAToINHG(value: Float) -> Double{
        return Double(value*0.295300)
    }
 
    func convertAirPressureINHGToMBAR(value: Float) -> Double{
        return Double(value*33.864)
    }
    
    func convertAirPressureMBARToINHG(value: Float) -> Double{
        return Double(value/33.864)
    }
    
    func getColorCodeOCTALvalue(colorValue:String) -> Int {
        switch colorValue {
        case "#F7F9F9":
            return 0x01
        case "#3E82F7":
            return 0x02
        case "#800080":
            return 0x03
        case "#E15D5B":
            return 0x04
        case "#FFA500":
            return 0x05
        case "#DEBF54":
            return 0x06
        case "#32C772":
            return 0x07
        case "#FFC0CB":
            return 0x08
        default:
            return 0x00
        }
        //let arrColorName:[String] = ["White", "Blue", "Purple", "Red", "Orange", "Yellow", "Green", "Pink"]
    }
}

extension LTSettingBaseViewController: ThresHoldBLEManagerManagerStateDelegate,ThresHoldDelegate {
    
    @objc func thresHoldWriteStatus(writeStatus:Bool){
        print("Write Status -  Parent view")
    }
    
    @objc func getThresHoldBLEManagerBleState(isConnectedBLEState:Bool) {
        DispatchQueue.main.async(execute: {
            self.tabBarController?.tabBar.isHidden = true
        })
        self.hideActivityIndicator(self.view)
        if self.isWriteCompleted == 1 {
            
        }else {
           self.showBleNotConnectAlert()
        }
        
    }
    
    func thresHoldDelegates()  {
        SettingBLEManager.shared.delegateThresHoldBleManagerState = self
        SettingBLEManager.shared.delegateThresHoldBleWriteState = self
    }
    
    func showBleNotConnectAlert()  {
        self.hideActivityIndicator(self.view)
        let titleString = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string:"Device not connected over Bluetooth. It could be due to Device is not in Bluetooth range or Device is already connected with another phone. Please try again later.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "Ok", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        Helper.shared.removeBleutoothConnection()
    }
    
}
extension LTSettingBaseViewController {
    
    func writeRadonValueViaBLE(selectedLowAlert:Float, selectedLowWarning:Float, deviceIDSetting: Int, deviceSerialID: String)  {
        //self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.thresHoldLowAlert = Int(selectedLowAlert * 100)
        SettingBLEManager.shared.thresHoldLowWarning = Int(selectedLowWarning * 100)
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothThresHoldWriteRadon)
        self.thresHoldDelegates()
    }
    
    func writeVOCValueViaBLE(selectedLowAlert:Float, selectedLowWarning:Float, deviceIDSetting: Int, deviceSerialID: String)  {
       // self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.thresHoldLowAlert = Int(selectedLowAlert)
        SettingBLEManager.shared.thresHoldLowWarning = Int(selectedLowWarning)
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothThresHoldWriteVOC)
        self.thresHoldDelegates()
    }
    
    func writeECOValueViaBLE(selectedLowAlert:Float, selectedLowWarning:Float, deviceIDSetting: Int, deviceSerialID: String)  {
       // self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.thresHoldLowAlert = Int(selectedLowAlert)
        SettingBLEManager.shared.thresHoldLowWarning = Int(selectedLowWarning)
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothThresHoldWriteECO)
        self.thresHoldDelegates()
    }
    
    func writeTempratureValueViaBLE(selectedLowWarning:Float, selectedHighWarning:Float, selectedLowAlert:Float, selectedHighAlert:Float, deviceIDSetting: Int, deviceSerialID: String)  {
        //self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.thresHoldLowWarning = Int(selectedLowWarning * 100)
        SettingBLEManager.shared.thresHoldHighWarning = Int(selectedHighWarning * 100)
        SettingBLEManager.shared.thresHoldLowAlert = Int(selectedLowAlert * 100)
        SettingBLEManager.shared.thresHoldHighAlert = Int(selectedHighAlert * 100)
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothThresHoldWriteTempearture)
        self.thresHoldDelegates()
    }
    
    func writeAirPressureValueViaBLE(selectedLowWarning:Float, selectedHighWarning:Float, selectedLowAlert:Float, selectedHighAlert:Float, deviceIDSetting: Int, deviceSerialID: String)  {
        
        var isLocalAltitudeINHG: Float = 0.0
        if Helper.shared.getDeviceDataAltitude(deviceID: deviceIDSetting).isAltitude == true {
            isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: deviceIDSetting).isLocalAltitudeINHG
        }
       // self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.thresHoldLowWarning = Int((selectedLowWarning - isLocalAltitudeINHG) * 100)
        SettingBLEManager.shared.thresHoldHighWarning = Int((selectedHighWarning - isLocalAltitudeINHG) * 100)
        SettingBLEManager.shared.thresHoldLowAlert = Int((selectedLowAlert - isLocalAltitudeINHG) * 100)
        SettingBLEManager.shared.thresHoldHighAlert = Int((selectedHighAlert - isLocalAltitudeINHG) * 100)
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothThresHoldWriteAirpressure)
        self.thresHoldDelegates()
    }
    
    func writeHumidityValueViaBLE(selectedLowWarning:Float, selectedHighWarning:Float, selectedLowAlert:Float, selectedHighAlert:Float, deviceIDSetting: Int, deviceSerialID: String)  {
       // self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.thresHoldLowWarning = Int(selectedLowWarning * 100)
        SettingBLEManager.shared.thresHoldHighWarning = Int(selectedHighWarning * 100)
        SettingBLEManager.shared.thresHoldLowAlert = Int(selectedLowAlert * 100)
        SettingBLEManager.shared.thresHoldHighAlert = Int(selectedHighAlert * 100)
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothThresHoldWriteHumidity)
        self.thresHoldDelegates()
    }
    
    func writeOkColorCodeValueViaBLE(colorCode:Int, deviceIDSetting: Int, deviceSerialID: String,brightNessColorCode:String)  {
        //self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.okColorCode = colorCode
        SettingBLEManager.shared.ledBrightnessColorCode = brightNessColorCode
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothColorOKWrite)
        self.thresHoldDelegates()
    }
    
    func writeWarningColorCodeValueViaBLE(colorCode:Int, deviceIDSetting: Int, deviceSerialID: String,brightNessColorCode:String)  {
        //self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.warningColorCode = colorCode
        SettingBLEManager.shared.ledBrightnessColorCode = brightNessColorCode
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothColorWarningWrite)
        self.thresHoldDelegates()
    }
    
    func writeAlertColorCodeValueViaBLE(colorCode:Int, deviceIDSetting: Int, deviceSerialID: String,brightNessColorCode:String)  {
       // self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.alertColorCode = colorCode
        SettingBLEManager.shared.ledBrightnessColorCode = brightNessColorCode
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothColorAlertWrite)
        self.thresHoldDelegates()
    }
    
    func writeNightColorCodeValueViaBLE(nightColorCode:Int, nightColorStartTimeCode:Int, nightColorEndTimeCode:Int, deviceIDSetting: Int, deviceSerialID: String,brightNessColorCode:String)  {
        //self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.nightColorCode = nightColorCode
        SettingBLEManager.shared.nightColorStartTime = nightColorStartTimeCode
        SettingBLEManager.shared.nightColorEndTime = nightColorEndTimeCode
        SettingBLEManager.shared.ledBrightnessColorCode = brightNessColorCode
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothNightColorAlertWrite)
        self.thresHoldDelegates()
    }
    
    func writeTempOffsetValueViaBLE(tempOffsetValue:Int,deviceIDSetting: Int, deviceSerialID: String)  {
        //self.showActivityIndicator(self.view)
        Helper.shared.removeBleutoothConnection()
        SettingBLEManager.shared.didWriteStatus = 0
        SettingBLEManager.shared.tempOffset = tempOffsetValue
        SettingBLEManager.shared.connectBlueTooth(blueToothName: deviceSerialID, bleFeature: .BlueToothTempOffsetWrite)
        self.thresHoldDelegates()
    }
}

extension LTSettingBaseViewController {
    
    func getDeviceLedBrightnessValue(colorSetting:RealmColorSetting)  {
        
        var arrOKLEDColorBrightness:[RealmColorSetting] = []
        arrOKLEDColorBrightness.removeAll()
        arrOKLEDColorBrightness = RealmDataManager.shared.readColorDataValues(deviceID: colorSetting.device_id, colorType: ColorType.ColorOk.rawValue)
        if arrOKLEDColorBrightness.count > 0 {
            self.isOkLEDBrightNess =  arrOKLEDColorBrightness[0].color_led_brightness
        }
        
        var arrWarningLEDColorBrightness:[RealmColorSetting] = []
        arrWarningLEDColorBrightness.removeAll()
        arrWarningLEDColorBrightness = RealmDataManager.shared.readColorDataValues(deviceID: colorSetting.device_id, colorType: ColorType.ColorWarning.rawValue)
        if arrWarningLEDColorBrightness.count > 0 {
            self.isWarningLEDBrightNess =  arrWarningLEDColorBrightness[0].color_led_brightness
        }
        
        var arrAlertLEDColorBrightness:[RealmColorSetting] = []
        arrAlertLEDColorBrightness.removeAll()
        arrAlertLEDColorBrightness = RealmDataManager.shared.readColorDataValues(deviceID: colorSetting.device_id, colorType: ColorType.ColorAlert.rawValue)
        if arrAlertLEDColorBrightness.count > 0 {
            self.isAlertLEDBrightNess =  arrAlertLEDColorBrightness[0].color_led_brightness
        }
        
        var arrNightLEDColorBrightness:[RealmColorSetting] = []
        arrNightLEDColorBrightness.removeAll()
        arrNightLEDColorBrightness = RealmDataManager.shared.readColorDataValues(deviceID: colorSetting.device_id, colorType: ColorType.ColorNightLight.rawValue)
        if arrNightLEDColorBrightness.count > 0 {
            self.isNightlightLEDBrightNess =  arrNightLEDColorBrightness[0].color_led_brightness
        }

    }
}
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

