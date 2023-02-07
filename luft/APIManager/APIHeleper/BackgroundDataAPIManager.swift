//
//  BackgroundDataAPIManager.swift
//  luft
//
//  Created by iMac Augusta on 11/6/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation


protocol AllReadingDelegate:class {
    func getallBackGroundWifiReadingStatus(update:Bool)
}

protocol IndividualDeviceReadingDelegate:class {
    func indDeviceReadingDelegate()
}

class BackgroundDataAPIManager: NSObject {
    
    var arrReadindMyDeviceList: [DeviceReading]? = []
    var arrBackGroundDeviceList: [RealmDeviceList]? = []
    var latestDeviceReading: DeviceReading? = nil
    //ProtoCol
    var allReadingData:AllReadingDelegate? = nil
    var individualData:IndividualDeviceReadingDelegate? = nil
    var isCompleted:Bool? = false
    var isWholeDataSyncCompleted:Bool? = false
    var strBackGroundDeviceToken:String? = ""
    var isBackGroundAPICallStopConnectWifi:Bool? = false//Are stoping background api call in connect wifi page
    
    class var shared: BackgroundDataAPIManager {
        struct Static {
            static let instance: BackgroundDataAPIManager = BackgroundDataAPIManager()
        }
        return Static.instance
    }
}

extension BackgroundDataAPIManager {
    
    func callSyncBackGroundDeviceDetailsAPI(){
        print("background state20")
        if dataBasePathChange == true {
            return
        }
        if RealmDataManager.shared.readDummyDeviceListDataValues().count != 0 {
            self.isCompleted = false
            RealmDataManager.shared.delegateAPILogIndexDelegate = nil
            RealmDataManager.shared.delegateAPILogIndexDelegate = self
            self.callDeviceAPI1(index: 0)
        }else {
            if RealmDataManager.shared.readDeviceListDataValues().count != 0 {
                
                RealmDataManager.shared.deleteAllDummyData()
                let arrOrginalDeviceList = RealmDataManager.shared.readDeviceListDataValues()
                var arrDummyDeviceData:[RealmDummyDeviceList] = []
                for deviceData in arrOrginalDeviceList ?? [] {
                    let dummyDevice = RealmDummyDeviceList()
                    dummyDevice.auto_id = deviceData.auto_id
                    dummyDevice.device_id = deviceData.device_id
                    dummyDevice.device_token = deviceData.device_token
                    dummyDevice.name = deviceData.name
                    dummyDevice.serial_id = deviceData.serial_id
                    dummyDevice.user_id = deviceData.user_id
                    dummyDevice.shared = deviceData.shared
                    dummyDevice.wifi_status = deviceData.wifi_status
                    dummyDevice.shared_user_email = deviceData.shared_user_email
                    dummyDevice.time_zone = deviceData.time_zone
                    dummyDevice.firmware_version = deviceData.firmware_version
                    dummyDevice.maxLogIndex = deviceData.maxLogIndex
                    arrDummyDeviceData.append(dummyDevice)
                }
                RealmDataManager.shared.insertDeviceDummyTBLValues(dummyDeviceValues: arrDummyDeviceData)
                self.isCompleted = false
                self.callDeviceAPI1(index: 0)
                RealmDataManager.shared.delegateAPILogIndexDelegate = nil
                RealmDataManager.shared.delegateAPILogIndexDelegate = self
            }else {
                self.isCompleted = true
            }
        }
    }
    
