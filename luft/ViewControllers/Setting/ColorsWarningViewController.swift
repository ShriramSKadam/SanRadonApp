//
//  ColorsWarningViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/12/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreBluetooth

class ColorsWarningViewController: LTSettingBaseViewController {
    
    @IBOutlet weak var lblWarningDeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var btnDeviceNameWarning: UIButton!
    //Color Option Label
    @IBOutlet weak var lblColorOptionWarning: LTCellSubTitleLabel!
    //Color Option Button
    @IBOutlet weak var btnColorOptionWarning: UIButton!
    //Apply All Button
    @IBOutlet weak var btnWarningApplyAll: UIButton!
    //Apply All ImgView Selection
    @IBOutlet weak var viewWarningApplyAllView: LTCellView!
    //Reset Button Alerts
    @IBOutlet weak var btnWarningReaset: UIButton!
    //Save Button Alerts
    @IBOutlet weak var btnWarningColorSave: UIButton!
    
    @IBOutlet weak var imgViewWarningApplyAllView: UIImageView!
    
    @IBOutlet weak var stackViewBottom: UIStackView!
    @IBOutlet weak var stackViewBottomheightConstant: NSLayoutConstraint!
    @IBOutlet weak var lblBottomHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var imgViewDevice: UIImageView!
    var isColorWarningOnOff:Bool = false
    
    //Switch Button Alerts
    @IBOutlet weak var switchColor: UISwitch!
    @IBOutlet weak var stackViewColor: UIStackView!
    @IBOutlet weak var stackViewColorHeight: NSLayoutConstraint!
    @IBOutlet weak var imgViewTip: UIImageView!
    @IBOutlet weak var lblImgTip: UILabel!
    
    var colorType:ColorType = .ColorWarning
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedColorCode:String = ""
    var selectedColorValue:String = ""
    var arrWarningColorCodeData:[RealmColorSetting] = []
    var isColorWarningApplyAll:Bool = false
    
    var arrCurrentDevice:[RealmDeviceList] = []
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    var serialDeviceName:String = ""
    var isFromInitialAddDevice:Bool = false
    
    var previousColorCode:String = ""
    @IBOutlet weak var sliderOkColorComponent: UISlider!
    @IBOutlet weak var sliderOkColorStackView: UIStackView!
    var strOffsetColorLEDValue:String =  "5"
    var previousColorLEDValue:String =  "5"
    var writeWarningColorLEDValue:String =  "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblWarningDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceDataWarningColor(deviceID: self.selectedDeviceID)
        self.viewWarningApplyAllView.isHidden = true
        self.loadColorWarningValues()
        self.viewWarningApplyAllView.isHidden = false
        //self.imgViewWarningApplyAllView.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewWarningApplyAllView.image = UIImage.init(named:CELL_BLANK_CHECKMARK)!

