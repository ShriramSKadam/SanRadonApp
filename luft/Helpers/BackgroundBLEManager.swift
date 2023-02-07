//
//  BackgroundBLEManager.swift
//  luft
//
//  Created by iMac Augusta on 11/6/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import CoreData
import CoreBluetooth
import Realm
import RealmSwift



protocol CurrentLogIndexDelegate:class {
    func getBluetoothCurrentIndexLogData(isConnectedBLE:Bool)
}

protocol BLEBackGroudLogIndexDelegate:class {
    func getBLEBackGroudLogIndex(isBLEBackGroudStatus:Bool)
}

protocol BackGroundBleStateDelegate:class {
    func getBackGroundBleState(isConnectedBLEState:Bool)
}

protocol BackGroundBleSyncCompletedDelegate:class {
    func getWholebackGroundBleSyncCompletedDelegate()
}

class BackgroundBLEManager: NSObject {
    
    var strRadon: String = "0.0"
    var strVoc: String = "0.0"
    var strEco2: String = "0.0"
    var strTemp: String = "0.0"
    var strHumidity: String = "0.0"
    var strPressure: String = "0.0"
    var strConnectPeripheral: String = "LUFT"
    var strLastSyncTime: String = "0.0"
    var strDeviceSerialID: String = "0.0"
    var strDeviceID: Int = 0
    var strNotifiyStatus: String = "0.0"

    var deviceLogIndexStatusDelgate:CurrentLogIndexDelegate? = nil
    
    //New Good
    var strBlueToothName:String? = ""
    var centralManager: CBCentralManager!
    var mainPeripheral: CBPeripheral!
    var blueToothFeatureType: BlueToothFeatureType!
    var didUpdate: Int = 0
    var strDeviceToken: String = ""
    var upperBoundValue: Int = 0
    var lowerBoundValue: Int = 0
    var writeBoundValue: Int = 0
    var upperLogIndex: Int = 0
    
    var readDatasCBCharacteristic:[CBCharacteristic] = []
    var readDummyCBCharacteristic:[CBCharacteristic] = []
    
    var isBleConnectState:Bool = false
    var isBleCharacteristicsState:Bool = false
    var delegateBackGroundBleState:BackGroundBleStateDelegate? = nil
    
    var theService: CBService?
    var isFromAddDevice: Bool! = false
    
    var isBleBackGroundSyncDevice: Bool! = false
    var backGroundBleSyncCompletedDelegate:BackGroundBleSyncCompletedDelegate? = nil
    class var shared: BackgroundBLEManager {
        struct Static {
            static let instance: BackgroundBLEManager = BackgroundBLEManager()
        }
        return Static.instance
    }
    
