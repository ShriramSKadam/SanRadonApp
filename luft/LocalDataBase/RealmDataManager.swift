//
//  RealmDataManager.swift
//  luft
//
//  Created by iMac Augusta on 10/18/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import CoreData

struct WeekWithDateStruct {
    var weekNumber:String = "0"
    var dateString:String = ""
}

enum SevenDaysEnum: String {
    case AM12 = "1"
    case AM4 = "2"
    case AM8 = "3"
    case PM12 = "4"
    case PM4 = "5"
    case PM8 = "6"
    case unknown = "unknown"
}

protocol LogIndexDelegate:class {
    func writeLogIndexDelegate(logIndexDone:Bool)
}

protocol APILogIndexDelegate:class {
    func apiUpdateLogIndexDelegate(logIndexDone:Bool)
}

class RealmDataManager: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let realm = try! Realm()
    var arrMyDeviceList: [MyDeviceModel]? = []
    var pollutantType:PollutantType? = .PollutantNone
    var colorType:ColorType? = .ColorNone
    var delegateLogIndexDone:LogIndexDelegate? = nil
    var delegateAPILogIndexDelegate:APILogIndexDelegate? = nil
    
    struct Static {
         static var instance: RealmDataManager?
    }
    
    class var shared: RealmDataManager {
        
        if Static.instance == nil {
            Static.instance = RealmDataManager()
        }
        return Static.instance!
    }
    
    func dispose()
    {
        if RealmDataManager.Static.instance != nil {
            RealmDataManager.Static.instance = nil
        }
        print("Disposed Singleton instance")
    }
    
    func deleteRelamSettingColorDataBase() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(RealmThresHoldSetting.self))
            realm.delete(realm.objects(RealmColorSetting.self))
        }
    }
    
    func deleteDeviceRelamDataBase() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(RealmDeviceList.self))
        }
    }
    
    func deleteDUMMYDeviceRelamDataBase() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(RealmDummyDeviceList.self))
        }
    }
    
    func deleteRelamPollutantDataBase() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(RealmPollutantValuesTBL.self))
        }
    }
 
    func insertDeviceDataValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            let deviceListRM = RealmDeviceList()
            deviceListRM.auto_id = self.nextDeviceListId()
            deviceListRM.name = deviceData.name ?? ""
            deviceListRM.device_id = Int(deviceData.id ?? 0)
            deviceListRM.device_token = deviceData.token ?? ""
            deviceListRM.serial_id = deviceData.serialId ?? ""
            deviceListRM.user_id = Int(deviceData.userId ?? 0)
            deviceListRM.shared = false
            deviceListRM.wifi_status = deviceData.isWifiOn ?? false
            if deviceData.shareduseremail == nil {
                deviceListRM.shared_user_email = ""
            }else {
                deviceListRM.shared_user_email = deviceData.shareduseremail ?? ""
            }
            deviceListRM.time_zone = deviceData.deviceTimeZone ?? ""
            deviceListRM.timeDiffrence = deviceData.deviceTimeDifference ?? ""
            deviceListRM.firmware_version = deviceData.firmwareVersion ?? ""
            deviceListRM.maxLogIndex = deviceData.maxlogindex ?? ""
            deviceListRM.deviceLat = String(format: "%f", deviceData.geocode?.x ?? 0.0)
            deviceListRM.deviceLong = String(format: "%f", deviceData.geocode?.y ?? 0.0)
            // New good
            deviceListRM.pressure_altitude_correction_status = deviceData.altitudeCorrectionStatus ?? false
            deviceListRM.pressure_elevation = "0.0"
            deviceListRM.pressure_elevation_deviation_mbr = "0.0"
            deviceListRM.pressure_elevation_deviation_ihg = "0.0"
            if deviceData.elevation?.count != 0 {
                deviceListRM.pressure_elevation = deviceData.elevation ?? ""
            }
            if deviceData.elevationdeviationmbr?.count != 0 {
                deviceListRM.pressure_elevation_deviation_mbr = deviceData.elevationdeviationmbr ?? "0.0"
            }
            if deviceData.elevationdeviationihg?.count != 0 {
                deviceListRM.pressure_elevation_deviation_ihg = deviceData.elevationdeviationihg ?? "0.0"
            }
            deviceListRM.isBluetoothSync = deviceData.isBluetoothSync ?? false
            let realm = try! Realm()
            try! realm.write {
                realm.add(deviceListRM)
            }
        }
    }
    
    func insertDummyDeviceDataValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            let deviceListRM = RealmDummyDeviceList()
            deviceListRM.auto_id = self.nextDummyDeviceListId()
            deviceListRM.name = deviceData.name ?? ""
            deviceListRM.device_id = Int(deviceData.id ?? 0)
            deviceListRM.device_token = deviceData.token ?? ""
            deviceListRM.serial_id = deviceData.serialId ?? ""
            deviceListRM.user_id = Int(deviceData.userId ?? 0)
            deviceListRM.shared = false
            deviceListRM.wifi_status = deviceData.isWifiOn ?? false
            deviceListRM.shared_user_email = deviceData.shareduseremail ?? ""
            deviceListRM.time_zone = deviceData.deviceTimeZone ?? ""
            deviceListRM.firmware_version = deviceData.firmwareVersion ?? ""
            deviceListRM.maxLogIndex = deviceData.maxlogindex ?? ""
            // New good
            deviceListRM.pressure_altitude_correction_status = deviceData.altitudeCorrectionStatus ?? false
            deviceListRM.pressure_elevation = deviceData.elevation ?? ""
            deviceListRM.pressure_elevation_deviation_mbr = deviceData.elevationdeviationmbr ?? ""
            deviceListRM.pressure_elevation_deviation_ihg = deviceData.elevationdeviationihg ?? ""
            deviceListRM.isBluetoothSync = deviceData.isBluetoothSync ?? false
            let realm = try! Realm()
            try! realm.write {
                realm.add(deviceListRM)
            }
        }
    }
    
    func insertCoreDataDeviceDataValues(arrDeviceData: [MyDeviceModel])  {
        
        let context = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: TBL_DEVICEDATA))
        do {
            try context.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
        
        for deviceData in arrDeviceData  {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_DEVICEDATA, into: context)
            newSetting.setValue(String(format: "%@", deviceData.serialId ?? ""), forKey: "serialId")
            newSetting.setValue(true, forKey: "syncdata")
        }
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func updateCoreDataDeviceDataValues(deviceSerialID:String,sync:Bool)  {
        let viewcontextValue = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_DEVICEDATA)
        let predicate = NSPredicate(format: "serialId = '\(deviceSerialID)'")
         UserDefaults.standard.set(deviceSerialID, forKey: "Selected_DeviceName_SerialID")
        fetchRequest.predicate = predicate
        do {
            let result = try viewcontextValue.fetch(fetchRequest)
            if let objectToUpdate = result.first as? NSManagedObject {
                objectToUpdate.setValue(sync, forKey: "syncdata")
                try viewcontextValue.save()
            }
        } catch {
            print(error)
        }
    }
    
    func getDataDeviceDataValues(deviceSerialID:String) -> Bool  {
        let viewcontextValue = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_DEVICEDATA)
        let predicate = NSPredicate(format: "serialId = '\(deviceSerialID)'")
        fetchRequest.predicate = predicate
        do {
            let result = try viewcontextValue.fetch(fetchRequest)
            if let objectToUpdate = result.first as? NSManagedObject {
                let resultd:Bool = (objectToUpdate.value(forKey: "syncdata") != nil)
                return resultd
            }
            return true
        } catch _ as NSError {
            return true
        }
    }
    
    func insertRadonValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.pollutantType = .PollutantRadon
            let thresHoldSetting = RealmThresHoldSetting()
            thresHoldSetting.auto_id = self.nextThresHoldId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.pollutant =  self.pollutantType?.rawValue ?? ""
            thresHoldSetting.low_waring_value = String(format: "%f", deviceData.radonThresholdWarningLevel ?? 0.0)
            thresHoldSetting.high_waring_value = ""
            thresHoldSetting.low_alert_value = String(format: "%f", deviceData.radonThresholdAlertLevel ?? 0.0)
            thresHoldSetting.high_alert_value = ""
            thresHoldSetting.temp_offset =  ""
            thresHoldSetting.should_notify = deviceData.shouldNotifyOnRadon ?? false
            thresHoldSetting.sync = false
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    
    func insertTemperatureValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.pollutantType = .PollutantTemperature
            let thresHoldSetting = RealmThresHoldSetting()
            thresHoldSetting.auto_id = self.nextThresHoldId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.pollutant =  self.pollutantType?.rawValue ?? ""
            thresHoldSetting.low_waring_value = String(format: "%f", deviceData.temperatureThresholdLowWarningLevel ?? 0.0)
            thresHoldSetting.high_waring_value = String(format: "%f", deviceData.temperatureThresholdHighWarningLevel ?? 0.0)
            thresHoldSetting.low_alert_value = String(format: "%f", deviceData.temperatureThresholdLowalertLevel ?? 0.0)
            thresHoldSetting.high_alert_value = String(format: "%f", deviceData.temperatureThresholdHighalertLevel ?? 0.0)
            thresHoldSetting.temp_offset =  String(format: "%@", deviceData.tempOffset ?? "")
            thresHoldSetting.should_notify = deviceData.shouldNotifyOnTemperature ?? false
            thresHoldSetting.sync = false
            textLog.writeAPI("Pollutant Temperature" + self.pollutantType!.rawValue)
            let realmRadon = try! Realm()
            try! realmRadon.write {
               realmRadon.add(thresHoldSetting)
            }
        }
    }
    
    func insertHumidityValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.pollutantType = .PollutantHumidity
            let thresHoldSetting = RealmThresHoldSetting()
            thresHoldSetting.auto_id = self.nextThresHoldId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.pollutant =  self.pollutantType?.rawValue ?? ""
            thresHoldSetting.low_waring_value = String(format: "%d", deviceData.humidityThresholdLowWarningLevel ?? 0.0)
            thresHoldSetting.high_waring_value = String(format: "%d", deviceData.humidityThresholdHighWarningLevel ?? 0.0)
            thresHoldSetting.low_alert_value = String(format: "%d", deviceData.humidityThresholdLowalertLevel ?? 0.0)
            thresHoldSetting.high_alert_value = String(format: "%d", deviceData.humidityThresholdHighalertLevel ?? 0.0)
            thresHoldSetting.temp_offset =  ""
            thresHoldSetting.should_notify = deviceData.shouldNotifyOnHumidity ?? false
            thresHoldSetting.sync = false
            textLog.writeAPI("Pollutant Humidity" + self.pollutantType!.rawValue)
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    
    func insertAirPressureValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.pollutantType = .PollutantAirPressure
            let thresHoldSetting = RealmThresHoldSetting()
            thresHoldSetting.auto_id = self.nextThresHoldId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.pollutant =  self.pollutantType?.rawValue ?? ""
            thresHoldSetting.low_waring_value = String(format: "%f", deviceData.airpressureThresholdLowWarningLevel ?? 0.0)
            thresHoldSetting.high_waring_value = String(format: "%f", deviceData.airpressureThresholdHighWarningLevel ?? 0.0)
            thresHoldSetting.low_alert_value = String(format: "%f", deviceData.airpressureThresholdLowalertLevel ?? 0.0)
            thresHoldSetting.high_alert_value = String(format: "%f", deviceData.airpressureThresholdHighalertLevel ?? 0.0)
            thresHoldSetting.temp_offset =  ""
            thresHoldSetting.should_notify = deviceData.shouldNotifyOnAirPressure ?? false
            thresHoldSetting.sync = false
            textLog.writeAPI("Pollutant AirPressure" + self.pollutantType!.rawValue)
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    
    func insertECO2Values(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.pollutantType = .PollutantECO2
            let thresHoldSetting = RealmThresHoldSetting()
            thresHoldSetting.auto_id = self.nextThresHoldId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.pollutant =  self.pollutantType?.rawValue ?? ""
            thresHoldSetting.low_waring_value = String(format: "%d", deviceData.co2ThresholdWarningLevel ?? 0.0)
            thresHoldSetting.high_waring_value = ""
            thresHoldSetting.low_alert_value = String(format: "%d", deviceData.co2ThresholdAlertLevel ?? 0.0)
            thresHoldSetting.high_alert_value = ""
            thresHoldSetting.temp_offset =  ""
            thresHoldSetting.should_notify = deviceData.shouldNotifyOnCo2 ?? false
            thresHoldSetting.sync = false
            textLog.writeAPI("Pollutant ECO2" + self.pollutantType!.rawValue)
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    
    func insertVOCValues(arrDeviceData: [MyDeviceModel])  { //VOC
        for deviceData in arrDeviceData  {
            self.pollutantType = .PollutantVOC
            let thresHoldSetting = RealmThresHoldSetting()
            thresHoldSetting.auto_id = self.nextThresHoldId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.pollutant =  self.pollutantType?.rawValue ?? ""
            thresHoldSetting.low_waring_value = String(format: "%d", deviceData.vocThresholdWarningLevel ?? 0.0)
            thresHoldSetting.high_waring_value = ""
            thresHoldSetting.low_alert_value = String(format: "%d", deviceData.vocThresholdAlertLevel ?? 0.0)
            thresHoldSetting.high_alert_value = ""
            thresHoldSetting.temp_offset =  ""
            thresHoldSetting.should_notify = deviceData.shouldNotifyOnVoc ?? false
            thresHoldSetting.sync = false
            textLog.writeAPI("Pollutant VOC" + self.pollutantType!.rawValue )
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    //Color Setting
    
    func insertOKColorValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.colorType = .ColorOk
            let thresHoldSetting = RealmColorSetting()
            thresHoldSetting.auto_id = self.nextColorSettingId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.color_type =  self.colorType?.rawValue ?? ""
            if deviceData.okColorCodeHex == "0x00" {
                thresHoldSetting.color_code = "#32C772"
                thresHoldSetting.color_code_disable = true
            }else {
                thresHoldSetting.color_code = String(format: "%@", deviceData.okColorCodeHex ?? 0.0)
                thresHoldSetting.color_code_disable = false
            }
            thresHoldSetting.night_light_start_time = 0
            thresHoldSetting.night_light_end_time = 0
            thresHoldSetting.night_light_color_on_off = false
            thresHoldSetting.sync = false
            thresHoldSetting.color_led_brightness = deviceData.okColorLedbrightness ?? "1"
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    func insertWarningColorValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.colorType = .ColorWarning
            let thresHoldSetting = RealmColorSetting()
            thresHoldSetting.auto_id = self.nextColorSettingId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.color_type =  self.colorType?.rawValue ?? ""
            if deviceData.warningColorCodeHex == "0x00" {
                thresHoldSetting.color_code = "#DEBF54"
                thresHoldSetting.color_code_disable = true
            }else {
                thresHoldSetting.color_code = String(format: "%@", deviceData.warningColorCodeHex ?? 0.0)
                thresHoldSetting.color_code_disable = false
            }
            thresHoldSetting.night_light_start_time = 0
            thresHoldSetting.night_light_end_time = 0
            thresHoldSetting.night_light_color_on_off = false
            thresHoldSetting.sync = false
            thresHoldSetting.color_led_brightness = deviceData.waringColorLedbrightness ?? "1"
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    func insertAlertColorValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.colorType = .ColorAlert
            let thresHoldSetting = RealmColorSetting()
            thresHoldSetting.auto_id = self.nextColorSettingId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.color_type =  self.colorType?.rawValue ?? ""
            if deviceData.alertColorCodeHex == "0x00" {
                thresHoldSetting.color_code = "#E15D5B"
                thresHoldSetting.color_code_disable = true
            }else {
                thresHoldSetting.color_code = String(format: "%@", deviceData.alertColorCodeHex ?? 0.0)
                thresHoldSetting.color_code_disable = false
            }
            thresHoldSetting.night_light_start_time = 0
            thresHoldSetting.night_light_end_time = 0
            thresHoldSetting.night_light_color_on_off = false
            thresHoldSetting.sync = false
            thresHoldSetting.color_led_brightness = deviceData.alertColorLedbrightness ?? "1"

            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    func insertNightLightColorValues(arrDeviceData: [MyDeviceModel])  {
        for deviceData in arrDeviceData  {
            self.colorType = .ColorNightLight
            let thresHoldSetting = RealmColorSetting()
            thresHoldSetting.auto_id = self.nextColorSettingId()
            thresHoldSetting.device_id = Int(deviceData.id ?? 0)
            thresHoldSetting.color_type =  self.colorType?.rawValue ?? ""
            if deviceData.nightlightColorCodeHex == "" || deviceData.nightlightColorCodeHex == nil || deviceData.nightlightColorCodeHex?.lowercased() == "select"{
                thresHoldSetting.color_code = "0x00"
            }else {
                 thresHoldSetting.color_code = String(format: "%@", deviceData.nightlightColorCodeHex ?? 0)
            }
            thresHoldSetting.night_light_start_time = Int(deviceData.nightColorStartTime ?? 0)
            thresHoldSetting.night_light_end_time = Int(deviceData.nightColorEndTime ?? 0)
            thresHoldSetting.night_light_color_on_off = false
            thresHoldSetting.sync = false
            thresHoldSetting.color_led_brightness = deviceData.nightLightColorLedbrightness ?? "1"
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(thresHoldSetting)
            }
        }
    }
    // PollutantValuesTBL
    func insertRealmPollutantDummyValuesTBLValues(strDate:Date,deviceID:Int,co2:Float,air_pressure:Float,temperature:Float,humidity:Float,voc:Float,radon:Float,isWiFi:Bool,serialID:String,logIndex:Int,timeStamp:Int) {
        
        let realm = try! Realm()
        let deviceAllData:[RealmPollutantValuesTBL] = realm.objects(RealmPollutantValuesTBL.self).filter({ $0.device_SerialID == serialID})
        if deviceAllData.count > 0 {
            let deviceGetData = deviceAllData.filter({ $0.LogIndex == logIndex})
            if deviceGetData.count != 0 {
                if let deviceData = deviceGetData.first {
                    try! realm.write {
                        deviceData.LogIndex = logIndex
                        deviceData.device_SerialID = serialID
                        deviceData.Device_ID = deviceID
                        deviceData.date = strDate
                        deviceData.CO2 = co2
                        deviceData.AirPressure = air_pressure
                        deviceData.Temperature = temperature
                        deviceData.Humidity = humidity
                        deviceData.VOC = voc
                        deviceData.Radon = radon
                        deviceData.timeStamp = timeStamp
                        deviceData.isWifi = isWiFi
                        deviceData.onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: strDate))
                        deviceData.WeekValue = String.init(format: "%d", Helper.shared.getWeekOfYear(date: Helper.shared.getDateFromDateTime(dateStr: Helper.shared.convertDateToString(date: strDate))))
                    }
                }
            }else {
                let pollutantValues = RealmPollutantValuesTBL()
                pollutantValues.auto_id = self.nextPollutantListId()
                pollutantValues.LogIndex = logIndex
                pollutantValues.device_SerialID = serialID
                pollutantValues.Device_ID = deviceID
                pollutantValues.date = strDate
                pollutantValues.CO2 = co2
                pollutantValues.AirPressure = air_pressure
                pollutantValues.Temperature = temperature
                pollutantValues.Humidity = humidity
                pollutantValues.VOC = voc
                pollutantValues.Radon = radon
                pollutantValues.timeStamp = timeStamp
                pollutantValues.isWifi = isWiFi
                pollutantValues.onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: strDate))
                pollutantValues.WeekValue = String.init(format: "%d", Helper.shared.getWeekOfYear(date: Helper.shared.getDateFromDateTime(dateStr: Helper.shared.convertDateToString(date: strDate))))
                let realmRadon = try! Realm()
                try! realmRadon.write {
                    realmRadon.add(pollutantValues)
                }
            }
        }
       
    }
    
    func updatePollutantTableData(strDate:String,deviceID:Int,co2:String,air_pressure:String,temperature:String,humidity:String,voc:String,radon:String,isWiFi:Bool,device_SerialID:String) {
        let realm = try! Realm()
        let deviceAllData:[RealmPollutantValuesTBL] = realm.objects(RealmPollutantValuesTBL.self).filter({ $0.device_SerialID == device_SerialID})
        if deviceAllData.count > 0 {
            let deviceGetData = deviceAllData.filter({ $0.LogIndex == -1})
            if let deviceData = deviceGetData.first {
                try! realm.write {
                    
                    var timeStampvalue =  strDate.toInt() ?? 0
                    timeStampvalue = timeStampvalue * 1000
                    
                    deviceData.LogIndex = -1
                    deviceData.Device_ID = deviceID
                    deviceData.device_SerialID = device_SerialID
                    deviceData.date = Date(milliseconds:timeStampvalue)
                    deviceData.CO2 = co2.toFloat() ?? 0.0
                    deviceData.AirPressure = air_pressure.toFloat() ?? 0.0
                    deviceData.Temperature = temperature.toFloat() ?? 0.0
                    deviceData.Humidity = humidity.toFloat() ?? 0.0
                    deviceData.VOC = voc.toFloat() ?? 0.0
                    deviceData.Radon = radon.toFloat() ?? 0.0
                    deviceData.isWifi = isWiFi
                    deviceData.timeStamp = timeStampvalue
                    deviceData.onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: deviceData.date))
                    deviceData.WeekValue = String.init(format: "%d", Helper.shared.getWeekOfYear(date: Helper.shared.getDateFromDateTime(dateStr: Helper.shared.convertDateToString(date: deviceData.date))))
                }
            }
        }

    }
    
    func convertDateToString(date: Date)-> String{
        let utc = TimeZone(identifier: "UTC")
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = utc ?? TimeZone.init(secondsFromGMT: 0)!
        return dateFormatter.string(from: date)
    }

    func readCurrentIndexPollutantDataValues(device_ID:Int) ->  [RealmPollutantValuesTBL] {
        let realm = try! Realm()
        
        let data = realm.objects(RealmPollutantValuesTBL.self).filter("Device_ID == \(device_ID)").sorted(byKeyPath: "timeStamp", ascending: false)
        if data.count != 0 {
            return [data[0]]
        }
        return []
        var pollutantDataList = Array(realm.objects(RealmPollutantValuesTBL.self)).filter({ $0.Device_ID == device_ID})
        if pollutantDataList.count != 0 {
            pollutantDataList = pollutantDataList.sorted(by: { $0.timeStamp > $1.timeStamp })
            if pollutantDataList.count != 0 {
                return [pollutantDataList[0]]
            }
        }
        return pollutantDataList
    }
    
    func readLogFirstIndexPollutantDataValues(device_ID:Int) ->  [RealmPollutantValuesTBL] {
        let realm = try! Realm()
        var pollutantDataList = Array(realm.objects(RealmPollutantValuesTBL.self)).filter({ $0.Device_ID == device_ID})
        pollutantDataList = pollutantDataList.filter({ $0.LogIndex == -1})
        if pollutantDataList.count != 0 {
            pollutantDataList = pollutantDataList.sorted(by: { $0.timeStamp > $1.timeStamp })
            if pollutantDataList.count != 0 {
                return [pollutantDataList[0]]
            }
        }
        return pollutantDataList
    }
    
    func readPollutantDataValues() ->  [RealmPollutantValuesTBL] {
        let realm = try! Realm()
        let pollutantDataList = Array(realm.objects(RealmPollutantValuesTBL.self))
        if pollutantDataList.count != 0 {
            return [pollutantDataList[0]]
        }
        return []
    }
    
    func readTimeBasePollutantDataValues(device_ID:Int) ->  Int {
        let realm = try! Realm()
        let pollutantDataList = realm.objects(RealmPollutantValuesTBL.self).filter({ $0.Device_ID == device_ID})
        if pollutantDataList.count != 0 {
            let maxVal = pollutantDataList.max { $0.LogIndex < $1.LogIndex }
            return maxVal?.LogIndex ?? 0
        }
        return 0
        
    }
}

