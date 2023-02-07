//
//  BluetoothManager.swift
//  luft
//
//  Created by iMac Augusta on 10/21/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import CoreData
import CoreBluetooth
import Realm
import RealmSwift

protocol DeviceSerialNumberReadDelegate{
    func didReadSerialNumber(serialNumber: String)
}

protocol WIFIStatusDelegate:class {
    func wifiStatusCheck(wifiDeviceStaus:String)
}
protocol FirmwareDelegate:class {
    func firmwareVesrion(fwVersion:String)
}

protocol SSIDWriteDelegate:class {
    func writeSSIDName()
    func writeSSIDPassword()
    func writeSSIDSocketURL()
    func writeSSIDCloudWebURL()
    func writeSSIDSocketAuthToken()
}

protocol BleManagerStateDelegate:class {
    func getBleManagerBleState(isConnectedBLEState:Bool)
}
protocol BLEWriteStateDelegate:class {
    func getBLEWriteStateDelegate(bleWriteType:BlueToothFeatureType)
}

protocol TIMEStampWriteDelegate:class {
    func writeTIMEStampWrite()
}

class BluetoothManager: NSObject {
    
    
    var strDeviceSerialID: String = "0.0"
    var strDeviceID: Int = 0
    
    var deviceWifiStatusDelgate:WIFIStatusDelegate? = nil
    var deviceWriteStatusDelgate:SSIDWriteDelegate? = nil
    
    //New Good
    var strWifiStatus: String = "0.0"
    var strBlueToothName:String? = ""
    var centralManager: CBCentralManager!
    var mainPeripheral: CBPeripheral!
    var blueToothFeatureType: BlueToothFeatureType!
    var selectedWifiName: String? = ""
    var selectedWifiPassword: String? = ""
    var strDeviceToken: String = ""
    var strFWVersion: String = "0.0"
    
    var isBleManagerConnectState:Bool = false
    var isBleManagerCharacteristicsState:Bool = false
    var delegateBleManagerState:BleManagerStateDelegate? = nil
    var delegateBleWriteState:BLEWriteStateDelegate? = nil
    var delegateFwVersion:FirmwareDelegate? = nil
    var serialNumberReadDelegate: DeviceSerialNumberReadDelegate? = nil
    
    var delegateTimeStampVersion:TIMEStampWriteDelegate? = nil
    var timeStampValue: Int = 0
    
    var theService: CBService?
    
    
    struct Static {
         static var instance: BluetoothManager?
    }
    
    class var shared: BluetoothManager {
        
        if Static.instance == nil {
            Static.instance = BluetoothManager()
        }
        return Static.instance!
    }
    
    func dispose()
    {
        BluetoothManager.Static.instance = nil
        print("Disposed Singleton instance")
    }
    
