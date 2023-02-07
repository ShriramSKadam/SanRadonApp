//
//  ThersHoldHumityViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class ThersHoldHumityViewController:LTSettingBaseViewController {
    
    
    @IBOutlet weak var lblThersHoldHUMITYDeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var btnDeviceNameThersHoldHUMITY: UIButton!
    
    //Warnings
    @IBOutlet weak var lblThersHoldHUMITYLowWarning: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldHUMITYHighWarning: LTCellSubTitleLabel!
    
    //Alerts
    @IBOutlet weak var lblThersHoldHUMITYLowAlert: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldHUMITYHighAlert: LTCellSubTitleLabel!
    
    
    //Button Warnings
    @IBOutlet weak var btnThersHoldHUMITYLowWarning: UIButton!
    @IBOutlet weak var btnThersHoldHUMITYHighWarning: UIButton!
    
    //Button Alerts
    @IBOutlet weak var btnThersHoldHUMITYLowAlert: UIButton!
    @IBOutlet weak var btnThersHoldHUMITYHighAlert: UIButton!
    
    //Apply All Button
    @IBOutlet weak var btnThersHoldeHUMITYBtnApplyAll: UIButton!
    
    
    //Apply All ImgView Selection
    @IBOutlet weak var viewThersHoldHUMITYApplyAllView: LTCellView!
    
    //Reset Button Alerts
    @IBOutlet weak var btnThersHoldeHUMITYBtnReaset: UIButton!
    
    //Save Button Alerts
    @IBOutlet weak var btnThersHoldeHUMITYBtnSave: UIButton!
    
    @IBOutlet weak var imgViewThersHoldHUMITYApplyAllView: UIImageView!
    
    @IBOutlet weak var stackViewBottom: UIStackView!
    @IBOutlet weak var stackViewBottomheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewWarnning: UIStackView!
    @IBOutlet weak var stackViewWarnningheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewAlert: UIStackView!
    @IBOutlet weak var stackViewAlertheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewResetToDefault: UIStackView!
    @IBOutlet weak var stackViewResetToDefaultheightConstant: NSLayoutConstraint!
    
    //Switch Button Alerts
    @IBOutlet weak var switchAlertEnable: UISwitch!
    @IBOutlet weak var imgViewDevice: UIImageView!
    
    var selectedDropDownType:AppDropDownType? = .DropDownHUMIDITY
    var selectedType:SelectedFieldType? = .SelectedNone
    var humidityContext: NSManagedObjectContext!
    
    var pollutantType:PollutantType = .PollutantHumidity
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedLowWarning:String = ""
    var selectedLowAlert:String = ""
    var selectedHighWarning:String = ""
    var selectedHighAlert:String = ""
    var arrPollutantHumidityData:[RealmThresHoldSetting] = []
    var isThersHUmidityApplyAll:Bool = false
    
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
    var previousHighWarning:String = ""
    var previousHighAlert:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.humidityContext = appDelegate.persistentContainer.viewContext
        self.lblThersHoldHUMITYDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.loadHumidityvalues()
        self.viewThersHoldHUMITYApplyAllView.isHidden = false
        self.imgViewThersHoldHUMITYApplyAllView.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage

       // self.switchAlertEnable.isOn = true
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        if UserDefaults.standard.bool(forKey: "AirPressureSwitch") == true {
            self.switchAlertEnable.isOn = true
            self.stackViewBottom.isHidden = false
            self.stackViewBottomheightConstant.constant = 45
            self.stackViewWarnning.isHidden = false
            self.stackViewWarnningheightConstant.constant = 125
            self.stackViewResetToDefault.isHidden = false
            self.stackViewResetToDefaultheightConstant.constant = 45
            self.stackViewAlert.isHidden = false
            self.stackViewAlertheightConstant.constant = 125
        } else{ 
            self.switchAlertEnable.isOn = false
            //            self.stackViewBottom.isHidden = true
            //            self.stackViewBottomheightConstant.constant = 0
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
            //            self.stackViewResetToDefault.isHidden = true
            //            self.stackViewResetToDefaultheightConstant.constant = 0
            self.stackViewAlert.isHidden = true
            self.stackViewAlertheightConstant.constant = 0
            
        }
       
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
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
            self.stackViewAlert.isHidden = false
            self.stackViewAlertheightConstant.constant = 125
            UserDefaults.standard.set(true, forKey: "HumiditySwitch")
            
        }else{
//            self.stackViewBottom.isHidden = true
//            self.stackViewBottomheightConstant.constant = 0
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
//            self.stackViewResetToDefault.isHidden = true
//            self.stackViewResetToDefaultheightConstant.constant = 0
            self.stackViewAlert.isHidden = true
            self.stackViewAlertheightConstant.constant = 0
            
            self.lblThersHoldHUMITYHighAlert.text = "32000"
            self.lblThersHoldHUMITYLowAlert.text = "0"
            self.lblThersHoldHUMITYHighWarning.text = "32000"
            self.lblThersHoldHUMITYLowWarning.text = "0"
            UserDefaults.standard.set(false, forKey: "HumiditySwitch")
        }
    }
    
    
    func isFromInitialAddDeviceView()  {
        self.stackViewBottom?.isHidden = true
        self.stackViewBottomheightConstant?.constant = 0.0
        self.btnDeviceNameThersHoldHUMITY.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
    
    func loadHumidityvalues() {
        self.btnDeviceNameThersHoldHUMITY.addTarget(self, action:#selector(self.btnDeviceNameThersHoldHUMITYTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldHUMITYLowWarning.addTarget(self, action:#selector(self.btnThersHoldHUMITYLowWarningTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldHUMITYHighWarning.addTarget(self, action:#selector(self.btnThersHoldHUMITYHighWarningTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldHUMITYLowAlert.addTarget(self, action:#selector(self.btnThersHoldHUMITYLowAlertTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldHUMITYHighAlert.addTarget(self, action:#selector(self.btnThersHoldHUMITYHighAlertTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeHUMITYBtnApplyAll.addTarget(self, action:#selector(self.btnThersHoldeHUMITYBtnApplyAllTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeHUMITYBtnReaset.addTarget(self, action:#selector(self.btnThersHoldeHUMITYBtnResetTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeHUMITYBtnSave.addTarget(self, action:#selector(self.btnThersHoldeHUMITYBtnSaveTap(_sender:)), for: .touchUpInside)
    }
    
    func getDeviceThersHold(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrPollutantHumidityData = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceID, pollutantType: self.pollutantType.rawValue)
        if self.arrPollutantHumidityData.count == 0 {
            self.lblThersHoldHUMITYDeviceName.text = "Select"
            self.lblThersHoldHUMITYLowWarning.text = "Select"
            self.lblThersHoldHUMITYLowAlert.text = "Select"
            self.lblThersHoldHUMITYHighWarning.text = "Select"
            self.lblThersHoldHUMITYHighAlert.text = "Select"
            self.lblThersHoldHUMITYDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldHUMITYLowWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldHUMITYLowAlert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldHUMITYHighWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldHUMITYHighAlert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            return
        }
        
        self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
        self.selectedLowWarning = String(format: "%@ %%",self.arrPollutantHumidityData[0].low_waring_value)
        self.selectedLowAlert = String(format: "%@ %%",self.arrPollutantHumidityData[0].low_alert_value)
        self.selectedHighWarning = String(format: "%@ %%",self.arrPollutantHumidityData[0].high_waring_value)
        self.selectedHighAlert = String(format: "%@ %%",self.arrPollutantHumidityData[0].high_alert_value)
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        
        self.lblThersHoldHUMITYDeviceName.text = self.selectedDeviceName
        self.lblThersHoldHUMITYLowWarning.text = self.selectedLowWarning
        self.lblThersHoldHUMITYLowAlert.text = self.selectedLowAlert
        self.lblThersHoldHUMITYHighWarning.text = self.selectedHighWarning
        self.lblThersHoldHUMITYHighAlert.text = self.selectedHighAlert
        self.previousCopyconvertValuesAsPerUnits()
    }
}
extension ThersHoldHumityViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnDeviceNameThersHoldHUMITYTap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    
    @objc func btnThersHoldHUMITYLowWarningTap(_sender:UIButton) {
        self.selectedType = .SelectedLowWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    @objc func btnThersHoldHUMITYHighWarningTap(_sender:UIButton) {
        self.selectedType = .SelectedHighWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldHUMITYLowAlertTap(_sender:UIButton) {
        self.selectedType = .SelectedLowAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldHUMITYHighAlertTap(_sender:UIButton) {
        self.selectedType = .SelectedHighAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldeHUMITYBtnApplyAllTap(_sender:UIButton) {
        if self.isThersHUmidityApplyAll == false {
            self.isThersHUmidityApplyAll = true
            self.imgViewThersHoldHUMITYApplyAllView.image = ThemeManager.currentTheme().cellSelectedCheckIconImage
        }else {
            self.imgViewThersHoldHUMITYApplyAllView.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage

            self.isThersHUmidityApplyAll = false
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
    
    @objc func btnThersHoldeHUMITYBtnResetTap(_sender:UIButton) {
        self.readResetDataHUmidity()
    }
    
    @objc func btnThersHoldeHUMITYBtnSaveTap(_sender:UIButton) {
        if self.lblThersHoldHUMITYLowWarning.text?.count != 0  && self.lblThersHoldHUMITYLowAlert.text?.count != 0 && self.lblThersHoldHUMITYHighWarning.text?.count != 0 && self.lblThersHoldHUMITYHighAlert.text?.count != 0 {
            self.convertValuesAsPerUnits()
            self.writeHumidityValueBle()
        }
    }
    
}

extension ThersHoldHumityViewController: LTDropDownThersHoldDelegate ,LTDropDownDeviceListDelegate {
    
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int) {
        self.lblThersHoldHUMITYDeviceName?.text = selectedDeviceName
        self.selectedDeviceID = selectedDeviceID
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.lblThersHoldHUMITYDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    func selectedThresHoldValue(selectedValue:String){
        
        if self.selectedType == .SelectedLowWarning {
            self.lblThersHoldHUMITYLowWarning.text = selectedValue
        }
        else if self.selectedType == .SelectedLowAlert {
            self.lblThersHoldHUMITYLowAlert.text = selectedValue
        }
        else if self.selectedType == .SelectedHighWarning {
            self.lblThersHoldHUMITYHighWarning.text = selectedValue
        }
        else if self.selectedType == .SelectedHighAlert {
            self.lblThersHoldHUMITYHighAlert.text = selectedValue
        }
        else {
            self.lblThersHoldHUMITYDeviceName.text = selectedValue
        }
    }
    
    func readResetDataHUmidity()  {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_HUMIDITY)
        let predicate = NSPredicate(format: "lowwarning == %@", NSNumber(value: true))
        fetch.predicate = predicate
        do {
            let result = try self.humidityContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.lblThersHoldHUMITYLowWarning?.text = data.value(forKey: "humidityvalue") as? String
            }
        } catch {
            print("Failed")
        }
        
        let predicate1 = NSPredicate(format: "lowalert == %@", NSNumber(value: true))
        fetch.predicate = predicate1
        do {
            let result = try self.humidityContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.lblThersHoldHUMITYLowAlert?.text = data.value(forKey: "humidityvalue") as? String
            }
        } catch {
            print("Failed")
        }
        let predicate2 = NSPredicate(format: "highwarning == %@", NSNumber(value: true))
        fetch.predicate = predicate2
        do {
            let result = try self.humidityContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.lblThersHoldHUMITYHighWarning?.text = data.value(forKey: "humidityvalue") as? String
            }
        } catch {
            print("Failed")
        }
        let predicate3 = NSPredicate(format: "highalert == %@", NSNumber(value: true))
        fetch.predicate = predicate3
        do {
            let result = try self.humidityContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.lblThersHoldHUMITYHighAlert?.text = data.value(forKey: "humidityvalue") as? String
            }
        } catch {
            print("Failed")
        }
    }
}