        self.colorCodeSet()
        self.loadSliderDefaultValues()
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    
    func loadColorWarningValues() {
        self.btnDeviceNameWarning.addTarget(self, action:#selector(self.btnDeviceNameWarningTap(_sender:)), for: .touchUpInside)
        self.btnColorOptionWarning.addTarget(self, action:#selector(self.btnColorOptionWarningTap(_sender:)), for: .touchUpInside)
        self.btnWarningApplyAll.addTarget(self, action:#selector(self.btnWarningApplyAllTap(_sender:)), for: .touchUpInside)
        self.btnWarningReaset.addTarget(self, action:#selector(self.btnWarningReasetTap(_sender:)), for: .touchUpInside)
        self.btnWarningColorSave.addTarget(self, action:#selector(self.btnWarningColorSaveTap(_sender:)), for: .touchUpInside)
        
    }
    
    func getDeviceDataWarningColor(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrWarningColorCodeData.removeAll()
        self.arrWarningColorCodeData = RealmDataManager.shared.readColorDataValues(deviceID: deviceID, colorType: self.colorType.rawValue)
        if self.arrWarningColorCodeData.count > 0 {
            self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
            self.selectedColorCode =  self.arrWarningColorCodeData[0].color_code
            self.selectedColorValue = self.readColorValueData(colorCodeValue: self.arrWarningColorCodeData[0].color_code)
            self.lblWarningDeviceName.text = self.selectedDeviceName
            self.lblColorOptionWarning.text = self.selectedColorValue
            self.isColorWarningOnOff = self.arrWarningColorCodeData[0].color_code_disable
            self.strOffsetColorLEDValue = self.arrWarningColorCodeData[0].color_led_brightness
            self.getDeviceLedBrightnessValue(colorSetting: self.arrWarningColorCodeData[0])
            
            self.swicthhandle(isSwicth: self.isColorWarningOnOff)
            
        }else {
            self.lblWarningDeviceName.text = "Select"
            self.lblColorOptionWarning.text = "Select"
            self.lblWarningDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblColorOptionWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.isColorWarningOnOff = true
            self.swicthhandle(isSwicth: self.isColorWarningOnOff)
        }
        self.previousCopyconvertValuesAsPerUnits()
        self.sliderOkColorComponent.value = self.strOffsetColorLEDValue.toFloat() ?? 0.0
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        if self.isFromInitialAddDevice{
            self.isFromInitialAddDeviceView()
        }
    }
    
    func isFromInitialAddDeviceView()  {
        self.stackViewBottom?.isHidden = true
        self.stackViewBottomheightConstant?.constant = 0.0
        self.lblBottomHeightConstant?.constant = 0.0
        self.btnDeviceNameWarning.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
}

extension ColorsWarningViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnColorOptionWarningTap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownCOLOR_CODE)
    }
    
    @objc func btnDeviceNameWarningTap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    @objc func btnWarningApplyAllTap(_sender:UIButton) {
        if self.isColorWarningApplyAll == false {
            self.isColorWarningApplyAll = true
            self.imgViewWarningApplyAllView.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.imgViewWarningApplyAllView.image = UIImage.init(named:CELL_BLANK_CHECKMARK)!

            //self.imgViewWarningApplyAllView.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.isColorWarningApplyAll = false
        }
    }
    
    @objc func btnWarningReasetTap(_sender:UIButton) {
        self.readResetWarningColor()
    }
    
    func showDropDownDeviceList(appDropDownType:AppDropDownType) {
        let dropDownVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LTDropDownViewController") as! LTDropDownViewController
        dropDownVC.dropDownType = appDropDownType
        dropDownVC.dropDownColorDelegate = self
        dropDownVC.dropDownThersHoldDelegate = self
        dropDownVC.dropDownDeviceList = self
        dropDownVC.modalPresentationStyle = .overFullScreen
        self.present(dropDownVC, animated: false, completion: nil)
    }
    
    @objc func btnWarningColorSaveTap(_sender:UIButton) {
        if self.switchColor.isOn == false {
            self.selectedColorCode = "0x00"
        }
        self.writeWarningColorValueBle()
    }
}
extension ColorsWarningViewController: LTDropDownThersHoldDelegate,LTDropDownColorDelegate,LTDropDownDeviceListDelegate {
    
    
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int) {
        self.lblWarningDeviceName?.text = selectedDeviceName
        self.selectedDeviceID = selectedDeviceID
        self.getDeviceDataWarningColor(deviceID: self.selectedDeviceID)
        self.lblWarningDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    func selectedThresHoldValue(selectedValue:String) {
        self.lblWarningDeviceName?.text = selectedValue
    }
    
    func selectedColor(selectedColor:String,selectedColorCode:String) {
        self.lblColorOptionWarning?.text = selectedColor
        self.selectedColorCode = selectedColorCode
    }
    
    func readResetWarningColor()  {
        self.lblColorOptionWarning?.text = "Yellow"
        self.selectedColorCode = "#DEBF54"
        self.sliderOkColorComponent.setValue(Float(5), animated: true)
        self.strOffsetColorLEDValue = "5"
        self.swicthhandle(isSwicth: false)
    }
}

extension ColorsWarningViewController {
    
    func saveWarningColorAPINewGood(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isColorWarningApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        if deviceData.wifi_status == true {
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "WarningColorCode", value: self.selectedColorCode, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "WaringColorLedbrightness", value: self.strOffsetColorLEDValue, deviceId: Int64(deviceData.device_id)))
                        }
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            if self.switchColor.isOn == false {
                                self.selectedColorCode = "#DEBF54"
                            }
                            RealmDataManager.shared.updateAllDeviceFilterData(colorType: self.colorType.rawValue, colorCode: self.selectedColorCode, isColorCodeOnOff: !self.switchColor.isOn, brightnessLEDValue: self.strOffsetColorLEDValue)
                            if RealmDataManager.shared.getAllDeviceWifiStatus()  {
                                self.showApplyToAllUpdateAlert()
                            }else {
                                Helper().showSnackBarAlert(message: LUFT_DETAILS_UPDATED, type: .Success)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else {
                            Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                        }
                    })
                }
            }else {
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "WarningColorCode", value: self.selectedColorCode, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "WaringColorLedbrightness", value: self.strOffsetColorLEDValue, deviceId: Int64(self.selectedDeviceID)))
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    self.hideActivityIndicator(self.view)
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    if error == nil {
                        if self.switchColor.isOn == false {
                            self.selectedColorCode = "#DEBF54"
                        }
                        RealmDataManager.shared.updateFilterData(deviceID: self.selectedDeviceID, colorType: self.colorType.rawValue, colorCode:  self.selectedColorCode, isColorCodeOnOff: !self.switchColor.isOn, brightnessLEDValue: self.strOffsetColorLEDValue)
                        Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
                        self.navigationController?.popViewController(animated: true)
                    }else {
                        Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    }
                })
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }    
}
extension ColorsWarningViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveWarningColorAPINewGood()
        }
    }
    
    func writeWarningColorValueBle()  {
        self.getLedBrightnessFormValue()
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true || self.isColorWarningApplyAll == true {
                self.saveWarningColorAPINewGood()
            }else {
                self.serialDeviceName = self.arrCurrentDevice[0].serial_id
                self.scanCheckCount = 0
                self.isWriteCompleted = 0
                self.scanBLEDevices()
            }
        }
        
    }
}
// MARK: BLE Scanning
extension ColorsWarningViewController:CBCentralManagerDelegate{
    
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
        if self.peripherals.contains(where: { $0.name == self.serialDeviceName }) == true{
            self.scanCheckCount = 30
            self.stopScanForBLEDevices()
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Device connected via Bluetooth")
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on device")
                self.writeWarningColorCodeValueViaBLE(colorCode: self.getColorCodeOCTALvalue(colorValue: self.selectedColorCode), deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id,brightNessColorCode: self.writeWarningColorLEDValue)
            }
        }
    }
}
extension ColorsWarningViewController {
    
