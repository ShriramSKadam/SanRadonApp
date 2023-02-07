//
//  ColorsOKViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/12/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreBluetooth

class ColorsOKViewController: LTSettingBaseViewController {
    
    
    @IBOutlet weak var lblOKDeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var btnDeviceNameOK: UIButton!
    //Color Option Label
    @IBOutlet weak var lblColorOptionOK: LTCellSubTitleLabel!
    //Color Option Button
    @IBOutlet weak var btnColorOptionOK: UIButton!
    //Apply All Button
    @IBOutlet weak var btnOKApplyAll: UIButton!
    //Apply All ImgView Selection
    @IBOutlet weak var viewOKApplyAllView: LTCellView!
    //Reset Button Alerts
    @IBOutlet weak var btnOKReaset: UIButton!
    
    //Save Button Alerts
    @IBOutlet weak var btnOKSave: UIButton!
    
    @IBOutlet weak var imgViewOKApplyAllView: UIImageView!
    
    @IBOutlet weak var stackViewBottom: UIStackView!
    @IBOutlet weak var stackViewBottomheightConstant: NSLayoutConstraint!
    @IBOutlet weak var lblBottomHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var imgViewDevice: UIImageView!
    
    
    //Switch Button Alerts
    @IBOutlet weak var switchColor: UISwitch!
    @IBOutlet weak var stackViewColor: UIStackView!
    @IBOutlet weak var stackViewColorHeight: NSLayoutConstraint!
    @IBOutlet weak var imgViewTip: UIImageView!
    @IBOutlet weak var lblImgTip: UILabel!
    
    @IBOutlet weak var sliderOkColorComponent: UISlider!
    @IBOutlet weak var sliderOkColorStackView: UIStackView!
    
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedColorCode:String = ""
    var selectedColorValue:String = ""
    var arrOKColorCodeData:[RealmColorSetting] = []
    var isColorOKApplyAll:Bool = false
    var isColorOKOnOff:Bool = false
    
    var arrCurrentDevice:[RealmDeviceList] = []
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    var serialDeviceName:String = ""
    var isFromInitialAddDevice:Bool = false
    
    var previousColorCode:String = ""
    var strOffsetColorLEDValue:String =  "5"
    var writeOKColorLEDValue:String =  "5"
    var previousColorLEDValue:String =  "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblOKDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceDataOKColor(deviceID: self.selectedDeviceID)
        self.viewOKApplyAllView.isHidden = true
        self.loadColorValues()
        self.viewOKApplyAllView.isHidden = false
        //self.imgViewOKApplyAllView.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewOKApplyAllView.image = UIImage.init(named:CELL_BLANK_CHECKMARK)!

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
    
