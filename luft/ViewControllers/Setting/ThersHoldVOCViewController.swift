//
//  ThersHoldVOCViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class ThersHoldVOCViewController:LTSettingBaseViewController {
    
    
    @IBOutlet weak var lblThersHoldVOCDeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var btnThersHoldVOCDeviceName: UIButton!
    @IBOutlet weak var lblThersHoldVOCWarning: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldVOCAlert: LTCellSubTitleLabel!
    @IBOutlet weak var btnThersHoldVOCWarning: UIButton!
    @IBOutlet weak var btnThersHoldVOCAlert: UIButton!
    @IBOutlet weak var viewTThersHoldVOCbtnApplyAll: LTCellView!
    @IBOutlet weak var btnThersHoldVOCbtnApplyAll: UIButton!
    @IBOutlet weak var btnThersHoldVOCbtnReset: UIButton!
    @IBOutlet weak var btnThersHoldVOCSave: UIButton!
    @IBOutlet weak var imgViewThersHoldVOCbtnApplyAll: UIImageView!
    
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
    
    var selectedDropDownType:AppDropDownType? = .DropDownVOC
    var selectedType:SelectedFieldType? = .SelectedNone
    var vocContext: NSManagedObjectContext!
    
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedLowWarning:String = ""
    var selectedLowAlert:String = ""
    var arrPollutantVOCData:[RealmThresHoldSetting] = []
    var isThersVOCbtnApplyAll:Bool = false
    
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
        self.lblThersHoldVOCDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        self.vocContext = appDelegate.persistentContainer.viewContext
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.loadVOCvalues()
        self.viewTThersHoldVOCbtnApplyAll.isHidden = false
        self.imgViewThersHoldVOCbtnApplyAll.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage
        
       // self.switchAlertEnable.isOn = true
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        
        
        if UserDefaults.standard.bool(forKey: "TVOCSwitch") == true {
            self.switchAlertEnable.isOn = true
            self.stackViewBottom.isHidden = false
            self.stackViewBottomheightConstant.constant = 45
            self.stackViewWarnning.isHidden = false
            self.stackViewWarnningheightConstant.constant = 125
            self.stackViewResetToDefault.isHidden = false
            self.stackViewResetToDefaultheightConstant.constant = 45
            self.labelYouWillBeNotified.isHidden = false
        } else{
            self.switchAlertEnable.isOn = false
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
            self.lblThersHoldVOCWarning.text = "32000"
            self.lblThersHoldVOCAlert.text = "0"
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
            UserDefaults.standard.set(true, forKey: "TVOCSwitch")
            
        }else{
//            self.stackViewBottom.isHidden = true
//            self.stackViewBottomheightConstant.constant = 0
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
//            self.stackViewResetToDefault.isHidden = true
//            self.stackViewResetToDefaultheightConstant.constant = 0
//            self.labelYouWillBeNotified.isHidden = true
            UserDefaults.standard.set(false, forKey: "TVOCSwitch")
        }
    }
    
    func isFromInitialAddDeviceView()  {
        self.stackViewBottom?.isHidden = true
        self.stackViewBottomheightConstant?.constant = 0.0
        self.btnThersHoldVOCDeviceName.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
    
    func loadVOCvalues() {
        self.btnThersHoldVOCDeviceName.addTarget(self, action:#selector(self.btnTapThersVOCDeviceList(_sender:)), for: .touchUpInside)
        self.btnThersHoldVOCWarning.addTarget(self, action:#selector(self.btnTapThersVOCWarning(_sender:)), for: .touchUpInside)
        self.btnThersHoldVOCAlert.addTarget(self, action:#selector(self.btnTapThersVOCAlert(_sender:)), for: .touchUpInside)
        self.btnThersHoldVOCbtnApplyAll.addTarget(self, action:#selector(self.btnTapThersVOCApplyAll(_sender:)), for: .touchUpInside)
        self.btnThersHoldVOCbtnReset.addTarget(self, action:#selector(self.btnTapThersVOCResetAll(_sender:)), for: .touchUpInside)
        self.btnThersHoldVOCSave.addTarget(self, action:#selector(self.btnTapThersHoldVOCSave(_sender:)), for: .touchUpInside)
    }
    
    func getDeviceThersHold(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrPollutantVOCData = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceID, pollutantType: PollutantType.PollutantVOC.rawValue)
        if self.arrPollutantVOCData.count == 0 {
            self.lblThersHoldVOCDeviceName.text = "Select"
            self.lblThersHoldVOCWarning.text = "Select"
            self.lblThersHoldVOCAlert.text = "Select"
            
            self.lblThersHoldVOCDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldVOCWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldVOCAlert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            return
        }
        self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
        self.selectedLowWarning =  self.arrPollutantVOCData[0].low_waring_value
        self.selectedLowAlert =  self.arrPollutantVOCData[0].low_alert_value
        self.lblThersHoldVOCDeviceName.text = self.selectedDeviceName
        self.lblThersHoldVOCWarning.text = String(format: "%@ ppb", self.selectedLowWarning)
        self.lblThersHoldVOCAlert.text = String(format: "%@ ppb", self.selectedLowAlert)
        self.previousCopyconvertValuesAsPerUnits()
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
    }
}

extension ThersHoldVOCViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnTapThersVOCDeviceList(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    
    @objc func btnTapThersVOCWarning(_sender:UIButton) {
        self.selectedType = .SelectedWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnTapThersVOCAlert(_sender:UIButton) {
        self.selectedType = .SelectedAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnTapThersVOCApplyAll(_sender:UIButton) {
        if self.isThersVOCbtnApplyAll == false {
            self.isThersVOCbtnApplyAll = true
            self.imgViewThersHoldVOCbtnApplyAll.image = ThemeManager.currentTheme().cellSelectedCheckIconImage
        }else {
            self.imgViewThersHoldVOCbtnApplyAll.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage
            self.isThersVOCbtnApplyAll = false
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
    
    @objc func btnTapThersVOCResetAll(_sender:UIButton) {
        self.readResetDataVOC()
    }
    
    @objc func btnTapThersHoldVOCSave(_sender:UIButton) {
        if self.lblThersHoldVOCWarning.text?.count != 0  && self.lblThersHoldVOCAlert.text?.count != 0 {
            self.convertValuesAsPerUnits()
            self.writeVOCValueBle()
        }
    }
}

extension ThersHoldVOCViewController: LTDropDownThersHoldDelegate,LTDropDownDeviceListDelegate {
    
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int) {
        self.lblThersHoldVOCDeviceName?.text = selectedDeviceName
        self.selectedDeviceID = selectedDeviceID
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.lblThersHoldVOCDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    func selectedThresHoldValue(selectedValue:String){
        
        if self.selectedType == .SelectedWarning {
            self.lblThersHoldVOCWarning.text = selectedValue
        }
        else if self.selectedType == .SelectedAlert {
            self.lblThersHoldVOCAlert.text = selectedValue
        }
        else {
            self.lblThersHoldVOCDeviceName.text = selectedValue
        }
    }
    
    func readResetDataVOC()  {
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_VOC)
        let predicate = NSPredicate(format: "warning == %@", NSNumber(value: true))
        fetch.predicate = predicate
        do {
            let result = try self.vocContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.lblThersHoldVOCWarning?.text = data.value(forKey: "vocvalue") as? String
            }
        } catch {
            print("Failed")
        }
        
        let predicate1 = NSPredicate(format: "alert == %@", NSNumber(value: true))
        fetch.predicate = predicate1
        do {
            let result = try self.vocContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.lblThersHoldVOCAlert?.text = data.value(forKey: "vocvalue") as? String
            }
        } catch {
            print("Failed")
        }
    }
}
extension ThersHoldVOCViewController {
    
    func saveThresHoldVOCAPINewGood(){
        
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isThersVOCbtnApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        if deviceData.wifi_status == true{
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "VocThresholdWarningLevel", value: self.removeWhiteSpace(text: self.selectedLowWarning), deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "VocThresholdAlertLevel", value: self.removeWhiteSpace(text:self.selectedLowAlert), deviceId: Int64(deviceData.device_id)))
                        }
                        
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            RealmDataManager.shared.updateAllThresHoldFilterData(pollutantType: PollutantType.PollutantVOC.rawValue, lowWarning: self.removeWhiteSpace(text:self.selectedLowWarning), highWarning: "", lowAlert: self.removeWhiteSpace(text:self.selectedLowAlert), highAlert: "", tempOffset: "")
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
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "VocThresholdWarningLevel", value: self.selectedLowWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "VocThresholdAlertLevel", value: self.selectedLowAlert, deviceId: Int64(self.selectedDeviceID)))
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    self.hideActivityIndicator(self.view)
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    if error == nil {
                        RealmDataManager.shared.updateThresHoldFilterData(deviceID: self.selectedDeviceID, pollutantType: PollutantType.PollutantVOC.rawValue, lowWarning: self.selectedLowWarning, highWarning: "", lowAlert: self.selectedLowAlert, highAlert: "", tempOffset: "")
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
extension ThersHoldVOCViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveThresHoldVOCAPINewGood()
        }
        
    }
    
    func writeVOCValueBle()  {
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true || self.isThersVOCbtnApplyAll == true {
                self.saveThresHoldVOCAPINewGood()
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
extension ThersHoldVOCViewController:CBCentralManagerDelegate{
    
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
                self.writeVOCValueViaBLE(selectedLowAlert: self.selectedLowAlert.toFloat() ?? 0.0, selectedLowWarning: self.selectedLowWarning.toFloat()  ?? 0.0, deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id)
            }
        }
    }
}
extension ThersHoldVOCViewController {
    
    func convertValuesAsPerUnits()  {
        self.selectedLowWarning = self.lblThersHoldVOCWarning.text!.replacingOccurrences(of: "ppb", with: "")
        self.selectedLowAlert = self.lblThersHoldVOCAlert.text!.replacingOccurrences(of: "ppb", with: "")
        self.selectedLowWarning = self.removeWhiteSpace(text: self.selectedLowWarning)
        self.selectedLowAlert = self.removeWhiteSpace(text: self.selectedLowAlert)
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
        if self.previousLowWarning != self.selectedLowWarning || self.previousLowAlert != self.selectedLowAlert || self.isThersVOCbtnApplyAll == true  {
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
            self.writeVOCValueBle()
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