extension RealmDataManager {
    func getRealmPollutantValuesTBLValues(strDate:Date,deviceID:Int,co2:Float,air_pressure:Float,temperature:Float,humidity:Float,voc:Float,radon:Float,isWiFi:Bool,serialID:String,logIndex:Int,timeStamp:Int) -> RealmPollutantValuesTBL{
        let pollutantValues = RealmPollutantValuesTBL()
        pollutantValues.LogIndex = logIndex
        pollutantValues.device_SerialID = serialID
        pollutantValues.Device_ID = deviceID
        pollutantValues.date = strDate
        pollutantValues.CO2 = co2
        pollutantValues.AirPressure = air_pressure
        pollutantValues.Temperature = temperature
        pollutantValues.Humidity = humidity
        pollutantValues.VOC = voc
        pollutantValues.Radon = radon
        pollutantValues.isWifi = isWiFi
        pollutantValues.onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: strDate))
        pollutantValues.WeekValue = String.init(format: "%d", Helper.shared.getWeekOfYear(date: Helper.shared.getDateFromDateTime(dateStr: Helper.shared.convertDateToString(date: strDate))))
        pollutantValues.timeStamp = timeStamp
        return pollutantValues
    }
    
//    func insertRealmPollutantValuesTBLValues(pollutantValues: [RealmPollutantValuesTBL]) {
//        for pollutant in pollutantValues {
//            let realm = try! Realm()
//            var deviceAllData = realm.objects(RealmPollutantValuesTBL.self).filter({ $0.device_SerialID == pollutant.device_SerialID})
//            deviceAllData = deviceAllData.filter({ $0.LogIndex == pollutant.LogIndex})
//            if deviceAllData.count != 0 {
//                if let deviceData = deviceAllData.first {
//                    try! realm.write {
//                        deviceData.LogIndex = pollutant.LogIndex
//                        deviceData.device_SerialID = pollutant.device_SerialID
//                        deviceData.Device_ID = pollutant.Device_ID
//                        deviceData.date = pollutant.date
//                        deviceData.CO2 = pollutant.CO2
//                        deviceData.AirPressure = pollutant.AirPressure
//                        deviceData.Temperature = pollutant.Temperature
//                        deviceData.Humidity = pollutant.Humidity
//                        deviceData.VOC = pollutant.VOC
//                        deviceData.Radon = pollutant.Radon
//                        deviceData.timeStamp = pollutant.timeStamp
//                        deviceData.isWifi = pollutant.isWifi
//                        deviceData.onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: pollutant.date))
//                        deviceData.WeekValue = String.init(format: "%d", Helper.shared.getWeekOfYear(date: Helper.shared.getDateFromDateTime(dateStr: Helper.shared.convertDateToString(date: pollutant.date))))
//                    }
//                }
//            }else {
//                let realmRadon = try! Realm()
//                try! realmRadon.write {
//                    realmRadon.add(pollutant)
//                }
//            }
//        }
//    }
    
    func insertMAXLogINDEXRealmPollutantValuesTBLValues(pollutantValues: [RealmPollutantValuesTBL]) {
        let realmRadon = try! Realm()
        try! realmRadon.write {
            for pollutant in pollutantValues {
                pollutant.auto_id = realmRadon.objects(RealmPollutantValuesTBL.self).map{$0.auto_id}.max() ?? 0
                pollutant.auto_id = pollutant.auto_id + 1
                realmRadon.add(pollutant)
            }
        }
    }
    
    func insertRealmPollutantValuesTBLValues(pollutantValues: [RealmPollutantValuesTBL]) {
        
//        let realmRadon = try! Realm()
//        try! realmRadon.write {
//            for pollutant in pollutantValues {
//                pollutant.auto_id = realmRadon.objects(RealmPollutantValuesTBL.self).map{$0.auto_id}.max() ?? 0
//                pollutant.auto_id = pollutant.auto_id + 1
//                realmRadon.add(pollutant)
//            }
//        }
        
        DispatchQueue(label: "background").async {
            autoreleasepool {
                // Get realm and table instances for this thread
                let realm = try! Realm()
                
                // Break up the writing blocks into smaller portions
                // by starting a new transaction
               
                realm.beginWrite()
                var auto_ID = realm.objects(RealmPollutantValuesTBL.self).map{$0.auto_id}.max() ?? 0
                
                if auto_ID < 1000{
                    auto_ID += 1000
                }
                var deviceSerialID:String = ""
                // Add row via dictionary. Property order is ignored.
                for pollutant in pollutantValues {
                    pollutant.auto_id = auto_ID + 1
                    auto_ID += 1
                    let deviceData = realm.objects(RealmPollutantValuesTBL.self).filter("LogIndex == \(pollutant.LogIndex) AND Device_ID == \(pollutant.Device_ID)")
                    deviceSerialID = pollutant.device_SerialID
                    if deviceData.count >= 1 {
//                        try! realm.write {
//                            deviceData[0].device_SerialID = pollutant.device_SerialID
//                            deviceData[0].Device_ID = pollutant.Device_ID
//                            deviceData[0].LogIndex = pollutant.LogIndex
//                            deviceData[0].Temperature = pollutant.Temperature
//                            deviceData[0].CO2 = pollutant.CO2
//                            deviceData[0].Radon = pollutant.Radon
//                            deviceData[0].AirPressure = pollutant.AirPressure
//                            deviceData[0].VOC = pollutant.VOC
//                            deviceData[0].date = pollutant.date
//                            deviceData[0].Humidity = pollutant.Humidity
//                            deviceData[0].onlyDate = pollutant.onlyDate
//                            deviceData[0].WeekValue = pollutant.WeekValue
//                            deviceData[0].dummyValue = pollutant.dummyValue
//                            deviceData[0].timeStamp = pollutant.timeStamp
//                        }
                    }else {
                        
                        if dataBasePathChange == false {
                            realm.add(pollutant)
                        }
                        //textLog.write(String(format: "Background Sync Get Result Notify Device ID - %d,Log index -%d,Time Stamp -%d", pollutant.Device_ID,pollutant.LogIndex,pollutant
                        //realm.add(pollutant)
                    }
//                    pollutant.auto_id = pollutant.auto_id + 1
                    
                }
                self.updateCoreDataDeviceDataValues(deviceSerialID: deviceSerialID, sync: false)
                // Commit the write transaction
                // to make this data available to other threads
//                //debugPrint(pollutantValues.count)
                self.delegateLogIndexDone?.writeLogIndexDelegate(logIndexDone: true)
                self.delegateAPILogIndexDelegate?.apiUpdateLogIndexDelegate(logIndexDone: true)
                print("Completed new good Daa %@",deviceSerialID)
                try! realm.commitWrite()
            }
        }
    }
    
    func readDeviceListDataValues() -> [RealmDeviceList] {
        let realm = try! Realm()
        let deviceData = Array(realm.objects(RealmDeviceList.self))
        if deviceData.count != 0 {
            return deviceData
        }
        return []
    }
    
    func insertDeviceDummyTBLValues(dummyDeviceValues: [RealmDummyDeviceList]) {
        let realmRadon = try! Realm()
        try! realmRadon.write {
            for dummyDeviceData in dummyDeviceValues {
               // dummyDeviceData.auto_id = self.nextDummyDeviceListId()
                realmRadon.add(dummyDeviceData)
            }
            
        }
    }
    
    func deleteAllDummyData()  {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmDummyDeviceList.self))
        if deviceDataList.count != 0 {
            try! realm.write {
                realm.delete(deviceDataList)
            }
        }
    }
    
    func readDeviceListDataBasedToken(deviceToken:String) -> [RealmDeviceList] {
        let realm = try! Realm()
        let deviceData = Array(realm.objects(RealmDeviceList.self))
        if deviceData.count != 0{
            let deviceDataList = Array(realm.objects(RealmDeviceList.self).filter({ $0.device_token == deviceToken }))
            return deviceDataList
        }
        return []
    }
    
    // Dummy Data
    func readDummyDeviceListDataValues() -> [RealmDummyDeviceList] {
        let realm = try! Realm()
        let deviceData = Array(realm.objects(RealmDummyDeviceList.self))
        if deviceData.count != 0 {
            return deviceData
        }
        return []
    }
    
    func removeDummyDeviceUpdate(deviceID:Int) -> Bool{
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmDummyDeviceList.self).filter({ $0.device_id == deviceID}))
        if deviceDataList.count != 0 {
            try! realm.write {
                realm.delete(deviceDataList)
            }
            return true
        }
        return false
    }
    
    func removeDeviceUpdate(deviceID:Int){
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmDeviceList.self).filter({ $0.device_id == deviceID}))
        if deviceDataList.count != 0 {
            try! realm.write {
                realm.delete(deviceDataList)
            }
        }
    }
   
    
    func readFirstDeviceDataValues() -> Int {
        let realm = try! Realm()
        let deviceData = Array(realm.objects(RealmDeviceList.self))
        if deviceData.count != 0{
            let deviceDataList = Array(realm.objects(RealmDeviceList.self).filter({ $0.device_id == deviceData[0].device_id }))
            return deviceDataList[0].device_id
        }
        return 0
    }
    
    func updateDeviceWifiStatus(deviceID:Int,wifiStatus:Bool) {
        let deviceAllData = realm.objects(RealmDeviceList.self).filter({ $0.device_id == deviceID})
        let realm = try! Realm()
        if deviceAllData.count != 0 {
            if let deviceData = deviceAllData.first {
                try! realm.write {
                    deviceData.wifi_status = wifiStatus
                }
            }
        }
    }
    
    func getFromTableDeviceName(deviceID:Int) ->  String {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmDeviceList.self).filter({ $0.device_id == deviceID}))
        if deviceDataList.count != 0 {
            return deviceDataList[0].name
        }
        return ""
    }
    
    func getDeviceData(deviceID:Int) ->  [RealmDeviceList] {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmDeviceList.self).filter({ $0.device_id == deviceID}))
        if deviceDataList.count != 0 {
            return deviceDataList
        }
        return []
    }
    
    func getFromTableDeviceID(serial_id:String) ->  Int {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmDeviceList.self).filter({ $0.serial_id == serial_id}))
        if deviceDataList.count != 0 {
            return deviceDataList[0].device_id
        }
        return 0
    }
    
    func getFromTableDeviceSerialID(deviceID:Int) ->  String {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmDeviceList.self).filter({ $0.device_id == deviceID}))
        if deviceDataList.count != 0 {
            return deviceDataList[0].serial_id
        }
        return ""
    }
    
    func readPollutantDataValues(deviceID:Int, pollutantType: String) ->  [RealmThresHoldSetting] {
        let realm = try! Realm()
        let pollutantDataList = Array(realm.objects(RealmThresHoldSetting.self).filter({ $0.device_id == deviceID}))
        if pollutantDataList.count != 0 {
            return pollutantDataList.filter({ $0.pollutant == pollutantType})
        }
        return []
    }
    
    
    func readColorDataValues(deviceID:Int, colorType: String) ->  [RealmColorSetting] {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmColorSetting.self).filter({ $0.device_id == deviceID}))
        if deviceDataList.count != 0 {
            return deviceDataList.filter({ $0.color_type == colorType})
        }
        return []
    }
   
    
    func updateFilterData(deviceID:Int, colorType: String, colorCode:String, isColorCodeOnOff:Bool, brightnessLEDValue:String) {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmColorSetting.self).filter({ $0.device_id == deviceID}))
        if deviceDataList.count != 0 {
            let deviceData = deviceDataList.filter({ $0.color_type == colorType})
            if deviceData.count != 0 {
                try! realm.write {
                    deviceData[0].color_code = colorCode
                    deviceData[0].color_code_disable = isColorCodeOnOff
                    deviceData[0].color_led_brightness = brightnessLEDValue
                    realm.add(deviceData, update: true)
                }
            }
        }
    }
    
    func updateAllDeviceFilterData(colorType: String, colorCode:String, isColorCodeOnOff:Bool, brightnessLEDValue:String) {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmColorSetting.self).filter({ $0.color_type == colorType}))
        if deviceDataList.count != 0 {
            for deviceAllData in deviceDataList {
                try! realm.write {
                     deviceAllData.color_code = colorCode
                     deviceAllData.color_code_disable = isColorCodeOnOff
                    deviceAllData.color_led_brightness = brightnessLEDValue
                }
            }
        }
    }
    
    func updateNightLightFilterData(deviceID:Int, colorType: String, colorCode:String, startTime:Int, endTime:Int, isNightSwitchOn:Bool, brightnessLEDValue:String) {
        var deviceAllData = realm.objects(RealmColorSetting.self).filter({ $0.device_id == deviceID})
        deviceAllData = deviceAllData.filter({ $0.color_type == colorType})
        let realm = try! Realm()
        if let deviceData = deviceAllData.first {
            try! realm.write {
                deviceData.color_code = colorCode
                deviceData.night_light_start_time = startTime
                deviceData.night_light_end_time = endTime
                deviceData.night_light_color_on_off = isNightSwitchOn
                deviceData.color_led_brightness = brightnessLEDValue
            }
        }
    }
    
    func updateNightLightAllDeviceFilterData(colorType: String, colorCode:String, startTime:Int, endTime:Int, isNightSwitchOn:Bool, brightnessLEDValue:String) {
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmColorSetting.self).filter({ $0.color_type == colorType}))
        if deviceDataList.count != 0 {
            for deviceAllData in deviceDataList {
                try! realm.write {
                    deviceAllData.color_code = colorCode
                    deviceAllData.night_light_start_time = startTime
                    deviceAllData.night_light_end_time = endTime
                    deviceAllData.night_light_color_on_off = isNightSwitchOn
                    deviceAllData.color_led_brightness = brightnessLEDValue
                }
            }
        }
    }
    
    
    func updateThresHoldFilterData(deviceID:Int, pollutantType: String, lowWarning:String, highWarning:String, lowAlert:String, highAlert:String, tempOffset:String) {
        var newGoodDeviceDatas = realm.objects(RealmThresHoldSetting.self).filter({ $0.device_id == deviceID})
        newGoodDeviceDatas = newGoodDeviceDatas.filter({ $0.pollutant == pollutantType})
        let realm = try! Realm()
        if let newGoodDevData = newGoodDeviceDatas.first {
            try! realm.write {
                newGoodDevData.low_waring_value = lowWarning
                newGoodDevData.high_waring_value = highWarning
                newGoodDevData.low_alert_value = lowAlert
                newGoodDevData.high_alert_value = highAlert
                newGoodDevData.temp_offset = tempOffset
            }
        }
    }
    
    func updateThresHoldTempOffSet(deviceID:Int, pollutantType: String,tempOffset:String) {
        var newGoodDeviceDatas = realm.objects(RealmThresHoldSetting.self).filter({ $0.device_id == deviceID})
        newGoodDeviceDatas = newGoodDeviceDatas.filter({ $0.pollutant == pollutantType})
        let realm = try! Realm()
        if let newGoodDevData = newGoodDeviceDatas.first {
            try! realm.write {
                newGoodDevData.temp_offset = tempOffset
            }
        }
    }
    
    func updateAllThresHoldFilterData(pollutantType: String, lowWarning:String, highWarning:String, lowAlert:String, highAlert:String, tempOffset:String){
        let deviceAllData = realm.objects(RealmThresHoldSetting.self).filter({ $0.pollutant == pollutantType})
        let realm = try! Realm()
        for deviceDataValue in deviceAllData {
            
            let deviceData:RealmThresHoldSetting = deviceDataValue
            if deviceData != nil{
                try! realm.write {
                    deviceData.low_waring_value = lowWarning
                    deviceData.high_waring_value = highWarning
                    deviceData.low_alert_value = lowAlert
                    deviceData.high_alert_value = highAlert
                    deviceData.temp_offset = tempOffset
                }
            }
//            if let deviceData:RealmThresHoldSetting = deviceDataValue {
//
//            }
        }
        
    }
    
    func updateDeviceAltitudeStatus(deviceID:Int,altitudeStatus:Bool) {
        let deviceAllData = realm.objects(RealmDeviceList.self).filter({ $0.device_id == deviceID})
        let realm = try! Realm()
        if deviceAllData.count != 0 {
            if let deviceData = deviceAllData.first {
                try! realm.write {
                    deviceData.pressure_altitude_correction_status = altitudeStatus
                }
            }
        }
    }
    
    func updateAllDeviceAltitudeStatus(altitudeStatus:Bool) {
        let deviceAllData = realm.objects(RealmDeviceList.self)
        let realm = try! Realm()
        if deviceAllData.count != 0 {
            for deviceData in deviceAllData {
                try! realm.write {
                    deviceData.pressure_altitude_correction_status = altitudeStatus
                }
            }
        }
    }
    
    
    
    func updateNotifiyAllThresHoldFilterData(pollutantType: String, isShouldNotifi:Bool,deviceID:Int){
        var deviceAllData = realm.objects(RealmThresHoldSetting.self).filter({ $0.pollutant == pollutantType})
        deviceAllData = deviceAllData.filter({ $0.device_id == deviceID})
        let realm = try! Realm()
        if let deviceData = deviceAllData.first {
            try! realm.write {
                deviceData.should_notify = isShouldNotifi
            }
        }
    }
    
    func readRadonValues()  {
        self.pollutantType = .PollutantRadon
        let realm = try! Realm()
        let radonData1 = realm.objects(RealmThresHoldSetting.self)
        print(radonData1)
        let deviceContacts = Array(realm.objects(RealmThresHoldSetting.self).filter({ $0.pollutant == "VOC" }))
        print(deviceContacts)
    }
    
    func removeDeviceListInTable(deviceID:Int) -> Bool{
        let realm = try! Realm()
        let deviceDataList = Array(realm.objects(RealmDeviceList.self).filter({ $0.device_id == deviceID}))
        if deviceDataList.count != 0 {
            realm.delete(deviceDataList)
            return true
        }
        return false
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////

    
    func getDeviceDetails(deviceID: String)-> Results<RealmThresHoldSetting>{
        let data = realm.objects(RealmThresHoldSetting.self).filter("device_id == \(deviceID)")
        return data
    }
    
    
    func getRealMPollutantValues24HoursFiltered( deviceID: String, endDate: Date)-> (array: [RealmPollutantValuesTBL], average: AverageValues){
        
        let yesterdayStart: Date = {
            let components = DateComponents(day: -1, second: 0)
            return Calendar.current.date(byAdding: components, to: endDate)!
        }()
       

      
        let logIndex = -1
        
//        let startDateToFetch = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: yesterdayStart.toLocalTime(), deviceId: Int(deviceID) ?? 0)
//        let endDateToFetch = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: endDate.toLocalTime(), deviceId: Int(deviceID) ?? 0)
        let startDateToFetch = yesterdayStart.toLocalTime()
         let endDateToFetch = endDate.toLocalTime()
        let data = realm.objects(RealmPollutantValuesTBL.self).filter("LogIndex != \(logIndex) AND Device_ID == \(deviceID) AND date BETWEEN {%@, %@}", startDateToFetch, endDateToFetch).sorted(byKeyPath: "date", ascending: false)
        var pollutantValues: [RealmPollutantValuesTBL] = []
        
        //debugPrint(startDateToFetch)
        //debugPrint(endDateToFetch)
        
       
        
       

//        //debugPrint(data)
        for i in data{
            
            let pollutantValue = RealmPollutantValuesTBL.init()
            pollutantValue.AirPressure = i.AirPressure
            pollutantValue.CO2 = i.CO2
            pollutantValue.Humidity = i.Humidity
            pollutantValue.Temperature = i.Temperature
            pollutantValue.VOC = i.VOC
            pollutantValue.Radon = i.Radon
            pollutantValue.date = i.date
            pollutantValue.onlyDate = self.getTimeFromFullDate(date: i.date)
//            if pollutantValue.onlyDate == "2019/08/19 23" || pollutantValue.onlyDate == "2019/08/19 00"{
//
//            }else{
                pollutantValues.append(pollutantValue)
//            }
            
            
        }
        pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
       //debugPrint("sorting completed")
//        //debugPrint(pollutantValues)
        
        let isBefore = self.checkForMissedDataAndTimeline(startDate: startDateToFetch, endDate: endDateToFetch, data: pollutantValues)
        
        var last24Hours = Date.getLast24Hours(forLastNDays: 24, endDate: endDateToFetch, isBefore: isBefore)
        last24Hours = last24Hours.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
         //debugPrint("sorted hours\(last24Hours)")
        var index = 0

        for i in last24Hours{
//            //debugPrint(i)
            if pollutantValues.contains(where: { $0.onlyDate == i}) {
                // found
            } else {

                if pollutantValues.count == 24{
                    break
                }
                if index == 0 || index == last24Hours.count - 1{

                    let groupValCount = data.count
                    let sumOfAirPressure = data.lazy.compactMap { $0.AirPressure }
                        .reduce(0, +)
                    let sumOfCO2 = data.lazy.compactMap { $0.CO2 }
                        .reduce(0, +)
                    let sumOfHumidity = data.lazy.compactMap { $0.Humidity }
                        .reduce(0, +)
                    let sumOfTemperature = data.lazy.compactMap { $0.Temperature }
                        .reduce(0, +)
                    let sumOfVOC = data.lazy.compactMap { $0.VOC }
                        .reduce(0, +)
                    let sumOfRadon = data.lazy.compactMap { $0.Radon }
                        .reduce(0, +)

                    let pollutantValue = RealmPollutantValuesTBL.init()
                    pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
                    pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
                    pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
                    pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
                    pollutantValue.VOC = sumOfVOC/Float(groupValCount)
                    pollutantValue.Radon = sumOfRadon/Float(groupValCount)
                    pollutantValue.date = self.getHourDateFormatter(datestr: i)
                    pollutantValue.onlyDate = i
                    if index == 0{
                        pollutantValue.dummyValue = -12345
                    }else{
                        pollutantValue.dummyValue = -123456
                    }
                    pollutantValues.append(pollutantValue)
                }
                else{
                    let pollutantValue = RealmPollutantValuesTBL.init()
                    pollutantValue.AirPressure = 0
                    pollutantValue.CO2 = 0
                    pollutantValue.Humidity = 0
                    pollutantValue.Temperature = 0
                    pollutantValue.VOC = 0
                    pollutantValue.Radon = 0
                    pollutantValue.date = self.getHourDateFormatter(datestr: i)
                    pollutantValue.onlyDate = i
                    pollutantValue.dummyValue = -1000
                    pollutantValues.append(pollutantValue)
                }
            }
            index += 1
        }
        
        pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
        
        var indexVal = 1
        for value in pollutantValues{
            if value.dummyValue == -12345{
                value.LogIndex = -1
            }else if value.dummyValue == -123456{
                value.LogIndex = pollutantValues.count
            }else{
                value.LogIndex = indexVal
                indexVal+=1
            }
        }
        
        // average
        let radonAverage = (data.lazy.compactMap{$0.Radon}.reduce(0, +))/Float(data.count)
        let temperatureAverage = (data.lazy.compactMap{$0.Temperature}.reduce(0, +))/Float(data.count)
        let humidityAverage = (data.lazy.compactMap{$0.Humidity}.reduce(0, +))/Float(data.count)
        let vocAverage = (data.lazy.compactMap{$0.VOC}.reduce(0, +))/Float(data.count)
        let co2Average = (data.lazy.compactMap{$0.CO2}.reduce(0, +))/Float(data.count)
        let airPresssureAverage = (data.lazy.compactMap{$0.AirPressure}.reduce(0, +))/Float(data.count)
        
        let averageData = AverageValues.init(radonAverage: radonAverage, vocAverage: vocAverage, co2Average: co2Average, humidityAverage: humidityAverage, airPressureAverage: airPresssureAverage, temperatureAverage: temperatureAverage)
        
        if data.count == 0{
            return ([], averageData)
        }
        return (pollutantValues, averageData)
    }
    
    
    func checkForMissedDataAndTimeline(startDate: Date, endDate: Date, data: [RealmPollutantValuesTBL])->Bool{
        if data.count > 0{
            
            let dataStartDate = data.first?.date
            let dataEndDate = data.last?.date
            
            var isFirstMissing = false
            var isLastMissing = false
            
            let startTimeDiffrence = checkTimeDifferenceBetweenDates(date1: startDate, date2: dataStartDate ?? Date())
            let endTimeDifference = checkTimeDifferenceBetweenDates(date1: endDate, date2: dataEndDate ?? Date())

            
            if startTimeDiffrence >= 60 || startTimeDiffrence < 0{
                // first data missing
                isFirstMissing = true
            }
            
            if endTimeDifference > 0 || endTimeDifference <= -60   {
                // last data missing
                isLastMissing = true
            }
            
            if isFirstMissing == false{
                let localHours = self.getHoursFromDate(date: startDate)
                let dataHours = self.getHoursFromDate(date: dataStartDate ?? Date())
                
                if localHours == dataHours{
                    return true
                }
                else if localHours > dataHours{
                    return true
                }
                else if localHours < dataHours{
                    return false
                }
            }
            
            else if isLastMissing == false{
                let localHours = self.getHoursFromDate(date: endDate)
                let dataHours = self.getHoursFromDate(date: dataEndDate ?? Date())

                if localHours == dataHours{
                    return false
                }
                else if localHours > dataHours{
                    return true
                }
                else if localHours < dataHours{
                    return false
                }
            }
            else{
                let localStartHours = self.getHoursFromDate(date: startDate)
//                let localEndHours = self.getHoursFromDate(date: endDate)
                let dataStartHours = self.getHoursFromDate(date: dataStartDate ?? Date())
//                let dataEndHours = self.getHoursFromDate(date: dataEndDate ?? Date())
//
//                let localStartMinutes = self.getMinutesFromDate(date: startDate)
//                let localEndMinutes = self.getMinutesFromDate(date: endDate)
//                let dataStartMinutes = self.getMinutesFromDate(date: dataStartDate ?? Date())
//                let dataEndMinutes = self.getMinutesFromDate(date: dataEndDate ?? Date())
                
                let startTimeDiffrence = checkTimeDifferenceBetweenDates(date1: startDate, date2: dataStartDate ?? Date())
                
                for i in 0...23{
                    if ((startTimeDiffrence / 60) == i){
                        if (localStartHours == (dataStartHours - i)){
                            return true
                        }
                        else if localStartHours > (dataStartHours - i){
                            return true
                        }
                        else if localStartHours < (dataStartHours - i){
                            return false
                        }
                    }
                }
                
            }
            
        }
        return false
    }
    
    func checkTimeDifferenceBetweenDates(date1: Date, date2: Date)-> Int{
        let cal = Calendar.current
        let components = cal.dateComponents([.minute], from: date1, to: date2)
        let diff = components.minute!
        return diff
    }
    
    func getRealMPollutantValues7DaysFiltered( deviceID: String, endDate: Date)->  (array: [RealmPollutantValuesTBL], average: AverageValues){
        
        let weekstart: Date = {
            let components = DateComponents(day: -7, second: 0)
            return Calendar.current.date(byAdding: components, to: endDate.toLocalTime())!
        }()
        
        
//        let startDateToFetch = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: weekstart.toLocalTime(), deviceId: Int(deviceID) ?? 0)
//        let endDateToFetch = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: endDate.toLocalTime(), deviceId: Int(deviceID) ?? 0)
        
        let startDateToFetch =  weekstart.toLocalTime()
        let endDateToFetch = endDate.toLocalTime()
        
        let data = realm.objects(RealmPollutantValuesTBL.self).filter("LogIndex != -1 AND Device_ID == \(deviceID) AND date BETWEEN {%@, %@}", startDateToFetch, endDateToFetch)
        var pollutantValues: [RealmPollutantValuesTBL] = []
        
//        var groupedItems = Dictionary<String, [RealmPollutantValuesTBL]>.init()

        // this is for finding missing  values
//        let dateArrayVal : [String] = Date.getDates(forLastNDays: 7)
//        var arrayVal : [String] = []
//
//        var baseIndex = 0
//
//        var firstIndexLevel: String = ""
//        for appendVal in dateArrayVal{
//
//
//            for indexAm in 1...4{
//
//
//                if baseIndex == 0{
//                    firstIndexLevel = self.getGroupFromDate(newDate: endDate.toLocalTime(), deviceID: deviceID).rawValue
//
//                    let intVal = firstIndexLevel.toInt() ?? 0
//                    if intVal != nil {
//                        for i in 1...intVal{
//                            arrayVal.append(String(format: "%@-%d", appendVal,i))
//                        }
//                    }
//
//
//                    break
//                }
//
//                else if baseIndex == (dateArrayVal.count - 1){
//                    let intVal = firstIndexLevel.toInt() ?? 0
//                    if intVal + 1 <= 4{
//                        for i in (intVal+1)...4{
//                            arrayVal.append(String(format: "%@-%d", appendVal,i))
//                        }
//                    }
//
//
//                    break
//                }
//                else {
//                    arrayVal.append(String(format: "%@-%d", appendVal,indexAm))
//                }
//
//            }
//            baseIndex += 1
//        }
//
//        arrayVal = arrayVal.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }


//        for item in data{
//            //debugPrint(Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: item.date, deviceId: Int(deviceID) ?? 0))
//            //debugPrint(getGroupFromDate(newDate: item.date, deviceID: deviceID).rawValue)
//
//            let onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: item.date, deviceId: Int(deviceID) ?? 0)))
//            let key = String.init(format: "%@-%@", onlyDate, getGroupFromDate(newDate: item.date, deviceID: deviceID).rawValue)
//            //debugPrint(key)
//            if groupedItems[key] == nil{
//                groupedItems[key] = [item]
//            }
//            else{
//                 groupedItems[key]?.append(item)
//            }
//
//        }

        
        for i in data{
            
            let pollutantValue = RealmPollutantValuesTBL.init()
            pollutantValue.AirPressure = i.AirPressure
            pollutantValue.CO2 = i.CO2
            pollutantValue.Humidity = i.Humidity
            pollutantValue.Temperature = i.Temperature
            pollutantValue.VOC = i.VOC
            pollutantValue.Radon = i.Radon
            pollutantValue.date = i.date
            pollutantValue.onlyDate = self.getTimeFromFullDate(date: i.date)
            pollutantValues.append(pollutantValue)
            
//            //debugPrint(i)
//            var groupVal = i.value
//            groupVal = groupVal.sorted(by: { $0.timeStamp < $1.timeStamp })
//            let groupValCount = groupVal.count
//            let sumOfAirPressure = groupVal.lazy.compactMap { $0.AirPressure }
//                .reduce(0, +)
//            let sumOfCO2 = groupVal.lazy.compactMap { $0.CO2 }
//                .reduce(0, +)
//            let sumOfHumidity = groupVal.lazy.compactMap { $0.Humidity }
//                .reduce(0, +)
//            let sumOfTemperature = groupVal.lazy.compactMap { $0.Temperature }
//                .reduce(0, +)
//            let sumOfVOC = groupVal.lazy.compactMap { $0.VOC }
//                .reduce(0, +)
//            let sumOfRadon = groupVal.lazy.compactMap { $0.Radon }
//                .reduce(0, +)
//
//            let pollutantValue = RealmPollutantValuesTBL.init()
//            pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
//            pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
//            pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
//            pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
//            pollutantValue.VOC = sumOfVOC/Float(groupValCount)
//            pollutantValue.Radon = sumOfRadon/Float(groupValCount)
//            pollutantValue.date = groupVal.last!.date
//            pollutantValue.onlyDate = i.key
//            pollutantValue.LogIndex =
//            if i.key == "2019/08/13-1" || i.key == "2019/08/19-4"{
//            }else{
//                pollutantValues.append(pollutantValue)
//            }
        
        }
        pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
        
        let isBefore = self.checkForMissedDataAndTimeline(startDate: startDateToFetch, endDate: endDateToFetch, data: pollutantValues)
               
               var last24Hours = Date.getLast24Hours(forLastNDays: 168, endDate: endDateToFetch, isBefore: isBefore)
               last24Hours = last24Hours.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
//                //debugPrint("sorted hours\(last24Hours)")
               var index = 0

               for i in last24Hours{
//                   //debugPrint(i)
                   if pollutantValues.contains(where: { $0.onlyDate == i}) {
                       // found
                   } else {

                       if pollutantValues.count == 168{
                           break
                       }
                       if index == 0 || index == last24Hours.count - 1{

                           let groupValCount = data.count
                           let sumOfAirPressure = data.lazy.compactMap { $0.AirPressure }
                               .reduce(0, +)
                           let sumOfCO2 = data.lazy.compactMap { $0.CO2 }
                               .reduce(0, +)
                           let sumOfHumidity = data.lazy.compactMap { $0.Humidity }
                               .reduce(0, +)
                           let sumOfTemperature = data.lazy.compactMap { $0.Temperature }
                               .reduce(0, +)
                           let sumOfVOC = data.lazy.compactMap { $0.VOC }
                               .reduce(0, +)
                           let sumOfRadon = data.lazy.compactMap { $0.Radon }
                               .reduce(0, +)

                           let pollutantValue = RealmPollutantValuesTBL.init()
                           pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
                           pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
                           pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
                           pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
                           pollutantValue.VOC = sumOfVOC/Float(groupValCount)
                           pollutantValue.Radon = sumOfRadon/Float(groupValCount)
                           pollutantValue.date = self.getHourDateFormatter(datestr: i)
                           pollutantValue.onlyDate = i
                           if index == 0{
                               pollutantValue.dummyValue = -12345
                           }else{
                               pollutantValue.dummyValue = -123456
                           }
                           pollutantValues.append(pollutantValue)
                       }
                       else{
                           let pollutantValue = RealmPollutantValuesTBL.init()
                           pollutantValue.AirPressure = 0
                           pollutantValue.CO2 = 0
                           pollutantValue.Humidity = 0
                           pollutantValue.Temperature = 0
                           pollutantValue.VOC = 0
                           pollutantValue.Radon = 0
                           pollutantValue.date = self.getHourDateFormatter(datestr: i)
                           pollutantValue.onlyDate = i
                           pollutantValue.dummyValue = -1000
                           pollutantValues.append(pollutantValue)
                       }
                   }
                   index += 1
               }
               
               pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
               
//        var index = 0
//
//        for i in arrayVal{
//            //debugPrint(i)
//            if pollutantValues.contains(where: { $0.onlyDate == i}) {
//                // found
//            } else {
//
//                if pollutantValues.count == 168{
//                    break
//                }
//
//                if index == 0 || index == arrayVal.count - 1{
//
//                    let groupValCount = data.count
//                    let sumOfAirPressure = data.lazy.compactMap { $0.AirPressure }
//                        .reduce(0, +)
//                    let sumOfCO2 = data.lazy.compactMap { $0.CO2 }
//                        .reduce(0, +)
//                    let sumOfHumidity = data.lazy.compactMap { $0.Humidity }
//                        .reduce(0, +)
//                    let sumOfTemperature = data.lazy.compactMap { $0.Temperature }
//                        .reduce(0, +)
//                    let sumOfVOC = data.lazy.compactMap { $0.VOC }
//                        .reduce(0, +)
//                    let sumOfRadon = data.lazy.compactMap { $0.Radon }
//                        .reduce(0, +)
//
//                    let pollutantValue = RealmPollutantValuesTBL.init()
//                    pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
//                    pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
//                    pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
//                    pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
//                    pollutantValue.VOC = sumOfVOC/Float(groupValCount)
//                    pollutantValue.Radon = sumOfRadon/Float(groupValCount)
//                    var dateTemp = i
//                    dateTemp.removeLast(2)
//                    pollutantValue.date = self.getDateFromString(strDate: dateTemp).toLocalTime()
//                    pollutantValue.onlyDate = i
//                    if index == 0{
//                        pollutantValue.dummyValue = -12345
//                    }else{
//                        pollutantValue.dummyValue = -123456
//                    }
//                    pollutantValues.append(pollutantValue)
//                }
//                else{
//                    let pollutantValue = RealmPollutantValuesTBL.init()
//                    pollutantValue.AirPressure = 0
//                    pollutantValue.CO2 = 0
//                    pollutantValue.Humidity = 0
//                    pollutantValue.Temperature = 0
//                    pollutantValue.VOC = 0
//                    pollutantValue.Radon = 0
//                    pollutantValue.date = Date()
//                    pollutantValue.onlyDate = i
//                    pollutantValue.dummyValue = -1000
//                    pollutantValues.append(pollutantValue)
//                }
//
//            }
//
//            index += 1
//        }
        
        pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
        
        var indexVal = 1
        for value in pollutantValues{
            if value.dummyValue == -12345{
                value.LogIndex = -1
            }else if value.dummyValue == -123456{
                value.LogIndex = pollutantValues.count
            }else{
                value.LogIndex = indexVal
                indexVal+=1
            }
        }
        
//        self.performUnitConversionIfAny(values: pollutantValues)
        // average
        
        
        let data1 = realm.objects(RealmPollutantValuesTBL.self).filter("LogIndex != -1 AND Device_ID == \(deviceID) AND date BETWEEN {%@, %@}", weekstart.toLocalTime(), endDate.toLocalTime())
        let radonAverage = (data1.lazy.compactMap{$0.Radon}.reduce(0, +))/Float(data1.count)
        let temperatureAverage = (data1.lazy.compactMap{$0.Temperature}.reduce(0, +))/Float(data1.count)
        let humidityAverage = (data1.lazy.compactMap{$0.Humidity}.reduce(0, +))/Float(data1.count)
        let vocAverage = (data1.lazy.compactMap{$0.VOC}.reduce(0, +))/Float(data1.count)
        let co2Average = (data1.lazy.compactMap{$0.CO2}.reduce(0, +))/Float(data1.count)
        let airPresssureAverage = (data1.lazy.compactMap{$0.AirPressure}.reduce(0, +))/Float(data1.count)
        
        let averageData = AverageValues.init(radonAverage: radonAverage, vocAverage: vocAverage, co2Average: co2Average, humidityAverage: humidityAverage, airPressureAverage: airPresssureAverage, temperatureAverage: temperatureAverage)
        
        if data.count == 0{
            return ([], averageData)
        }
        return (pollutantValues, averageData)
    }
    
    
    func getGroupFromDate( newDate: Date, deviceID: String)->SevenDaysEnum{
        
        let date = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: newDate, deviceId: Int(deviceID) ?? 0)
        
        let utc = TimeZone(identifier: "UTC")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc ?? TimeZone.init(secondsFromGMT: 0)!
        
        let Am12Start = DateComponents(calendar: calendar, hour:00)
        let Am12End   = DateComponents(calendar: calendar, hour:03, minute : 59)
        
        let Am4Start = DateComponents(calendar: calendar, hour:04)
        let Am4End   = DateComponents(calendar: calendar, hour:07, minute: 59)
        
        let Am8Start = DateComponents(calendar: calendar, hour:08)
        let Am8End   = DateComponents(calendar: calendar, hour:11, minute: 59)
        
        let Pm12Start = DateComponents(calendar: calendar, hour:12)
        let Pm12End   = DateComponents(calendar: calendar, hour:15, minute: 59)
        
        let Pm4Start = DateComponents(calendar: calendar, hour:16)
        let Pm4End   = DateComponents(calendar: calendar, hour:19, minute: 59)
        
        let Pm8Start = DateComponents(calendar: calendar, hour:20)
        let Pm8End   = DateComponents(calendar: calendar, hour:23, minute: 59)
        
        let startOfToday = calendar.startOfDay(for: date)
        
        let startTime1   = calendar.date(byAdding: Am12Start, to: startOfToday)!
        let endTime1      = calendar.date(byAdding: Am12End, to: startOfToday)!
        
        let startTime2   = calendar.date(byAdding: Am4Start, to: startOfToday)!
        let endTime2      = calendar.date(byAdding: Am4End, to: startOfToday)!
        
        let startTime3   = calendar.date(byAdding: Am8Start, to: startOfToday)!
        let endTime3      = calendar.date(byAdding: Am8End, to: startOfToday)!
        
        let startTime4   = calendar.date(byAdding: Pm12Start, to: startOfToday)!
        let endTime4      = calendar.date(byAdding: Pm12End, to: startOfToday)!
        
        let startTime5   = calendar.date(byAdding: Pm4Start, to: startOfToday)!
        let endTime5      = calendar.date(byAdding: Pm4End, to: startOfToday)!
        
        let startTime6   = calendar.date(byAdding: Pm8Start, to: startOfToday)!
        let endTime6      = calendar.date(byAdding: Pm8End, to: startOfToday)!
        
        if startTime1 <= date && date <= endTime1 {
//            print("between 12 AM and 6:00 AM")
            return .AM12
        }else if startTime2 <= date && date <= endTime2 {
//            print("between 6 AM and 12 PM")
           return .AM4
        }
        else if startTime3 <= date && date <= endTime3 {
//            print("between 12 PM and 6 PM")
            return .AM8
        }
        else if startTime4 <= date && date <= endTime4 {
//            print("between 6 PM and 12 AM")
             return .PM12
        }
        else if startTime5 <= date && date <= endTime5 {
//            print("between 6 PM and 12 AM")
             return .PM4
        }
        else if startTime6 <= date && date <= endTime6 {
//            print("between 6 PM and 12 AM")
             return .PM8
        }
        
        return .unknown
    }
    

    func getRealMPollutantValues1MonthFiltered( deviceID: String, endDate: Date)->  (array: [RealmPollutantValuesTBL], average: AverageValues){
//        let weekstart: Date = {
//            let components = DateComponents()
//            return Calendar.current.date(byAdding: components, value: -30, to: endDate)
//        }()
        let weekstart = Calendar.current.date(byAdding: .day, value: -30, to: endDate)
        
        
//        let startDateToFetch = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: weekstart?.toLocalTime() ?? Date(), deviceId: Int(deviceID) ?? 0)
//        let endDateToFetch = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: endDate.toLocalTime(), deviceId: Int(deviceID) ?? 0)
        
        let startDateToFetch = weekstart?.toLocalTime()
        let endDateToFetch = endDate.toLocalTime()
        
        
        //debugPrint("startDateToFetch \(startDateToFetch)")
        //debugPrint("endDateToFetch \(endDateToFetch)")
        
        let data = realm.objects(RealmPollutantValuesTBL.self).filter("LogIndex != -1 AND Device_ID == \(deviceID) AND date BETWEEN {%@, %@}", startDateToFetch, endDateToFetch).sorted(byKeyPath: "date", ascending: false)
        var pollutantValues: [RealmPollutantValuesTBL] = []
        
        
        var groupedItems = Dictionary<String, [RealmPollutantValuesTBL]>.init()
               
                // this is for finding missing  values
                let dateArrayVal : [String] = Date.getDates(forLastNDays: 30)
                var arrayVal : [String] = []
                
                var baseIndex = 0
                
                var firstIndexLevel: String = ""
                for appendVal in dateArrayVal{
                    
                    
                    for indexAm in 1...6{
                        
                        
                        if baseIndex == 0{
                            firstIndexLevel = self.getGroupFromDate(newDate: endDate.toLocalTime(), deviceID: deviceID).rawValue
                            
                            let intVal = firstIndexLevel.toInt() ?? 0
                            if intVal != nil {
                                for i in 1...intVal{
                                    arrayVal.append(String(format: "%@-%d", appendVal,i))
                                }
                            }
                            
                            
                            break
                        }
                        
                        else if baseIndex == (dateArrayVal.count - 1){
                            let intVal = firstIndexLevel.toInt() ?? 0
                            if intVal + 1 <= 6{
                                for i in (intVal+1)...6{
                                    arrayVal.append(String(format: "%@-%d", appendVal,i))
                                }
                            }
                            
                            
                            break
                        }
                        else {
                            arrayVal.append(String(format: "%@-%d", appendVal,indexAm))
                        }
                        
                    }
                    baseIndex += 1
                }
                
                arrayVal = arrayVal.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }


                for item in data{
                    //debugPrint(Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: item.date, deviceId: Int(deviceID) ?? 0))
                    //debugPrint(getGroupFromDate(newDate: item.date, deviceID: deviceID).rawValue)
                    
                    let onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: item.date, deviceId: Int(deviceID) ?? 0)))
                    let key = String.init(format: "%@-%@", onlyDate, getGroupFromDate(newDate: item.date, deviceID: deviceID).rawValue)
                    //debugPrint(key)
                    if groupedItems[key] == nil{
                        groupedItems[key] = [item]
                    }
                    else{
                         groupedItems[key]?.append(item)
                    }
                   
                }
                
                
                for i in groupedItems{
//                    //debugPrint(i)
                    var groupVal = i.value
                    groupVal = groupVal.sorted(by: { $0.timeStamp < $1.timeStamp })
                    let groupValCount = groupVal.count
                    let sumOfAirPressure = groupVal.lazy.compactMap { $0.AirPressure }
                        .reduce(0, +)
                    let sumOfCO2 = groupVal.lazy.compactMap { $0.CO2 }
                        .reduce(0, +)
                    let sumOfHumidity = groupVal.lazy.compactMap { $0.Humidity }
                        .reduce(0, +)
                    let sumOfTemperature = groupVal.lazy.compactMap { $0.Temperature }
                        .reduce(0, +)
                    let sumOfVOC = groupVal.lazy.compactMap { $0.VOC }
                        .reduce(0, +)
                    let sumOfRadon = groupVal.lazy.compactMap { $0.Radon }
                        .reduce(0, +)
                    
                    let pollutantValue = RealmPollutantValuesTBL.init()
                    pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
                    pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
                    pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
                    pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
                    pollutantValue.VOC = sumOfVOC/Float(groupValCount)
                    pollutantValue.Radon = sumOfRadon/Float(groupValCount)
                    pollutantValue.date = groupVal.last!.date
                    pollutantValue.onlyDate = i.key
        //            pollutantValue.LogIndex =
        //            if i.key == "2019/08/13-1" || i.key == "2019/08/19-4"{
        //            }else{
                        pollutantValues.append(pollutantValue)
        //            }
                
                }
                pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
                var index = 0
            
                for i in arrayVal{
//                    //debugPrint(i)
                    if pollutantValues.contains(where: { $0.onlyDate == i}) {
                        // found
                    } else {
                        
                        if pollutantValues.count == 180{
                            break
                        }
                        
                        if index == 0 || index == arrayVal.count - 1{
                            
                            let groupValCount = data.count
                            let sumOfAirPressure = data.lazy.compactMap { $0.AirPressure }
                                .reduce(0, +)
                            let sumOfCO2 = data.lazy.compactMap { $0.CO2 }
                                .reduce(0, +)
                            let sumOfHumidity = data.lazy.compactMap { $0.Humidity }
                                .reduce(0, +)
                            let sumOfTemperature = data.lazy.compactMap { $0.Temperature }
                                .reduce(0, +)
                            let sumOfVOC = data.lazy.compactMap { $0.VOC }
                                .reduce(0, +)
                            let sumOfRadon = data.lazy.compactMap { $0.Radon }
                                .reduce(0, +)
                            
                            let pollutantValue = RealmPollutantValuesTBL.init()
                            pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
                            pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
                            pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
                            pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
                            pollutantValue.VOC = sumOfVOC/Float(groupValCount)
                            pollutantValue.Radon = sumOfRadon/Float(groupValCount)
                            var dateTemp = i
                            dateTemp.removeLast(2)
                            pollutantValue.date = self.getDateFromString(strDate: dateTemp).toLocalTime()
                            pollutantValue.onlyDate = i
                            if index == 0{
                                pollutantValue.dummyValue = -12345
                            }else{
                                pollutantValue.dummyValue = -123456
                            }
                            pollutantValues.append(pollutantValue)
                        }
                        else{
                            let pollutantValue = RealmPollutantValuesTBL.init()
                            pollutantValue.AirPressure = 0
                            pollutantValue.CO2 = 0
                            pollutantValue.Humidity = 0
                            pollutantValue.Temperature = 0
                            pollutantValue.VOC = 0
                            pollutantValue.Radon = 0
                            pollutantValue.date = Date()
                            pollutantValue.onlyDate = i
                            pollutantValue.dummyValue = -1000
                            pollutantValues.append(pollutantValue)
                        }
                        
                    }
                    
                    index += 1
                }
                
                pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
        
