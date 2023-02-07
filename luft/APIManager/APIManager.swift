//
//  APIManager.swift
//  luft
//
//  Created by iMac Augusta on 10/23/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyJSON


protocol MEDataAPIDelegate:class {
    func medataAPIData(meData:AppUserMobileDetails?)
}
protocol DeviceMEAPIDelegate:class {
    func deviceDataAPIStatus(update:Bool)
}
protocol LatestReadingDelegate:class {
    func getLatestReadingStatus(update:Bool)
}



protocol MAXINDEXDataAPIDelegate:class {
    func updateMaxIdex(updateStatus:Bool)
}

class APIManager: NSObject {
    var arrMyDeviceList: [MyDeviceModel]? = []
    var arrReadindMyDeviceList: [DeviceReading]? = []
    var latestDeviceReading: DeviceReading? = nil
    var arrBackGroundDeviceList: [RealmDeviceList]? = []
    var pollutantType:PollutantType? = .PollutantNone
    var colorType:ColorType? = .ColorNone
    var appUserSettingData: AppUser? = nil
    var saveMobileUserSetting: AppUserMobileDetails? = nil
    var tempMobileUserSetting: AppUserMobileDetails? = nil
    //ProtoCol
    var meDelegate:MEDataAPIDelegate? = nil
    var myDeviceDelegate:DeviceMEAPIDelegate? = nil
    var latestReadingDelegate:LatestReadingDelegate? = nil
    var maxIndexDelegate:MAXINDEXDataAPIDelegate? = nil
    var isAddDeviceAPICompleted:Bool = false
    
    class var shared: APIManager {
        struct Static {
            static let instance: APIManager = APIManager()
        }
        return Static.instance
    }
}

extension APIManager {
    
    func callUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            AppUserAPI.apiAppUserMeGet { (response, error) in
                if error == nil {
                    if let responseValue = response {
                        self.appUserSettingData = response
                        self.saveMobileUserSetting = AppUserMobileDetails.init(firstName: self.appUserSettingData?.firstName, lastName: self.appUserSettingData?.lastName, buildingtypeid: self.appUserSettingData?.buildingtypeid, mitigationsystemtypeid: self.appUserSettingData?.mitigationsystemtypeid, enableNotifications: self.appUserSettingData?.enableNotifications, isTextNotificationEnabled: self.appUserSettingData?.isTextNotificationEnabled, mobileNo: self.appUserSettingData?.mobileNo, isEmailNotificationEnabled: self.appUserSettingData?.isEmailNotificationEnabled, notificationEmail: self.appUserSettingData?.notificationEmail, isMobileNotificationFrequencyEnabled: self.appUserSettingData?.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: self.appUserSettingData?.isSummaryEmailEnabled, isDailySummaryEmailEnabled: self.appUserSettingData?.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: self.appUserSettingData?.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: self.appUserSettingData?.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: self.appUserSettingData?.temperatureUnitTypeId, pressureUnitTypeId: self.appUserSettingData?.pressureUnitTypeId, radonUnitTypeId: self.appUserSettingData?.radonUnitTypeId, appLayout: self.appUserSettingData?.appLayout, appTheme: self.appUserSettingData?.appTheme, outageNotificationsDuration: self.appUserSettingData?.outageNotificationsDuration, notificationFrequency: self.appUserSettingData?.notificationFrequency, isMobileOutageNotificationsEnabled: self.appUserSettingData?.isMobileOutageNotificationsEnabled)
                        //Save User default data's
                        AppSession.shared.setMEAPIData(userSettingData: responseValue)
                        AppSession.shared.setMobileUserMeData(mobileSettingData: self.saveMobileUserSetting!)
                        self.meDelegate?.medataAPIData(meData: self.saveMobileUserSetting!)
                    }
                }else {
                    self.meDelegate?.medataAPIData(meData: self.saveMobileUserSetting ?? nil)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            }
        }
        else{
            self.meDelegate?.medataAPIData(meData: self.saveMobileUserSetting ?? nil)
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}

extension APIManager {
    
