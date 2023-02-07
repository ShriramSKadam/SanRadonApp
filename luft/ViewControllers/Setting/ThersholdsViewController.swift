//
//  ThersholdsViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData

let TBL_AIR_INKG = "AirPressureINHG"
let TBL_AIR_KPA = "AirPressureKpa"
let TBL_AIR_MBAR = "Mbar"

let TBL_TEMP_CELSIUS = "TemperatureCelsius"
let TBL_TEMP_FAHRENHEIT = "TemperatureFahrenheit"
let TBL_HUMIDITY = "Humidity"
let TBL_RADON_PCII = "RadonPCII"
let TBL_RADON_BQM = "RadonBqm3"
let TBL_ECO2 = "Eco2value"
let TBL_VOC = "Voc"
let TBL_COLORS = "Colors"
let TBL_BUILDING_TYPE = "BuilldingType"
let TBL_MITIGATION_TYPE = "MitigationType"
let TBL_DEVICEDATA = "DeviceDataSync"

class ThersholdsViewController:UIViewController, LTIntialAGREEDelegate {
    func selectedIntialAGREE() {
        print("ios")
    }
    
    var thersholdsContext: NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isFromInitialAddDevice:Bool = false
    var isFromInitialSelectedDeviceID:Int = 0
    var isFromInitialSelectedDeviceTokenThres:String = ""
    var avilableDeviceSharedEMailIsfromAddDeviceThres:String = ""
    
    var selectedDeviceID:Int = 0
    var defaultDeviceID: Int = 0
    var defaultDeviceToken: String = ""
    var defaultDeviceSharedEMail: String = ""
    
    
    @IBOutlet weak var lblEcoTitle: UILabel!
    @IBOutlet weak var btnNextSkip: UIButton!
    @IBOutlet weak var btnThersholdsBack: UIButton!
    @IBOutlet weak var lblTipThersholds: UILabel!
    @IBOutlet weak var lblTip1Thersholds: UILabel!
    @IBOutlet weak var imgViewTip1: UIImageView!
    @IBOutlet weak var GetMoreHelp: UIButton!
    
    @IBOutlet weak var lblRadon: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblTemperature: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblHumidity: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblAirPressure: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblECO2: LTCellHeaderDataTitleLabel!
    @IBOutlet weak var lblTVOC: LTCellHeaderDataTitleLabel!
    
    
    @IBOutlet weak var btnRadon: UIButton!
    @IBOutlet weak var btnTemperature: UIButton!
    @IBOutlet weak var btnHumidity: UIButton!
    @IBOutlet weak var btnAirPressure: UIButton!
    @IBOutlet weak var btnECO2: UIButton!
    @IBOutlet weak var btnTVOC: UIButton!
    
    //var switchUpdatedDictionary: [String: Bool] = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.lblRadon.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
        self.lblTemperature.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
        self.lblHumidity.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
        self.lblAirPressure.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
        self.lblECO2.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
        self.lblTVOC.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
        
        self.thersholdsContext = appDelegate.persistentContainer.viewContext
        self.deleteThresholdValueEnity()
        self.btnNextSkip.addTarget(self, action:#selector(self.btnNextSkipTapped(_sender:)), for: .touchUpInside)
        let numberString = NSMutableAttributedString(string: "Here you can customize each Air-Quality sensor’s warning and alarm thresholds! However, all sensors have default settings and can be changed at any time later. We recommend to tailor the Temperature and Humidity settings to your environment first and retain the default Radon, tVOC, and eCO", attributes: [.font: UIFont.setAppFontRegular(14)])
        numberString.append(NSAttributedString(string: "2", attributes: [.font: UIFont.setAppFontRegular(14), .baselineOffset: -2]))
        numberString.append(NSAttributedString(string: " settings to get started.", attributes: [.font: UIFont.setAppFontRegular(14)]))
        self.lblTipThersholds.attributedText = numberString
        self.lblTipThersholds.backgroundColor = ThemeManager.currentTheme().clearColor
        self.lblTipThersholds.textColor = ThemeManager.currentTheme().subtitleTextColor
        
        self.lblTip1Thersholds.text = "Set the thresholds for the sensors."
        self.lblTip1Thersholds.backgroundColor = ThemeManager.currentTheme().clearColor
        self.lblTip1Thersholds.textColor = ThemeManager.currentTheme().subtitleTextColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tabBarController?.tabBar.isHidden = true
        }
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.setMyLabelText()
        if self.isFromInitialAddDevice == true {
            self.btnThersholdsBack.isHidden = true
            self.btnNextSkip?.isHidden = false
        }
        
