//
//  LTDashBoardNotificationViewController.swift
//  luft
//
//  Created by user on 10/29/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class LTDashBoardNotificationViewController:LTSettingBaseViewController {
    
    @IBOutlet weak var lblEcoTitle: UILabel!
    
    var isSelectThersRadon: Bool = false
    var isSelectThersTemperature: Bool = false
    var isSelectThersHumditiy: Bool = false
    var isSelectThersAirPressure: Bool = false
    var isSelectThersEco2: Bool = false
    var isSelectThersVoc: Bool = false
    var isSelectDeviceID: Int = 0

    @IBOutlet weak var imgViewSelectThersRadon: UIImageView!
    @IBOutlet weak var imgViewSelectThersTemperature: UIImageView!
    @IBOutlet weak var imgViewSelectThersHumditiy: UIImageView!
    @IBOutlet weak var imgViewSelectThersAirPressure: UIImageView!
    @IBOutlet weak var imgViewSelectThersEco2: UIImageView!
    @IBOutlet weak var imgViewSelectThersVoc: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.setMyLabelText()
        self.loadData()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func loadData()  {
        self.imgViewSelectThersRadon.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewSelectThersTemperature.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewSelectThersHumditiy.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewSelectThersAirPressure.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewSelectThersEco2.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewSelectThersVoc.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.isSelectThersRadon = false
        self.isSelectThersTemperature = false
        self.isSelectThersHumditiy = false
        self.isSelectThersAirPressure = false
        self.isSelectThersEco2 = false
        self.isSelectThersVoc = false
        
        if RealmDataManager.shared.readPollutantDataValues(deviceID: self.isSelectDeviceID, pollutantType: PollutantType.PollutantRadon.rawValue).count != 0
        {
            if RealmDataManager.shared.readPollutantDataValues(deviceID: self.isSelectDeviceID, pollutantType: PollutantType.PollutantRadon.rawValue)[0].should_notify == true
            {
                self.isSelectThersRadon = true
                self.imgViewSelectThersRadon.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            }
            
        }
        if RealmDataManager.shared.readPollutantDataValues(deviceID: self.isSelectDeviceID, pollutantType: PollutantType.PollutantTemperature.rawValue)[0].should_notify
        {
            self.isSelectThersTemperature = true
            self.imgViewSelectThersTemperature.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }
        if RealmDataManager.shared.readPollutantDataValues(deviceID: self.isSelectDeviceID, pollutantType: PollutantType.PollutantHumidity.rawValue)[0].should_notify
        {
            self.isSelectThersHumditiy = true
            self.imgViewSelectThersHumditiy.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }
        if RealmDataManager.shared.readPollutantDataValues(deviceID: self.isSelectDeviceID, pollutantType: PollutantType.PollutantAirPressure.rawValue)[0].should_notify
        {
            self.isSelectThersAirPressure = true
            self.imgViewSelectThersAirPressure.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }
        if RealmDataManager.shared.readPollutantDataValues(deviceID: self.isSelectDeviceID, pollutantType: PollutantType.PollutantECO2.rawValue)[0].should_notify
        {
            self.isSelectThersEco2 = true
            self.imgViewSelectThersEco2.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }
        if RealmDataManager.shared.readPollutantDataValues(deviceID: self.isSelectDeviceID, pollutantType: PollutantType.PollutantVOC.rawValue)[0].should_notify
        {
            self.isSelectThersVoc = true
            self.imgViewSelectThersVoc.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }
    }
    
    func setMyLabelText() {
        let numberString = NSMutableAttributedString(string: "eCO", attributes: [.font: UIFont.setSystemFontRegular(17)])
        numberString.append(NSAttributedString(string: "2", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: -2]))
        self.lblEcoTitle.attributedText = numberString
        self.lblEcoTitle.backgroundColor = ThemeManager.currentTheme().clearColor
        self.lblEcoTitle.textColor = ThemeManager.currentTheme().headerTitleTextColor
    }
    
}
extension LTDashBoardNotificationViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTapRadonBtn(_ sender: Any) {
        if self.isSelectThersRadon == false {
            self.isSelectThersRadon = true
            self.imgViewSelectThersRadon.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.isSelectThersRadon = false
            self.imgViewSelectThersRadon.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }
        self.showActivityIndicator(self.view)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserTogglePollutionNotificationPost(deviceId: Int64(self.isSelectDeviceID), settingName: "ShouldNotifyOnRadon", value: self.isSelectThersRadon) { (error) in
            self.hideActivityIndicator(self.view)
            if error == nil {
                RealmDataManager.shared.updateNotifiyAllThresHoldFilterData(pollutantType: PollutantType.PollutantRadon.rawValue, isShouldNotifi: self.isSelectThersRadon, deviceID: self.isSelectDeviceID)
                Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
            }else {
                Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
            }
        }
    }
    
    @IBAction func btnTapTemperatureBtn(_ sender: Any) {
        if self.isSelectThersTemperature == false {
            self.isSelectThersTemperature = true
            self.imgViewSelectThersTemperature.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.isSelectThersTemperature = false
            self.imgViewSelectThersTemperature.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }
        self.showActivityIndicator(self.view)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserTogglePollutionNotificationPost(deviceId: Int64(self.isSelectDeviceID), settingName: "ShouldNotifyOnTemperature", value: self.isSelectThersTemperature) { (error) in
            self.hideActivityIndicator(self.view)
            if error == nil {
                RealmDataManager.shared.updateNotifiyAllThresHoldFilterData(pollutantType: PollutantType.PollutantTemperature.rawValue, isShouldNotifi: self.isSelectThersTemperature, deviceID: self.isSelectDeviceID)
                Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
            }else {
                Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
            }
        }
    }
    
    @IBAction func btnTapHumidityBtn(_ sender: Any) {
        if self.isSelectThersHumditiy == false {
            self.isSelectThersHumditiy = true
            self.imgViewSelectThersHumditiy.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.isSelectThersHumditiy = false
            self.imgViewSelectThersHumditiy.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }
        self.showActivityIndicator(self.view)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserTogglePollutionNotificationPost(deviceId: Int64(self.isSelectDeviceID), settingName: "ShouldNotifyOnHumidity", value: self.isSelectThersHumditiy) { (error) in
            self.hideActivityIndicator(self.view)
            if error == nil {
                RealmDataManager.shared.updateNotifiyAllThresHoldFilterData(pollutantType: PollutantType.PollutantHumidity.rawValue, isShouldNotifi: self.isSelectThersHumditiy, deviceID: self.isSelectDeviceID)
                Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
            }else {
                Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
            }
        }
    }
    
    @IBAction func btnTapAirPressureBtn(_ sender: Any) {
        if self.isSelectThersAirPressure == false {
            self.isSelectThersAirPressure = true
            self.imgViewSelectThersAirPressure.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.isSelectThersAirPressure = false
            self.imgViewSelectThersAirPressure.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }
        self.showActivityIndicator(self.view)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserTogglePollutionNotificationPost(deviceId: Int64(self.isSelectDeviceID), settingName: "ShouldNotifyOnAirPressure", value: self.isSelectThersAirPressure) { (error) in
            self.hideActivityIndicator(self.view)
            if error == nil {
                RealmDataManager.shared.updateNotifiyAllThresHoldFilterData(pollutantType: PollutantType.PollutantAirPressure.rawValue, isShouldNotifi: self.isSelectThersAirPressure, deviceID: self.isSelectDeviceID)
                Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
            }else {
                Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
            }
        }
    }
    
    @IBAction func btnTapCO2Btn(_ sender: Any) {
        if self.isSelectThersEco2 == false {
            self.isSelectThersEco2 = true
            self.imgViewSelectThersEco2.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.isSelectThersEco2 = false
            self.imgViewSelectThersEco2.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }
        self.showActivityIndicator(self.view)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserTogglePollutionNotificationPost(deviceId: Int64(self.isSelectDeviceID), settingName: "ShouldNotifyOnCo2", value: self.isSelectThersEco2) { (error) in
            self.hideActivityIndicator(self.view)
            if error == nil {
                RealmDataManager.shared.updateNotifiyAllThresHoldFilterData(pollutantType: PollutantType.PollutantECO2.rawValue, isShouldNotifi: self.isSelectThersEco2, deviceID: self.isSelectDeviceID)
                Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
            }else {
                Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
            }
        }
    }
    
    @IBAction func btnTapVOCBtn(_ sender: Any) {
        if self.isSelectThersVoc == false {
            self.isSelectThersVoc = true
            self.imgViewSelectThersVoc.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.isSelectThersVoc = false
             self.imgViewSelectThersVoc.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }
        self.showActivityIndicator(self.view)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserTogglePollutionNotificationPost(deviceId: Int64(self.isSelectDeviceID), settingName: "ShouldNotifyOnVoc", value: self.isSelectThersVoc) { (error) in
            self.hideActivityIndicator(self.view)
            if error == nil {
                RealmDataManager.shared.updateNotifiyAllThresHoldFilterData(pollutantType: PollutantType.PollutantVOC.rawValue, isShouldNotifi: self.isSelectThersVoc, deviceID: self.isSelectDeviceID)
                Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
            }else {
                Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
            }
        }
    }
}