    func previousCopyconvertValuesAsPerUnits()  {
        self.previousColorCode = self.selectedColorCode
        self.previousColorLEDValue = self.strOffsetColorLEDValue
    }
    
    func backCompareValues() -> Bool{
        if self.arrCurrentDevice.count == 0 {
            return true
        }
        if self.previousColorCode != self.selectedColorCode || self.isColorWarningApplyAll == true || self.previousColorLEDValue != self.strOffsetColorLEDValue {
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
            self.writeWarningColorValueBle()
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
extension ColorsWarningViewController {
    
    func colorCodeSet()  {
        self.switchColor.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        self.lblImgTip?.text = "In this mode, only the device LED will be turned off and the mobile app color will be set to its default value, i.e. yellow"
        self.showHideTipMessage(isHide: true)
        self.swicthhandle(isSwicth: self.isColorWarningOnOff)
    }
    
    @objc func switchColorStatusChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            self.stackViewColorHeight.constant = 80
            self.stackViewColor.isHidden = false
            self.showHideTipMessage(isHide: true)
            self.readResetWarningColor()
        }else{
            self.stackViewColorHeight.constant = 0
            self.stackViewColor.isHidden = true
            self.showHideTipMessage(isHide: false)
        }
    }
    
    func showHideTipMessage(isHide:Bool)  {
        self.lblImgTip?.isHidden = isHide
        self.imgViewTip?.isHidden = isHide
    }
    
    func swicthhandle(isSwicth:Bool)  {
        self.switchColor.isOn = !isSwicth
        if  self.switchColor.isOn {
            self.stackViewColorHeight.constant = 80
            self.stackViewColor.isHidden = false
            self.showHideTipMessage(isHide: true)
        }else{
            self.stackViewColorHeight.constant = 0
            self.stackViewColor.isHidden = true
            self.showHideTipMessage(isHide: false)
        }
    }
}
extension ColorsWarningViewController {
    
    func loadSliderDefaultValues()  {
        for i in 1..<6{
            let label = UILabel()
            label.text = "\(i)"
            label.textAlignment = .center
            label.textColor = ThemeManager.currentTheme().ltCellTitleColor
            self.sliderOkColorStackView?.addArrangedSubview(label)
        }
    }
    
    @IBAction func slideValueChange(_ sender: Any) {
        let sliderObj = sender as! UISlider
        let roundOff = lroundf(sliderObj.value * 4.0)
        let value = Double(roundOff) / 4.0
        debugPrint(value)
        let finalValue = lroundf(Float(value.rounded()))
        debugPrint(finalValue)
        self.sliderOkColorComponent.setValue(Float(finalValue), animated: true)
        self.strOffsetColorLEDValue = "\(finalValue)"
    }
    
    func getLedBrightnessFormValue() {
        self.writeWarningColorLEDValue =  String(format: "0x%@%@%@%@", self.isOkLEDBrightNess,self.strOffsetColorLEDValue,self.isAlertLEDBrightNess,self.isNightlightLEDBrightNess)
    }
    
    func showApplyToAllUpdateAlert() {
        let titleString = NSAttributedString(string: LUFT_DETAILS_UPDATED, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: LUFT_BLUETOOTH_APPLY_ALL, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(ok)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}