//        var last30Days = Date.getMonthDates()
//
//        //debugPrint(data)
//
//
//        let newArray = convertOnlyDateToDeviceTimeZone(data: data)
//
//        let groupedItems = Dictionary(grouping: newArray, by: {$0.onlyDate})
//
//        for i in groupedItems{
////            //debugPrint(i)
//            let groupVal = i.value
//            let groupValCount = groupVal.count
//            let sumOfAirPressure = groupVal.lazy.compactMap { $0.AirPressure }
//                .reduce(0, +)
//            let sumOfCO2 = groupVal.lazy.compactMap { $0.CO2 }
//                .reduce(0, +)
//            let sumOfHumidity = groupVal.lazy.compactMap { $0.Humidity }
//                .reduce(0, +)
//            let sumOfTemperature = groupVal.lazy.compactMap { $0.Temperature }
//                .reduce(0, +)
//            let sumOfVOC = groupVal.lazy.compactMap { $0.VOC }
//                .reduce(0, +)
//            let sumOfRadon = groupVal.lazy.compactMap { $0.Radon }
//                .reduce(0, +)
//
//            let pollutantValue = RealmPollutantValuesTBL.init()
//            pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
//            pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
//            pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
//            pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
//            pollutantValue.VOC = sumOfVOC/Float(groupValCount)
//            pollutantValue.Radon = sumOfRadon/Float(groupValCount)
//            pollutantValue.date = self.getDateFromStringWithDeviceTime(strDate:i.key, deviceId: GlobalDeviceID)
//            //debugPrint(i.key)
//            //debugPrint(pollutantValue.date)
//            pollutantValue.onlyDate = i.key
//            pollutantValue.LogIndex = self.getDayOfYear(date: self.getDateFromString(strDate: i.key))
////            if pollutantValue.LogIndex == 202 || pollutantValue.LogIndex == 231{
////
////            }else{
//                pollutantValues.append(pollutantValue)
////            }
//
////            //debugPrint(pollutantValue.LogIndex)
////            pollutantValues.append(pollutantValue)
//
//        }
//
//        last30Days = last30Days.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
//        pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
//        var index = 0
//        for i in last30Days{
//            //debugPrint(i)
//            if pollutantValues.contains(where: { $0.onlyDate == i}) {
//                // found
//            } else {
//
//                if last30Days.count == pollutantValues.count{
//                    break // alreday all data is there, no need to check for missing data
//                }
//
//                if index == 0 || index == last30Days.count - 1{
//
//                    let groupValCount = data.count
//                    let sumOfAirPressure = data.lazy.compactMap { $0.AirPressure }
//                        .reduce(0, +)
//                    let sumOfCO2 = data.lazy.compactMap { $0.CO2 }
//                        .reduce(0, +)
//                    let sumOfHumidity = data.lazy.compactMap { $0.Humidity }
//                        .reduce(0, +)
//                    let sumOfTemperature = data.lazy.compactMap { $0.Temperature }
//                        .reduce(0, +)
//                    let sumOfVOC = data.lazy.compactMap { $0.VOC }
//                        .reduce(0, +)
//                    let sumOfRadon = data.lazy.compactMap { $0.Radon }
//                        .reduce(0, +)
//
//                    let pollutantValue = RealmPollutantValuesTBL.init()
//                    pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
//                    pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
//                    pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
//                    pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
//                    pollutantValue.VOC = sumOfVOC/Float(groupValCount)
//                    pollutantValue.Radon = sumOfRadon/Float(groupValCount)
//                    pollutantValue.date = self.getDateFromDateTime(date: self.getDateFromString(strDate: i))
//                    pollutantValue.onlyDate = i
//                    if index == 0{
//                        pollutantValue.dummyValue = -12345
//                    }else{
//                        pollutantValue.dummyValue = -123456
//                    }
//                    pollutantValues.append(pollutantValue)
//                }
//                else{
//                    let pollutantValue = RealmPollutantValuesTBL.init()
//                    pollutantValue.AirPressure = 0
//                    pollutantValue.CO2 = 0
//                    pollutantValue.Humidity = 0
//                    pollutantValue.Temperature = 0
//                    pollutantValue.VOC = 0
//                    pollutantValue.Radon = 0
//                    pollutantValue.date = self.getDateFromDateTime(date: self.getDateFromString(strDate: i))
//                    pollutantValue.onlyDate = i
////                    pollutantValue.LogIndex = self.getDayOfYear(date: self.getDateFromString(strDate: i))
//                    pollutantValue.dummyValue = -1000
//                    pollutantValues.append(pollutantValue)
//                }
//            }
//
//            index += 1
//        }
//        pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
        var indexVal = 1
        for value in pollutantValues{
            if value.dummyValue == -12345{
                value.LogIndex = -1
            }else if value.dummyValue == -123456{
                value.LogIndex = pollutantValues.count
            }else{
                value.LogIndex = indexVal
                indexVal+=1
            }
        }
