//
//  ThersHoldTemperatureViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class ThersHoldTemperatureViewController:LTSettingBaseViewController {
    
    @IBOutlet weak var lblThersHoldTempDeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var btnDeviceNameThersHoldTemp: UIButton!
    
    //Alerts
    @IBOutlet weak var lblThersHoldTempLowAlert: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldTempHighAlert: LTCellSubTitleLabel!
    
    //Warnings
    @IBOutlet weak var lblThersHoldTempLowWarning: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldTempHighWarning: LTCellSubTitleLabel!
    
    //Button Warnings
    @IBOutlet weak var btnThersHoldTempLowWarning: UIButton!
    @IBOutlet weak var btnThersHoldTempHighWarning: UIButton!
    
    //Button Alerts
    @IBOutlet weak var btnThersHoldTempLowAlert: UIButton!
    @IBOutlet weak var btnThersHoldTempHighAlert: UIButton!
    
    //Apply All Button
    @IBOutlet weak var btnThersHoldeTempBtnApplyAll: UIButton!
    
    
    //Apply All ImgView Selection
    @IBOutlet weak var viewThersHoldTempApplyAllView: LTCellView!
    
    //Reset Button Alerts
    @IBOutlet weak var btnThersHoldeTempBtnReaset: UIButton!
    
    //Reset Button Alerts
    @IBOutlet weak var btnThersHoldeTempBtnSave: UIButton!
    
    @IBOutlet weak var imgViewThersHoldTempApplyAllView: UIImageView!
    
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
    
    var selectedDropDownType:AppDropDownType? = .DropDownNone
    var selectedType:SelectedFieldType? = .SelectedNone
    var tempContext: NSManagedObjectContext!
    
    var pollutantType:PollutantType = .PollutantTemperature
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedLowWarning:String = ""
    var selectedAlertEnabled:String = ""
    var selectedLowAlert:String = ""
    var selectedHighWarning:String = ""
    var selectedHighAlert:String = ""
    var selectedTempOffset:String = ""
    var arrPollutantTempData:[RealmThresHoldSetting] = []
    var isThersTEMPApplyAll:Bool = false
    
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
        self.tempContext = appDelegate.persistentContainer.viewContext
        self.lblThersHoldTempDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        self.selectedDropDownType = .DropDownTEMPERATURE_CELSIUS
        if AppSession.shared.getMobileUserMeData()?.temperatureUnitTypeId == 1{
            self.selectedDropDownType = .DropDownTEMPERATURE_FAHRENHEIT
        }
        self.loadTempvalues()
        self.viewThersHoldTempApplyAllView.isHidden = true
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.viewThersHoldTempApplyAllView.isHidden = false
        self.imgViewThersHoldTempApplyAllView.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage
        
