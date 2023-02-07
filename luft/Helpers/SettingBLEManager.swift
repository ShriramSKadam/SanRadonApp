//
//  SettingBLEManager.swift
//  Luft
//
//  Created by iMac Augusta on 11/14/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import CoreData
import CoreBluetooth
//CBUUID(string: "626B87D0-39CE-491B-A871-5B9A209EEDC8")
//Radon
let CHARACTERISTIC_THRESHOLD_WARNING_RADON_LEVEL_UUID = CBUUID(string: "626B87DD-39CE-491B-A871-5B9A209EEDC8")
let CHARACTERISTIC_THRESHOLD_HAZARD_RADON_LEVEL_UUID = CBUUID(string: "626B87E1-39CE-491B-A871-5B9A209EEDC8")
//VOC
let CHARACTERISTIC_THRESHOLD_WARNING_TVOC_LEVEL_UUID = CBUUID(string: "626b87dc-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_HAZARD_TVOC_LEVEL_UUID = CBUUID(string: "626b87e0-39ce-491b-a871-5b9a209eedc8")
//ECO2
let CHARACTERISTIC_THRESHOLD_WARNING_ECO2_LEVEL_UUID = CBUUID(string: "626b87db-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_HAZARD_ECO2_LEVEL_UUID = CBUUID(string: "626b87df-39ce-491b-a871-5b9a209eedc8")
//TEMPRARETURE
let CHARACTERISTIC_THRESHOLD_LOW_WARNING_TEMPERARUTE_LEVEL_UUID = CBUUID(string: "626b87fe-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_HIGH_WARNING_TEMPERARUTE_LEVEL_UUID = CBUUID(string: "626b87ff-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_LOW_ALERT_TEMPERARUTE_LEVEL_UUID = CBUUID(string: "626b87f4-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_HIGH_ALERT_TEMPERARUTE_LEVEL_UUID = CBUUID(string: "626b87f5-39ce-491b-a871-5b9a209eedc8")

//AIRPRESSURE
let CHARACTERISTIC_THRESHOLD_LOW_WARNING_AIR_PRESSURE_LEVEL_UUID = CBUUID(string: "626b87fc-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_HIGH_WARNING_AIR_PRESSURE_LEVEL_UUID = CBUUID(string: "626b87fd-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_LOW_ALERT_AIR_PRESSURE_LEVEL_UUID = CBUUID(string: "626b87f2-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_HIGH_ALERT_AIR_PRESSURE_LEVEL_UUID = CBUUID(string: "626b87f3-39ce-491b-a871-5b9a209eedc8")
//HUMIDITY
let CHARACTERISTIC_THRESHOLD_LOW_WARNING_HUMIDITY_LEVEL_UUID = CBUUID(string: "626b87fa-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_HIGH_WARNING_HUMIDITY_LEVEL_UUID = CBUUID(string: "626b87fb-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_LOW_ALERT_HUMIDITY_LEVEL_UUID = CBUUID(string: "626b87f0-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_THRESHOLD_HIGH_ALERT_HUMIDITY_LEVEL_UUID = CBUUID(string: "626b87f1-39ce-491b-a871-5b9a209eedc8")
//COLOR CODE
let CHARACTERISTIC_AIR_QUALITY_NORMAL_COLOR_UUID = CBUUID(string: "626b87d9-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_AIR_QUALITY_WARNING_COLOR_UUID = CBUUID(string: "626b87da-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_AIR_QUALITY_HAZARD_COLOR_UUID = CBUUID(string: "626b87de-39ce-491b-a871-5b9a209eedc8")
//NIGHT COLOR CODE
let CHARACTERISTIC_NIGHT_LIGHT_COLOR_UUID = CBUUID(string: "626b87e2-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_NIGHT_LIGHT_START_TIME_UUID = CBUUID(string: "626b87e3-39ce-491b-a871-5b9a209eedc8")
let CHARACTERISTIC_NIGHT_LIGHT_END_TIME_UUID = CBUUID(string: "626b87e4-39ce-491b-a871-5b9a209eedc8")

let CHARACTERISTIC_LED_BRIGHTNESS_COLOR_UUID = CBUUID(string: "626b87e8-39ce-491b-a871-5b9a209eedc8")


//Temp Offset CODE
let CHARACTERISTIC_TEMP_OFFSET_UUID = CBUUID(string: "626b87f9-39ce-491b-a871-5b9a209eedc8")





public enum BlueToothThresHoldWriteType : Int {
    case BlueToothThresHoldWriteNone = -1
    case BlueToothThresHoldWriteRadon = 1
    case BlueToothThresHoldWriteVOC = 2
    case BlueToothThresHoldWriteECO = 3
    case BlueToothThresHoldWriteHumidity = 4
    case BlueToothThresHoldWriteAirpressure = 5
    case BlueToothThresHoldWriteTempearture = 6
    
    case BlueToothColorOKWrite = 7
    case BlueToothColorWarningWrite = 8
    case BlueToothColorAlertWrite = 9
    case BlueToothNightColorAlertWrite = 10
    case BlueToothTempOffsetWrite = 11
}

protocol ThresHoldDelegate:class {
    func thresHoldWriteStatus(writeStatus:Bool)
}

protocol ThresHoldBLEManagerManagerStateDelegate:class {
    func getThresHoldBLEManagerBleState(isConnectedBLEState:Bool)
}


class SettingBLEManager: NSObject {
    
    
    var currentThresHoldDeviceSerialID: String = "0.0"
    var currentThresHoldDeviceID: Int = 0
    var thresHoldLowWarning: Int = 0
    var thresHoldHighWarning: Int = 0
    var thresHoldLowAlert: Int = 0
    var thresHoldHighAlert: Int = 0
    
    var okColorCode: Int = 0
    var warningColorCode: Int = 0
    var alertColorCode: Int = 0
    
    var nightColorCode: Int = 0
    var nightColorStartTime: Int = 0
    var nightColorEndTime: Int = 0
    
    var didWriteStatus: Int = 0
    
    //New Good
    var strBlueToothName:String? = ""
    var centralManager: CBCentralManager!
    var mainPeripheral: CBPeripheral!
    
    var selectedWifiName: String? = ""
    var selectedWifiPassword: String? = ""
    var strDeviceToken: String = ""
    
    
    var isThresHoldBleManagerConnectState:Bool = false
    var isThresHoldBleManagerCharacteristicsState:Bool = false
    var delegateThresHoldBleManagerState:ThresHoldBLEManagerManagerStateDelegate? = nil
    var delegateThresHoldBleWriteState:ThresHoldDelegate? = nil
    var bleThresHoldWritetype: BlueToothThresHoldWriteType!
    
    var theService: CBService?
    var tempOffset: Int = 0
    var ledBrightnessColorCode: String = "0"
    
    class var shared: SettingBLEManager {
        struct Static {
            static let instance: SettingBLEManager = SettingBLEManager()
        }
        return Static.instance
    }
    
    func connectBlueTooth(blueToothName:String,bleFeature:BlueToothThresHoldWriteType)  {
        self.strBlueToothName = blueToothName
        self.bleThresHoldWritetype = bleFeature
        if self.strBlueToothName != "" {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }else {
            
        }
        print(self.thresHoldHighWarning,"self.thresHoldHighWarning")
        print(self.thresHoldLowWarning,"self.thresHoldLowWarning")
        print(self.thresHoldLowAlert,"self.thresHoldLowAlert")
        print(self.thresHoldHighAlert,"self.thresHoldHighAlert")
    }
}
extension SettingBLEManager: CBCentralManagerDelegate,CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            NotificationCenter.default.post(name:.postNotifiResetDevice, object: nil, userInfo: nil)
            print("central.state is .resetting")
        case .unsupported:
            Helper.shared.showSnackBarAlert(message: "Bluetooth unsupported", type: .Failure)
            print("central.state is .unsupported")
        case .unauthorized:
            Helper.shared.showSnackBarAlert(message: "Bluetooth unauthorized", type: .Failure)
            print("central.state is .unauthorized")
        case .poweredOff:
            Helper.shared.showSnackBarAlert(message: "Please enable bluetooth", type: .Failure)
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
            self.isThresHoldBleManagerConnectState = true
            self.isThresHoldBleManagerCharacteristicsState = true
            centralManager.stopScan()
            centralManager.connect(mainPeripheral)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                if self.centralManager == nil {
                    return
                }
                if self.isThresHoldBleManagerConnectState == true {
                    
                }else {
                    self.delegateThresHoldBleManagerState?.getThresHoldBLEManagerBleState(isConnectedBLEState: false)
                    self.centralManager?.stopScan()
                    return
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        mainPeripheral.discoverServices([])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.delegateThresHoldBleManagerState?.getThresHoldBLEManagerBleState(isConnectedBLEState: false)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services
            else {
                self.delegateThresHoldBleManagerState?.getThresHoldBLEManagerBleState(isConnectedBLEState: false)
                return
        }
        for service in services {
            print(service)
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteRadon {
                if service.uuid == LUFT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothThresHoldWriteVOC {
                if service.uuid == LUFT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothThresHoldWriteECO {
                if service.uuid == LUFT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothThresHoldWriteTempearture {
                if service.uuid == LUFT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothThresHoldWriteAirpressure {
                if service.uuid == LUFT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothThresHoldWriteHumidity {
                if service.uuid == LUFT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothColorOKWrite {
                if service.uuid == LUFT_NIGHT_LIGHT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothColorWarningWrite {
                if service.uuid == LUFT_NIGHT_LIGHT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothColorAlertWrite {
                if service.uuid == LUFT_NIGHT_LIGHT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothNightColorAlertWrite {
                if service.uuid == LUFT_NIGHT_LIGHT_SETTING_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else if self.bleThresHoldWritetype == .BlueToothTempOffsetWrite {
                if service.uuid == LUFT_TEMP_OFFSET_SERVICE {
                    self.theService = service
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }else {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if self.isThresHoldBleManagerCharacteristicsState == true {
                
            }else {
                self.centralManager?.stopScan()
                self.delegateThresHoldBleManagerState?.getThresHoldBLEManagerBleState(isConnectedBLEState: false)
            }
        }
        
        for characteristic in self.theService?.characteristics ?? [] {
            self.isThresHoldBleManagerCharacteristicsState = true
            //Write Index
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteRadon { //Radon
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_WARNING_RADON_LEVEL_UUID{
                    var vint:Int16 = Int16(self.thresHoldLowWarning)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HAZARD_RADON_LEVEL_UUID{
                    var vint:Int16 = Int16(self.thresHoldLowAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
            }
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteVOC { //VOC
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_WARNING_TVOC_LEVEL_UUID{
                    var vint:Int16 = Int16(self.thresHoldLowWarning)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HAZARD_TVOC_LEVEL_UUID{
                    var vint:Int16 = Int16(self.thresHoldLowAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteECO { //ECO2
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_WARNING_ECO2_LEVEL_UUID{
                    var vint:Int16 = Int16(self.thresHoldLowWarning)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HAZARD_ECO2_LEVEL_UUID{
                    var vint:Int16 = Int16(self.thresHoldLowAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            /////// Temperature
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteTempearture { //Temperature
                //peripheral.discoverDescriptors(for: characteristic)
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_WARNING_TEMPERARUTE_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldLowWarning)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_WARNING_TEMPERARUTE_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldHighWarning)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_ALERT_TEMPERARUTE_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldLowAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_ALERT_TEMPERARUTE_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldHighAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            /////// AIRPRESSURE
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteAirpressure { //Temperature
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_WARNING_AIR_PRESSURE_LEVEL_UUID{
                    //self.thresHoldLowWarning = 2970
                    var vint:Int32 = Int32(self.thresHoldLowWarning)
                    print(self.thresHoldLowWarning)
                    print("/////// AIRPRESSURE)")
                    print("/////// AIRPRESSURE)")
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_WARNING_AIR_PRESSURE_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldHighWarning)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_ALERT_AIR_PRESSURE_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldLowAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_ALERT_AIR_PRESSURE_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldHighAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
                //peripheral.discoverDescriptors(for: characteristic)
            }
            /////// HUMIDITY
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteHumidity { //Temperature
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_WARNING_HUMIDITY_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldLowWarning)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_WARNING_HUMIDITY_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldHighWarning)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_ALERT_HUMIDITY_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldLowAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_ALERT_HUMIDITY_LEVEL_UUID{
                    var vint:Int32 = Int32(self.thresHoldHighAlert)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            //OK Color Code
            if self.bleThresHoldWritetype == .BlueToothColorOKWrite { // Color Code
                if characteristic.uuid == CHARACTERISTIC_AIR_QUALITY_NORMAL_COLOR_UUID{
                    var vint:Int8 = Int8(self.okColorCode)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int8>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
                if characteristic.uuid == CHARACTERISTIC_LED_BRIGHTNESS_COLOR_UUID{
                    var vint:Int16 = Int16(UInt16(strtoul(self.ledBrightnessColorCode, nil, 16)))
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            //Warning Color Code
            if self.bleThresHoldWritetype == .BlueToothColorWarningWrite { // Color Code
                if characteristic.uuid == CHARACTERISTIC_AIR_QUALITY_WARNING_COLOR_UUID{
                    var vint:Int8 = Int8(self.warningColorCode)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int8>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_LED_BRIGHTNESS_COLOR_UUID{
                    var vint:Int16 = Int16(UInt16(strtoul(self.ledBrightnessColorCode, nil, 16)))
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            //Alert Color Code
            if self.bleThresHoldWritetype == .BlueToothColorAlertWrite { // Color Code
                if characteristic.uuid == CHARACTERISTIC_AIR_QUALITY_HAZARD_COLOR_UUID{
                    var vint:Int8 = Int8(self.alertColorCode)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int8>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_LED_BRIGHTNESS_COLOR_UUID{
                    var vint:Int16 = Int16(UInt16(strtoul(self.ledBrightnessColorCode, nil, 16)))
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            //Night Color Code
            if self.bleThresHoldWritetype == .BlueToothNightColorAlertWrite { // Color Code
                //peripheral.discoverDescriptors(for: characteristic)
                if characteristic.uuid == CHARACTERISTIC_NIGHT_LIGHT_COLOR_UUID{
                    var vint:Int8 = Int8(self.nightColorCode)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int8>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_NIGHT_LIGHT_START_TIME_UUID{
                    var vint:Int32 = Int32(self.nightColorStartTime)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_NIGHT_LIGHT_END_TIME_UUID{
                    var vint:Int32 = Int32(self.nightColorEndTime)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int32>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid == CHARACTERISTIC_LED_BRIGHTNESS_COLOR_UUID{
                    var vint:Int16 = Int16(UInt16(strtoul(self.ledBrightnessColorCode, nil, 16)))
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
            //Temp offset Code
            if self.bleThresHoldWritetype == .BlueToothTempOffsetWrite { // Color Code
                //peripheral.discoverDescriptors(for: characteristic)
                if characteristic.uuid == CHARACTERISTIC_TEMP_OFFSET_UUID{
                    var vint:Int16 = Int16(self.tempOffset * 100)
                    let intData = Data(bytes: &vint, count: MemoryLayout<Int16>.size)
                    peripheral.writeValue(intData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        if self.bleThresHoldWritetype == .BlueToothThresHoldWriteTempearture { //Temperature
            
        }
        /////// AIRPRESSURE
        if self.bleThresHoldWritetype == .BlueToothThresHoldWriteAirpressure {
            
            
        }
        //Night Color Code
        if self.bleThresHoldWritetype == .BlueToothNightColorAlertWrite { // Color Code
            
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error discovering services: error")
            self.centralManager?.stopScan()
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteHumidity {
                if self.didWriteStatus > 4 {
                    return
                }else {
                    self.delegateThresHoldBleManagerState?.getThresHoldBLEManagerBleState(isConnectedBLEState: false)
                }
            }else {
                self.delegateThresHoldBleManagerState?.getThresHoldBLEManagerBleState(isConnectedBLEState: false)
            }
            return
        }
        
        //for characteristic in self.theService?.characteristics ?? [] {
        /////// Radon
        if self.bleThresHoldWritetype == .BlueToothThresHoldWriteRadon {
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_WARNING_RADON_LEVEL_UUID{
                print("Radon Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HAZARD_RADON_LEVEL_UUID{
                print("Radon Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if self.didWriteStatus == 2 {
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        /////// VOC
        if self.bleThresHoldWritetype == .BlueToothThresHoldWriteVOC {
            
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_WARNING_TVOC_LEVEL_UUID{
                print("VOC Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HAZARD_TVOC_LEVEL_UUID{
                print("VOC Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if self.didWriteStatus == 2 {
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        /////// ECO
        if self.bleThresHoldWritetype == .BlueToothThresHoldWriteECO {
            
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_WARNING_ECO2_LEVEL_UUID{
                print("ECO Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HAZARD_ECO2_LEVEL_UUID{
                print("ECO Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if self.didWriteStatus == 2 {
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        /////// Temperature
        if self.bleThresHoldWritetype == .BlueToothThresHoldWriteTempearture {
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_WARNING_TEMPERARUTE_LEVEL_UUID{
                print("Temperature Low Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_WARNING_TEMPERARUTE_LEVEL_UUID{
                print("Temperature High Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_ALERT_TEMPERARUTE_LEVEL_UUID{
                print("Temperature Low Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_ALERT_TEMPERARUTE_LEVEL_UUID{
                print("Temperature High Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if self.didWriteStatus == 4 {
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        /////// AIRPRESSURE
        if self.bleThresHoldWritetype == .BlueToothThresHoldWriteAirpressure {
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_WARNING_AIR_PRESSURE_LEVEL_UUID{
                print("AIRPRESSURE Low Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_WARNING_AIR_PRESSURE_LEVEL_UUID{
                print("AIRPRESSURE High Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_ALERT_AIR_PRESSURE_LEVEL_UUID{
                print("AIRPRESSURE Low Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_ALERT_AIR_PRESSURE_LEVEL_UUID{
                print("AIRPRESSURE High Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if self.didWriteStatus == 4 {
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        /////// Humidity
        if self.bleThresHoldWritetype == .BlueToothThresHoldWriteHumidity {
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_WARNING_HUMIDITY_LEVEL_UUID{
                print("Humidity Low Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_WARNING_HUMIDITY_LEVEL_UUID{
                print("Humidity High Warning Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_LOW_ALERT_HUMIDITY_LEVEL_UUID{
                print("Humidity Low Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_THRESHOLD_HIGH_ALERT_HUMIDITY_LEVEL_UUID{
                print("Humidity High Alert Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if self.didWriteStatus == 4 {
                self.didWriteStatus = self.didWriteStatus + 1
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        //OK Color Code
        if self.bleThresHoldWritetype == .BlueToothColorOKWrite { // Color Code
            if characteristic.uuid == CHARACTERISTIC_AIR_QUALITY_NORMAL_COLOR_UUID{
                print("OK Color Message sent")
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        //Warning Color Code
        if self.bleThresHoldWritetype == .BlueToothColorWarningWrite { // Color Code
            if characteristic.uuid == CHARACTERISTIC_AIR_QUALITY_WARNING_COLOR_UUID{
                print("Warning Color Message sent")
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        //Alert Color Code
        if self.bleThresHoldWritetype == .BlueToothColorAlertWrite { // Color Code
            if characteristic.uuid == CHARACTERISTIC_AIR_QUALITY_HAZARD_COLOR_UUID{
                print("Alert Color Message sent")
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        //Night Color Code
        if self.bleThresHoldWritetype == .BlueToothNightColorAlertWrite { // Color Code
            if characteristic.uuid == CHARACTERISTIC_NIGHT_LIGHT_COLOR_UUID{
                print("NIGHT_LIGHT_COLOR Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_NIGHT_LIGHT_START_TIME_UUID{
                print("NIGHT_LIGHT_START_TIME Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if characteristic.uuid == CHARACTERISTIC_NIGHT_LIGHT_END_TIME_UUID{
                print("NIGHT_LIGHT_END_TIME Color Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if self.didWriteStatus == 3 {
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        if self.bleThresHoldWritetype == .BlueToothTempOffsetWrite { // Color Code
            if characteristic.uuid == CHARACTERISTIC_TEMP_OFFSET_UUID{
                print("CHARACTERISTIC_TEMP_OFFSET Message sent")
                self.didWriteStatus = self.didWriteStatus + 1
            }
            if self.didWriteStatus == 1 {
                self.delegateThresHoldBleWriteState?.thresHoldWriteStatus(writeStatus: true)
            }
        }
        
        //}
        
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
        for characteristic in self.theService?.characteristics ?? [] {
            if self.bleThresHoldWritetype == .BlueToothThresHoldWriteRadon {
                switch characteristic.uuid {
                case wifi_Connected_CharacteristicCBUUID:
                    print("")
                default:
                    print("")
                }
            }else {
                
            }
        }
    }
    
}

