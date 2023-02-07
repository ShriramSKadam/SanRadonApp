//
//  ColorsNightLightViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/12/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreBluetooth

class ColorsNightLightViewController: LTSettingBaseViewController {
    
    @IBOutlet weak var lblNightLightDeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var btnDeviceNameNightLight: UIButton!
    //Color Option Label
    @IBOutlet weak var lblColorOptionNightLight: LTCellSubTitleLabel!
    //Color Option Button
    @IBOutlet weak var btnColorOptionNightLight: UIButton!
    //Apply All Button
    @IBOutlet weak var btnNightLightApplyAll: UIButton!
    //Apply All ImgView Selection
    @IBOutlet weak var viewNightLightApplyAllView: LTCellView!
    //Reset Button Alerts
    @IBOutlet weak var btnNightLightReaset: UIButton!
    
    //Switch Button Alerts
    @IBOutlet weak var switchColor: UISwitch!
    
    //Button StartTime End Time Alerts
    @IBOutlet weak var btnStartTime: UIButton!
    @IBOutlet weak var btnEndTime: UIButton!
    @IBOutlet weak var btnSaveNightLight: UIButton!
    @IBOutlet weak var lblStartTime: LTCellTitleLabel!
    
    @IBOutlet weak var stackViewColorHeight: NSLayoutConstraint!
    @IBOutlet weak var stackViewColor: UIStackView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var btnDonedatePicker: UIBarButtonItem!
    @IBOutlet weak var btnCanceldatePicker: UIBarButtonItem!
    @IBOutlet weak var lblEndTime: LTCellSubTitleLabel!
    
    @IBOutlet weak var imgViewNightLightApplyAllView: UIImageView!
    
    @IBOutlet weak var stackViewBottom: UIStackView!
    @IBOutlet weak var stackViewBottomheightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var lblBottomHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var imgViewDevice: UIImageView!
    
    @IBOutlet weak var lblHint: LTSettingHintLabel!
    @IBOutlet weak var lblTip: LTSettingHintLabel!
    var selectedType:SelectedFieldType? = .SelectedNone
    let dateFormatter = DateFormatter()
    let locale = NSLocale.current
    
    
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedColorCode:String = ""
    var selectedColorValue:String = ""
    
    var selectedDisplayStartTime:String = ""
    var selectedDisplayEndTime:String = ""
    
    var selectedStartTimeValue:Int = 0
    var selectedEndTimeValue:Int = 0
    
    var arrOKColorCodeData:[RealmColorSetting] = []
    var isColorNightLightApplyAll:Bool = false
    
    var selectedTodayTimeValue:Int = 0
    var selectedTimeZoneDiff:Int = 0
    
    var arrCurrentDevice:[RealmDeviceList] = []
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    var serialDeviceName:String = ""
    var isFromInitialAddDevice:Bool = false
    
    var previousColorCode:String = ""
    var previousStartTime:Int = 0
    var previousEndTime:Int = 0
    var previousIsSwitchOn:Bool = false
    
    @IBOutlet weak var sliderOkColorComponent: UISlider!
    @IBOutlet weak var sliderOkColorStackView: UIStackView!
    var strOffsetColorLEDValue:String =  "5"
    var previousColorLEDValue:String =  "5"
    var writeNightLightColorLEDValue:String =  "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.switchColor.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        self.lblNightLightDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        self.loadColorNightLightValues()
        self.dateView.isHidden = true
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceDataNightLightColor(deviceID: self.selectedDeviceID)
        self.viewNightLightApplyAllView.isHidden = true
        self.viewNightLightApplyAllView.isHidden = false
        //self.imgViewNightLightApplyAllView.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewNightLightApplyAllView.image = UIImage.init(named:CELL_BLANK_CHECKMARK)!

        self.loadSliderDefaultValues()
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    
    