extension ThersHoldHumityViewController {
    
    func saveThresHoldHumidityAPINewGood(){
        
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isThersHUmidityApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        if deviceData.wifi_status == true{
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "HumidityThresholdLowWarningLevel", value: self.selectedLowWarning, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "HumidityThresholdLowalertLevel", value: self.selectedLowAlert, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "HumidityThresholdHighWarningLevel", value: self.selectedHighWarning, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "HumidityThresholdHighalertLevel", value: self.selectedHighAlert, deviceId: Int64(deviceData.device_id)))
                        }
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            RealmDataManager.shared.updateAllThresHoldFilterData(pollutantType: self.pollutantType.rawValue, lowWarning: self.selectedLowWarning, highWarning: self.selectedHighWarning, lowAlert: self.selectedLowAlert, highAlert: self.selectedHighAlert, tempOffset: "")
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
                
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "HumidityThresholdLowWarningLevel", value: self.selectedLowWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "HumidityThresholdLowalertLevel", value: self.selectedLowAlert, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "HumidityThresholdHighWarningLevel", value: self.selectedHighWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "HumidityThresholdHighalertLevel", value: self.selectedHighAlert, deviceId: Int64(self.selectedDeviceID)))
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    self.hideActivityIndicator(self.view)
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    if error == nil {
                        RealmDataManager.shared.updateThresHoldFilterData(deviceID: self.selectedDeviceID, pollutantType: self.pollutantType.rawValue, lowWarning: self.selectedLowWarning, highWarning: self.selectedHighWarning, lowAlert: self.selectedLowAlert, highAlert: self.selectedHighAlert, tempOffset: "")
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
extension ThersHoldHumityViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveThresHoldHumidityAPINewGood()
        }
    }
    
    func writeHumidityValueBle()  {
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true || self.isThersHUmidityApplyAll == true {
                self.saveThresHoldHumidityAPINewGood()
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
extension ThersHoldHumityViewController:CBCentralManagerDelegate{
    
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
                self.writeHumidityValueViaBLE(selectedLowWarning: self.selectedLowWarning.toFloat() ?? 0.0, selectedHighWarning: self.selectedHighWarning.toFloat() ?? 0.0, selectedLowAlert: self.selectedLowAlert.toFloat() ?? 0.0, selectedHighAlert: self.selectedHighAlert.toFloat() ?? 0.0, deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id)
            }
        }
    }
}
extension ThersHoldHumityViewController {
    