    func connectBlueTooth(blueToothName:String,bleFeature:BlueToothFeatureType)  {
        self.strBlueToothName = blueToothName
        self.blueToothFeatureType = bleFeature
        if self.strBlueToothName != "" {
            centralManager = CBCentralManager(delegate: self, queue: nil)
            self.centralManager.delegate = self
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                if self.centralManager == nil {
                    return
                }
                if self.isBleConnectState != true {
                    textLog.write("BLE NOT CONNECT")
                    self.delegateBackGroundBleState?.getBackGroundBleState(isConnectedBLEState: false)
                    self.centralManager?.stopScan()
                    return
                }
            }
        }
    }
}
extension BackgroundBLEManager: CBCentralManagerDelegate,CBPeripheralDelegate {
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            NotificationCenter.default.post(name:.postNotifiResetDevice, object: nil, userInfo: nil)
            print("central.state is .resetting")
        case .unsupported:
            self.delegateBackGroundBleState?.getBackGroundBleState(isConnectedBLEState: false)
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            self.delegateBackGroundBleState?.getBackGroundBleState(isConnectedBLEState: false)
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if peripheral.name == self.strBlueToothName{
            mainPeripheral = peripheral
            mainPeripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(mainPeripheral)
            self.isBleConnectState = true
            self.isBleCharacteristicsState = true
            self.deviceLogIndexStatusDelgate?.getBluetoothCurrentIndexLogData(isConnectedBLE:true)
                print("Hide 15")
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                if self.centralManager == nil {
                    return
                }
                if self.isBleConnectState == true {
                    textLog.write("BLE VIA - self.isBleConnectState")
                }else {
                    self.delegateBackGroundBleState?.getBackGroundBleState(isConnectedBLEState: false)
                    self.centralManager?.stopScan()
                    return
                }
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
       
        if self.blueToothFeatureType == .BlueToothFeatureLogCurrentIndexWrite {
            if self.isFromAddDevice == true {
                self.delegateBackGroundBleState?.getBackGroundBleState(isConnectedBLEState: true)
            }else {
                
            }
        }
        mainPeripheral.discoverServices([])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Not Connected!")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if self.blueToothFeatureType == .BlueToothFeatureLogCurrentIndexWrite{
            self.delegateBackGroundBleState?.getBackGroundBleState(isConnectedBLEState: false)
                   self.centralManager?.stopScan()
                   print("Not Connected!")
        }
        if self.blueToothFeatureType == .BlueToothLowerBound{
            self.delegateBackGroundBleState?.getBackGroundBleState(isConnectedBLEState: false)
                   self.centralManager?.stopScan()
                   print("Not Connected!")
        }
       
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services
            else {
                return
        }
        for service in services {
            if self.blueToothFeatureType == .BlueToothFeatureLogCurrentIndexWrite {
                if service.uuid == LUFT_BACKGROUND_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.blueToothFeatureType == .BlueToothFeatureLogCurrentGetValue {
                if service.uuid == LUFT_BACKGROUND_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            else if self.blueToothFeatureType == .BlueToothLowerBound {
                if service.uuid == LUFT_BACKGROUND_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            else if self.blueToothFeatureType == .BlueToothUpperBound {
                if service.uuid == LUFT_BACKGROUND_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            else if self.blueToothFeatureType == .BlueToothBackWrite {
                if service.uuid == LUFT_BACKGROUND_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.blueToothFeatureType == .BlueToothUpperBackGroundDataBound {
                if service.uuid == LUFT_BACKGROUND_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            else {
                print(service)
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
       
        //self.deviceLogIndexStatusDelgate?.getBluetoothCurrentIndexLogData(isConnectedBLE:false) // New Good Dont remove this line for time being show status message
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.isBleCharacteristicsState == true {
                
            }else {
                self.centralManager?.stopScan()
                self.delegateBackGroundBleState?.getBackGroundBleState(isConnectedBLEState: false)
                return
            }
        }
        
        if self.blueToothFeatureType == .BlueToothFeatureLogCurrentGetValue {
            self.isBleCharacteristicsState = true
            for characteristic in self.theService?.characteristics ?? []{
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }else if self.blueToothFeatureType == .BlueToothBackWrite {
            self.isBleCharacteristicsState = true
            for characteristic in self.theService?.characteristics ?? [] {
//                if characteristic.uuid == result_slc_hour_idx_CharacteristicCBUUID{
//                    var vint:Int32 = Int32(self.upperLogIndex)
//                    print("**********************************")
//                    print(self.upperLogIndex)
//                    print("**********************************")
//                    
//                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
//                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
//                    peripheral.setNotifyValue(true, for: characteristic)
//                }
//                if characteristic.properties.contains(.notify) {
//                    peripheral.setNotifyValue(true, for: characteristic)
//                }
                
                if characteristic.uuid == result_slc_hour_idx_CharacteristicCBUUID{
                   var vint:Int32 = Int32(self.writeBoundValue)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
                if characteristic.uuid == result_slc_NOTIFIY_stamp_CharacteristicCBUUID{
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
                
            }
        }
        else if self.blueToothFeatureType == .BlueToothUpperBound {
            self.isBleCharacteristicsState = true
            for characteristic in self.theService?.characteristics ?? []{
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        else if self.blueToothFeatureType == .BlueToothLowerBound {
            self.isBleCharacteristicsState = true
            for characteristic in self.theService?.characteristics ?? []{
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        else if self.blueToothFeatureType == .BlueToothUpperBackGroundDataBound {
            self.isBleCharacteristicsState = true
            for characteristic in self.theService?.characteristics ?? [] {
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        else if self.blueToothFeatureType == .BlueToothFeatureLogCurrentIndexWrite {
            self.isBleCharacteristicsState = true
            for characteristic in self.theService?.characteristics ?? [] {
                if characteristic.uuid == result_slc_hour_idx_CharacteristicCBUUID{
                    var vint:Int32 = -1
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    if RealmDataManager.shared.readLogFirstIndexPollutantDataValues(device_ID: self.strDeviceID).count == 0 {
                        RealmDataManager.shared.insertRealmPollutantDummyValuesTBLValues(strDate: Date(), deviceID: self.strDeviceID, co2: 0.0, air_pressure:  0.0, temperature:  0.0, humidity: 0.0, voc:  0.0, radon:  0.0, isWiFi: false, serialID: self.strDeviceSerialID ,logIndex:-1,timeStamp:0)
                    }
                }
                if characteristic.uuid == result_slc_NOTIFIY_stamp_CharacteristicCBUUID{
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                }
            }
        }
    
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            return
        }
        
        if self.blueToothFeatureType == .BlueToothFeatureLogCurrentIndexWrite {
            if characteristic.uuid == result_slc_NOTIFIY_stamp_CharacteristicCBUUID{
                print("Message sent")
                //self.mainPeripheral.discoverServices([result_slc_NOTIFIY_stamp_CharacteristicCBUUID])
            }
        }
        if self.blueToothFeatureType == .BlueToothBackWrite {
            if characteristic.uuid == result_slc_NOTIFIY_stamp_CharacteristicCBUUID{
                print("BlueToothBackWrite Message sent")
                //self.mainPeripheral.discoverServices([result_slc_NOTIFIY_stamp_CharacteristicCBUUID])
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
        
        if self.blueToothFeatureType == .BlueToothFeatureLogCurrentGetValue {
            //for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case result_radon_CharacteristicCBUUID:
                    self.getResultRadon(from: characteristic)
                case result_air_voc_CharacteristicCBUUID:
                    self.getAirVoc(from: characteristic)
                case result_air_co2_CharacteristicCBUUID:
                    self.geteco2(from: characteristic)
                case result_air_temp_CharacteristicCBUUID:
                    self.getTempValue(from: characteristic)
                case result_air_humidity_CharacteristicCBUUID:
                    self.getResultAirHumidity(from: characteristic)
                case result_air_pressure_CharacteristicCBUUID:
                    self.getAirPressure(from: characteristic)
                case result_slc_time_stamp_CharacteristicCBUUID:
                    self.getTimeStamp(from: characteristic)
                default:
                    print("")
                }
            //}
        }else if self.blueToothFeatureType == .BlueToothFeatureLogCurrentIndexWrite {
            //for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case result_slc_NOTIFIY_stamp_CharacteristicCBUUID:
                    self.getResultNotifiy(from: characteristic)
                default:
                    print("")
                }
            //}
            
        }else if self.blueToothFeatureType == .BlueToothBackWrite {
            //for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case result_slc_NOTIFIY_stamp_CharacteristicCBUUID:
                    self.getResultNotifiyBack(from: characteristic)
                default:
                    print("")
                }
            //}
        }
        else if self.blueToothFeatureType == .BlueToothUpperBackGroundDataBound {
            //for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case result_radon_CharacteristicCBUUID:
                    self.getResultRadon(from: characteristic)
                case result_air_voc_CharacteristicCBUUID:
                    self.getAirVoc(from: characteristic)
                case result_air_co2_CharacteristicCBUUID:
                    self.geteco2(from: characteristic)
                case result_air_temp_CharacteristicCBUUID:
                    self.getTempValue(from: characteristic)
                case result_air_humidity_CharacteristicCBUUID:
                    self.getResultAirHumidity(from: characteristic)
                case result_air_pressure_CharacteristicCBUUID:
                    self.getAirPressure(from: characteristic)
                case result_slc_time_stamp_CharacteristicCBUUID:
                    self.getTimeStamp(from: characteristic)
                default:
                    print("")
                }
            //}
        } else if self.blueToothFeatureType == .BlueToothLowerBound {
            //for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case result_LOWER_BOUND_time_stamp_CharacteristicCBUUID:
                    self.getLowerBound(from: characteristic)
                default:
                    print("")
                }
           // }
        }else if self.blueToothFeatureType == .BlueToothUpperBound {
            //for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case result_UPPER_BOUND_time_stamp_CharacteristicCBUUID:
                    self.getUpperBound(from: characteristic)
                default:
                    print("")
                }
            //}
        }else {
            
        }
        
    }
    
    
    func didUpdateCheck() {
        self.didUpdate = self.didUpdate + 1
        if self.didUpdate == 7 {
            
            if self.blueToothFeatureType == .BlueToothUpperBackGroundDataBound {
                
                print(self.strRadon)
                print(self.strVoc)
                print(self.strEco2)
                print(self.strTemp)
                print(self.strPressure)
                print(self.strHumidity)
                print(self.strLastSyncTime)
                print(self.writeBoundValue)
                print(self.upperBoundValue)
                var pollutants: [RealmPollutantValuesTBL] = []
                var timeStampvalue =  self.strLastSyncTime.toInt() ?? 0
                timeStampvalue = timeStampvalue * 1000
                let strLastSyncTime1 =  Date(milliseconds: timeStampvalue)
                
                let pollutant = RealmDataManager.shared.getRealmPollutantValuesTBLValues(strDate: strLastSyncTime1, deviceID: self.strDeviceID,co2: self.strEco2.toFloat() ?? 0.0, air_pressure: self.strPressure.toFloat() ?? 0.0, temperature: self.strTemp.toFloat() ?? 0.0, humidity: self.strHumidity.toFloat() ?? 0.0, voc: self.strVoc.toFloat() ?? 0.0, radon: self.strRadon.toFloat() ?? 0.0, isWiFi: false, serialID: self.strDeviceSerialID , logIndex: self.writeBoundValue, timeStamp: timeStampvalue)
                textLog.write(String(format: "Background Sync Get Result Notify log index updated- %d", self.writeBoundValue))

                pollutant.auto_id = self.upperLogIndex
                pollutants.append(pollutant)
                DispatchQueue.global(qos: .background).async {
                    RealmDataManager.shared.insertRealmPollutantValuesTBLValues(pollutantValues: pollutants)
                    DispatchQueue.main.async {
                        
                    }
                }
            }else {
                print(self.strRadon)
                print(self.strVoc)
                print(self.strEco2)
                print(self.strTemp)
                print(self.strPressure)
                print(self.strHumidity)
                print(self.strLastSyncTime)
                print("-1")
                self.updatePollutantTableData(strDate: self.strLastSyncTime, deviceID: self.strDeviceID, co2: self.strEco2, air_pressure: self.strPressure, temperature: self.strTemp, humidity: self.strHumidity, voc: self.strVoc, radon: self.strRadon, isWiFi: false, device_SerialID: self.strDeviceSerialID)
                self.deviceLogIndexStatusDelgate?.getBluetoothCurrentIndexLogData(isConnectedBLE: false)
                print("Hide 16")
            }
           
            
        }
    }

}

extension BackgroundBLEManager {
    
    private func getResultNotifiy(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            if(characteristic.value != nil){
                let msgLength = Int32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
                if msgLength != 0{
                    self.strNotifiyStatus = String(format: "%d", msgLength)
                }else {
                    self.strNotifiyStatus = "0.0"
                }
                self.blueToothFeatureType = .BlueToothFeatureLogCurrentGetValue
                self.mainPeripheral.discoverServices([])
            }
        }
    }
    
    func getCharAsOptional(characteristic: CBCharacteristic) -> String? {
        return String(format: "%d", UInt32(data:characteristic.value!))
    }
    
    private func getResultNotifiyBack(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            if(characteristic.value != nil){
                let msgLength = Int32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
                if msgLength != 0{
                    if let syncValue:String = getCharAsOptional(characteristic: characteristic) {
                        if self.writeBoundValue == Int(syncValue) {
                            self.blueToothFeatureType = .BlueToothUpperBackGroundDataBound
                            self.mainPeripheral.discoverServices([])
                        }else {
                            self.getUpdateBLEBackGroundData(isFristTime: false)
                        }
                        self.isBleBackGroundSyncDevice = false
                        textLog.write(String(format: "Background Sync Get Result Notify log index start- %d", self.writeBoundValue))
                    }
                    self.strNotifiyStatus = String(format: "%d", msgLength)
                }else {
                    self.strNotifiyStatus = "0.0"
                }
            }
        }
    }
    
    private func getResultRadon(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let techvalue = float_t(characteristic.value?.uint16 ?? 0)
            self.strRadon = String(format: "%.2f", techvalue / 100)
            self.didUpdateCheck()
        }else {
            self.strRadon = "0.0"
            self.didUpdateCheck()
        }
        
    }
    
   
    private func getAirVoc(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            if msgLength != 0{
                let backToInt32:Int16 = Int16(characteristic.value?.uint16 ?? 0)
                self.strVoc = String(format: "%d", backToInt32)
                
            }else {
                self.strVoc = "0.0"
            }
            print(self.strVoc)
            self.didUpdateCheck()
        }
        
    }
    
    private func geteco2(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            if msgLength != 0{
                let backToInt32:Int16 = Int16(characteristic.value?.uint16 ?? 0)
                self.strEco2 = String(format: "%d", backToInt32)
                
            }else {
                self.strEco2 = "0.0"
            }
            self.didUpdateCheck()
        }
    }
    
    private func getTempValue(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            if msgLength != 0{
                //let percentageValue:float_t = float_t()
                let techvalue = float_t(UInt32(data:characteristic.value!))
                self.strTemp = String(format: "%.2f", techvalue / 100)
                //self.strTemp = String(format: "%d", UInt32(data:characteristic.value!) / 100)
                
            }else {
                self.strTemp = "0.0"
            }
            self.didUpdateCheck()
        }
        
    }
    
    private func getResultAirHumidity(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            if msgLength != 0{
                let techvalue = float_t(UInt32(data:characteristic.value!))
                self.strHumidity = String(format: "%.2f", techvalue / 100)
                
            }else {
                self.strHumidity = "0.0"
            }
            self.didUpdateCheck()
        }
    }
    
    private func getAirPressure(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            if msgLength != 0{
                let techvalue = float_t(UInt32(data:characteristic.value!))
                self.strPressure = String(format: "%.2f", techvalue / 100)
                
            }else {
                self.strPressure = "0.0"
            }
            
            self.didUpdateCheck()
        }
    }
    
    private func getTimeStamp(from characteristic: CBCharacteristic) {
        
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            if msgLength != 0{
                if let syncValue:String = getCharAsOptional(characteristic: characteristic) {
                    self.strLastSyncTime = syncValue
                }
            }else {
                self.strLastSyncTime = "0.0"
            }
            self.didUpdateCheck()
        }
    }
        
        

    
    
    private func getUpperBound(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            if msgLength != 0{
                let backToInt32:Int16 = Int16(characteristic.value?.uint16 ?? 0)
                self.upperBoundValue = Int(backToInt32)
                self.getUpdateBLEBackGroundData(isFristTime: true)
            }else {
                self.upperBoundValue = 0
            }
        }
    }
    private func getLowerBound(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            if msgLength != 0{
                let backToInt32:Int16 = Int16(characteristic.value?.uint16 ?? 0)
                self.lowerBoundValue = Int(backToInt32)
                //self.lowerBoundValue = 7750
                self.blueToothFeatureType = .BlueToothUpperBound
                self.mainPeripheral.discoverServices([])
            }else {
                self.lowerBoundValue = 0
                self.blueToothFeatureType = .BlueToothUpperBound
                self.mainPeripheral.discoverServices([])
            }
        }
        RealmDataManager.shared.delegateLogIndexDone = nil
        RealmDataManager.shared.delegateLogIndexDone = self
    }
    
    
    func getUpdateBLEBackGroundData(isFristTime:Bool)  {
        var backGroundLogIndex:Int = 0
        self.blueToothFeatureType = .BlueToothBackWrite
        if RealmDataManager.shared.readPollutantDataValues().count != 0 {
            self.didUpdate = 0
            print(self.strDeviceID)
            print("self.strDeviceID")
            print(self.lowerBoundValue)
            print("self.lowerBoundValue")
            print(self.writeBoundValue)
            print("self.writeBoundValue")
            
            backGroundLogIndex = RealmDataManager.shared.readTimeBasePollutantDataValues(device_ID: self.strDeviceID)
            if backGroundLogIndex >=  self.upperBoundValue {
                self.isBleBackGroundSyncDevice = true
                self.backGroundBleSyncCompletedDelegate?.getWholebackGroundBleSyncCompletedDelegate()
                Helper.shared.removeBleutoothConnection()
                return
            }
            else if backGroundLogIndex >=  self.lowerBoundValue {
                backGroundLogIndex =  backGroundLogIndex + 1
                self.writeBoundValue = backGroundLogIndex
            }else {
                if isFristTime != true {
                    self.writeBoundValue = self.lowerBoundValue + 1
                }
                //self.writeBoundValue = 7700
            }
        }
        if  self.writeBoundValue > self.upperBoundValue {
            self.isBleBackGroundSyncDevice = true
            self.backGroundBleSyncCompletedDelegate?.getWholebackGroundBleSyncCompletedDelegate()

            Helper.shared.removeBleutoothConnection()
            return
        }
        self.mainPeripheral.discoverServices([])
    }
    
    func updatePollutantTableData(strDate:String,deviceID:Int,co2:String,air_pressure:String,temperature:String,humidity:String,voc:String,radon:String,isWiFi:Bool,device_SerialID:String) {
        let realm = try! Realm()
        var deviceAllData = realm.objects(RealmPollutantValuesTBL.self).filter({ $0.device_SerialID == device_SerialID})
        deviceAllData = deviceAllData.filter({ $0.LogIndex == -1})
        if let deviceData = deviceAllData.first {
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
        } else {
            print("Enter new data")
            var timeStampvalue =  strDate.toInt() ?? 0
            timeStampvalue = timeStampvalue * 1000
            let pollutantValues = RealmPollutantValuesTBL()
            pollutantValues.auto_id = RealmDataManager.shared.nextPollutantListId()
            pollutantValues.LogIndex = -1
            pollutantValues.device_SerialID = device_SerialID
            pollutantValues.Device_ID = deviceID
            pollutantValues.date = Date(milliseconds:timeStampvalue)
            pollutantValues.CO2 = co2.toFloat() ?? 0.0
            pollutantValues.AirPressure = air_pressure.toFloat() ?? 0.0
            pollutantValues.Temperature = temperature.toFloat() ?? 0.0
            pollutantValues.Humidity = humidity.toFloat() ?? 0.0
            pollutantValues.VOC = voc.toFloat() ?? 0.0
            pollutantValues.Radon = radon.toFloat() ?? 0.0
            pollutantValues.timeStamp = timeStampvalue
            pollutantValues.isWifi = isWiFi
            pollutantValues.onlyDate = Helper.shared.getDateStringFromDateTime(dateStr: Helper.shared.convertDateToString(date: pollutantValues.date))
            pollutantValues.WeekValue = String.init(format: "%d", Helper.shared.getWeekOfYear(date: Helper.shared.getDateFromDateTime(dateStr: Helper.shared.convertDateToString(date: pollutantValues.date))))
            let realmRadon = try! Realm()
            try! realmRadon.write {
                realmRadon.add(pollutantValues)
            }
        }
    }
}

extension BackgroundBLEManager:LogIndexDelegate {
    func writeLogIndexDelegate(logIndexDone: Bool) {
        textLog.write("Background Sync Get Result Notify log index - Done")
        self.getUpdateBLEBackGroundData(isFristTime: false)
    }
}
