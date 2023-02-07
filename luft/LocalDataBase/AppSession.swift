//
//  AppSettingData.swift
//  luft
//
//  Created by iMac Augusta on 10/15/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation

struct SettingData {
    var title: String
    var subTitle: String
    var imageType: String
    
    init(title: String, subTitle: String, imageType: String) {
        self.title = title
        self.subTitle = subTitle
        self.imageType = subTitle
    }
}

class AppSession: NSObject {
    
    var userDefaults :UserDefaults
    var appUserSettingData: AppUser?
    
    var previousMobileuserData: AppUserMobileDetails?
    var currentMobileuserData: AppUserMobileDetails?
    
    class var shared: AppSession {
        struct Static {
            static let instance = AppSession()
        }
        return Static.instance
    }
    
    override init() {
        self.userDefaults = UserDefaults()
    }
    
    func removeAllInstance()  {
        let defaults = userDefaults
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            print(key)
            if key == "UserSelectedThemeKey" {
                
            }else if key == "LiveState" {
                
            }else if key == "IsInfo" {
                
            }
            else {
                defaults.removeObject(forKey: key)
            }
            
        }
    }
    func saveValue() {
        self.userDefaults.synchronize()
    }
}



//MARK:- App Related
extension AppSession {
    
    func setMEAPIData(userSettingData: AppUser){
        self.appUserSettingData = userSettingData
    }
    
    func getMEAPIData()->AppUser?{
        return self.appUserSettingData ?? nil
    }
    
