//
//  ThersHoldRadonViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class ThersHoldRadonViewController:LTSettingBaseViewController {
    
    
    @IBOutlet weak var lblRadDeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var btnRadDeviceName: UIButton!
    @IBOutlet weak var lblRadWarning: LTCellSubTitleLabel!
    @IBOutlet weak var btnRadAlert: UIButton!
    @IBOutlet weak var lblRadAlert: LTCellSubTitleLabel!
    @IBOutlet weak var btnRadbtnWarning: UIButton!
    @IBOutlet weak var viewThersRadonbtnApplyAll: LTCellView!
    @IBOutlet weak var btnThersRadonbtnApplyAll: UIButton!
    @IBOutlet weak var btnThersRadonbtnReset: UIButton!
    @IBOutlet weak var btnThersRadonbtnSave: UIButton!
    @IBOutlet weak var imgViewThersRadonbtnApplyAll: UIImageView!
    
    @IBOutlet weak var stackViewBottomRadon: UIStackView!
    @IBOutlet weak var stackViewBottomheightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewResetToDefault: UIStackView!
    @IBOutlet weak var stackViewResetToDefaultheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewAlertsAndWarnning: UIStackView!
    @IBOutlet weak var stackViewAlertsAndWarnningheightConstant: NSLayoutConstraint!
    
    //Switch Button Alerts
    @IBOutlet weak var switchAlertEnable: UISwitch!
    
    @IBOutlet weak var imgViewDevice: UIImageView!
    
    var selectedDropDownType:AppDropDownType? = .DropDownNone
    var selectedType:SelectedFieldType? = .SelectedNone
    var radonContext: NSManagedObjectContext!
    
    var pollutantType:PollutantType = .PollutantRadon
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedLowWarning:String = ""
    var selectedLowAlert:String = ""
    var arrPollutantRadonData:[RealmThresHoldSetting] = []
    var arrCurrentDevice:[RealmDeviceList] = []
    var isThersRadonbtnApplyAll:Bool = false
    
    var previousLowWarning:String = ""
    var previousLowAlert:String = ""
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    var serialDeviceName:String = ""
    var isFromInitialAddDevice:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.radonContext = appDelegate.persistentContainer.viewContext
        self.lblRadDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        self.selectedDropDownType = .DropDownRadonBQM
        if AppSession.shared.getMobileUserMeData()?.radonUnitTypeId == 2{
            self.selectedDropDownType = .DropDownRadonPCII
        }
        self.loadRadonvalues()
        print(self.selectedDeviceID)
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.viewThersRadonbtnApplyAll.isHidden = false
        //Apply all image icon change- Gauri
        self.imgViewThersRadonbtnApplyAll.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage
        
       // self.switchAlertEnable.isOn = true
        
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        
        
        if UserDefaults.standard.bool(forKey: "RadonSwitch") == true {
            self.switchAlertEnable.isOn = true
            self.stackViewBottomRadon.isHidden = false
            self.stackViewBottomheightConstant.constant = 45
            self.stackViewResetToDefault.isHidden = false
            self.stackViewResetToDefaultheightConstant.constant = 45
            self.stackViewAlertsAndWarnning.isHidden = false
            self.stackViewAlertsAndWarnningheightConstant.constant = 125
        } else{
            self.switchAlertEnable.isOn = false
            self.stackViewAlertsAndWarnning.isHidden = true
            self.stackViewAlertsAndWarnningheightConstant.constant = 0
            self.lblRadWarning.text = "32000"
            self.lblRadAlert.text = "0"
            
            print(self.lblRadWarning.text ?? "")
            print(self.lblRadAlert.text ?? "")
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
        
       // self.readResetData()
        if self.isFromInitialAddDevice{
            self.isFromInitialAddDeviceView()
        }
    }
   
    
    @objc func switchColorStatusChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            self.stackViewAlertsAndWarnning.isHidden = false
            self.stackViewAlertsAndWarnningheightConstant.constant = 125
            self.readResetData()
            UserDefaults.standard.set(true, forKey: "RadonSwitch")
        }else{
            self.stackViewAlertsAndWarnning.isHidden = true
            self.stackViewAlertsAndWarnningheightConstant.constant = 0
            self.lblRadWarning.text = "32000"
            self.lblRadAlert.text = "0"
            UserDefaults.standard.set(false, forKey: "RadonSwitch")
        }
    }
    
    
    func isFromInitialAddDeviceView()  {
        self.stackViewBottomRadon?.isHidden = true
        self.stackViewBottomheightConstant?.constant = 0.0
        self.btnRadDeviceName.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
    
    func loadRadonvalues() {
        self.btnRadDeviceName.addTarget(self, action:#selector(self.btnTapThersRadonDeviceList(_sender:)), for: .touchUpInside)
        self.btnRadbtnWarning.addTarget(self, action:#selector(self.btnTapThersRadonWarning(_sender:)), for: .touchUpInside)
        self.btnRadAlert.addTarget(self, action:#selector(self.btnTapThersRadonAlert(_sender:)), for: .touchUpInside)
        self.btnThersRadonbtnApplyAll.addTarget(self, action:#selector(self.btnTapThersRadonbtnApplyAll(_sender:)), for: .touchUpInside)
        self.btnThersRadonbtnReset.addTarget(self, action:#selector(self.btnTapThersRadonbtnResetAll(_sender:)), for: .touchUpInside)
        self.btnThersRadonbtnSave.addTarget(self, action:#selector(self.btnThersRadonbtnSaveTap(_sender:)), for: .touchUpInside)
    }
    
    func getDeviceThersHold(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrPollutantRadonData = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceID, pollutantType: self.pollutantType.rawValue)
        if self.arrPollutantRadonData.count == 0 {
            self.lblRadWarning.text = "Select"
            self.lblRadAlert.text = "Select"
            self.lblRadDeviceName.text = "Select"
            self.lblRadWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblRadAlert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblRadDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            return
        }
        self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
        if self.selectedDropDownType == .DropDownRadonBQM{
            let myLowWarningValue = Int(self.convertRadonPCILToBQM3(value: Float(self.arrPollutantRadonData[0].low_waring_value) ?? 0.0).rounded())
            self.selectedLowWarning = String(format: "%d",myLowWarningValue)
            let myLowAlertValue = Int(self.convertRadonPCILToBQM3(value: Float(self.arrPollutantRadonData[0].low_alert_value) ?? 0.0).rounded())
            self.selectedLowAlert = String(format: "%d",myLowAlertValue)
            
            let valueStr = String(format: "%@ Bq/m" , self.selectedLowWarning)
            let numberString = NSMutableAttributedString(string: valueStr, attributes: [.font: UIFont.setSystemFontRegular(17)])
            numberString.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 8]))
            self.lblRadWarning.attributedText = numberString
            
            let valueStr1 = String(format: "%@ Bq/m" , self.selectedLowAlert)
            let numberString1 = NSMutableAttributedString(string: valueStr1, attributes: [.font: UIFont.setSystemFontRegular(17)])
            numberString1.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 8]))
            self.lblRadAlert.attributedText = numberString1
            
            
        }else {
            let floatLowWarning = Float(self.arrPollutantRadonData[0].low_waring_value)
            self.selectedLowWarning = String(format: "%.1f pCi/l",floatLowWarning ?? 0.0)
            let floatLowAlert = Float(self.arrPollutantRadonData[0].low_alert_value)
            self.selectedLowAlert = String(format: "%.1f pCi/l",floatLowAlert ?? 0.0)
            self.lblRadWarning.text = self.selectedLowWarning
            self.lblRadAlert.text = self.selectedLowAlert
            self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        }
        self.lblRadDeviceName.text = self.selectedDeviceName
        self.previousCopyconvertValuesAsPerUnits()
    }
}
extension ThersHoldRadonViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnTapThersRadonDeviceList(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    
    @objc func btnTapThersRadonAlert(_sender:UIButton) {
        self.selectedType = .SelectedWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnTapThersRadonWarning(_sender:UIButton) {
        self.selectedType = .SelectedAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnTapThersRadonbtnApplyAll(_sender:UIButton) {
        if self.isThersRadonbtnApplyAll == false {
            self.isThersRadonbtnApplyAll = true
            self.imgViewThersRadonbtnApplyAll.image = ThemeManager.currentTheme().cellSelectedCheckIconImage
        }else {
            //Apply all image icon change- Gauri
            self.imgViewThersRadonbtnApplyAll.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage
            self.isThersRadonbtnApplyAll = false
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
    
    @objc func btnTapThersRadonbtnResetAll(_sender:UIButton) {
        self.readResetData()
    }
    
    @objc func btnThersRadonbtnSaveTap(_sender:UIButton) {
        
        if self.lblRadWarning.text?.count != 0  && self.lblRadAlert.text?.count != 0 {
            self.convertValuesAsPerUnits()
            self.writeRadonValueBle()
        }
    }
    
}

extension ThersHoldRadonViewController: LTDropDownThersHoldDelegate,LTDropDownDeviceListDelegate {
    
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int) {
        self.lblRadDeviceName?.text = selectedDeviceName
        self.selectedDeviceID = selectedDeviceID
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.lblRadDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    
    func selectedThresHoldValue(selectedValue:String){
        
        if self.selectedType == .SelectedWarning {
            self.selectedLowWarning = selectedValue
            self.lblRadWarning.text = selectedValue
            if self.selectedDropDownType == .DropDownRadonBQM{
                let valueStr = String(format: "%@ Bq/m" , selectedValue)
                let numberString = NSMutableAttributedString(string: valueStr, attributes: [.font: UIFont.setSystemFontRegular(17)])
                numberString.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 8]))
                self.lblRadWarning.attributedText = numberString
            }
            
        }
        else if self.selectedType == .SelectedAlert {
            self.selectedLowAlert = selectedValue
            self.lblRadAlert.text = selectedValue
            if self.selectedDropDownType == .DropDownRadonBQM{
                let valueStr1 = String(format: "%@ Bq/m" , selectedValue)
                let numberString1 = NSMutableAttributedString(string: valueStr1, attributes: [.font: UIFont.setSystemFontRegular(17)])
                numberString1.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 8]))
                self.lblRadAlert.attributedText = numberString1
            }
            
        }
        else {
            self.lblRadDeviceName.text = selectedValue
        }
    }
    
    func readResetData()  {
        
        var entityName:String = TBL_RADON_PCII
        if self.selectedDropDownType == .DropDownRadonBQM {
            entityName = TBL_RADON_BQM
        }
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let predicate = NSPredicate(format: "warning == %@", NSNumber(value: true))
        fetch.predicate = predicate
        do {
            let result = try self.radonContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownRadonBQM {
                    self.selectedLowWarning = data.value(forKey: "bqm3") as? String ?? ""
                    let valueStr = String(format: "%@ Bq/m" , data.value(forKey: "bqm3") as? String ?? "")
                    let numberString = NSMutableAttributedString(string: valueStr, attributes: [.font: UIFont.setSystemFontRegular(17)])
                    numberString.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 8]))
                    self.lblRadWarning.attributedText = numberString
                    
                }else {
                    self.lblRadWarning?.text = data.value(forKey: "pcii") as? String
                }
            }
        } catch {
            print("Failed")
        }
        
        let predicate1 = NSPredicate(format: "alert == %@", NSNumber(value: true))
        fetch.predicate = predicate1
        do {
            let result = try self.radonContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownRadonBQM {
                    self.selectedLowAlert = data.value(forKey: "bqm3") as? String ?? ""
                    let valueStr = String(format: "%@ Bq/m" , data.value(forKey: "bqm3") as? String ?? "")
                    let numberString = NSMutableAttributedString(string: valueStr, attributes: [.font: UIFont.setSystemFontRegular(17)])
                    numberString.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 8]))
                    self.lblRadAlert.attributedText = numberString
                }else {
                    self.lblRadAlert?.text = data.value(forKey: "pcii") as? String
                }
            }
        } catch {
            print("Failed")
        }
    }
}
extension ThersHoldRadonViewController {
    