//        self.performUnitConversionIfAny(values: pollutantValues)
        // average
        let radonAverage = (data.lazy.compactMap{$0.Radon}.reduce(0, +))/Float(data.count)
        let temperatureAverage = (data.lazy.compactMap{$0.Temperature}.reduce(0, +))/Float(data.count)
        let humidityAverage = (data.lazy.compactMap{$0.Humidity}.reduce(0, +))/Float(data.count)
        let vocAverage = (data.lazy.compactMap{$0.VOC}.reduce(0, +))/Float(data.count)
        let co2Average = (data.lazy.compactMap{$0.CO2}.reduce(0, +))/Float(data.count)
        let airPresssureAverage = (data.lazy.compactMap{$0.AirPressure}.reduce(0, +))/Float(data.count)
        
        let averageData = AverageValues.init(radonAverage: radonAverage, vocAverage: vocAverage, co2Average: co2Average, humidityAverage: humidityAverage, airPressureAverage: airPresssureAverage, temperatureAverage: temperatureAverage)
        
        if data.count == 0{
            return ([], averageData)
        }
        return (pollutantValues, averageData)
    }
    
    func convertOnlyDateToDeviceTimeZone(data: Results<RealmPollutantValuesTBL>)-> [RealmPollutantValuesTBL]{
        var array:[RealmPollutantValuesTBL] = []
        for item in data{
            let pollutantValue = RealmPollutantValuesTBL.init()
            pollutantValue.AirPressure = item.AirPressure
            pollutantValue.CO2 =  item.CO2
            pollutantValue.Humidity =  item.Humidity
            pollutantValue.Temperature =  item.Temperature
            pollutantValue.VOC =  item.VOC
            pollutantValue.Radon =  item.Radon
            pollutantValue.date =  Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: item.date, deviceId: GlobalDeviceID)
            pollutantValue.LogIndex = item.LogIndex
            pollutantValue.auto_id = item.auto_id
            pollutantValue.device_SerialID = item.device_SerialID
            pollutantValue.Device_ID = item.Device_ID
            pollutantValue.isWifi = item.isWifi
            pollutantValue.dummyValue = item.dummyValue
            pollutantValue.timeStamp = item.timeStamp
            pollutantValue.WeekValue = item.WeekValue
            let convertedDate =  Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: item.date, deviceId: GlobalDeviceID)
            pollutantValue.onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: convertedDate))
            array.append(pollutantValue)
        }
        
        return array
    }
    
    func convertWeekValueToDeviceTimeZone(data: Results<RealmPollutantValuesTBL>)-> [RealmPollutantValuesTBL]{
        var array:[RealmPollutantValuesTBL] = []
        for item in data{
            let pollutantValue = RealmPollutantValuesTBL.init()
            pollutantValue.AirPressure = item.AirPressure
            pollutantValue.CO2 =  item.CO2
            pollutantValue.Humidity =  item.Humidity
            pollutantValue.Temperature =  item.Temperature
            pollutantValue.VOC =  item.VOC
            pollutantValue.Radon =  item.Radon
            pollutantValue.date =  item.date
            pollutantValue.LogIndex = item.LogIndex
            pollutantValue.auto_id = item.auto_id
            pollutantValue.device_SerialID = item.device_SerialID
            pollutantValue.Device_ID = item.Device_ID
            pollutantValue.isWifi = item.isWifi
            pollutantValue.dummyValue = item.dummyValue
            pollutantValue.timeStamp = item.timeStamp
            //pollutantValue.WeekValue = item.WeekValue
            let convertedDate =  Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: item.date, deviceId: GlobalDeviceID)
            pollutantValue.WeekValue = String.init(format: "%d", Helper.shared.getDayBy2OfYear(date: Helper.shared.getDateFromDateTime(dateStr: Helper.shared.convertDateToString(date: convertedDate))))
            pollutantValue.onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: convertedDate))
            array.append(pollutantValue)
        }
        
        return array
    }
    
    func getRealMPollutantValues1YearFiltered( deviceID: String, endDate: Date)->  (array: [RealmPollutantValuesTBL], average: AverageValues){
        
        guard let arrayVal1:[WeekWithDateStruct] = Date.getWeekDates(forLastNDays: 182) else {
            let averageData = AverageValues.init(radonAverage: 0.0, vocAverage: 0.0, co2Average: 0.0, humidityAverage: 0.0, airPressureAverage: 0.0, temperatureAverage: 0.0)
            return ([], averageData)
        }

        var arrayVal:[WeekWithDateStruct] = []
        arrayVal.removeAll()
        arrayVal.append(contentsOf: arrayVal1)
        let weekstart: Date = {
            let components = DateComponents(day: -364)
            //            let components = DateComponents(day: -, second: 0)
            return Calendar.current.date(byAdding: components, to: endDate)!
        }()
        
//        let startDateToFetch = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: weekstart.toLocalTime(), deviceId: Int(deviceID) ?? 0)
//        let endDateToFetch = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: endDate.toLocalTime(), deviceId: Int(deviceID) ?? 0)
        
        let startDateToFetch = weekstart.toLocalTime()
        let endDateToFetch = endDate.toLocalTime()
        
        
        //debugPrint("startDateToFetch \(startDateToFetch)")
        //debugPrint("endDateToFetch \(endDateToFetch)")
        
        
        let data = realm.objects(RealmPollutantValuesTBL.self).filter("LogIndex != -1 AND Device_ID == \(deviceID) AND date BETWEEN {%@, %@}", startDateToFetch, endDateToFetch).sorted(byKeyPath: "date", ascending: false)
        var pollutantValues: [RealmPollutantValuesTBL] = []
        
        let newArray = convertWeekValueToDeviceTimeZone(data: data)
        
        let groupedItems = Dictionary(grouping: newArray, by: {$0.WeekValue})
        for i in groupedItems{
            //debugPrint(i.key)
            let groupVal = i.value
            let groupValCount = groupVal.count
            let sumOfAirPressure = groupVal.lazy.compactMap { $0.AirPressure }
                .reduce(0, +)
            let sumOfCO2 = groupVal.lazy.compactMap { $0.CO2 }
                .reduce(0, +)
            let sumOfHumidity = groupVal.lazy.compactMap { $0.Humidity }
                .reduce(0, +)
            let sumOfTemperature = groupVal.lazy.compactMap { $0.Temperature }
                .reduce(0, +)
            let sumOfVOC = groupVal.lazy.compactMap { $0.VOC }
                .reduce(0, +)
            let sumOfRadon = groupVal.lazy.compactMap { $0.Radon }
                .reduce(0, +)
            
            let pollutantValue = RealmPollutantValuesTBL.init()
            pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
            pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
            pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
            pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
            pollutantValue.VOC = sumOfVOC/Float(groupValCount)
            pollutantValue.Radon = sumOfRadon/Float(groupValCount)
            pollutantValue.date = groupVal[0].date
            pollutantValue.onlyDate = groupVal[0].onlyDate
            pollutantValue.WeekValue = i.key
            pollutantValues.append(pollutantValue)
            
        }
        arrayVal = arrayVal.sorted(by: {$0.dateString < $1.dateString})
        
        pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
        var index = 0
        for i in arrayVal{
            if pollutantValues.contains(where: { $0.WeekValue == i.weekNumber}) {
            }
            else{
                
                if pollutantValues.count == 182{
                    break
                }
                
                if index == 0 || index == arrayVal.count - 1{
                    
                    let groupValCount = data.count
                    let sumOfAirPressure = data.lazy.compactMap { $0.AirPressure }
                        .reduce(0, +)
                    let sumOfCO2 = data.lazy.compactMap { $0.CO2 }
                        .reduce(0, +)
                    let sumOfHumidity = data.lazy.compactMap { $0.Humidity }
                        .reduce(0, +)
                    let sumOfTemperature = data.lazy.compactMap { $0.Temperature }
                        .reduce(0, +)
                    let sumOfVOC = data.lazy.compactMap { $0.VOC }
                        .reduce(0, +)
                    let sumOfRadon = data.lazy.compactMap { $0.Radon }
                        .reduce(0, +)
                    
                    let pollutantValue = RealmPollutantValuesTBL.init()
                    pollutantValue.AirPressure = sumOfAirPressure/Float(groupValCount)
                    pollutantValue.CO2 = sumOfCO2/Float(groupValCount)
                    pollutantValue.Humidity = sumOfHumidity/Float(groupValCount)
                    pollutantValue.Temperature = sumOfTemperature/Float(groupValCount)
                    pollutantValue.VOC = sumOfVOC/Float(groupValCount)
                    pollutantValue.Radon = sumOfRadon/Float(groupValCount)
                    pollutantValue.date = self.getDateFromString(strDate: i.dateString)
                    pollutantValue.onlyDate = i.dateString
                    if index == 0{
                        pollutantValue.dummyValue = -12345
                    }else{
                        pollutantValue.dummyValue = -123456
                    }
                    pollutantValues.append(pollutantValue)
                }
                else{
                    let pollutantValue = RealmPollutantValuesTBL.init()
                    pollutantValue.AirPressure = 0
                    pollutantValue.CO2 = 0
                    pollutantValue.Humidity = 0
                    pollutantValue.Temperature = 0
                    pollutantValue.VOC = 0
                    pollutantValue.Radon = 0
                    pollutantValue.date = self.getDateFromDateTime(date: self.getDateFromString(strDate: i.dateString))
                    pollutantValue.onlyDate = i.dateString
                    pollutantValue.dummyValue = -1000
                    pollutantValue.WeekValue = i.weekNumber
                    pollutantValues.append(pollutantValue)
                }
                
                
            }
             index += 1
        }
        
        pollutantValues = pollutantValues.sorted(by: { $0.onlyDate < $1.onlyDate })
        var indexVal = 1
        for value in pollutantValues{
            if value.dummyValue == -12345{
                value.LogIndex = -1
            }else if value.dummyValue == -123456{
                value.LogIndex = pollutantValues.count
            }else{
                value.LogIndex = indexVal
                indexVal+=1
            }
        }
//        self.performUnitConversionIfAny(values: pollutantValues)
        // average
        let radonAverage = (data.lazy.compactMap{$0.Radon}.reduce(0, +))/Float(data.count)
        let temperatureAverage = (data.lazy.compactMap{$0.Temperature}.reduce(0, +))/Float(data.count)
        let humidityAverage = (data.lazy.compactMap{$0.Humidity}.reduce(0, +))/Float(data.count)
        let vocAverage = (data.lazy.compactMap{$0.VOC}.reduce(0, +))/Float(data.count)
        let co2Average = (data.lazy.compactMap{$0.CO2}.reduce(0, +))/Float(data.count)
        let airPresssureAverage = (data.lazy.compactMap{$0.AirPressure}.reduce(0, +))/Float(data.count)
        
        let averageData = AverageValues.init(radonAverage: radonAverage, vocAverage: vocAverage, co2Average: co2Average, humidityAverage: humidityAverage, airPressureAverage: airPresssureAverage, temperatureAverage: temperatureAverage)
        if data.count == 0{
            return ([], averageData)
        }
        return (pollutantValues, averageData)
    }
    
    func performUnitConversionIfAny(values: [RealmPollutantValuesTBL]){
        var tempUserData  = AppSession.shared.getMobileUserMeData()
        if tempUserData?.pressureUnitTypeId == 1 || tempUserData?.pressureUnitTypeId == 0 || tempUserData?.pressureUnitTypeId == nil{
            for item in values{
                item.AirPressure = item.AirPressure * 3.38639 // hg to kPa cpnversion
            }
        }
        
    }
    
    func getDayOfYear(date:Date)-> Int{
//        let cal = Calendar.current
        let utc = TimeZone(identifier: "UTC")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc ?? TimeZone.init(secondsFromGMT: 0)!
        
        let day = calendar.ordinality(of: .day, in: .year, for: date)
//        //debugPrint("Day number :\(day)")
        return day ?? 0
    }
    
    func getWeekOfYear(date:Date)-> Int{
        let cal = Calendar.current
        let day = cal.ordinality(of: .weekOfYear, in: .year, for: date)
//        //debugPrint("Day number :\(day)")
        return day ?? 0
    }
    
    func getDateFromDateTime(date: Date)-> Date{
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return  Calendar.current.date(from: components)!
    }
    
    func getDateFromString(strDate:String) -> Date{
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        let date = dateFormatter.date(from: strDate)
        return date?.toLocalTime() ?? Date()
    }
    
    func getDateFromStringWithDeviceTime(strDate:String, deviceId: Int) -> Date{
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        let date = dateFormatter.date(from: strDate)
        
        return Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: date?.toLocalTime() ?? Date(), deviceId: deviceId)
    }
    
    func getDateStringFromDateTime(dateStr: String)-> String{
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'" //Your date format
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        if date == nil {
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let date1 = dateFormatter.date(from: dateStr)
            if date1 == nil{
                return ""
            }else {
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let newDateString = dateFormatter.string(from: date1!)
                
                return newDateString
            }
        }
        //Convert String to Date
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let newDateString = dateFormatter.string(from: date!)
        
        return newDateString
    }
    
    func getHourDateFormatter(datestr: String)-> Date{
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy/MM/dd HH" //Your date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        var newDateString = dateFormatter.date(from: datestr) ?? Date()//according to date format your date string
        return newDateString
    }
    func getTimeFromFullDate(date: Date)-> String{
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?//Your date format
        var newDateString = dateFormatter.string(from: date)//according to date format your date string
        newDateString = self.luftMateFullDateFormat(dateStr: newDateString)
        return newDateString
    }
    func luftMateFullDateFormat(dateStr:String) -> String
    {
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?//Your date format
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        if date == nil {
            dateFormatter.dateFormat = "yyyy/MM/dd HH"
            let date1 = dateFormatter.date(from: dateStr)
            if date1 == nil{
                return ""
            }else {
                dateFormatter.dateFormat = "yyyy/MM/dd HH"
                let newDateString = dateFormatter.string(from: date1!)
                
                return newDateString
            }
        }
        //Convert String to Date
        dateFormatter.dateFormat = "yyyy/MM/dd HH"
        let newDateString = dateFormatter.string(from: date!)
        
        return newDateString
    }
    func getDateFromDateTime(dateStr: String)-> Date{
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'" //Your date format
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        return date ?? Date()
    }
  
    
    func populateRealMdataFromJson(){
        
        let realm = try! Realm()
        //        realm.deleteAll()
        if let path = Bundle.main.path(forResource: "ColorSettings", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["ColorSettings"] as? [Any] {
                    // do stuff
                    for item in person{
                        var item1 = item as? Dictionary<String, AnyObject>
                        var obj = item1?["properties"] as? Dictionary<String, AnyObject>
                        
                        try! realm.write {
                            realm.create(ColorSettings.self, value: obj, update: .error)
                        }
//                        //debugPrint(obj)
                    }
                }
            } catch {
                // handle error
            }
        }
        
        if let path = Bundle.main.path(forResource: "DeviceDetails", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["DeviceDetails"] as? [Any] {
                    // do stuff
                    for item in person{
                        var item1 = item as? Dictionary<String, AnyObject>
                        var obj = item1?["properties"] as? Dictionary<String, AnyObject>
                        
                        try! realm.write {
                            realm.create(DeviceDetailsJson.self, value: obj, update: .error)
                        }
//                        //debugPrint(obj)
                    }
                }
            } catch {
                // handle error
            }
        }
        
        if let path = Bundle.main.path(forResource: "DeviceSettings", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["DeviceSettings"] as? [Any] {
                    // do stuff
                    for item in person{
                        var item1 = item as? Dictionary<String, AnyObject>
                        var obj = item1?["properties"] as? Dictionary<String, AnyObject>
                        
                        try! realm.write {
                            realm.create(DeviceSettings.self, value: obj, update: .error)
                        }
//                        //debugPrint(obj)
                    }
                }
            } catch {
                // handle error
            }
        }
        
        if let path = Bundle.main.path(forResource: "PollutantUnits", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["PollutantUnits"] as? [Any] {
                    // do stuff
                    for item in person{
                        var item1 = item as? Dictionary<String, AnyObject>
                        var obj = item1?["properties"] as? Dictionary<String, AnyObject>
                        
                        try! realm.write {
                            realm.create(PollutantUnits.self, value: obj, update: .error)
                        }
                        //debugPrint(obj)
                    }
                }
            } catch {
                // handle error
            }
        }
        
        if let path = Bundle.main.path(forResource: "PollutantValues2", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult1 = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                for var item in (jsonResult1 as? [[String: Any]])!{
                    
                    let rfc3339DateFormatter = DateFormatter()
                    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
                    rfc3339DateFormatter.locale = enUSPOSIXLocale
                    rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
                    rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let date: Date?
                    if let value = item["date"] as? String {
                        item["onlyDate"] = self.getDateStringFromDateTime(dateStr: value)
                        item["WeekValue"] = String.init(format: "%d", self.getWeekOfYear(date: getDateFromDateTime(dateStr: value)))
                        date = rfc3339DateFormatter.date(from: value)
                    } else {
                        date = nil
                    }
                    item["date"] = date
                    
                    try! realm.write {
                        realm.create(PollutantValues.self, value: item, update: .error)
                    }
//                    //debugPrint(item)
                }
                

            } catch {
                // handle error
            }
        }
        
        if let path = Bundle.main.path(forResource: "UserDetails", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["UserDetails"] as? [Any] {
                    // do stuff
                    for item in person{
                        var item1 = item as? Dictionary<String, AnyObject>
                        let obj = item1?["properties"] as? Dictionary<String, AnyObject>
                        
                        try! realm.write {
                            realm.create(UserDetailsJson.self, value: obj, update: .error)
                        }
//                        //debugPrint(obj)
                    }
                }
            } catch {
                // handle error
            }
        }
        
    }
    
    func getMinutesFromDateLocal(date: Date)->Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let dateString = dateFormatter.string(from: date)
        return dateString.toInt() ?? 0
    }
    
    func getHoursFromDateLocal(date: Date)->Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let dateString = dateFormatter.string(from: date)
        return dateString.toInt() ?? 0
    }
    
    func getMinutesFromDate(date: Date)->Int{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        dateFormatter.dateFormat = "mm"
        let dateString = dateFormatter.string(from: date)
        
        return dateString.toInt() ?? 0
    }
    
    func getHoursFromDate(date: Date)->Int{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        dateFormatter.dateFormat = "HH"
        let dateString = dateFormatter.string(from: date)
        
        return dateString.toInt() ?? 0
    }
   
    func getAllDeviceWifiStatus() -> Bool {
        let deviceAllData = realm.objects(RealmDeviceList.self)
        let realm = try! Realm()
        if deviceAllData.count != 0 {
            let deviceListFilteredList = Array(realm.objects(RealmDeviceList.self).filter({ $0.wifi_status == false}))
            if deviceListFilteredList.count != 0 {
               return true
            }
        }
       return false
    }
}