    func callDeviceDetailsTypeApi(isUpdateDummy:Bool){
        if Reachability.isConnectedToNetwork() == true {
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            AppUserAPI.apiAppUserGetMyDevicesGet { (response, error) in
                if error == nil {
                    if let responseValue = response,responseValue.count > 0 {
                        self.arrMyDeviceList = responseValue
                        RealmDataManager.shared.deleteDeviceRelamDataBase()
                        RealmDataManager.shared.deleteRelamSettingColorDataBase()
                        if isUpdateDummy ==  true {
                            RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
                            RealmDataManager.shared.insertDummyDeviceDataValues(arrDeviceData: self.arrMyDeviceList!)
                            RealmDataManager.shared.insertCoreDataDeviceDataValues(arrDeviceData: self.arrMyDeviceList!)

                        }
                        RealmDataManager.shared.insertDeviceDataValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertRadonValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertTemperatureValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertHumidityValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertAirPressureValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertVOCValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertECO2Values(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertOKColorValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertWarningColorValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertAlertColorValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertNightLightColorValues(arrDeviceData: self.arrMyDeviceList!)
                    }else {
                        RealmDataManager.shared.deleteDeviceRelamDataBase()
                        RealmDataManager.shared.deleteRelamSettingColorDataBase()
                        RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
                    }
                    print("Device implement added")
                    self.myDeviceDelegate?.deviceDataAPIStatus(update: true)
                    NotificationCenter.default.post(name: .postNotifiDeviceUpadte, object: nil)

                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                     self.myDeviceDelegate?.deviceDataAPIStatus(update: false)
                    
                    NotificationCenter.default.post(name: .postNotifiDeviceUpadte, object: nil)

                }
            }
        }
        else{
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            self.myDeviceDelegate?.deviceDataAPIStatus(update: false)
        }
    }
}

extension APIManager {
        
    func callDeviceLatestReadingAPI()  {
        
        var deviceSerialID = ""
        let deviceData = RealmDataManager.shared.readDeviceListDataValues()
        if deviceData.count == 0 {
            return
        }else {
            let deviceData = RealmDataManager.shared.readDeviceListDataBasedToken(deviceToken: AppSession.shared.getCurrentDeviceToken())
            deviceSerialID = deviceData[0].serial_id
        }
        if Reachability.isConnectedToNetwork() == true {
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
            DeviceAPI.apiDeviceGetLatestReadingGet { (responseValue, error) in
                if responseValue != nil {
                    self.latestDeviceReading = responseValue
                    let idValue: Int64 = self.latestDeviceReading?.deviceId ?? 0
                    let deviceID = Int(truncating: NSNumber(value: idValue))
                    let logIndexValue = -1
                    let strRadon = Float(self.latestDeviceReading?.radon ?? 0.0)
                    let strVoc = Float(self.latestDeviceReading?.voc ?? 0.0)
                    let strEco2 = Float(self.latestDeviceReading?.co2 ?? 0.0)
                    let strTemp = Float(self.latestDeviceReading?.temperature ?? 0.0)
                    let strHumidity = Float(self.latestDeviceReading?.humidity ?? 0.0)
                    let strPressure = Float(self.latestDeviceReading?.airPressure ?? 0.0)
                    let timeStampvalue =  Int(self.latestDeviceReading?.timeStampUtc ?? 0)
//                    timeStampvalue = timeStampvalue * 1000
                    let strLastSyncTime =  Date(milliseconds: timeStampvalue)
                    debugPrint(timeStampvalue)
                    RealmDataManager.shared.updatePollutantTableData(strDate: String.init(format: "%d", timeStampvalue), deviceID: deviceID, co2: String.init(format: "%f", strEco2), air_pressure: String.init(format: "%f", strPressure), temperature: String.init(format: "%f", strTemp), humidity: String.init(format: "%f", strHumidity), voc: String.init(format: "%f", strVoc), radon: String.init(format: "%f", strRadon), isWiFi: true, device_SerialID: deviceSerialID)

                    //                    RealmDataManager.shared.insertRealmPollutantDummyValuesTBLValues(strDate: strLastSyncTime, deviceID: deviceID, co2: strEco2, air_pressure: strPressure, temperature: strTemp, humidity: strHumidity, voc: strVoc, radon: strRadon, isWiFi: false, serialID: deviceSerialID,logIndex:logIndexValue,timeStamp:timeStampvalue)
                    self.latestReadingDelegate?.getLatestReadingStatus(update: true)
                }else {
                    self.latestReadingDelegate?.getLatestReadingStatus(update: false)
                }
            }
        }
        else{
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }

    }
    