    func setMobileUserMeData(mobileSettingData: AppUserMobileDetails) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(mobileSettingData) {
            self.userDefaults.set(encoded, forKey: "AppUserMobileDetails")
        }
        self.saveValue()
    }
    func getMobileUserMeData() -> AppUserMobileDetails? {
        
        if let keySettings = self.userDefaults.object(forKey: "AppUserMobileDetails") as? Data {
            let decoder = JSONDecoder()
            
            if let messageActionResultIEnumerableKeySettings = try? decoder.decode(AppUserMobileDetails.self, from: keySettings){
                
                return messageActionResultIEnumerableKeySettings
            }
        }
        return nil
    }
    
    func setIsUserLogin(userLoginStatus: Bool) {
        self.userDefaults.set(userLoginStatus, forKey: "isUserLogin")
        self.saveValue()
    }
    
    func getIsUserLogin() -> Bool {
        return self.userDefaults.bool(forKey: "isUserLogin")
    }
    
    func setAccessToken (_ value: String) {
        self.userDefaults.set(value, forKey: "AccessToken")
        self.saveValue()
    }
    
    func getAccessToken ()-> String {
        let value: String? = self.userDefaults.object(forKey: "AccessToken") as? String
        return value ?? ""
    }
    
    func setCurrentDeviceToken (_ value: String) {
        
        self.userDefaults.set(value, forKey: "DeviceToken")
        self.saveValue()
    }
    
    func getCurrentDeviceToken ()-> String {
        let value: String? = self.userDefaults.object(forKey: "DeviceToken") as? String
        return value ?? ""
    }

    // App Theme
    func setTheme(themeType: Int) {
        self.userDefaults.set(themeType, forKey: SelectedThemeKey)
        self.saveValue()
    }
    
    func getTheme() -> Int {
        return self.userDefaults.integer(forKey: SelectedThemeKey)
    }
    
    func setUserSelectedTheme(themeType: Int) {
        self.userDefaults.set(themeType, forKey: "UserSelectedThemeKey")
        self.saveValue()
    }
    
    func getUserSelectedTheme() -> Int {
        return self.userDefaults.integer(forKey: "UserSelectedThemeKey")
    }
    
    func setUserSelectedLayout(layOut: Int) {
        self.userDefaults.set(layOut, forKey: "UserSelectedLayout")
        self.saveValue()
    }
    
    func getUserSelectedLayout() -> Int {
        return self.userDefaults.integer(forKey: "UserSelectedLayout")
    }

    func getIsShowBack() -> Bool {
        return self.userDefaults.bool(forKey: "isShowBack")
    }
    
    func setIsShowBack(isShow: Bool) {
        self.userDefaults.set(isShow, forKey: "isShowBack")
        self.saveValue()
    }
    
    
    func getIsColorStatus() -> Bool {
        return self.userDefaults.bool(forKey: "isColorStatus")
    }
    
    func setIsColorStatus(isShow: Bool) {
        self.userDefaults.set(isShow, forKey: "isColorStatus")
        self.saveValue()
    }
    
    func setUserSortFilterType(sortfilterType: Int) {
        self.userDefaults.set(sortfilterType, forKey: "SortFilterTypeEnum")
        self.saveValue()
    }
    
    func getUserSortFilterType() -> Int {
        return self.userDefaults.integer(forKey: "SortFilterTypeEnum")
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func getIsAddedNewDevice() -> Bool {
        return self.userDefaults.bool(forKey: "isAddedNewDevice")
    }
    
    func setIsAddedNewDevice(isAddedDevice: Bool) {
        self.userDefaults.set(isAddedDevice, forKey: "isAddedNewDevice")
        self.saveValue()
    }
    
    func getIsConnectedWifi() -> Bool {
        return self.userDefaults.bool(forKey: "ConnectedWifi")
    }
    
    func setIsConnectedWifi(iswifi: Bool) {
        self.userDefaults.set(iswifi, forKey: "ConnectedWifi")
        self.saveValue()
    }
    
    func setPrevSelectedDeviceID(prevSelectedDevice: Int) {
        self.userDefaults.set(prevSelectedDevice, forKey: "PrevSelectedDeviceID")
        self.saveValue()
    }
    
    func getPrevSelectedDeviceID() -> Int {
        let value: Int? = self.userDefaults.object(forKey: "PrevSelectedDeviceID") as? Int
        return value ?? -100
    }
    
    func getUserLiveState() -> Int {
        if self.userDefaults.object(forKey: "LiveState") != nil {
            return self.userDefaults.integer(forKey: "LiveState")
        }
        return 0
    }
    
    func setLiveState(state: Int) {
        self.userDefaults.set(state, forKey: "LiveState")
        self.saveValue()
    }
    
    func getIntervalTimeStamp() -> Int {
        if self.userDefaults.object(forKey: "IntervalTimeStamp") != nil {
            return self.userDefaults.integer(forKey: "IntervalTimeStamp")
        }
        return 0
    }
    
    func setIntervalTimeStamp(intervalTime: Int) {
        self.userDefaults.set(intervalTime, forKey: "IntervalTimeStamp")
        self.saveValue()
    }
    
    func getIsInfo() -> Bool {
        return self.userDefaults.bool(forKey: "IsInfo")
    }
    
    func setIsInfo(isInfo: Bool) {
        self.userDefaults.set(isInfo, forKey: "IsInfo")
        self.saveValue()
    }

   
    
    func getShowAppleIsInfo() -> Int {
        if self.userDefaults.object(forKey: "AppleIsInfo") != nil {
            return self.userDefaults.integer(forKey: "AppleIsInfo")
        }
        return 2
    }
    
    func setShowAppleIsInfo(isAppleLogin: Int) {
        self.userDefaults.set(isAppleLogin, forKey: "AppleIsInfo")
        self.saveValue()
    }
    
    
    func getAutoScale() -> Bool {
        return self.userDefaults.bool(forKey: "isAutoScale")
    }
    
    func setAutoScale(isAutoScale: Bool) {
        self.userDefaults.set(isAutoScale, forKey: "isAutoScale")
        self.saveValue()
    }
}

public enum LTWarningSummaryType {
    case Daliy
    case Weekly
    case Monthly
}

public enum LTUnitsTemperature {
    case Fahrenheit
    case Celsius
    case Monthly
}

public enum LTUnitsAirPressureType {
    case kPa
    case inHg
}

public enum LTUnitsRadonType {
    case pCil
    case Bq
}
