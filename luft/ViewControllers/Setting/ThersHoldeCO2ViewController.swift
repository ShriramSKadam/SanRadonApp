//
//  ThersHoldeCO2ViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class ThersHoldeCO2ViewController:LTSettingBaseViewController {
    
    
    @IBOutlet weak var lblThersHoldeCO2DeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldeCO2Warning: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldeCO2Alert: LTCellSubTitleLabel!
    @IBOutlet weak var viewThersHoldeCO2Imagview: LTCellView!
    @IBOutlet weak var btnThersHoldeCO2DeviceName: UIButton!
    @IBOutlet weak var btnThersHoldeCO2Alert: UIButton!
    @IBOutlet weak var btnThersHoldeCO2Warning: UIButton!
    @IBOutlet weak var btnThersHoldeCO2btnApplyAll: UIButton!
    @IBOutlet weak var btnThersHoldeCO2btnReset: UIButton!
    @IBOutlet weak var btnThersHoldeCO2btnSave: UIButton!
    @IBOutlet weak var lblEcoTitle: UILabel!
    @IBOutlet weak var imgViewThersHoldeCO2Imagview: UIImageView!
    
    @IBOutlet weak var stackViewBottom: UIStackView!
    @IBOutlet weak var stackViewBottomheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewWarnning: UIStackView!
    @IBOutlet weak var stackViewWarnningheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewResetToDefault: UIStackView!
    @IBOutlet weak var stackViewResetToDefaultheightConstant: NSLayoutConstraint!
    @IBOutlet weak var labelYouWillBeNotified: UILabel!
    //Switch Button Alerts
    @IBOutlet weak var switchAlertEnable: UISwitch!

    @IBOutlet weak var imgViewDevice: UIImageView!
    
    var isThersCO2btnApplyAll:Bool = false
    var selectedType:SelectedFieldType? = .SelectedNone
    var selectedDropDownType:AppDropDownType? = .DropDownECO2
    var eocContext: NSManagedObjectContext!
    
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedLowWarning:String = ""
    var selectedLowAlert:String = ""
    var arrPollutantECO2Data:[RealmThresHoldSetting] = []
    var arrCurrentDevice:[RealmDeviceList] = []
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    var serialDeviceName:String = ""
    var isFromInitialAddDevice:Bool = false
    
    var previousLowWarning:String = ""
    var previousLowAlert:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eocContext = appDelegate.persistentContainer.viewContext
        self.lblThersHoldeCO2DeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.loadCO2values()
        self.setMyLabelText()
        self.viewThersHoldeCO2Imagview.isHidden = false
        self.imgViewThersHoldeCO2Imagview.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage
        