extension RealmDataManager {
    
    func nextColorSettingId() -> Int {
        return (self.realm.objects(RealmColorSetting.self).map{$0.auto_id}.max() ?? 0) + 1
    }
    
    
    func nextThresHoldId() -> Int {
        return (self.realm.objects(RealmThresHoldSetting.self).map{$0.auto_id}.max() ?? 0) + 1
    }
    
    
    func nextDeviceListId() -> Int {
        return (self.realm.objects(RealmDeviceList.self).map{$0.auto_id}.max() ?? 0) + 1
    }
    
    func nextPollutantListId() -> Int {
        let randomInt = Int.random(in:0..<900)
        let pollutantFilteredList = Array(realm.objects(RealmPollutantValuesTBL.self).filter({ $0.auto_id == randomInt}))
        if pollutantFilteredList.count != 0 {
           self.nextPollutantListId()
        }
        return randomInt
    }
    
    func nextDummyDeviceListId() -> Int {
        return (self.realm.objects(RealmDummyDeviceList.self).map{$0.auto_id}.max() ?? 0) + 1
    }
}
extension Date {
    static func getDates(forLastNDays nDays: Int) -> [String] {
        let cal = NSCalendar.current
//        // start with today
//        let dayVal = Date()
//        var date = dayVal//cal.startOfDay(for: dayVal)
//
        var arrDates = [String]()
//
//        for _ in 1 ... nDays {
//            // move back in time by one day:
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy/MM/dd"
//            let dateString = dateFormatter.string(from: date)
//            arrDates.append(dateString)
//
//            date = cal.date(byAdding: Calendar.Component.hour, value: -24, to: date)!
//
//
//        }
//        print(arrDates)
//        return arrDates
//
        
        var date = cal.date(byAdding: Calendar.Component.hour, value: -(nDays * 24), to: Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: Date().toLocalTime(), deviceId: GlobalDeviceID))! // first date
        let endDate = Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: Date().toLocalTime(), deviceId: GlobalDeviceID) // last date
        
        // Formatter for printing the date, adjust it according to your needs:
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy/MM/dd"
        
        while date <= endDate {
            print(fmt.string(from: date))
            let dateString = fmt.string(from: date)
            arrDates.append(dateString)
            date = cal.date(byAdding: .day, value: 1, to: date)!
            
        }