//        self.switchAlertEnable.isOn = true
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        
        if UserDefaults.standard.bool(forKey: "TemperatureSwitch") == true {
            self.switchAlertEnable.isOn = true
            self.stackViewBottom.isHidden = false
            self.stackViewBottomheightConstant.constant = 45
            self.stackViewWarnning.isHidden = false
            self.stackViewWarnningheightConstant.constant = 125
            self.stackViewAlert.isHidden = false
            self.stackViewAlertheightConstant.constant = 125
            self.stackViewResetToDefault.isHidden = false
            self.stackViewResetToDefaultheightConstant.constant = 45
        } else{
            self.switchAlertEnable.isOn = false
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
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
            self.stackViewAlert.isHidden = false
            self.stackViewAlertheightConstant.constant = 125
//            self.stackViewResetToDefault.isHidden = false
//            self.stackViewResetToDefaultheightConstant.constant = 45
            UserDefaults.standard.set(true, forKey: "TemperatureSwitch")
        }else{
//            self.stackViewBottom.isHidden = true
//            self.stackViewBottomheightConstant.constant = 0
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
            self.stackViewAlert.isHidden = true
            self.stackViewAlertheightConstant.constant = 0
//            self.stackViewResetToDefault.isHidden = true
//            self.stackViewResetToDefaultheightConstant.constant = 0
            self.lblThersHoldTempHighAlert.text = "32000"
            self.lblThersHoldTempLowAlert.text = "0"
            self.lblThersHoldTempHighWarning.text = "32000"
            self.lblThersHoldTempLowWarning.text = "0"
            UserDefaults.standard.set(false, forKey: "TemperatureSwitch")
        }
    }
    
    
    func isFromInitialAddDeviceView()  {
        self.stackViewBottom?.isHidden = true
        self.stackViewBottomheightConstant?.constant = 0.0
        self.btnDeviceNameThersHoldTemp.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
    
    func loadTempvalues() {
        self.btnDeviceNameThersHoldTemp.addTarget(self, action:#selector(self.btnDeviceNameThersHoldTempTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldTempLowWarning.addTarget(self, action:#selector(self.btnThersHoldTempLowWarningTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldTempHighWarning.addTarget(self, action:#selector(self.btnThersHoldTempHighWarningTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldTempLowAlert.addTarget(self, action:#selector(self.btnThersHoldTempLowAlertTap1(_sender:)), for: .touchUpInside)
        self.btnThersHoldTempHighAlert.addTarget(self, action:#selector(self.btnThersHoldTempHightAlertTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeTempBtnApplyAll.addTarget(self, action:#selector(self.btnThersHoldeTempBtnApplyAllTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeTempBtnReaset.addTarget(self, action:#selector(self.btnThersHoldeTempBtnReasetTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeTempBtnSave.addTarget(self, action:#selector(self.btnThersHoldeTempBtnSaveTap(_sender:)), for: .touchUpInside)
        
    }
    
    func getDeviceThersHold(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrPollutantTempData = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceID, pollutantType: self.pollutantType.rawValue)
        
        if self.arrPollutantTempData.count == 0 {
            self.lblThersHoldTempDeviceName.text = "Select"
            self.lblThersHoldTempLowWarning.text = "Select"
            self.lblThersHoldTempLowAlert.text = "Select"
            self.lblThersHoldTempHighWarning.text = "Select"
            self.lblThersHoldTempHighAlert.text = "Select"
            
            self.lblThersHoldTempDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldTempLowWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldTempLowAlert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldTempHighWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldTempHighAlert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            return
        }
        
        self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
        if self.selectedDropDownType == .DropDownTEMPERATURE_CELSIUS{
            self.selectedLowAlert = String(format: "%f",self.convertTemperatureFahrenheitToCelsius(value: self.arrPollutantTempData[0].low_alert_value.toFloat() ?? 0.0))
            self.selectedLowAlert = String(format: "%d Celsius",self.selectedLowAlert.toInt() ?? 0)
            
            self.selectedLowWarning = String(format: "%f",self.convertTemperatureFahrenheitToCelsius(value: self.arrPollutantTempData[0].low_waring_value.toFloat() ?? 0.0))
            self.selectedLowWarning = String(format: "%d Celsius",self.selectedLowWarning.toInt() ?? 0)
            
            self.selectedHighWarning = String(format: "%f",self.convertTemperatureFahrenheitToCelsius(value: self.arrPollutantTempData[0].high_waring_value.toFloat() ?? 0.0))
            self.selectedHighWarning = String(format: "%d Celsius",self.selectedHighWarning.toInt() ?? 0)
            
            self.selectedHighAlert = String(format: "%f",self.convertTemperatureFahrenheitToCelsius(value: self.arrPollutantTempData[0].high_alert_value.toFloat() ?? 0.0))
            self.selectedHighAlert = String(format: "%d Celsius",self.selectedHighAlert.toInt() ?? 0)
            self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
            
        }else {
            self.selectedLowWarning = String(format: "%d Fahrenheit",self.arrPollutantTempData[0].low_waring_value.toInt() ?? 0.0)
            self.selectedLowAlert = String(format: "%d Fahrenheit",self.arrPollutantTempData[0].low_alert_value.toInt() ?? 0.0)
            self.selectedHighWarning = String(format: "%d Fahrenheit",self.arrPollutantTempData[0].high_waring_value.toInt() ?? 0.0)
            self.selectedHighAlert = String(format: "%d Fahrenheit",self.arrPollutantTempData[0].high_alert_value.toInt() ?? 0.0)
            self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        }
        self.selectedTempOffset = self.arrPollutantTempData[0].temp_offset
        if self.arrPollutantTempData[0].temp_offset == "" {
            self.selectedTempOffset = "-1"
        }
        self.lblThersHoldTempDeviceName.text = self.selectedDeviceName
        self.lblThersHoldTempLowWarning.text = self.selectedLowWarning
        self.lblThersHoldTempLowAlert.text = self.selectedLowAlert
        self.lblThersHoldTempHighWarning.text = self.selectedHighWarning
        self.lblThersHoldTempHighAlert.text = self.selectedHighAlert
        self.previousCopyconvertValuesAsPerUnits()
    }
}
extension ThersHoldTemperatureViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnDeviceNameThersHoldTempTap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    
    @objc func btnThersHoldTempLowWarningTap(_sender:UIButton) {
        self.selectedType = .SelectedLowWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    @objc func btnThersHoldTempHighWarningTap(_sender:UIButton) {
        self.selectedType = .SelectedHighWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldTempHightAlertTap(_sender:UIButton) {
        self.selectedType = .SelectedLowAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldTempLowAlertTap1(_sender:UIButton) {
        self.selectedType = .SelectedHighAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldeTempBtnApplyAllTap(_sender:UIButton) {
        if self.isThersTEMPApplyAll == false {
            self.isThersTEMPApplyAll = true
            self.imgViewThersHoldTempApplyAllView.image = ThemeManager.currentTheme().cellSelectedCheckIconImage
        }else {
            self.imgViewThersHoldTempApplyAllView.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage

            self.isThersTEMPApplyAll = false
        }
    }
    
    func showDropDownDeviceList(appDropDownType:AppDropDownType) {
        let dropDownVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LTDropDownViewController") as! LTDropDownViewController
        dropDownVC.dropDownType = appDropDownType
        dropDownVC.dropDownThersHoldDelegate = self
        dropDownVC.dropDownDeviceList = self
        dropDownVC.selectedDropType = self.selectedType
        dropDownVC.modalPresentationStyle = .overFullScreen
        self.present(dropDownVC, animated: false, completion: nil)
    }
    
    @objc func btnThersHoldeTempBtnReasetTap(_sender:UIButton) {
        self.readResetDataTEMP()
    }
    
    @objc func btnThersHoldeTempBtnSaveTap(_sender:UIButton) {
        if self.lblThersHoldTempLowWarning.text?.count != 0  && self.lblThersHoldTempLowAlert.text?.count != 0 && self.lblThersHoldTempHighWarning.text?.count != 0 && self.lblThersHoldTempHighAlert.text?.count != 0  {
            self.convertValuesAsPerUnits()
            self.writeTemperatureValueBle()
        }
    }
}

extension ThersHoldTemperatureViewController: LTDropDownThersHoldDelegate,LTDropDownDeviceListDelegate {
    
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int) {
        self.lblThersHoldTempDeviceName?.text = selectedDeviceName
        self.selectedDeviceID = selectedDeviceID
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.lblThersHoldTempDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    func selectedThresHoldValue(selectedValue:String){
        
        if self.selectedType == .SelectedLowWarning {
            self.lblThersHoldTempLowWarning.text = selectedValue
        }
        else if self.selectedType == .SelectedLowAlert {
            self.lblThersHoldTempLowAlert.text = selectedValue
        }
        else if self.selectedType == .SelectedHighWarning {
            self.lblThersHoldTempHighWarning.text = selectedValue
        }
        else if self.selectedType == .SelectedHighAlert {
            self.lblThersHoldTempHighAlert.text = selectedValue
        }
        else {
            self.lblThersHoldTempDeviceName.text = selectedValue
        }
    }
    
    func readResetDataTEMP()  {
        
        var entityName:String = TBL_TEMP_CELSIUS
        if self.selectedDropDownType == .DropDownTEMPERATURE_FAHRENHEIT {
            entityName = TBL_TEMP_FAHRENHEIT
        }
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let predicate = NSPredicate(format: "lowwarning == %@", NSNumber(value: true))
        fetch.predicate = predicate
        do {
            let result = try self.tempContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownTEMPERATURE_FAHRENHEIT {
                    self.lblThersHoldTempLowWarning?.text = data.value(forKey: "tempfahrenheitvalue") as? String
                }else {
                    self.lblThersHoldTempLowWarning?.text = data.value(forKey: "temperaturecelsiusvalue") as? String
                }
            }
        } catch {
            print("Failed")
        }
        
        let predicate1 = NSPredicate(format: "lowalert == %@", NSNumber(value: true))
        fetch.predicate = predicate1
        do {
            let result = try self.tempContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownTEMPERATURE_FAHRENHEIT {
                    self.lblThersHoldTempLowAlert?.text = data.value(forKey: "tempfahrenheitvalue") as? String
                }else {
                    self.lblThersHoldTempLowAlert?.text = data.value(forKey: "temperaturecelsiusvalue") as? String
                }
            }
        } catch {
            print("Failed")
        }
        let predicate2 = NSPredicate(format: "highwarning == %@", NSNumber(value: true))
        fetch.predicate = predicate2
        do {
            let result = try self.tempContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownTEMPERATURE_FAHRENHEIT {
                    self.lblThersHoldTempHighWarning?.text = data.value(forKey: "tempfahrenheitvalue") as? String
                }else {
                    self.lblThersHoldTempHighWarning?.text = data.value(forKey: "temperaturecelsiusvalue") as? String
                }
            }
        } catch {
            print("Failed")
        }
        let predicate3 = NSPredicate(format: "highalert == %@", NSNumber(value: true))
        fetch.predicate = predicate3
        do {
            let result = try self.tempContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownTEMPERATURE_FAHRENHEIT {
                    self.lblThersHoldTempHighAlert?.text = data.value(forKey: "tempfahrenheitvalue") as? String
                }else {
                    self.lblThersHoldTempHighAlert?.text = data.value(forKey: "temperaturecelsiusvalue") as? String
                }
            }
        } catch {
            print("Failed")
        }
    }
}
extension ThersHoldTemperatureViewController {
    