        if UserDefaults.standard.bool(forKey: "RadonSwitch") == true {
            self.lblRadon.textColor = ThemeManager.currentTheme().labelTextColor
          
        } else{
            self.lblRadon.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "TemperatureSwitch") == true {
            self.lblTemperature.textColor = ThemeManager.currentTheme().labelTextColor
        } else{
            self.lblTemperature.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "HumiditySwitch") == true {
            self.lblHumidity.textColor = ThemeManager.currentTheme().labelTextColor
        } else{
            self.lblHumidity.textColor = .gray
        }
        
        if  UserDefaults.standard.bool(forKey: "AirPressureSwitch") == true {
            self.lblAirPressure.textColor = ThemeManager.currentTheme().labelTextColor
        } else{
            self.lblAirPressure.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "ECO2Switch") == true {
            self.lblECO2.textColor = ThemeManager.currentTheme().labelTextColor
            self.lblECO2.textColor = ThemeManager.currentTheme().labelTextColor
        } else{
            self.lblECO2.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "TVOCSwitch") == true {
            self.lblTVOC.textColor = ThemeManager.currentTheme().labelTextColor
        } else{
            self.lblTVOC.textColor = .gray
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        self.btnNextSkip?.isHidden = true
        //        if self.isFromInitialAddDevice == true {
        //
        //        }
    }
    
    @IBAction func GetMoreHelp(_ sender: Any) {
        self.moveToWebView()
    }
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
        webdataView.Urltodisplay = Thresholds_url
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = "Thresholds"
        webdataView.strTitle = "Thresholds"
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .pageSheet
        self.present(webdataView, animated: false, completion: nil)
    }
    
    
    func setMyLabelText() {
        let numberString = NSMutableAttributedString(string: "eCO", attributes: [.font: UIFont.setSystemFontRegular(17)])
        numberString.append(NSAttributedString(string: "2", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: -2]))
        self.lblEcoTitle.attributedText = numberString
        self.lblEcoTitle.backgroundColor = ThemeManager.currentTheme().clearColor
        self.lblEcoTitle.textColor = ThemeManager.currentTheme().headerTitleTextColor
    }
    
    @objc func btnNextSkipTapped(_sender:UIButton) {
        self.btnNextSkip.titleLabel?.text = ""
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorsViewController") as! ColorsViewController
        mainTabbar.isFromInitialAddDevice = true
        mainTabbar.isFromInitialSelectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.avilableDeviceSharedEMailIsfromAddDeviceColor = self.avilableDeviceSharedEMailIsfromAddDeviceThres
        mainTabbar.isFromInitialSelectedDeviceTokenColor = self.isFromInitialSelectedDeviceTokenThres
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
}
extension ThersholdsViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if let vcs = self.navigationController?.viewControllers {
            for vc in vcs {
                if (vc.isKind(of: SettingViewController.self) == true) {
                    let vcSetting = vc as! SettingViewController
                    vcSetting.luftSettingTabbar = 100
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTapRadonBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThersHoldRadonViewController") as! ThersHoldRadonViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    @IBAction func btnTapTemperatureBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThersHoldTemperatureViewController") as! ThersHoldTemperatureViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    @IBAction func btnTapHumidityBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThersHoldHumityViewController") as! ThersHoldHumityViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    @IBAction func btnTapAirPressureBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThersHoldAirPressureViewController") as! ThersHoldAirPressureViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    @IBAction func btnTapCO2Btn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThersHoldeCO2ViewController") as! ThersHoldeCO2ViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
        
    }
    
    @IBAction func btnTapVOCBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThersHoldVOCViewController") as! ThersHoldVOCViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
}