//        //debugPrint(arrDates.reversed())
        return arrDates.reversed()
    }
    
    static func getMonthDates() -> [String] {
        let cal = NSCalendar.current
        var arrDates = [String]()
        
        
        var date = cal.date(byAdding: Calendar.Component.day, value: -30, to: Date().toLocalTime())! // first date
        let endDate = Date().toLocalTime() // last date
        
        // Formatter for printing the date, adjust it according to your needs:
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy/MM/dd"
        
        while date <= endDate {
            print(fmt.string(from: date))
            let dateString = fmt.string(from: date)
            arrDates.append(dateString)
            date = cal.date(byAdding: .day, value: 1, to: date)!
            
        }
//        //debugPrint(arrDates.reversed())
        return arrDates.reversed()
    }
    
    
    static func getLast24Hours(forLastNDays nDays: Int, endDate: Date, isBefore: Bool = false) -> [String] {
        var cal = NSCalendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        // start with today
        let dayVal = endDate
        var date = dayVal//cal.startOfDay(for: dayVal)
        
        
        var arrDates = [String]()
        
        for _ in 1 ... nDays {
            // move back in time by one day:
            
            if isBefore == true{
                 date = cal.date(byAdding: Calendar.Component.hour, value: -1, to: date)!
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
            dateFormatter.dateFormat = "yyyy/MM/dd HH"
            let dateString = dateFormatter.string(from: date)
            
            if isBefore == false{
                date = cal.date(byAdding: Calendar.Component.hour, value: -1, to: date)!
            }

            
            
            arrDates.append(dateString)
        }
        return arrDates
    }
    
   
    static func getWeekDates(forLastNDays nDays: Int) -> [WeekWithDateStruct]? {
        //let cal = NSCalendar.current
        // start with today
        let dayVal = Date()
        var date = dayVal//cal.startOfDay(for: dayVal)
        
        var arrDates:[WeekWithDateStruct] = []
        
        var isEven: Bool = false
        var cal = Calendar.current
        cal.timeZone =  TimeZone(abbreviation: "UTC")!
        
        if let day = cal.ordinality(of: .day, in: .year, for: date){
            if (day ?? 0)%2 == 0{
                isEven = true
            }
            else{
                isEven = false
            }
        }
        
        for _ in 1 ... nDays {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            dateFormatter.timeZone =  TimeZone(abbreviation: "UTC")!
            let dateString = dateFormatter.string(from: date)
           
            let day = cal.ordinality(of: .day, in: .year, for: date)
//            //debugPrint("Week number :\(String(describing: day))")
            let dayValue = (day ?? 0)/2
            let dayNumberHlf = String(format: "%d", (day ?? 0)/2)
            
            if isEven{
                var dayNumberHlf = ""
                if dayValue - 1 < 0{
                    dayNumberHlf = String(format: "%d", 182)
                }
                else{
                    dayNumberHlf = String(format: "%d", dayValue - 1)
                }
                arrDates.append(WeekWithDateStruct(weekNumber: dayNumberHlf, dateString: dateString))
            }
            else{
                arrDates.append(WeekWithDateStruct(weekNumber: dayNumberHlf, dateString: dateString))
            }
            
//            //debugPrint("Date number :\(String(describing: dateString))")
            // move back in time by one day:
            
            if (day ?? 0)%2 == 0{
                date = cal.date(byAdding: Calendar.Component.day, value: -2, to: date)!
            }
            else{
                date = cal.date(byAdding: Calendar.Component.day, value: -1, to: date)!
            }
            
        }
        
        if let xy:[WeekWithDateStruct] = arrDates as? [WeekWithDateStruct]  {
            return xy
        }else {
            arrDates.removeAll()
            return arrDates
        }
    }
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone(abbreviation: "UTC")
        let seconds = -TimeInterval(timezone!.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone(abbreviation: "UTC")
        let seconds = TimeInterval(timezone!.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func toCurrentLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}


