//
//  TempOffsetViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/17/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreBluetooth

class TempOffsetViewController: LTSettingBaseViewController {

    @IBOutlet weak var sliderComponent: UISlider!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var btnTempOffsetSave: UIButton!
    var strOffsetValue:String =  ""
    var arrPollutantTempData:[RealmThresHoldSetting] = []
    var isDeviceSelected:RealmDeviceList? = nil
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    var serialDeviceName:String = ""
    var isFromInitialAddDevice:Bool = false
    var previousTempOffset:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in -5..<6{
            let label = UILabel()
            label.text = "\(i)"
            label.textAlignment = .center
            label.textColor = ThemeManager.currentTheme().ltCellTitleColor
            stackView.addArrangedSubview(label)
        }
        self.btnTempOffsetSave.addTarget(self, action:#selector(self.btnSaveTempOffsetTap(_sender:)), for: .touchUpInside)

    }
    override func viewWillAppear(_ animated: Bool) {
        self.arrPollutantTempData = RealmDataManager.shared.readPollutantDataValues(deviceID: self.isDeviceSelected?.device_id ?? 0, pollutantType: PollutantType.PollutantTemperature.rawValue)
        
        if self.arrPollutantTempData.count != 0 {
            self.strOffsetValue = self.arrPollutantTempData[0].temp_offset
            self.previousTempOffset = self.strOffsetValue
            if self.arrPollutantTempData[0].temp_offset == "" {
                self.strOffsetValue = "0"
            }
            if let floatVal = Float(strOffsetValue) {
                sliderComponent.setValue(floatVal, animated: true)
            }
        }
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
    }
    
    @IBAction func slideValueChange(_ sender: Any) {
        let sliderObj = sender as! UISlider
        let roundOff = lroundf(sliderObj.value * 4.0)
        let value = Double(roundOff) / 4.0
        debugPrint(value)
        let finalValue = lroundf(Float(value.rounded()))
        debugPrint(finalValue)
        sliderComponent.setValue(Float(finalValue), animated: true)
        self.strOffsetValue = "\(finalValue)"
    }
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
        
    }
    
    @objc func btnSaveTempOffsetTap(_sender:UIButton) {
        self.writeTempOffsetValueBle()
    }

}

extension TempOffsetViewController {
    
    func saveThresHoldtempAPINewGood(){
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TempOffset", value: self.strOffsetValue, deviceId: Int64(self.isDeviceSelected?.device_id ?? 0)))
            SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
            DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                self.hideActivityIndicator(self.view)
                SwaggerClientAPI.basePath = getAPIBaseUrl()
                if error == nil {
                    RealmDataManager.shared.updateThresHoldTempOffSet(deviceID: self.isDeviceSelected?.device_id ?? 0, pollutantType: PollutantType.PollutantTemperature.rawValue, tempOffset: self.strOffsetValue)
                    self.navigationController?.popViewController(animated: true)
                    Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
                    self.navigationController?.popViewController(animated: true)
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            })
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}

extension TempOffsetViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveThresHoldtempAPINewGood()
        }
    }
    
    func writeTempOffsetValueBle()  {
        if self.isDeviceSelected?.wifi_status == true {
            self.saveThresHoldtempAPINewGood()
        }else {
            self.scanCheckCount = 0
            self.isWriteCompleted = 0
            self.scanBLEDevices()
        }
    }
}
// MARK: BLE Scanning
extension TempOffsetViewController:CBCentralManagerDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("Please turn on bluetooth")
            Helper.shared.showSnackBarAlert(message: "Please turn on bluetooth", type: .Failure)
            break
        }
    }
    
    func scanBLEDevices() {
        Helper.shared.removeBleutoothConnection()
        self.showActivityIndicator(self.view, isShow: false, isShowText: "Trying to connect device via BLE")
        self.peripherals.removeAll()
        self.manager = CBCentralManager(delegate: self, queue: nil)
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if self.scanCheckCount != 30 {
                self.hideActivityIndicator(self.view)
                self.stopScanForBLEDevices()
                self.showBleNotConnectAlert()
            }
        }
    }
    
    func stopScanForBLEDevices() {
        manager?.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //pass reference to connected peripheral to parent view
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        print(peripheral.name ?? "")
        if(!peripherals.contains(peripheral)) {
            if peripheral.name != nil {
                if peripheral.name?.lowercased().contains("luft") == true{
                    self.peripherals.append(peripheral)
                    self.disCoverPeripheral = peripheral
                }
            }
            textLog.write("\(String(describing: peripheral.name))")
        }
        if self.peripherals.contains(where: { $0.name == self.isDeviceSelected?.serial_id }) == true{
            self.scanCheckCount = 30
            self.stopScanForBLEDevices()
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Device connected via Bluetooth")
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on device")
                self.writeTempOffsetValueViaBLE(tempOffsetValue: (Int(self.strOffsetValue) ?? 0 * 100), deviceIDSetting: self.isDeviceSelected?.device_id ?? 0, deviceSerialID: self.isDeviceSelected?.serial_id ?? "")
            }
        }
    }
    
}

extension TempOffsetViewController {
    
    
    func backCompareValues() -> Bool{
        
        if self.arrPollutantTempData.count == 0 {
           return true
        }
        if self.previousTempOffset != self.strOffsetValue {
            return false
        }
        return true
    }
    
    
    func backValidationAlert()  {
        self.hideActivityIndicator(self.view)
        let titleString = NSAttributedString(string: "Confirmation", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string:"Do you want to save changes?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "Yes", style: .cancel, handler: { action in
            self.writeTempOffsetValueBle()
        })
        alert.addAction(cancel)
        let save = UIAlertAction(title: "No", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(save)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}