    func saveThresHoldtempAPINewGood(){
        
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isThersTEMPApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        if deviceData.wifi_status == true{
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TemperatureThresholdLowWarningLevel", value: self.selectedLowWarning, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TemperatureThresholdLowalertLevel", value: self.selectedLowAlert, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TemperatureThresholdHighWarningLevel", value: self.selectedHighWarning, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TemperatureThresholdHighalertLevel", value: self.selectedHighAlert, deviceId: Int64(deviceData.device_id)))
                        }
                        
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            RealmDataManager.shared.updateAllThresHoldFilterData(pollutantType: self.pollutantType.rawValue, lowWarning: self.selectedLowWarning, highWarning: self.selectedHighWarning, lowAlert: self.selectedLowAlert, highAlert: self.selectedHighAlert, tempOffset: self.selectedTempOffset)
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
                
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TemperatureThresholdLowWarningLevel", value: self.selectedLowWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TemperatureThresholdLowalertLevel", value: self.selectedLowAlert, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TemperatureThresholdHighWarningLevel", value: self.selectedHighWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "TemperatureThresholdHighalertLevel", value: self.selectedHighAlert, deviceId: Int64(self.selectedDeviceID)))
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    self.hideActivityIndicator(self.view)
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    if error == nil {
                        RealmDataManager.shared.updateThresHoldFilterData(deviceID: self.selectedDeviceID, pollutantType: self.pollutantType.rawValue, lowWarning: self.selectedLowWarning, highWarning: self.selectedHighWarning, lowAlert: self.selectedLowAlert, highAlert: self.selectedHighAlert, tempOffset: self.selectedTempOffset)
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
extension ThersHoldTemperatureViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveThresHoldtempAPINewGood()
        }
    }
    
    func writeTemperatureValueBle()  {
        self.convertValuesAsPerUnits()
        print("Before API")
        print(self.previousLowWarning)
        print(self.previousLowAlert)
        print(self.previousHighAlert)
        print(self.previousHighWarning)
        print(self.selectedLowWarning)
        print(self.selectedLowAlert)
        print(self.selectedHighAlert)
        print(self.selectedHighWarning)
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true  || self.isThersTEMPApplyAll == true {
                self.saveThresHoldtempAPINewGood()
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
extension ThersHoldTemperatureViewController:CBCentralManagerDelegate{
    
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
                self.writeTempratureValueViaBLE(selectedLowWarning: self.selectedLowWarning.toFloat() ?? 0.0, selectedHighWarning: self.selectedHighWarning.toFloat() ?? 0.0, selectedLowAlert: self.selectedLowAlert.toFloat() ?? 0.0, selectedHighAlert: self.selectedHighAlert.toFloat() ?? 0.0, deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id)
            }
        }
    }
}
extension ThersHoldTemperatureViewController {
    