    private func getUNIXDateTime(timeResult: Double) -> String {
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd YYYY hh:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
}

extension APIManager {
    
    func callMAXINDEXDeviceData(deviceToken: String,maxLogIndex:Int,deviceSerialID: String,isFromIntial:Bool)  {
        var newMaxIndex = 0
        if Reachability.isConnectedToNetwork() == true {
            SwaggerClientAPI.customHeaders = ["token": deviceToken]
            
            if isFromIntial == true {
                newMaxIndex = maxLogIndex
                
                if newMaxIndex == 0 {
                    newMaxIndex = -1
                }
            }else {
                if RealmDataManager.shared.readPollutantDataValues().count != 0 {
                    newMaxIndex = RealmDataManager.shared.readTimeBasePollutantDataValues(device_ID: RealmDataManager.shared.getFromTableDeviceID(serial_id: deviceSerialID))
                    if newMaxIndex != 0 {
                       newMaxIndex = newMaxIndex + 1
                    }
                    
                }
            }
            
            DeviceAPI.apiDeviceGetReadingsByLogIndexGet(logIndex: Int64(newMaxIndex)) { (responseValue, error) in
                if error == nil {
                    print(responseValue ?? [])
                    self.arrReadindMyDeviceList?.removeAll()
                    self.arrReadindMyDeviceList = responseValue

                    if self.arrReadindMyDeviceList?.count != 0 {
                        var next_pollutantId = RealmDataManager.shared.nextPollutantListId()
                        var pollutants: [RealmPollutantValuesTBL] = []
                        for readingData in self.arrReadindMyDeviceList ?? [] {
                            let idValue: Int64 = readingData.deviceId ?? 0
                            let deviceID = Int(truncating: NSNumber(value: idValue))
                            var logIndexValue = -1
                            if isFromIntial ==  false {
                                let logIDValue: Int64 = readingData.logIndex ?? 0
                                logIndexValue = Int(truncating: NSNumber(value: logIDValue))
                            }
                            let strRadon = Float(readingData.radon ?? 0.0)
                            let strVoc = Float(readingData.voc ?? 0.0)
                            let strEco2 = Float(readingData.co2 ?? 0.0)
                            let strTemp = Float(readingData.temperature ?? 0.0)
                            let strHumidity = Float(readingData.humidity ?? 0.0)
                            let strPressure = Float(readingData.airPressure ?? 0.0)
                            var timeStampvalue =  Int(readingData.timeStampUtc ?? 0) 
                            timeStampvalue = timeStampvalue * 1000
                            let strLastSyncTime =  Date(milliseconds: timeStampvalue)
                            let pollutant = RealmDataManager.shared.getRealmPollutantValuesTBLValues(strDate: strLastSyncTime, deviceID: deviceID, co2: strEco2, air_pressure: strPressure, temperature: strTemp, humidity: strHumidity, voc: strVoc, radon: strRadon, isWiFi: true, serialID: deviceSerialID, logIndex: logIndexValue,timeStamp:timeStampvalue)
                            pollutant.auto_id = next_pollutantId
                            pollutants.append(pollutant)
                            next_pollutantId += 1
                        }
                        if isFromIntial ==  true { //MAX VALUES - 1
                             RealmDataManager.shared.insertMAXLogINDEXRealmPollutantValuesTBLValues(pollutantValues: pollutants)
                        }else {
                            RealmDataManager.shared.insertRealmPollutantValuesTBLValues(pollutantValues: pollutants)
                            self.isAddDeviceAPICompleted = true
                        }
                        self.maxIndexDelegate?.updateMaxIdex(updateStatus: true)
                    }else {
                        if isFromIntial ==  true { //MAX VALUES - 1
                        }else {
                            self.isAddDeviceAPICompleted = true
                        }
                        self.maxIndexDelegate?.updateMaxIdex(updateStatus: false)
                    }
                }else {
                    if isFromIntial ==  true { //MAX VALUES - 1
                    }else {
                        self.isAddDeviceAPICompleted = true
                    }
                    self.maxIndexDelegate?.updateMaxIdex(updateStatus: false)
                }
            }
        }
        else{
            self.isAddDeviceAPICompleted = true
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
        
    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