    func saveThresHoldradonAPINewGood(){
        
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isThersRadonbtnApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        if deviceData.wifi_status == true{
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "RadonThresholdWarningLevel", value: self.selectedLowWarning, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "RadonThresholdAlertLevel", value: self.selectedLowAlert, deviceId: Int64(deviceData.device_id)))
                        }
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            RealmDataManager.shared.updateAllThresHoldFilterData(pollutantType: self.pollutantType.rawValue, lowWarning: self.selectedLowWarning, highWarning: "", lowAlert: self.selectedLowAlert, highAlert: "", tempOffset: "")
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
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "RadonThresholdWarningLevel", value: self.selectedLowWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "RadonThresholdAlertLevel", value: self.selectedLowAlert, deviceId: Int64(self.selectedDeviceID)))
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    self.hideActivityIndicator(self.view)
                    if error == nil {
                        RealmDataManager.shared.updateThresHoldFilterData(deviceID: self.selectedDeviceID, pollutantType: self.pollutantType.rawValue, lowWarning: self.selectedLowWarning, highWarning: "", lowAlert: self.selectedLowAlert, highAlert: "", tempOffset: "")
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
extension ThersHoldRadonViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveThresHoldradonAPINewGood()
        }
    }
    
    func writeRadonValueBle()  {
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true  || self.isThersRadonbtnApplyAll == true {
                self.saveThresHoldradonAPINewGood()
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
extension ThersHoldRadonViewController:CBCentralManagerDelegate{
    
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
                self.writeRadonValueViaBLE(selectedLowAlert: self.selectedLowAlert.toFloat() ?? 0.0, selectedLowWarning: self.selectedLowWarning.toFloat()  ?? 0.0, deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id)
            }
        }
    }
}