    func convertValuesAsPerUnits()  {
        if self.selectedDropDownType == .DropDownTEMPERATURE_CELSIUS{
            self.selectedLowWarning = self.lblThersHoldTempLowWarning.text!.replacingOccurrences(of: "Celsius", with: "")
            self.selectedLowAlert = self.lblThersHoldTempLowAlert.text!.replacingOccurrences(of: "Celsius", with: "")
            if let floatWarning = self.removeWhiteSpace(text: self.selectedLowWarning).toFloat() {
                self.selectedLowWarning = String(format: "%f", self.convertTemperatureCelsiusToFahrenheit(value: floatWarning))
            }
            if let floatAlert = self.removeWhiteSpace(text: self.selectedLowAlert).toFloat() {
                self.selectedLowAlert = String(format: "%f", self.convertTemperatureCelsiusToFahrenheit(value: floatAlert))
            }
            
            self.selectedHighWarning = self.lblThersHoldTempHighWarning.text!.replacingOccurrences(of: "Celsius", with: "")
            self.selectedHighAlert = self.lblThersHoldTempHighAlert.text!.replacingOccurrences(of: "Celsius", with: "")
            if let floatHighWarning = self.removeWhiteSpace(text: self.selectedHighWarning).toFloat() {
                self.selectedHighWarning = String(format: "%f", self.convertTemperatureCelsiusToFahrenheit(value: floatHighWarning))
            }
            if let floatHighAlert = self.removeWhiteSpace(text: self.selectedHighAlert).toFloat() {
                self.selectedHighAlert = String(format: "%f", self.convertTemperatureCelsiusToFahrenheit(value: floatHighAlert))
            }
        }else {
            self.selectedLowWarning = self.removeWhiteSpace(text: self.lblThersHoldTempLowWarning.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.selectedLowAlert = self.removeWhiteSpace(text: self.lblThersHoldTempLowAlert.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.selectedHighWarning = self.removeWhiteSpace(text: self.lblThersHoldTempHighWarning.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.selectedHighAlert = self.removeWhiteSpace(text: self.lblThersHoldTempHighAlert.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
        }
    }
    func compareConvertValuesAsPerUnits()  {
        if self.selectedDropDownType == .DropDownTEMPERATURE_CELSIUS{
            self.selectedLowWarning = self.lblThersHoldTempLowWarning.text!.replacingOccurrences(of: "Celsius", with: "")
            self.selectedLowAlert = self.lblThersHoldTempLowAlert.text!.replacingOccurrences(of: "Celsius", with: "")
            self.selectedHighWarning = self.lblThersHoldTempHighWarning.text!.replacingOccurrences(of: "Celsius", with: "")
            self.selectedHighAlert = self.lblThersHoldTempHighAlert.text!.replacingOccurrences(of: "Celsius", with: "")
            
        }else {
            self.selectedLowWarning = self.removeWhiteSpace(text: self.lblThersHoldTempLowWarning.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.selectedLowAlert = self.removeWhiteSpace(text: self.lblThersHoldTempLowAlert.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.selectedHighWarning = self.removeWhiteSpace(text: self.lblThersHoldTempHighWarning.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.selectedHighAlert = self.removeWhiteSpace(text: self.lblThersHoldTempHighAlert.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
        }
    }
    
    func previousCopyconvertValuesAsPerUnits()  {
        if self.selectedDropDownType == .DropDownTEMPERATURE_CELSIUS{
            self.previousLowWarning = self.lblThersHoldTempLowWarning.text!.replacingOccurrences(of: "Celsius", with: "")
            self.previousLowAlert = self.lblThersHoldTempLowAlert.text!.replacingOccurrences(of: "Celsius", with: "")
            if let floatWarning = self.removeWhiteSpace(text: self.selectedLowWarning).toFloat() {
                self.previousLowWarning = String(format: "%f", self.convertTemperatureCelsiusToFahrenheit(value: floatWarning))
            }
            if let floatAlert = self.removeWhiteSpace(text: self.selectedLowAlert).toFloat() {
                self.previousLowAlert = String(format: "%f", self.convertTemperatureCelsiusToFahrenheit(value: floatAlert))
            }
            
            self.previousHighWarning = self.lblThersHoldTempHighWarning.text!.replacingOccurrences(of: "Celsius", with: "")
            self.previousHighAlert = self.lblThersHoldTempHighAlert.text!.replacingOccurrences(of: "Celsius", with: "")
            if let floatHighWarning = self.removeWhiteSpace(text: self.selectedHighWarning).toFloat() {
                self.previousHighWarning = String(format: "%f", self.convertTemperatureCelsiusToFahrenheit(value: floatHighWarning))
            }
            if let floatHighAlert = self.removeWhiteSpace(text: self.selectedHighAlert).toFloat() {
                self.previousHighAlert = String(format: "%f", self.convertTemperatureCelsiusToFahrenheit(value: floatHighAlert))
            }
        }else {
            self.previousLowWarning = self.removeWhiteSpace(text: self.lblThersHoldTempLowWarning.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.previousLowAlert = self.removeWhiteSpace(text: self.lblThersHoldTempLowAlert.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.previousHighWarning = self.removeWhiteSpace(text: self.lblThersHoldTempHighWarning.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
            self.previousHighAlert = self.removeWhiteSpace(text: self.lblThersHoldTempHighAlert.text!.replacingOccurrences(of: "Fahrenheit", with: ""))
        }
    }
    
    func backCompareValues() -> Bool{
        if self.arrCurrentDevice.count == 0 {
            return true
        }
        self.compareConvertValuesAsPerUnits()
        print(self.previousLowWarning)
        print(self.previousLowAlert)
        print(self.previousHighAlert)
        print(self.previousHighWarning)
        print(self.selectedLowWarning)
        print(self.selectedLowAlert)
        print(self.selectedHighAlert)
        print(self.selectedHighWarning)
        print("Before Compare")
        if self.previousLowWarning != self.selectedLowWarning || self.previousLowAlert != self.selectedLowAlert  || self.previousHighAlert != self.selectedHighAlert || self.previousHighWarning != self.selectedHighWarning || self.isThersTEMPApplyAll == true {
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
            self.writeTemperatureValueBle()
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