    func convertValuesAsPerUnits()  {
        self.selectedLowWarning = self.removeWhiteSpace(text: self.lblThersHoldHUMITYLowWarning.text!.replacingOccurrences(of: "%", with: ""))
        self.selectedLowAlert = self.removeWhiteSpace(text: self.lblThersHoldHUMITYLowAlert.text!.replacingOccurrences(of: "%", with: ""))
        self.selectedHighWarning = self.removeWhiteSpace(text: self.lblThersHoldHUMITYHighWarning.text!.replacingOccurrences(of: "%", with: ""))
        self.selectedHighAlert = self.removeWhiteSpace(text: self.lblThersHoldHUMITYHighAlert.text!.replacingOccurrences(of: "%", with: ""))
    }
    
    func previousCopyconvertValuesAsPerUnits()  {
        self.previousLowWarning = self.removeWhiteSpace(text: self.lblThersHoldHUMITYLowWarning.text!.replacingOccurrences(of: "%", with: ""))
        self.previousLowAlert = self.removeWhiteSpace(text: self.lblThersHoldHUMITYLowAlert.text!.replacingOccurrences(of: "%", with: ""))
        self.previousHighWarning = self.removeWhiteSpace(text: self.lblThersHoldHUMITYHighWarning.text!.replacingOccurrences(of: "%", with: ""))
        self.previousHighAlert = self.removeWhiteSpace(text: self.lblThersHoldHUMITYHighAlert.text!.replacingOccurrences(of: "%", with: ""))
    }
    
    func backCompareValues() -> Bool{
        if self.arrCurrentDevice.count == 0 {
            return true
        }
        self.convertValuesAsPerUnits()
        if self.previousLowWarning != self.selectedLowWarning || self.previousLowAlert != self.selectedLowAlert  || self.previousHighAlert != self.selectedHighAlert || self.previousHighWarning != self.selectedHighWarning || self.isThersHUmidityApplyAll == true  {
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
            self.writeHumidityValueBle()
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