extension ThersHoldRadonViewController {
    
    func convertValuesAsPerUnits()  {
        if self.selectedDropDownType == .DropDownRadonBQM{
            if let floatWarning = Float(self.removeWhiteSpace(text: self.selectedLowWarning)) {
                self.selectedLowWarning = String(format: "%f", self.convertRadonBQM3ToPCIL(value: floatWarning))
            }
            if let floatAlert = Float(self.removeWhiteSpace(text: self.selectedLowAlert)) {
                self.selectedLowAlert = String(format: "%f", self.convertRadonBQM3ToPCIL(value: floatAlert))
            }
        }else {
            self.selectedLowWarning = self.removeWhiteSpace(text: self.lblRadWarning.text!.replacingOccurrences(of: "pCi/l", with: ""))
            self.selectedLowAlert = self.removeWhiteSpace(text: self.lblRadAlert.text!.replacingOccurrences(of: "pCi/l", with: ""))
        }
    }
    
    func previousCopyconvertValuesAsPerUnits()  {
        if self.selectedDropDownType == .DropDownRadonBQM{
            if let floatWarning = Float(self.removeWhiteSpace(text: self.selectedLowWarning)) {
                self.previousLowWarning = String(format: "%f", self.convertRadonBQM3ToPCIL(value: floatWarning))
            }
            if let floatAlert = Float(self.removeWhiteSpace(text: self.selectedLowAlert)) {
                self.previousLowAlert = String(format: "%f", self.convertRadonBQM3ToPCIL(value: floatAlert))
            }
        }else {
            self.previousLowWarning = self.removeWhiteSpace(text: self.lblRadWarning.text!.replacingOccurrences(of: "pCi/l", with: ""))
            self.previousLowAlert = self.removeWhiteSpace(text: self.lblRadAlert.text!.replacingOccurrences(of: "pCi/l", with: ""))
        }
    }
    
    func backCompareValues() -> Bool{
        
        if self.arrCurrentDevice.count == 0 {
            return true
        }
        
        self.convertValuesAsPerUnits()
        if self.previousLowWarning != self.selectedLowWarning || self.previousLowAlert != self.selectedLowAlert || self.isThersRadonbtnApplyAll == true {
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
            self.writeRadonValueBle()
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