extension ThersholdsViewController {
    
    func loadRadonValue()  {
        let arrRadonBQM3:[String] = ["25", "50", "75", "100", "125", "150", "175", "200", "225", "250", "275", "300", "400", "500", "600", "800"]
        let arrRadonPCII:[String] = ["1.0 pCi/l", "2.0 pCi/l", "3.0 pCi/l", "4.0 pCi/l", "5.0 pCi/l", "7.0 pCi/l", "8.0 pCi/l", "9.0 pCi/l", "10.0 pCi/l", "11.0 pCi/l", "12.0 pCi/l", "13.0 pCi/l", "14.0 pCi/l", "15.0 pCi/l"]
        
        
        for radonBQM3Value in arrRadonBQM3 {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_RADON_BQM, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", radonBQM3Value), forKey: "bqm3")
            if RADONBQME_LOW_WARNING == radonBQM3Value{
                newSetting.setValue(true, forKey: "warning")
            }else {
                newSetting.setValue(false, forKey: "warning")
            }
            if RADONBQME_HIGH_WARNING == radonBQM3Value{
                newSetting.setValue(true, forKey: "alert")
            }else {
                newSetting.setValue(false, forKey: "alert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
        
        for radonPCIIValue in arrRadonPCII {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_RADON_PCII, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", radonPCIIValue), forKey: "pcii")
            if RADONPCII_LOW_WARNING == radonPCIIValue{
                newSetting.setValue(true, forKey: "warning")
            }else {
                newSetting.setValue(false, forKey: "warning")
            }
            if RADONPCII_HIGH_WARNING == radonPCIIValue{
                newSetting.setValue(true, forKey: "alert")
            }else {
                newSetting.setValue(false, forKey: "alert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
        
    }
    
    func loadECO2Value()  {
        let arrECO2PPM:[String] = ["200 ppm", "400 ppm", "600 ppm", "800 ppm", "1000 ppm", "1200 ppm", "1400 ppm", "1600 ppm", "1800 ppm", "2000 ppm", "2200 ppm", "2400 ppm", "2600 ppm", "2800 ppm", "3000 ppm"]
        for eco2Value in arrECO2PPM {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_ECO2, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", eco2Value), forKey: "eco2")
            if ECO2_LOW_WARNING == eco2Value{
                newSetting.setValue(true, forKey: "warning")
            }else {
                newSetting.setValue(false, forKey: "warning")
            }
            if ECO2_HIGH_WARNING == eco2Value{
                newSetting.setValue(true, forKey: "alert")
            }else {
                newSetting.setValue(false, forKey: "alert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func loadVOCValue()  {
        let arrVOCPPB:[String] = ["100 ppb","150 ppb","200 ppb","250 ppb","300 ppb","350 ppb","400 ppb","450 ppb","500 ppb","550 ppb","600 ppb","650 ppb","700 ppb","750 ppb","800 ppb"]
        for vocValue in arrVOCPPB {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_VOC, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", vocValue), forKey: "vocvalue")
            if VOC_LOW_WARNING == vocValue{
                newSetting.setValue(true, forKey: "warning")
            }else {
                newSetting.setValue(false, forKey: "warning")
            }
            if VOC_HIGH_WARNING == vocValue{
                newSetting.setValue(true, forKey: "alert")
            }else {
                newSetting.setValue(false, forKey: "alert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
        
    }
    
    func loadHUMIDITYValue()  {
        let arrHUMIDITYPec:[String] = ["10 %","15 %","20 %","25 %","30 %","35 %","40 %","45 %","50 %","55 %","60 %","65 %","70 %","75 %","80 %"]
        for pecValue in arrHUMIDITYPec {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_HUMIDITY, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", pecValue), forKey: "humidityvalue")
            if HUMIDITY_PRECENTAGE_LOW_WARNING == pecValue{
                newSetting.setValue(true, forKey: "lowwarning")
            }else {
                newSetting.setValue(false, forKey: "lowwarning")
            }
            if HUMIDITY_PRECENTAGE_HIGH_WARNING == pecValue{
                newSetting.setValue(true, forKey: "highwarning")
            }else {
                newSetting.setValue(false, forKey: "highwarning")
            }
            if HUMIDITY_PRECENTAGE_LOW_ALERT == pecValue{
                newSetting.setValue(true, forKey: "lowalert")
            }else {
                newSetting.setValue(false, forKey: "lowalert")
            }
            if HUMIDITY_PRECENTAGE_HIGH_ALERT == pecValue{
                newSetting.setValue(true, forKey: "highalert")
            }else {
                newSetting.setValue(false, forKey: "highalert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func loadTemperatureValue()  {
        let arrCelsiusValue:[String] = ["8 Celsius","9 Celsius","10 Celsius","11 Celsius","12 Celsius","13 Celsius","14 Celsius","15 Celsius","16 Celsius","17 Celsius","18 Celsius","19 Celsius","20 Celsius","21 Celsius","22 Celsius","23 Celsius","24 Celsius","25 Celsius","26 Celsius","27 Celsius","28 Celsius","29 Celsius","30 Celsius","31 Celsius","32 Celsius"]
        for tempCelValue in arrCelsiusValue {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_TEMP_CELSIUS, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", tempCelValue), forKey: "temperaturecelsiusvalue")
            if TEMP_CELSIUS_LOW_WARNING == tempCelValue{
                newSetting.setValue(true, forKey: "lowwarning")
            }else {
                newSetting.setValue(false, forKey: "lowwarning")
            }
            if TEMP_CELSIUS_HIGH_WARNING == tempCelValue{
                newSetting.setValue(true, forKey: "highwarning")
            }else {
                newSetting.setValue(false, forKey: "highwarning")
            }
            if TEMP_CELSIUS_LOW_ALERT == tempCelValue{
                newSetting.setValue(true, forKey: "lowalert")
            }else {
                newSetting.setValue(false, forKey: "lowalert")
            }
            if TEMP_CELSIUS_HIGH_ALERT == tempCelValue{
                newSetting.setValue(true, forKey: "highalert")
            }else {
                newSetting.setValue(false, forKey: "highalert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
        let arrFahrenheitValue:[String] = ["46 Fahrenheit","48 Fahrenheit","50 Fahrenheit","52 Fahrenheit","54 Fahrenheit","56 Fahrenheit","58 Fahrenheit","60 Fahrenheit","62 Fahrenheit","64 Fahrenheit","66 Fahrenheit","68 Fahrenheit","70 Fahrenheit","72 Fahrenheit","74 Fahrenheit","76 Fahrenheit","78 Fahrenheit","80 Fahrenheit","82 Fahrenheit","84 Fahrenheit","86 Fahrenheit","88 Fahrenheit","90 Fahrenheit","92 Fahrenheit","94 Fahrenheit"]
        for tempFahrenheitValue in arrFahrenheitValue {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_TEMP_FAHRENHEIT, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", tempFahrenheitValue), forKey: "tempfahrenheitvalue")
            if TEMP_FAHRENHEIT_LOW_WARNING == tempFahrenheitValue{
                newSetting.setValue(true, forKey: "lowwarning")
            }else {
                newSetting.setValue(false, forKey: "lowwarning")
            }
            if TEMP_FAHRENHEIT_HIGH_WARNING == tempFahrenheitValue{
                newSetting.setValue(true, forKey: "highwarning")
            }else {
                newSetting.setValue(false, forKey: "highwarning")
            }
            if TEMP_FAHRENHEIT_LOW_ALERT == tempFahrenheitValue{
                newSetting.setValue(true, forKey: "lowalert")
            }else {
                newSetting.setValue(false, forKey: "lowalert")
            }
            if TEMP_FAHRENHEIT_HIGH_ALERT == tempFahrenheitValue{
                newSetting.setValue(true, forKey: "highalert")
            }else {
                newSetting.setValue(false, forKey: "highalert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func loadAirPressureValue()  {
        let arrInHgValue:[String] = ["24.20 inHg","24.30 inHg","24.40 inHg","24.50 inHg","24.60 inHg","24.70 inHg","24.80 inHg","24.90 inHg","25.00 inHg","25.10 inHg","25.20 inHg","25.30 inHg","25.40 inHg","25.50 inHg","25.60 inHg","25.70 inHg","25.80 inHg","25.90 inHg","26.00 inHg","26.10 inHg","26.20 inHg","26.30 inHg","26.40 inHg","26.50 inHg","26.60 inHg","26.70 inHg","26.80 inHg","26.90 inHg","27.00 inHg","27.10 inHg","27.20 inHg","27.30 inHg","27.40 inHg","27.50 inHg","27.60 inHg","27.70 inHg","27.80 inHg","27.90 inHg","28.00 inHg","28.10 inHg","28.20 inHg","28.30 inHg","28.40 inHg","28.50 inHg","28.60 inHg","28.70 inHg","28.90 inHg","29.00 inHg","29.10 inHg","29.20 inHg","29.30 inHg","29.40 inHg","29.50 inHg","29.60 inHg","29.70 inHg","29.80 inHg","29.90 inHg","30.00 inHg","30.10 inHg","30.20 inHg","30.30 inHg","30.40 inHg","30.50 inHg","30.60 inHg","30.70 inHg","30.80 inHg","30.90 inHg","31.00 inHg"]
        for tempCelValue in arrInHgValue {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_AIR_INKG, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", tempCelValue), forKey: "airpreinhgvalue")
            if AIRPRESSURE_INHG_LOW_WARNING == tempCelValue{
                newSetting.setValue(true, forKey: "lowwarning")
            }else {
                newSetting.setValue(false, forKey: "lowwarning")
            }
            if AIRPRESSURE_INHG_HIGH_WARNING == tempCelValue{
                newSetting.setValue(true, forKey: "highwarning")
            }else {
                newSetting.setValue(false, forKey: "highwarning")
            }
            if AIRPRESSURE_INHG_LOW_ALERT == tempCelValue{
                newSetting.setValue(true, forKey: "lowalert")
            }else {
                newSetting.setValue(false, forKey: "lowalert")
            }
            if AIRPRESSURE_INHG_HIGH_ALERT == tempCelValue{
                newSetting.setValue(true, forKey: "highalert")
            }else {
                newSetting.setValue(false, forKey: "highalert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
        let arrkPaValue:[String] = ["82.0 kPa","82.2 kPa","82.4 kPa","82.6 kPa","82.8 kPa","83.0 kPa","83.2 kPa","83.4 kPa","83.6 kPa","83.8 kPa","84.0 kPa","84.2 kPa","84.4 kPa","84.6 kPa","84.8 kPa","85.0 kPa","85.2 kPa","85.4 kPa","85.6 kPa","85.8 kPa","86.0 kPa","86.2 kPa","86.4 kPa","86.6 kPa","86.8 kPa","87.0 kPa","87.2 kPa","87.4 kPa","87.6 kPa","87.8 kPa","88.0 kPa","88.2 kPa","88.4 kPa","88.6 kPa","88.8 kPa","89.0 kPa","89.2 kPa","89.4 kPa","89.6 kPa","89.8 kPa","90.0 kPa","90.2 kPa","90.4 kPa","90.6 kPa","90.8 kPa","91.0 kPa","91.2 kPa","91.4 kPa","91.6 kPa","91.8 kPa","92.0 kPa","92.2 kPa","92.4 kPa","92.6 kPa","92.8 kPa","93.0 kPa","93.2 kPa","93.4 kPa","93.6 kPa","93.8 kPa","94.0 kPa","94.2 kPa","94.4 kPa","94.6 kPa","94.8 kPa","95.0 kPa","95.2 kPa","95.4 kPa","95.6 kPa","95.8 kPa","96.0 kPa","96.2 kPa","96.4 kPa","96.6 kPa","96.8 kPa","97.0 kPa","97.2 kPa","97.4 kPa","97.6 kPa","97.8 kPa","98.0 kPa","98.2 kPa","98.4 kPa","98.6 kPa","98.9 kPa","99.0 kPa","99.2 kPa","99.4 kPa","99.6 kPa","99.8 kPa","100.0 kPa","100.2 kPa","100.4 kPa","100.6 kPa","100.8 kPa","101.0 kPa","101.2 kPa","101.4 kPa","101.6 kPa","101.8 kPa","102.0 kPa","102.2 kPa","102.4 kPa","102.6 kPa","102.8 kPa","103.0 kPa","103.2 kPa","103.4 kPa"]
        for tempCelValue in arrkPaValue {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_AIR_KPA, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", tempCelValue), forKey: "airprekpavalue")
            if AIRPRESSURE_KPA_LOW_WARNING == tempCelValue{
                newSetting.setValue(true, forKey: "lowwarning")
            }else {
                newSetting.setValue(false, forKey: "lowwarning")
            }
            if AIRPRESSURE_KPA_HIGH_WARNING == tempCelValue{
                newSetting.setValue(true, forKey: "highwarning")
            }else {
                newSetting.setValue(false, forKey: "highwarning")
            }
            if AIRPRESSURE_KPA_LOW_ALERT == tempCelValue{
                newSetting.setValue(true, forKey: "lowalert")
            }else {
                newSetting.setValue(false, forKey: "lowalert")
            }
            if AIRPRESSURE_KPA_HIGH_ALERT == tempCelValue{
                newSetting.setValue(true, forKey: "highalert")
            }else {
                newSetting.setValue(false, forKey: "highalert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
        
        
    }
    
    func loadAirMBARPressureValue()  {
        
        let arrmBarValue:[String] = ["820 mbar","821 mbar","822 mbar","823 mbar","824 mbar","825 mbar","826 mbar","827 mbar","828 mbar","829 mbar","830 mbar","831 mbar","832 mbar","833 mbar","834 mbar","835 mbar","836 mbar","837 mbar","838 mbar","839 mbar","840 mbar","841 mbar","842 mbar","843 mbar","844 mbar","845 mbar","846 mbar","847 mbar","848 mbar","849 mbar","850 mbar","851 mbar","852 mbar","853 mbar","854 mbar","855 mbar","856 mbar","857 mbar","858 mbar","859 mbar","860 mbar","861 mbar","862 mbar","863 mbar","864 mbar","865 mbar","866 mbar","867 mbar","868 mbar","869 mbar","870 mbar","871 mbar","872 mbar","873 mbar","874 mbar","875 mbar","876 mbar","877 mbar","878 mbar","879 mbar","880 mbar","881 mbar","882 mbar","883 mbar","884 mbar","885 mbar","886 mbar","887 mbar","888 mbar","889 mbar","890 mbar","891 mbar","892 mbar","893 mbar","894 mbar","895 mbar","896 mbar","897 mbar","898 mbar","899 mbar","900 mbar","901 mbar","902 mbar","903 mbar","904 mbar","905 mbar","906 mbar","907 mbar","908 mbar","909 mbar","910 mbar","911 mbar","912 mbar","913 mbar","914 mbar","915 mbar","916 mbar","917 mbar","918 mbar","919 mbar","920 mbar","921 mbar","922 mbar","923 mbar","924 mbar","925 mbar","926 mbar","927 mbar","928 mbar","929 mbar","930 mbar","931 mbar","932 mbar","933 mbar","934 mbar","935 mbar","936 mbar","937 mbar","938 mbar","939 mbar","940 mbar","941 mbar","942 mbar","943 mbar","944 mbar","945 mbar","946 mbar","947 mbar","948 mbar","949 mbar","950 mbar","951 mbar","952 mbar","953 mbar","954 mbar","955 mbar","956 mbar","957 mbar","958 mbar","959 mbar","960 mbar","961 mbar","962 mbar","963 mbar","964 mbar","965 mbar","966 mbar","967 mbar","968 mbar","969 mbar","970 mbar","971 mbar","972 mbar","973 mbar","974 mbar","975 mbar","976 mbar","977 mbar","978 mbar","979 mbar","980 mbar","981 mbar","982 mbar","983 mbar","984 mbar","985 mbar","986 mbar","987 mbar","988 mbar","989 mbar","990 mbar","991 mbar","992 mbar","993 mbar","994 mbar","995 mbar","996 mbar","997 mbar","998 mbar","999 mbar","1000 mbar","1001 mbar","1002 mbar","1003 mbar","1004 mbar","1005 mbar","1006 mbar","1007 mbar","1008 mbar","1009 mbar","1010 mbar","1011 mbar","1012 mbar","1013 mbar","1014 mbar","1015 mbar","1016 mbar","1017 mbar","1018 mbar","1019 mbar","1020 mbar","1021 mbar","1022 mbar","1023 mbar","1024 mbar","1025 mbar","1026 mbar","1027 mbar","1028 mbar","1029 mbar","1030 mbar","1031 mbar","1032 mbar","1033 mbar","1034 mbar","1035 mbar","1036 mbar","1037 mbar","1038 mbar","1039 mbar","1040 mbar","1041 mbar","1042 mbar","1043 mbar","1044 mbar","1045 mbar","1046 mbar","1047 mbar","1048 mbar","1049 mbar","1050 mbar"]
        for tempCelValue in arrmBarValue {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_AIR_MBAR, into: thersholdsContext)
            newSetting.setValue(String(format: "%@", tempCelValue), forKey: "mbarvalue")
            newSetting.setValue(arrmBarValue.count - 1, forKey: "idValue")
            if AIRPRESSURE_MBAR_LOW_WARNING == tempCelValue{
                newSetting.setValue(true, forKey: "lowwarning")
            }else {
                newSetting.setValue(false, forKey: "lowwarning")
            }
            if AIRPRESSURE_MBAR_HIGH_WARNING == tempCelValue{
                newSetting.setValue(true, forKey: "highwarning")
            }else {
                newSetting.setValue(false, forKey: "highwarning")
            }
            if AIRPRESSURE_MBAR_LOW_ALERT == tempCelValue{
                newSetting.setValue(true, forKey: "lowalert")
            }else {
                newSetting.setValue(false, forKey: "lowalert")
            }
            if AIRPRESSURE_MBAR_HIGH_ALERT == tempCelValue{
                newSetting.setValue(true, forKey: "highalert")
            }else {
                newSetting.setValue(false, forKey: "highalert")
            }
        }
        do {
            try thersholdsContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func deleteThresholdData(entityName:String) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entityName))
        do{
            try self.thersholdsContext.execute(deleteRequest)
        }catch let error as NSError {
            print(error)
        }
    }
    
    func loadEnityValues()  {
        self.loadRadonValue()
        self.loadECO2Value()
        self.loadVOCValue()
        self.loadHUMIDITYValue()
        self.loadTemperatureValue()
        self.loadAirPressureValue()
        self.loadAirMBARPressureValue()
    }
    
    func deleteThresholdValueEnity()  {
        self.deleteThresholdData(entityName: TBL_AIR_INKG)
        self.deleteThresholdData(entityName: TBL_AIR_KPA)
        self.deleteThresholdData(entityName: TBL_TEMP_CELSIUS)
        self.deleteThresholdData(entityName: TBL_TEMP_FAHRENHEIT)
        self.deleteThresholdData(entityName: TBL_HUMIDITY)
        self.deleteThresholdData(entityName: TBL_RADON_PCII)
        self.deleteThresholdData(entityName: TBL_RADON_BQM)
        self.deleteThresholdData(entityName: TBL_ECO2)
        self.deleteThresholdData(entityName: TBL_VOC)
        self.deleteThresholdData(entityName: TBL_AIR_MBAR)
        self.loadEnityValues()
    }
}