    func connectBlueTooth(blueToothName:String,bleFeature:BlueToothFeatureType)  {
        print(self.strBlueToothName)
        self.strBlueToothName = blueToothName
        textLog.write("WIFI CHECK START")

        self.blueToothFeatureType = bleFeature
        if self.strBlueToothName != "" {
            centralManager = CBCentralManager(delegate: self, queue: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                if self.isBleManagerConnectState != true {
                    self.delegateBleManagerState?.getBleManagerBleState(isConnectedBLEState: true)
                    self.centralManager?.stopScan()
                    return
                }
            }
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                if self.centralManager == nil {
                    textLog.write("connectBlueTooth self.centralManager == nil faliure")
                    return
                }
                if self.isBleManagerConnectState != true {
                    textLog.write("BLE NOT CONNECT")
                    self.delegateBleManagerState?.getBleManagerBleState(isConnectedBLEState: true)
                    self.centralManager?.stopScan()
                    return
                }
            }
        }
    }
}
extension BluetoothManager: CBCentralManagerDelegate,CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            textLog.write("central.state is .unknown")
            print("central.state is .unknown")
        case .resetting:
            textLog.write("central.state is .resetting")
            print("central.state is .resetting")
            NotificationCenter.default.post(name:.postNotifiResetDevice, object: nil, userInfo: nil)
        case .unsupported:
            textLog.write("central.state is .unsupported")
            print("central.state is .unsupported")
        case .unauthorized:
            textLog.write("central.state is .unauthorized")
            print("central.state is .unauthorized")
        case .poweredOff:
            textLog.write("central.state is .poweredOff")
            print("central.state is .poweredOff")
        case .poweredOn:
            textLog.write("central.state is .poweredOn")
            print("central.state is .poweredOn")
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("")
            print("Empty Array discovering 9283456779")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        if peripheral.name == self.strBlueToothName{
            mainPeripheral = peripheral
            mainPeripheral.delegate = self
            self.isBleManagerConnectState = true
            self.isBleManagerCharacteristicsState = true
            centralManager.stopScan()
            centralManager.connect(mainPeripheral)
            print(peripheral)
            print("peripheral connect")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        textLog.write("Connected!")
        mainPeripheral.discoverServices([])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(self.blueToothFeatureType ?? "")
        if self.blueToothFeatureType == .BlueToothFeatureWifiStatus{
           textLog.write("WIFI CHECK START new good")
            self.delegateBleManagerState?.getBleManagerBleState(isConnectedBLEState: true)
        }
        else if self.blueToothFeatureType == .BlueToothFirmwareVersion {
            self.delegateBleManagerState?.getBleManagerBleState(isConnectedBLEState: true)
        }
        else if self.blueToothFeatureType == .BlueToothTimeStampWrite {
            self.delegateBleManagerState?.getBleManagerBleState(isConnectedBLEState: true)
        }
        else if self.blueToothFeatureType == .BlueToothFeatureSSIDWrite {
            self.delegateBleManagerState?.getBleManagerBleState(isConnectedBLEState: true)
        }else if self.blueToothFeatureType == .BlueToothFeatureRemoveSSIDWrite {
            self.delegateBleManagerState?.getBleManagerBleState(isConnectedBLEState: true)
        }else {
            //self.delegateBleManagerState?.getBleManagerBleState(isConnectedBLEState: true)
        }
        
        print("Not Connected!")
        textLog.write("Not Connected!")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services
            else {
                textLog.write("didDiscoverServices faliure")
                return
        }
        for service in services {
            print(service)
            print("Empty Array service")
            if self.blueToothFeatureType == .BluetoothReadSerial{
                if service.uuid == LUFT_WIFI_SERVICE_STATUS {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
            if self.blueToothFeatureType == .BlueToothFirmwareVersion {
                if service.uuid == SERVICE_FWVERSION_CharacteristicCBUUID {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.blueToothFeatureType == .BlueToothFeatureWifiStatus {
                if service.uuid == LUFT_WIFI_SERVICE_STATUS {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                textLog.write("WIFI CHECK START new good")
            }else if self.blueToothFeatureType == .BlueToothFeatureSSIDWrite {
                if service.uuid == LUFT_WIFI_SERVICE_STATUS {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.blueToothFeatureType == .BlueToothFeatureRemoveSSIDWrite {
                if service.uuid == LUFT_WIFI_SERVICE_STATUS {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.blueToothFeatureType == .BlueToothTimeStampWrite {
                if service.uuid == LUFT_WIFI_SERVICE_STATUS {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else {
                if service.uuid == LUFT_SERVICE {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
       }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            textLog.write("didDiscoverServices characteristics faliure")
            return
        }
        
        if self.blueToothFeatureType == .BluetoothReadSerial{
            for characteristic in self.theService?.characteristics ?? [] {
                if characteristic.uuid == device_serial_CharacteristicCBUUID{
                   
                    if characteristic.properties.contains(.read) {
                        peripheral.readValue(for: characteristic)
                    }
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    textLog.write("serial number found")
                   
                }
            }
        }
        
        if self.blueToothFeatureType == .BlueToothFeatureSSIDWrite {
            for characteristic in self.theService?.characteristics ?? [] {
                //Write Index
                
                if characteristic.uuid == device_serial_CharacteristicCBUUID{
                   
                    if characteristic.properties.contains(.read) {
                        peripheral.readValue(for: characteristic)
                        
                    }
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    textLog.write("serial number found")
                   
                }
                
                if characteristic.uuid == wifi_SSID_Connected_CharacteristicCBUUID{
                    if let dataToSend = self.selectedWifiName?.data(using: String.Encoding.utf8) {
                        peripheral.writeValue(dataToSend, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        textLog.write("BLE VIA - CONNECTED SSID NAME WRITE SUCCESS \(self.selectedWifiName)")
                    }
                }
                if characteristic.uuid == wifi_SSID_PASSWORD_Connected_CharacteristicCBUUID{
                    if let dataToSend = self.selectedWifiPassword?.data(using: String.Encoding.utf8) {
                        peripheral.writeValue(dataToSend, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        textLog.write("BLE VIA - CONNECTED SSID PASSWORD WRITE SUCCESS \(self.selectedWifiPassword)")
                    }
                }
                if characteristic.uuid == wifi_WEBSOCKET_URL{
                    
                    if let dataToSend = getBLEWriteBaseUrl().data(using: String.Encoding.utf8) {
                        peripheral.writeValue(dataToSend, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        peripheral.setNotifyValue(true, for: characteristic)
                        textLog.write("BLE VIA - WIFI SOCKET URL WRITE SUCCESS")
                    }
                    
                }
                if characteristic.uuid == wifi_AUTH_TOKEN{
                    
                    if let dataToSend = self.strDeviceToken.data(using: String.Encoding.utf8) {
                        peripheral.writeValue(dataToSend, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        peripheral.setNotifyValue(true, for: characteristic)
                        textLog.write("BLE VIA - WIFI AUTHTOKEN WRITE SUCCESS")
                    }
                }
                if characteristic.uuid == wifi_COULD_URL{
                    if let dataToSend = getDeviceGetAPIBaseUrl().data(using: String.Encoding.utf8) {
                        peripheral.writeValue(dataToSend, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        peripheral.setNotifyValue(true, for: characteristic)
                        textLog.write("BLE VIA - WIFI COLUD URL WRITE SUCCESS")
                    }
                }
            }
        }
        if self.blueToothFeatureType == .BlueToothFeatureRemoveSSIDWrite {
            for characteristic in self.theService?.characteristics ?? [] {
                //Write Index
                
                
                
                if characteristic.uuid == wifi_SSID_Connected_CharacteristicCBUUID{
                    if let dataToSend = "".data(using: String.Encoding.utf8) {
                        peripheral.writeValue(dataToSend, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        textLog.write("BLE VIA - REMOVE SSID NAME WRITE SUCCESS \("")")
                    }
                }
                if characteristic.uuid == wifi_SSID_PASSWORD_Connected_CharacteristicCBUUID{
                    if let dataToSend = "".data(using: String.Encoding.utf8) {
                        peripheral.writeValue(dataToSend, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        textLog.write("BLE VIA - REMOVE SSID PASSWORD WRITE SUCCESS \("")")
                    }
                }
            }
        }
        if self.blueToothFeatureType == .BlueToothFeatureWifiStatus {
            for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case wifi_Connected_CharacteristicCBUUID:
                    if characteristic.properties.contains(.read) {
                        peripheral.readValue(for: characteristic)
                        
                    }
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    textLog.write("WIFI CHECK START characteristic found")
                case device_serial_CharacteristicCBUUID:
                    if characteristic.properties.contains(.read) {
                        peripheral.readValue(for: characteristic)
                    }
                    if characteristic.properties.contains(.notify) {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    textLog.write("serial number found")
                    
                default:
                    print("")
                }
            }
            
            if self.theService?.characteristics?.count == 0{
                textLog.write("WIFI CHECK START characteristic not found")
            }
           

        }
        if self.blueToothFeatureType == .BlueToothTimeStampWrite {
            for characteristic in self.theService?.characteristics ?? [] {
                //Write Index
                if characteristic.uuid == time_STAMP_SSID_Connected_CharacteristicCBUUID{
                    var vint:Int32 = Int32(self.timeStampValue)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        if self.blueToothFeatureType == .BlueToothFirmwareVersion {
            for characteristic in self.theService?.characteristics ?? [] {
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        else {
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("\(error.debugDescription)")
            print("Empty Array debugDescription")
            return
        }
        if ((characteristic.descriptors) != nil) {
            //Write Index
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            print("Empty Array discovering services: error")
            textLog.write("BLE VIA - WRITE FALIURE")
            if self.blueToothFeatureType == .BlueToothFeatureSSIDWrite {
                self.delegateBleWriteState?.getBLEWriteStateDelegate(bleWriteType: .BlueToothFeatureSSIDWrite)
            }
            if self.blueToothFeatureType == .BlueToothFeatureRemoveSSIDWrite {
                self.delegateBleWriteState?.getBLEWriteStateDelegate(bleWriteType: .BlueToothFeatureRemoveSSIDWrite)
            }
            
            if self.blueToothFeatureType == .BlueToothTimeStampWrite {
                self.delegateBleWriteState?.getBLEWriteStateDelegate(bleWriteType: .BlueToothTimeStampWrite)
            }
            return
        }
        if self.blueToothFeatureType == .BlueToothFeatureSSIDWrite {
            
            //for characteristic in self.theService?.characteristics ?? [] {
            if characteristic.uuid == wifi_WEBSOCKET_URL{
                self.deviceWriteStatusDelgate?.writeSSIDCloudWebURL()
                print("Message sent")
            }
            if characteristic.uuid == wifi_AUTH_TOKEN{
                self.deviceWriteStatusDelgate?.writeSSIDSocketAuthToken()
                print("Message sent")
                print(self.strDeviceToken)
                
            }
            if characteristic.uuid == wifi_COULD_URL{
                self.deviceWriteStatusDelgate?.writeSSIDSocketURL()
                print("Message sent")
            }
            if characteristic.uuid == wifi_SSID_Connected_CharacteristicCBUUID{
                self.deviceWriteStatusDelgate?.writeSSIDName()
                print("Message sent")
            }
            if characteristic.uuid == wifi_SSID_PASSWORD_Connected_CharacteristicCBUUID{
                self.deviceWriteStatusDelgate?.writeSSIDPassword()
                print("Message sent")
                print(self.selectedWifiPassword)
            }
            
            //}
            
        }
        if self.blueToothFeatureType == .BlueToothFeatureRemoveSSIDWrite {
            // for characteristic in self.theService?.characteristics ?? [] {
            if characteristic.uuid == wifi_SSID_Connected_CharacteristicCBUUID{
                self.deviceWriteStatusDelgate?.writeSSIDName()
                print("Message sent")
            }
            if characteristic.uuid == wifi_SSID_PASSWORD_Connected_CharacteristicCBUUID{
                self.deviceWriteStatusDelgate?.writeSSIDPassword()
                print("Message sent")
            }
            // }
        }
        if self.blueToothFeatureType == .BlueToothTimeStampWrite {
            // for characteristic in self.theService?.characteristics ?? [] {
            if characteristic.uuid == time_STAMP_SSID_Connected_CharacteristicCBUUID{
                self.delegateTimeStampVersion?.writeTIMEStampWrite()
                textLog.write("TIMEStampWrite Message sent")
                print("TIMEStampWrite Message sent")
            }
            // }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
        print("Empty Array characteristic")
        if self.blueToothFeatureType == .BlueToothFeatureWifiStatus {
            for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case wifi_Connected_CharacteristicCBUUID:
                    self.getDeviceWifiStatusViaBlueTooth(from: characteristic)
                case device_serial_CharacteristicCBUUID:
                    self.getDeviceSerialNumberViaBlueTooth(from: characteristic)
                default:
                    print("")
                }
            }
        }
        else if self.blueToothFeatureType == .BlueToothFirmwareVersion {
            for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case FWVERSION_CharacteristicCBUUID:
                    self.getDeviceFwVersionViaBlueTooth(from: characteristic)
                default:
                    print("")
                }
            }
        }
        
        else if self.blueToothFeatureType == .BlueToothFeatureSSIDWrite {
            for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case device_serial_CharacteristicCBUUID:
                    self.getDeviceSerialNumberViaBlueTooth(from: characteristic)
                default:
                    print("")
                }
            }
        }
        
        
        else if self.blueToothFeatureType == .BluetoothReadSerial {
            for characteristic in self.theService?.characteristics ?? [] {
                switch characteristic.uuid {
                case device_serial_CharacteristicCBUUID:
                    self.getDeviceSerialNumberViaBlueTooth(from: characteristic)
                default:
                    print("")
                }
            }
        }
        else {
            
        }
    }
    func getDeviceWifiStatusViaBlueTooth(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt8(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            let msgLengthValue:UInt8 = msgLength
            textLog.write("Bluetooth wifi data  msgLengthValue \(String(describing: msgLengthValue))")
            if msgLength != 0{
                let backToInt32:UInt8 = UInt8(characteristic.value?.uint8 ?? 0)
                let strStatus:String = String(format: "%d", backToInt32)
                //self.strWifiStatus = String(format: "%d", backToInt32)
            self.deviceWifiStatusDelgate?.wifiStatusCheck(wifiDeviceStaus: strStatus)
                print("WifiStatus Success")
                print("faliure1")
                print(strStatus)
                print("WifiStatus Success")
                textLog.write("WIFI CHECK START WifiStatus Success")
            }else {
                    self.strWifiStatus = "0"
                self.deviceWifiStatusDelgate?.wifiStatusCheck(wifiDeviceStaus: "0")
                print("WifiStatus NEwGood")
                print(self.strWifiStatus)
                print("WifiStatus NEwGood")
                textLog.write("WIFI CHECK START WifiStatus 0")
            }
        }

    }
    
    func getDeviceFwVersionViaBlueTooth(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            if(characteristic.value != nil){
                let msgLength = UInt8(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
                let nsdataStr = NSData.init(data: (characteristic.value)!)

                if nsdataStr.count != 0{
                    let nsdataStr = NSData.init(data: (characteristic.value)!)
                    let strValue = String(data: nsdataStr as Data, encoding: .utf8)
                    self.strFWVersion = strValue ?? ""
                    self.delegateFwVersion?.firmwareVesrion(fwVersion: self.strFWVersion)
                }else {
                    self.strFWVersion = "0"
                    self.delegateFwVersion?.firmwareVesrion(fwVersion: self.strFWVersion)
                }
            }
        }
    }
    
    func getDeviceSerialNumberViaBlueTooth(from characteristic: CBCharacteristic) {
        if(characteristic.value != nil){
            let msgLength = UInt32(bigEndian:(characteristic.value?.withUnsafeBytes { $0.pointee } ?? nil) ?? 0)
            let msgLengthValue:UInt32 = msgLength
            textLog.write("Bluetooth serial data  msgLengthValue \(String(describing: msgLengthValue))")
            if msgLength != 0{
                let backToInt32:UInt32 = UInt32(characteristic.value?.uint32 ?? 0)
                
                let strStatus:String = String(format:"%02X", backToInt32)
                self.serialNumberReadDelegate?.didReadSerialNumber(serialNumber: strStatus)
                
               
                textLog.write("WIFI CHECK START WifiStatus Success")
            }
        }

    }
    
}