    func loadColorNightLightValues() {
        self.btnDeviceNameNightLight.addTarget(self, action:#selector(self.btnDeviceNameNightLightTap(_sender:)), for: .touchUpInside)
        self.btnColorOptionNightLight.addTarget(self, action:#selector(self.btnColorOptionNightLightTap(_sender:)), for: .touchUpInside)
        self.btnNightLightApplyAll.addTarget(self, action:#selector(self.btnNightLightApplyAllTap(_sender:)), for: .touchUpInside)
        self.btnNightLightReaset.addTarget(self, action:#selector(self.btnNightLightReasetTap(_sender:)), for: .touchUpInside)
        self.btnStartTime.addTarget(self, action:#selector(self.btnStartTimeNightLightTap(_sender:)), for: .touchUpInside)
        self.btnEndTime.addTarget(self, action:#selector(self.btnEndTimeNightLightTap(_sender:)), for: .touchUpInside)
        self.btnSaveNightLight.addTarget(self, action:#selector(self.btnSaveNightLightTap(_sender:)), for: .touchUpInside)
        
        
    }
    
    func getDeviceDataNightLightColor(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrOKColorCodeData.removeAll()
        self.arrOKColorCodeData = RealmDataManager.shared.readColorDataValues(deviceID: deviceID, colorType: ColorType.ColorNightLight.rawValue)
        self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
        
        if self.arrOKColorCodeData.count > 0 {
            
            self.lblNightLightDeviceName.text = self.selectedDeviceName
            
            
            self.selectedStartTimeValue =  self.arrOKColorCodeData[0].night_light_start_time
            self.selectedEndTimeValue =  self.arrOKColorCodeData[0].night_light_end_time
            self.selectedTimeZoneDiff = RealmDataManager.shared.getDeviceData(deviceID: deviceID)[0].timeDiffrence.toInt() ?? 0
            
            let startDateTimeStamp =  self.selectedStartTimeValue + self.selectedTimeZoneDiff
            let endDateTimeStamp =  self.selectedEndTimeValue + self.selectedTimeZoneDiff
            
            let date = Date(timeIntervalSince1970: TimeInterval(startDateTimeStamp))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "HH:mm"
            self.selectedStartTimeValue = dateFormatter.string(from: date).secondFromString
            let date1 = Date(timeIntervalSince1970: TimeInterval(endDateTimeStamp))
            let dateFormatter1 = DateFormatter()
            dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter1.locale = NSLocale.current
            dateFormatter1.dateFormat = "HH:mm"
            self.selectedEndTimeValue = dateFormatter.string(from: date1).secondFromString
            
            self.selectedDisplayStartTime = self.readIntToSecondsValueData(timeValue: self.selectedStartTimeValue)
            self.selectedDisplayEndTime = self.readIntToSecondsValueData(timeValue: self.selectedEndTimeValue)
            self.lblStartTime.text = self.selectedDisplayStartTime
            self.lblEndTime.text = self.selectedDisplayEndTime
            
            self.selectedColorCode =  self.arrOKColorCodeData[0].color_code
            self.strOffsetColorLEDValue = self.arrOKColorCodeData[0].color_led_brightness
            self.getDeviceLedBrightnessValue(colorSetting: self.arrOKColorCodeData[0])
            
            if self.selectedColorCode == "" || self.selectedColorCode.lowercased() == "select" || self.selectedColorCode == "0x00" {
                self.switchColor.isOn = false
                self.stackViewColorHeight.constant = 0
                self.stackViewColor.isHidden = true
                self.lblColorOptionNightLight.text = "OFF"
            }else {
                self.selectedColorValue = self.readColorValueData(colorCodeValue: self.arrOKColorCodeData[0].color_code)
                self.switchColor.isOn = true
                self.stackViewColorHeight.constant = 80
                self.stackViewColor.isHidden = false
                self.lblColorOptionNightLight.text = self.selectedColorValue
            }
            
        }else {
            self.lblNightLightDeviceName.text = "Select"
            self.lblColorOptionNightLight.text = "Select"
            self.lblStartTime.text = "Select"
            self.lblEndTime.text = "Select"
            self.lblNightLightDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblColorOptionNightLight.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblStartTime.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblEndTime.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.switchColor.isOn = false
            self.stackViewColorHeight.constant = 0
            self.stackViewColor.isHidden = true
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
        self.lblBottomHeightConstant?.constant = 60.0
        self.btnDeviceNameNightLight.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
}

extension ColorsNightLightViewController {
    
    @objc func switchColorStatusChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            self.stackViewColorHeight.constant = 80
            self.stackViewColor.isHidden = false
            AppSession.shared.setIsColorStatus(isShow: true)
            if self.selectedColorCode == "" || self.selectedColorCode.lowercased() == "select" || self.selectedColorCode == "0x00" {
                self.lblColorOptionNightLight?.text = "Blue"
                self.selectedColorCode = "#3E82F7"
            }
        }else{
            self.stackViewColorHeight.constant = 0
            self.stackViewColor.isHidden = true
            AppSession.shared.setIsColorStatus(isShow: false)
        }
    }
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnDeviceNameNightLightTap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    
    @objc func btnColorOptionNightLightTap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownCOLOR_CODE)
    }
    
    @objc func btnStartTimeNightLightTap(_sender:UIButton) {
        self.selectedType = .SelectedStartTime
        self.doDatePicker()
    }
    
    @objc func btnEndTimeNightLightTap(_sender:UIButton) {
        self.selectedType = .SelectedEndTime
        self.doDatePicker()
    }
    
    @objc func btnNightLightApplyAllTap(_sender:UIButton) {
        if self.isColorNightLightApplyAll == false {
            self.isColorNightLightApplyAll = true
            self.imgViewNightLightApplyAllView.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            self.imgViewNightLightApplyAllView.image = UIImage.init(named:CELL_BLANK_CHECKMARK)!

            //self.imgViewNightLightApplyAllView.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.isColorNightLightApplyAll = false
        }
    }
    
    @objc func btnNightLightReasetTap(_sender:UIButton) {
        self.readResetNightLightColor()
    }
    
    @objc func btnSaveNightLightTap(_sender:UIButton) {
        self.writeNightValueBle()
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
    
    
}
extension ColorsNightLightViewController: LTDropDownThersHoldDelegate,LTDropDownColorDelegate,LTDropDownDeviceListDelegate {
    
    func selectedDeviceList(selectedDeviceName: String, selectedDeviceID: Int) {
        self.selectedDeviceID = selectedDeviceID
        self.selectedDeviceName = selectedDeviceName
        self.getDeviceDataNightLightColor(deviceID: self.selectedDeviceID)
        self.lblNightLightDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    
    func selectedThresHoldValue(selectedValue:String) {
        self.lblNightLightDeviceName?.text = selectedValue
    }
    
    func selectedColor(selectedColor:String,selectedColorCode:String) {
        self.lblColorOptionNightLight?.text = selectedColor
        self.selectedColorCode = selectedColorCode
    }
    
    func readResetNightLightColor()  {
        self.lblColorOptionNightLight?.text = "Blue"
        self.selectedColorCode = "#3E82F7"
        self.sliderOkColorComponent.setValue(Float(5), animated: true)
        self.strOffsetColorLEDValue = "5"
        self.selectedStartTimeValue = 79200
        self.selectedEndTimeValue = 28800
        self.selectedDisplayStartTime = self.readIntToSecondsValueData(timeValue: self.selectedStartTimeValue)
        self.selectedDisplayEndTime = self.readIntToSecondsValueData(timeValue: self.selectedEndTimeValue)
        self.lblStartTime.text = self.selectedDisplayStartTime
        self.lblEndTime.text = self.selectedDisplayEndTime
    }
    
    func doDatePicker(){
        // DatePicker
        self.datePickerView?.backgroundColor = UIColor.white
        self.datePickerView?.datePickerMode = UIDatePicker.Mode.time
        if self.selectedType == .SelectedStartTime {
            let date1 = Date(timeIntervalSince1970: TimeInterval(self.selectedStartTimeValue - self.selectedTimeZoneDiff))
            self.datePickerView?.setDate(date1, animated: false)
        }
        if self.selectedType == .SelectedEndTime{
            let date1 = Date(timeIntervalSince1970: TimeInterval(self.selectedEndTimeValue - self.selectedTimeZoneDiff))
            self.datePickerView?.setDate(date1, animated: false)
        }
        self.dateView.isHidden = false
    }
    
    
    @IBAction func doneClick() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        self.dateView.isHidden = true
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        print(dateFormatter.string(from: self.datePickerView.date))
        
        
        if self.selectedType == .SelectedStartTime {
            self.lblStartTime?.text = dateFormatter.string(from: self.datePickerView.date)
            self.selectedDisplayStartTime = self.lblStartTime?.text ?? ""
            dateFormatter.dateFormat = "HH:mm"
            self.selectedStartTimeValue = dateFormatter.string(from: self.datePickerView.date).secondFromString
        }
        if self.selectedType == .SelectedEndTime{
            self.lblEndTime?.text = dateFormatter.string(from: self.datePickerView.date)
            dateFormatter.dateFormat = "HH:mm"
            self.selectedDisplayEndTime = self.lblEndTime?.text ?? ""
            self.selectedEndTimeValue = dateFormatter.string(from: self.datePickerView.date).secondFromString
        }
    }
    
    @IBAction func cancelClick() {
        self.dateView.isHidden = true
    }
}

extension ColorsNightLightViewController {
    
    func getTodayTimeValue()  {
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        let dateAtMidnight = calendar.startOfDay(for: Date())
        let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
        self.selectedTodayTimeValue = 0
        self.selectedTodayTimeValue = Int(secondsSince1970)
    }
    
    func saveNightLightColorAPINewGood(){
        
        self.getTodayTimeValue()
        
        if  self.switchColor.isOn {
            if self.selectedColorCode == "" || self.selectedColorCode == "OFF" || self.selectedColorCode == "0x00"{
                self.lblColorOptionNightLight?.text = "Blue"
                self.selectedColorCode = "#3E82F7"
            }
        }else {
            self.selectedColorCode = "0x00"
        }
        
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isColorNightLightApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                var startTimeValueAPI = self.selectedStartTimeValue
                var endTimeValueAPI = self.selectedEndTimeValue
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        self.selectedTimeZoneDiff = 0
                        startTimeValueAPI = 0
                        endTimeValueAPI = 0
                        if deviceData.wifi_status == true {
                            self.selectedTimeZoneDiff = RealmDataManager.shared.getDeviceData(deviceID: deviceData.device_id)[0].timeDiffrence.toInt() ?? 0
                            startTimeValueAPI = (self.selectedTodayTimeValue + self.selectedStartTimeValue) - self.selectedTimeZoneDiff
                            endTimeValueAPI = (self.selectedTodayTimeValue + self.selectedEndTimeValue) - self.selectedTimeZoneDiff
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "NightlightColorCode", value: String(format: "%@", self.selectedColorCode), deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "NightColorStartTime", value: String(format: "%d", startTimeValueAPI), deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "NightColorEndTime", value: String(format: "%d", endTimeValueAPI), deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "NightLightColorLedbrightness", value: self.strOffsetColorLEDValue, deviceId: Int64(deviceData.device_id)))
                        }
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            RealmDataManager.shared.updateNightLightAllDeviceFilterData(colorType: ColorType.ColorNightLight.rawValue, colorCode:  self.selectedColorCode, startTime: startTimeValueAPI, endTime: endTimeValueAPI, isNightSwitchOn: self.switchColor.isOn, brightnessLEDValue: self.strOffsetColorLEDValue)
                            self.getDeviceDataNightLightColor(deviceID: self.selectedDeviceID)
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
                
                self.selectedStartTimeValue = (self.selectedTodayTimeValue + self.selectedStartTimeValue) - self.selectedTimeZoneDiff
                self.selectedEndTimeValue = (self.selectedTodayTimeValue + self.selectedEndTimeValue) - self.selectedTimeZoneDiff
                
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "NightlightColorCode", value: String(format: "%@", self.selectedColorCode), deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "NightColorStartTime", value: String(format: "%d", self.selectedStartTimeValue), deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "NightColorEndTime", value: String(format: "%d", self.selectedEndTimeValue), deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "NightLightColorLedbrightness", value: self.strOffsetColorLEDValue, deviceId: Int64(self.selectedDeviceID)))
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    self.hideActivityIndicator(self.view)
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    if error == nil {
                        RealmDataManager.shared.updateNightLightFilterData(deviceID: self.selectedDeviceID, colorType: ColorType.ColorNightLight.rawValue, colorCode:  self.selectedColorCode, startTime: self.selectedStartTimeValue, endTime: self.selectedEndTimeValue, isNightSwitchOn: self.switchColor.isOn, brightnessLEDValue: self.strOffsetColorLEDValue)
                        self.selectedStartTimeValue = 0
                        self.selectedEndTimeValue = 0
                        self.getDeviceDataNightLightColor(deviceID: self.selectedDeviceID)
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

extension ColorsNightLightViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveNightLightColorAPINewGood()
        }
    }
    
    func writeNightValueBle()  {
        self.getLedBrightnessFormValue()
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true || self.isColorNightLightApplyAll == true {
                self.saveNightLightColorAPINewGood()
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
extension ColorsNightLightViewController:CBCentralManagerDelegate{
    
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
                
                self.getTodayTimeValue()
                var startTimeValueAPI = self.selectedStartTimeValue
                var endTimeValueAPI = self.selectedEndTimeValue
                
                self.selectedTimeZoneDiff = 0
                startTimeValueAPI = 0
                endTimeValueAPI = 0
                self.selectedTimeZoneDiff = RealmDataManager.shared.getDeviceData(deviceID: self.selectedDeviceID)[0].timeDiffrence.toInt() ?? 0
                startTimeValueAPI = (self.selectedTodayTimeValue + self.selectedStartTimeValue) - self.selectedTimeZoneDiff
                endTimeValueAPI = (self.selectedTodayTimeValue + self.selectedEndTimeValue) - self.selectedTimeZoneDiff
                
                self.writeNightColorCodeValueViaBLE(nightColorCode: self.getColorCodeOCTALvalue(colorValue: self.selectedColorCode), nightColorStartTimeCode: startTimeValueAPI, nightColorEndTimeCode: endTimeValueAPI, deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id,brightNessColorCode: self.writeNightLightColorLEDValue)
            }
        }
    }
}

extension ColorsNightLightViewController {
    
    func previousCopyconvertValuesAsPerUnits()  {
        self.previousColorCode = self.selectedColorCode
        self.previousStartTime =  self.selectedStartTimeValue
        self.previousEndTime =  self.selectedEndTimeValue
        self.previousIsSwitchOn = self.switchColor.isOn
        self.previousColorLEDValue = self.strOffsetColorLEDValue
    }
    
    func backCompareValues() -> Bool{
        if self.arrCurrentDevice.count == 0 {
            return true
        }
        if self.previousColorCode != self.selectedColorCode || self.previousStartTime != self.selectedStartTimeValue || self.previousEndTime != self.selectedEndTimeValue || self.previousIsSwitchOn != self.switchColor.isOn || self.isColorNightLightApplyAll == true || self.previousColorLEDValue != self.strOffsetColorLEDValue {
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
            self.writeNightValueBle()
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
extension ColorsNightLightViewController {
    
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
        self.writeNightLightColorLEDValue =  String(format: "0x%@%@%@%@", self.isOkLEDBrightNess,self.isWarningLEDBrightNess,self.isAlertLEDBrightNess,self.strOffsetColorLEDValue)
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