//        self.switchAlertEnable.isOn = true
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
      
        
        if UserDefaults.standard.bool(forKey: "ECO2Switch") == true {
            self.switchAlertEnable.isOn = true
            self.stackViewBottom.isHidden = false
            self.stackViewBottomheightConstant.constant = 45
            self.stackViewWarnning.isHidden = false
            self.stackViewWarnningheightConstant.constant = 125
            self.stackViewResetToDefault.isHidden = false
            self.stackViewResetToDefaultheightConstant.constant = 45
            self.labelYouWillBeNotified.isHidden = false
        } else{
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    
    func setMyLabelText() {
        let numberString = NSMutableAttributedString(string: "eCO", attributes: [.font: UIFont.setSystemFontSemiBold(17)])
        numberString.append(NSAttributedString(string: "2", attributes: [.font: UIFont.setSystemFontSemiBold(14), .baselineOffset: -2]))
        self.lblEcoTitle.attributedText = numberString
        self.lblEcoTitle.backgroundColor = ThemeManager.currentTheme().clearColor
        self.lblEcoTitle.textColor = ThemeManager.currentTheme().headerTitleTextColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isFromInitialAddDevice{
            self.isFromInitialAddDeviceView()
        }
    }
    
    @objc func switchColorStatusChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
//            self.stackViewBottom.isHidden = false
//            self.stackViewBottomheightConstant.constant = 45
            self.stackViewWarnning.isHidden = false
            self.stackViewWarnningheightConstant.constant = 125
//            self.stackViewResetToDefault.isHidden = false
//            self.stackViewResetToDefaultheightConstant.constant = 45
//            self.labelYouWillBeNotified.isHidden = false
            UserDefaults.standard.set(true, forKey: "ECO2Switch")
        }else{
//            self.stackViewBottom.isHidden = true
//            self.stackViewBottomheightConstant.constant = 0
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
            self.lblThersHoldeCO2Warning.text = "32000"
            self.lblThersHoldeCO2Alert.text = "0"
//            self.stackViewResetToDefault.isHidden = true
//            self.stackViewResetToDefaultheightConstant.constant = 0
//            self.labelYouWillBeNotified.isHidden = true
            UserDefaults.standard.set(false, forKey: "ECO2Switch")
        }
    }
    
    func isFromInitialAddDeviceView()  {
        self.stackViewBottom?.isHidden = true
        self.stackViewBottomheightConstant?.constant = 0.0
        self.btnThersHoldeCO2DeviceName.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
    
    func loadCO2values() {
        self.btnThersHoldeCO2DeviceName.addTarget(self, action:#selector(self.btnTapThersEOCDeviceList(_sender:)), for: .touchUpInside)
        self.btnThersHoldeCO2Warning.addTarget(self, action:#selector(self.btnTapThersEOCWarning(_sender:)), for: .touchUpInside)
        self.btnThersHoldeCO2Alert.addTarget(self, action:#selector(self.btnTapThersEOCAlert(_sender:)), for: .touchUpInside)
        self.btnThersHoldeCO2btnApplyAll.addTarget(self, action:#selector(self.btnTapThersHoldeEOCbtnApplyAll(_sender:)), for: .touchUpInside)
        self.btnThersHoldeCO2btnReset.addTarget(self, action:#selector(self.btnTapThersEOCResetAll(_sender:)), for: .touchUpInside)
        self.btnThersHoldeCO2btnSave.addTarget(self, action:#selector(self.btnTapThersHoldECO2Save(_sender:)), for: .touchUpInside)
    }
    
    func getDeviceThersHold(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrPollutantECO2Data = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceID, pollutantType: PollutantType.PollutantECO2.rawValue)
        
        if self.arrPollutantECO2Data.count == 0 {
            self.lblThersHoldeCO2DeviceName.text = "Select"
            self.lblThersHoldeCO2Warning.text = "Select"
            self.lblThersHoldeCO2Alert.text = "Select"
            self.lblThersHoldeCO2DeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldeCO2Warning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldeCO2Alert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            return
        }
        self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
        self.selectedLowWarning =  self.arrPollutantECO2Data[0].low_waring_value
        self.selectedLowAlert =  self.arrPollutantECO2Data[0].low_alert_value
        self.lblThersHoldeCO2DeviceName.text = self.selectedDeviceName
        self.lblThersHoldeCO2Warning.text = String(format: "%@ ppm", self.selectedLowWarning)
        self.lblThersHoldeCO2Alert.text = String(format: "%@ ppm", self.selectedLowAlert)
        self.previousCopyconvertValuesAsPerUnits()
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
    }
}

extension ThersHoldeCO2ViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnTapThersEOCDeviceList(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    
    @objc func btnTapThersEOCWarning(_sender:UIButton) {
        self.selectedType = .SelectedWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnTapThersEOCAlert(_sender:UIButton) {
        self.selectedType = .SelectedAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnTapThersHoldeEOCbtnApplyAll(_sender:UIButton) {
        if self.isThersCO2btnApplyAll == false {
            self.isThersCO2btnApplyAll = true
            self.imgViewThersHoldeCO2Imagview.image = ThemeManager.currentTheme().cellSelectedCheckIconImage
        }else {
            self.imgViewThersHoldeCO2Imagview.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage

            self.isThersCO2btnApplyAll = false
        }
    }
    
    func showDropDownDeviceList(appDropDownType:AppDropDownType) {
        let dropDownVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LTDropDownViewController") as! LTDropDownViewController
        dropDownVC.dropDownType = appDropDownType
        dropDownVC.dropDownThersHoldDelegate = self
        dropDownVC.dropDownDeviceList = self
        dropDownVC.modalPresentationStyle = .overFullScreen
        dropDownVC.selectedDropType = self.selectedType
        self.present(dropDownVC, animated: false, completion: nil)
    }
    
    @objc func btnTapThersEOCResetAll(_sender:UIButton) {
        self.readResetDataEOC()
    }
    
    @objc func btnTapThersHoldECO2Save(_sender:UIButton) {
        if self.lblThersHoldeCO2Warning.text?.count != 0  && self.lblThersHoldeCO2Alert.text?.count != 0 {
            self.convertValuesAsPerUnits()
            self.writeECOValueBle()
        }
    }
}


extension ThersHoldeCO2ViewController: LTDropDownThersHoldDelegate,LTDropDownDeviceListDelegate {
    
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int) {
        self.lblThersHoldeCO2DeviceName?.text = selectedDeviceName
        self.selectedDeviceID = selectedDeviceID
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.lblThersHoldeCO2DeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    func selectedThresHoldValue(selectedValue:String){
        
        if self.selectedType == .SelectedWarning {
            self.lblThersHoldeCO2Warning.text = selectedValue
        }
        else if self.selectedType == .SelectedAlert {
            self.lblThersHoldeCO2Alert.text = selectedValue
        }
        else {
            self.lblThersHoldeCO2DeviceName.text = selectedValue
        }
    }
    
    func readResetDataEOC()  {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_ECO2)
        let predicate = NSPredicate(format: "warning == %@", NSNumber(value: true))
        fetch.predicate = predicate
        do {
            let result = try self.eocContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.lblThersHoldeCO2Warning?.text = data.value(forKey: "eco2") as? String
            }
        } catch {
            print("Failed")
        }
        
        let predicate1 = NSPredicate(format: "alert == %@", NSNumber(value: true))
        fetch.predicate = predicate1
        do {
            let result = try self.eocContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.lblThersHoldeCO2Alert?.text = data.value(forKey: "eco2") as? String
            }
        } catch {
            print("Failed")
        }
    }
}

extension ThersHoldeCO2ViewController {
    
    func saveThresHoldECO2APINewGood(){
        
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isThersCO2btnApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        if deviceData.wifi_status == true{
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "Co2ThresholdWarningLevel", value: self.selectedLowWarning, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "Co2ThresholdAlertLevel", value: self.selectedLowAlert, deviceId: Int64(deviceData.device_id)))
                        }
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            RealmDataManager.shared.updateAllThresHoldFilterData(pollutantType: PollutantType.PollutantECO2.rawValue, lowWarning: self.selectedLowWarning, highWarning: "", lowAlert: self.selectedLowAlert, highAlert: "", tempOffset: "")
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
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "Co2ThresholdWarningLevel", value: self.selectedLowWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "Co2ThresholdAlertLevel", value: self.selectedLowAlert, deviceId: Int64(self.selectedDeviceID)))
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    self.hideActivityIndicator(self.view)
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    if error == nil {
                        RealmDataManager.shared.updateThresHoldFilterData(deviceID: self.selectedDeviceID, pollutantType: PollutantType.PollutantECO2.rawValue, lowWarning: self.selectedLowWarning, highWarning: "", lowAlert: self.selectedLowAlert, highAlert: "", tempOffset: "")
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
extension ThersHoldeCO2ViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveThresHoldECO2APINewGood()
        }
    }
    
    func writeECOValueBle()  {
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true || self.isThersCO2btnApplyAll == true {
                self.saveThresHoldECO2APINewGood()
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
extension ThersHoldeCO2ViewController:CBCentralManagerDelegate{
    
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
                self.writeECOValueViaBLE(selectedLowAlert: self.selectedLowAlert.toFloat() ?? 0.0, selectedLowWarning: self.selectedLowWarning.toFloat()  ?? 0.0, deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id)
            }
        }
    }
}
extension ThersHoldeCO2ViewController {
    
    func convertValuesAsPerUnits()  {
        self.selectedLowWarning = self.removeWhiteSpace(text: self.lblThersHoldeCO2Warning.text!.replacingOccurrences(of: "ppm", with: ""))
        self.selectedLowAlert = self.removeWhiteSpace(text:self.lblThersHoldeCO2Alert.text!.replacingOccurrences(of: "ppm", with: ""))
    }
    
    func previousCopyconvertValuesAsPerUnits()  {
        self.previousLowWarning = self.selectedLowWarning
        self.previousLowAlert =  self.selectedLowAlert
    }
    
    func backCompareValues() -> Bool{
        if self.arrCurrentDevice.count == 0 {
            return true
        }
        self.convertValuesAsPerUnits()
        if self.previousLowWarning != self.selectedLowWarning || self.previousLowAlert != self.selectedLowAlert || self.isThersCO2btnApplyAll == true {
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
            self.writeECOValueBle()
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