    func callDeviceAPI1(index: Int)  {
        
        if dataBasePathChange == true {
            return
        }
        var backGroundLogIndex:Int = 0
        var deviceSerialID = ""
        var removeDeviceID = 0
        let deviceDataDummy = RealmDataManager.shared.readDummyDeviceListDataValues()
        if deviceDataDummy.count == 0 {
            self.isCompleted = true
            self.isWholeDataSyncCompleted = true
            NotificationCenter.default.post(name: .postNotifiWholeDataSync, object: nil)
            self.allReadingData?.getallBackGroundWifiReadingStatus(update:true)
            return
        }
        if deviceDataDummy.count !=  0{
           self.strBackGroundDeviceToken = ""
           self.strBackGroundDeviceToken = deviceDataDummy[0].device_token //AppSession.shared.setCurrentDeviceToken(deviceDataDummy[0].device_token)
            deviceSerialID = deviceDataDummy[0].serial_id
            removeDeviceID = deviceDataDummy[0].device_id
            if RealmDataManager.shared.readPollutantDataValues().count != 0 {
                backGroundLogIndex = RealmDataManager.shared.readTimeBasePollutantDataValues(device_ID: deviceDataDummy[0].device_id)
                
                if backGroundLogIndex == 0 ||  backGroundLogIndex == -1 {
                    backGroundLogIndex = 0
                }else {
                    backGroundLogIndex = backGroundLogIndex + 1
                }
                RealmDataManager.shared.updateCoreDataDeviceDataValues(deviceSerialID: deviceSerialID, sync: true)
            }else {
                backGroundLogIndex = 0
            }
        }
        if Reachability.isConnectedToNetwork() == true {
            DispatchQueue.global(qos: .background).async {
                let headers = ["token":  self.strBackGroundDeviceToken]
                SwaggerClientAPI.customHeaders = headers as! [String : String]
                //SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
//                if self.isBackGroundAPICallStopConnectWifi == true {
//                    return
//                }
                print("background state2")
                DeviceAPI.apiDeviceGetReadingsByLogIndexGet(logIndex: Int64(backGroundLogIndex)) { (responseValue, error) in
                    if error == nil {
                        DispatchQueue.global(qos: .background).async {
                            print(responseValue ?? [])
                            print("background state3")
                            self.arrReadindMyDeviceList?.removeAll()
                            self.arrReadindMyDeviceList = responseValue
                            if self.arrReadindMyDeviceList?.count != 0 {
                                var next_pollutantId = 0
                                var pollutants: [RealmPollutantValuesTBL] = []
                                for readingData in self.arrReadindMyDeviceList ?? [] {
                                    let idValue: Int64 = readingData.deviceId ?? 0
                                    let deviceID = Int(truncating: NSNumber(value: idValue))
                                    let logIDValue: Int64 = readingData.logIndex ?? 0
                                    let logIndexValue = Int(truncating: NSNumber(value: logIDValue))
                                    let strRadon = Float(readingData.radon ?? 0.0)
                                    let strVoc = Float(readingData.voc ?? 0.0)
                                    let strEco2 = Float(readingData.co2 ?? 0.0)
                                    let strTemp = Float(readingData.temperature ?? 0.0)
                                    let strHumidity = Float(readingData.humidity ?? 0.0)
                                    let strPressure = Float(readingData.airPressure ?? 0.0)
                                    var timeStampvalue =  Int(readingData.timeStampUtc ?? 0)
                                    timeStampvalue = timeStampvalue * 1000
                                    let strLastSyncTime =  Date(milliseconds: timeStampvalue)
                                    if dataBasePathChange == false {
                                        let pollutant = RealmDataManager.shared.getRealmPollutantValuesTBLValues(strDate: strLastSyncTime, deviceID: deviceID, co2: strEco2, air_pressure: strPressure, temperature: strTemp, humidity: strHumidity, voc: strVoc, radon: strRadon, isWiFi: true, serialID: deviceSerialID, logIndex: logIndexValue,timeStamp:timeStampvalue)
                                        pollutant.auto_id = next_pollutantId
                                        pollutants.append(pollutant)
                                        next_pollutantId += 1
                                        removeDeviceID = deviceID
                                    }
                                    
                                }
                                DispatchQueue.global(qos: .background).async {
                                    if dataBasePathChange == false {
                                       print("background state3")
                                        RealmDataManager.shared.insertRealmPollutantValuesTBLValues(pollutantValues: pollutants)
                                        let _:Bool = RealmDataManager.shared.removeDummyDeviceUpdate(deviceID: removeDeviceID)
                                        self.callDeviceAPI1(index: 0)
                                    }
                                    
                                    DispatchQueue.main.async {
                                    }
                                }
                            }else {
                                if dataBasePathChange == false {
                                    let _:Bool = RealmDataManager.shared.removeDummyDeviceUpdate(deviceID: removeDeviceID)
                                    self.callDeviceAPI1(index: 0)
                                }
                                RealmDataManager.shared.updateCoreDataDeviceDataValues(deviceSerialID: deviceSerialID, sync: true)
                                self.individualData?.indDeviceReadingDelegate()
                                //self.allReadingData?.getallBackGroundWifiReadingStatus(update:true)
                            }
                            DispatchQueue.main.async {
                            }
                        }
                    }else {
                        self.isCompleted = true
                        self.isWholeDataSyncCompleted = true
                        self.allReadingData?.getallBackGroundWifiReadingStatus(update:true)
                    }
                }
                DispatchQueue.main.async {
                }
            }
        }
        else{
            self.isWholeDataSyncCompleted = true
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}

extension BackgroundDataAPIManager:APILogIndexDelegate {
    func apiUpdateLogIndexDelegate(logIndexDone:Bool){
        print("SYNCED new good Daa 1")
        self.individualData?.indDeviceReadingDelegate()
    }
}