    func loadColorValues() {
        
        self.btnColorOptionOK.addTarget(self, action:#selector(self.btnColorOptionOKTap(_sender:)), for: .touchUpInside)
        self.btnDeviceNameOK.addTarget(self, action:#selector(self.btnDeviceNameOKTap(_sender:)), for: .touchUpInside)
        self.btnOKApplyAll.addTarget(self, action:#selector(self.btnOKApplyAllTap(_sender:)), for: .touchUpInside)
        self.btnOKReaset.addTarget(self, action:#selector(self.btnOKReasetTap(_sender:)), for: .touchUpInside)
        self.btnOKSave.addTarget(self, action:#selector(self.btnSaveOkTap(_sender:)), for: .touchUpInside)
    }
    
    func getDeviceDataOKColor(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrOKColorCodeData.removeAll()
        self.arrOKColorCodeData = RealmDataManager.shared.readColorDataValues(deviceID: deviceID, colorType: ColorType.ColorOk.rawValue)
        if self.arrOKColorCodeData.count > 0 {
            self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
            self.selectedColorCode =  self.arrOKColorCodeData[0].color_code
            self.selectedColorValue = self.readColorValueData(colorCodeValue: self.arrOKColorCodeData[0].color_code)
            self.lblOKDeviceName.text = self.selectedDeviceName
            self.lblColorOptionOK.text = self.selectedColorValue
            self.isColorOKOnOff = self.arrOKColorCodeData[0].color_code_disable
            self.strOffsetColorLEDValue = self.arrOKColorCodeData[0].color_led_brightness
            self.swicthhandle(isSwicth: self.isColorOKOnOff)
            self.getDeviceLedBrightnessValue(colorSetting: self.arrOKColorCodeData[0])
        }else {
            self.lblOKDeviceName.text = "Select"
            self.lblColorOptionOK.text = "Select"
            self.lblColorOptionOK.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblOKDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.isColorOKOnOff = true
            self.swicthhandle(isSwicth: self.isColorOKOnOff)
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
        self.btnDeviceNameOK.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
}

extension ColorsOKViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnColorOptionOKTap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownCOLOR_CODE)
    }
    
    @objc func btnDeviceNameOKTap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    
    @objc func btnOKApplyAllTap(_sender:UIButton) {
        if self.isColorOKApplyAll == false {
            self.isColorOKApplyAll = true
            self.imgViewOKApplyAllView.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.imgViewOKApplyAllView.image = UIImage.init(named:CELL_BLANK_CHECKMARK)!

            //self.imgViewOKApplyAllView.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.isColorOKApplyAll = false
        }
    }
    
    @objc func btnOKReasetTap(_sender:UIButton) {
        self.readResetOKColor()
    }
    
    func showDropDownDeviceList(appDropDownType:AppDropDownType) {
        let dropDownVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LTDropDownViewController") as! LTDropDownViewController
        dropDownVC.dropDownType = appDropDownType
        dropDownVC.dropDownColorDelegate = self
        dropDownVC.dropDownDeviceList = self
        dropDownVC.modalPresentationStyle = .overFullScreen
        self.present(dropDownVC, animated: false, completion: nil)
    }
    @objc func btnSaveOkTap(_sender:UIButton) {
        if self.switchColor.isOn == false {
            self.selectedColorCode = "0x00"
        }
        self.writeOKColorValueBle()
    }
    @objc func btnThersHoldeAIRPRESSUREBtnReasetTap(_sender:UIButton) {
        self.readResetOKColor()
    }
}
extension ColorsOKViewController: LTDropDownThersHoldDelegate,LTDropDownColorDelegate,LTDropDownDeviceListDelegate {
    
    func selectedThresHoldValue(selectedValue: String) {
        
    }
    
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int) {
        self.lblOKDeviceName?.text = selectedDeviceName
        self.selectedDeviceID = selectedDeviceID
        self.getDeviceDataOKColor(deviceID: self.selectedDeviceID)
        self.lblOKDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    func selectedColor(selectedColor:String,selectedColorCode:String) {
        self.lblColorOptionOK?.text = selectedColor
        self.selectedColorCode = selectedColorCode
    }
    
    func readResetOKColor()  {
        self.lblColorOptionOK?.text = "Green"
        self.selectedColorCode = "#32C772"
        self.sliderOkColorComponent.setValue(Float(5), animated: true)
        self.strOffsetColorLEDValue = "5"
        self.swicthhandle(isSwicth: false)
    } 
}
extension ColorsOKViewController {
    
    func saveOkColorAPINewGood(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isColorOKApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        if deviceData.wifi_status == true {
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "OkColorCode", value: self.selectedColorCode, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "OkColorLedbrightness", value: self.strOffsetColorLEDValue, deviceId: Int64(deviceData.device_id)))
                        }
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            if self.switchColor.isOn == false {
                                self.selectedColorCode = "#32C772"
                            }
                            RealmDataManager.shared.updateAllDeviceFilterData(colorType: ColorType.ColorOk.rawValue, colorCode: self.selectedColorCode, isColorCodeOnOff: !self.switchColor.isOn, brightnessLEDValue: self.strOffsetColorLEDValue)
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
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "OkColorCode", value: self.selectedColorCode, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "OkColorLedbrightness", value: self.strOffsetColorLEDValue, deviceId: Int64(self.selectedDeviceID)))
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    self.hideActivityIndicator(self.view)
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    if error == nil {
                        if self.switchColor.isOn == false {
                            self.selectedColorCode = "#32C772"
                        }
                        RealmDataManager.shared.updateFilterData(deviceID: self.selectedDeviceID, colorType: ColorType.ColorOk.rawValue, colorCode:  self.selectedColorCode, isColorCodeOnOff: !self.switchColor.isOn, brightnessLEDValue: self.strOffsetColorLEDValue)
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
extension ColorsOKViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveOkColorAPINewGood()
        }
    }
    
    func writeOKColorValueBle()  {
        self.getLedBrightnessFormValue()
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true || self.isColorOKApplyAll == true {
                self.saveOkColorAPINewGood()
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
extension ColorsOKViewController:CBCentralManagerDelegate{
    
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
                self.writeOkColorCodeValueViaBLE(colorCode: self.getColorCodeOCTALvalue(colorValue: self.selectedColorCode), deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id, brightNessColorCode: self.writeOKColorLEDValue)
            }
        }
    }
}

extension ColorsOKViewController {
    func previousCopyconvertValuesAsPerUnits()  {
        self.previousColorCode = self.selectedColorCode
        self.previousColorLEDValue = self.strOffsetColorLEDValue
        
    }
    
    func backCompareValues() -> Bool{
        if self.arrCurrentDevice.count == 0 {
            return true
        }
        if self.previousColorCode != self.selectedColorCode || self.isColorOKApplyAll == true || self.previousColorLEDValue != self.strOffsetColorLEDValue   {
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
            self.writeOKColorValueBle()
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
extension ColorsOKViewController {
    
    func colorCodeSet()  {
        self.switchColor.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        self.lblImgTip?.text = "In this mode, only the device LED will be turned off and the mobile app color will be set to its default value, i.e. green"
        self.showHideTipMessage(isHide: self.isColorOKOnOff)
        self.swicthhandle(isSwicth: self.isColorOKOnOff)
    }
    
    @objc func switchColorStatusChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            self.stackViewColorHeight.constant = 80
            self.stackViewColor.isHidden = false
            self.showHideTipMessage(isHide: true)
            self.readResetOKColor()
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
extension ColorsOKViewController {
    
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
        self.writeOKColorLEDValue =  String(format: "0x%@%@%@%@", self.strOffsetColorLEDValue,self.isWarningLEDBrightNess,self.isAlertLEDBrightNess,self.isNightlightLEDBrightNess)
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
