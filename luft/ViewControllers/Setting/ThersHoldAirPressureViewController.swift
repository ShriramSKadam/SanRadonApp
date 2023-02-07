//
//  ThersHoldAirPressureViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class ThersHoldAirPressureViewController:LTSettingBaseViewController {
    
    
    @IBOutlet weak var lblThersHoldAIRPRESSUREDeviceName: LTCellSubTitleLabel!
    @IBOutlet weak var btnDeviceNameThersHoldAIRPRESSURE: UIButton!
    
    //Warnings
    @IBOutlet weak var lblThersHoldAIRPRESSURELowWarning: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldAIRPRESSUREHighWarning: LTCellSubTitleLabel!
    
    //Alerts
    @IBOutlet weak var lblThersHoldAIRPRESSURELowAlert: LTCellSubTitleLabel!
    @IBOutlet weak var lblThersHoldAIRPRESSUREHighAlert: LTCellSubTitleLabel!
    
    
    //Button Warnings
    @IBOutlet weak var btnThersHoldAIRPRESSURELowWarning: UIButton!
    @IBOutlet weak var btnThersHoldAIRPRESSUREHighWarning: UIButton!
    
    //Button Alerts
    @IBOutlet weak var btnThersHoldAIRPRESSURELowAlert: UIButton!
    @IBOutlet weak var btnThersHoldAIRPRESSUREHighAlert: UIButton!
    
    //Apply All Button
    @IBOutlet weak var btnThersHoldeAIRPRESSUREBtnApplyAll: UIButton!
    
    
    //Apply All ImgView Selection
    @IBOutlet weak var viewThersHoldAIRPRESSUREApplyAllView: LTCellView!
    
    //Reset Button Alerts
    @IBOutlet weak var btnThersHoldeAIRPRESSUREBtnReaset: UIButton!
    
    //Save Button Alerts
    @IBOutlet weak var btnThersHoldeAIRPRESSURESave: UIButton!
    
    @IBOutlet weak var imgViewThersHoldAIRPRESSUREApplyAllView: UIImageView!
    
    @IBOutlet weak var stackViewBottom: UIStackView!
    @IBOutlet weak var stackViewBottomheightConstant: NSLayoutConstraint!
    
   
    @IBOutlet weak var stackViewWarnning: UIStackView!
    @IBOutlet weak var stackViewWarnningheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewAlert: UIStackView!
    @IBOutlet weak var stackViewAlertheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewResetToDefault: UIStackView!
    @IBOutlet weak var stackViewResetToDefaultheightConstant: NSLayoutConstraint!
    @IBOutlet weak var stackViewAltitudeCorrection: UIStackView!
    @IBOutlet weak var stackViewAltitudeCorrectionheightConstant: NSLayoutConstraint!
    @IBOutlet weak var labelYouWillBeNotified: UILabel!
    @IBOutlet weak var addIndicatorView: UIView!
    
    //Switch Button Alerts
    @IBOutlet weak var switchAlertEnable: UISwitch!
    @IBOutlet weak var imgViewDevice: UIImageView!
    
    //Switch Button Alerts
    @IBOutlet weak var switchAltitude: UISwitch!
    
    var selectedDropDownType:AppDropDownType? = .DropDownNone
    var selectedType:SelectedFieldType? = .SelectedNone
    var airContext: NSManagedObjectContext!
    
    var pollutantType:PollutantType = .PollutantAirPressure
    var selectedDeviceID:Int = 0
    var selectedDeviceName:String = ""
    var selectedLowWarning:String = ""
    var selectedLowAlert:String = ""
    var selectedHighWarning:String = ""
    var selectedHighAlert:String = ""
    var arrPollutantAirPressureData:[RealmThresHoldSetting] = []
    var isThersAIRPRESSUREApplyAll:Bool = false
    
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
    var selectAltitudeApply:Bool = false
    var previousAltitudeApply:Bool = false
    var altitudeValue:String = ""
    var altitudeMBARValue:String = ""
    var altitudeINHGRValue:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.airContext = appDelegate.persistentContainer.viewContext
        self.lblThersHoldAIRPRESSUREDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        self.selectedDropDownType = .DropDownAIRPRESSURE_MBAR
        if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
            self.selectedDropDownType = .DropDownAIRPRESSURE_INHG
        }
        self.viewThersHoldAIRPRESSUREApplyAllView.isHidden = true
        if self.isFromInitialAddDevice == false{
            self.selectedDeviceID = RealmDataManager.shared.readFirstDeviceDataValues()
        }
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.loadAirPressurevalues()
        self.viewThersHoldAIRPRESSUREApplyAllView.isHidden = false
        //self.imgViewThersHoldAIRPRESSUREApplyAllView.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgViewThersHoldAIRPRESSUREApplyAllView.image = UIImage.init(named:CELL_BLANK_CHECKMARK)!

        
//        self.switchAlertEnable.isOn = true
        self.switchAltitude.isOn = true
        self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        
        if UserDefaults.standard.bool(forKey: "AirPressureSwitch") == true {
            self.switchAlertEnable.isOn = true
            self.stackViewBottom.isHidden = false
            self.stackViewBottomheightConstant.constant = 45
            self.stackViewWarnning.isHidden = false
            self.stackViewWarnningheightConstant.constant = 125
            self.stackViewAlert.isHidden = false
            self.stackViewAlertheightConstant.constant = 125
            self.stackViewResetToDefault.isHidden = false
            self.stackViewResetToDefaultheightConstant.constant = 45
            self.stackViewAltitudeCorrection.isHidden = false
            self.stackViewAltitudeCorrectionheightConstant.constant = 84
            self.labelYouWillBeNotified.isHidden = false
            self.addIndicatorView.isHidden = false
        } else{
            self.switchAlertEnable.isOn = false
            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
            self.stackViewAlert.isHidden = true
            self.stackViewAlertheightConstant.constant = 0
            self.switchAltitude.isOn = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    
    @objc func switchAltitudeStatusChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            self.selectAltitudeApply = true
        }else{
            self.selectAltitudeApply = false
        }
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
            self.stackViewWarnning.isHidden = false
            self.stackViewWarnningheightConstant.constant = 125
            self.stackViewAlert.isHidden = false
            self.stackViewAlertheightConstant.constant = 125
            self.switchAltitude.isOn = true
            UserDefaults.standard.set(true, forKey: "AirPressureSwitch")
            
        }else{

            self.stackViewWarnning.isHidden = true
            self.stackViewWarnningheightConstant.constant = 0
            self.stackViewAlert.isHidden = true
            self.stackViewAlertheightConstant.constant = 0
            self.switchAltitude.isOn = false
            self.lblThersHoldAIRPRESSUREHighAlert.text = "32000"
            self.lblThersHoldAIRPRESSURELowAlert.text = "0"
            self.lblThersHoldAIRPRESSUREHighWarning.text = "32000"
            self.lblThersHoldAIRPRESSURELowWarning.text = "0"
            UserDefaults.standard.set(false, forKey: "AirPressureSwitch")
        }
    }
    
    
    func isFromInitialAddDeviceView()  {
        self.stackViewBottom?.isHidden = true
        self.stackViewBottomheightConstant?.constant = 0.0
        self.btnDeviceNameThersHoldAIRPRESSURE.isUserInteractionEnabled = false
        self.imgViewDevice.isHidden = true
    }
    
    func loadAirPressurevalues() {
        self.btnDeviceNameThersHoldAIRPRESSURE.addTarget(self, action:#selector(self.btnDeviceNameThersHoldAIRPRESSURETap(_sender:)), for: .touchUpInside)
        self.btnThersHoldAIRPRESSURELowWarning.addTarget(self, action:#selector(self.btnThersHoldAIRPRESSURELowWarningTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldAIRPRESSUREHighWarning.addTarget(self, action:#selector(self.btnThersHoldAIRPRESSUREHighWarningTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldAIRPRESSURELowAlert.addTarget(self, action:#selector(self.btnThersHoldAIRPRESSURELowAlertTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldAIRPRESSUREHighAlert.addTarget(self, action:#selector(self.btnThersHoldAIRPRESSUREHighAlertTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeAIRPRESSUREBtnApplyAll.addTarget(self, action:#selector(self.btnThersHoldeAIRPRESSUREBtnApplyAllTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeAIRPRESSUREBtnReaset.addTarget(self, action:#selector(self.btnThersHoldeAIRPRESSUREBtnReasetTap(_sender:)), for: .touchUpInside)
        self.btnThersHoldeAIRPRESSURESave.addTarget(self, action:#selector(self.btnThersHoldeAIRPRESSURESaveTap(_sender:)), for: .touchUpInside)
    }
    
    func getDeviceThersHold(deviceID:Int) {
        self.arrCurrentDevice = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        self.arrPollutantAirPressureData = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceID, pollutantType: self.pollutantType.rawValue)
        if self.arrPollutantAirPressureData.count == 0 {
            self.lblThersHoldAIRPRESSUREDeviceName.text = "Select"
            self.lblThersHoldAIRPRESSURELowWarning.text = "Select"
            self.lblThersHoldAIRPRESSURELowAlert.text = "Select"
            self.lblThersHoldAIRPRESSUREHighWarning.text = "Select"
            self.lblThersHoldAIRPRESSUREHighAlert.text = "Select"
            
            self.lblThersHoldAIRPRESSUREDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldAIRPRESSURELowWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldAIRPRESSURELowAlert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldAIRPRESSUREHighWarning.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            self.lblThersHoldAIRPRESSUREHighAlert.textColor = ThemeManager.currentTheme().ltCellSubtitleColor           
            return
        }
        self.selectedDeviceName =  RealmDataManager.shared.getFromTableDeviceName(deviceID: deviceID)
        if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR{
            self.selectedLowWarning = String(format: "%d mbar",Int(self.convertAirPressureINHGToMBAR(value: self.arrPollutantAirPressureData[0].low_waring_value.toFloat() ?? 0.0).rounded()))
            self.selectedLowAlert = String(format: "%d mbar",Int(self.convertAirPressureINHGToMBAR(value: self.arrPollutantAirPressureData[0].low_alert_value.toFloat() ?? 0.0).rounded()))
            self.selectedHighWarning = String(format: "%d mbar",Int(self.convertAirPressureINHGToMBAR(value: self.arrPollutantAirPressureData[0].high_waring_value.toFloat() ?? 0.0).rounded()))
            self.selectedHighAlert = String(format: "%d mbar",Int(self.convertAirPressureINHGToMBAR(value: self.arrPollutantAirPressureData[0].high_alert_value.toFloat() ?? 0.0).rounded()))
            self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        }else {
            let myLowWarningValue = Float(self.arrPollutantAirPressureData[0].low_waring_value)
            self.selectedLowWarning = String(format: "%.2f inHg",myLowWarningValue ?? 0)
            let myHighWarningValue = Float(self.arrPollutantAirPressureData[0].high_waring_value)
            self.selectedHighWarning = String(format: "%.2f inHg",myHighWarningValue ?? 0)
            let myLowAlertValue = Float(self.arrPollutantAirPressureData[0].low_alert_value)
            self.selectedLowAlert = String(format: "%.2f inHg",myLowAlertValue ?? 0)
            let myHighAlertValue = Float(self.arrPollutantAirPressureData[0].high_alert_value)
            self.selectedHighAlert = String(format: "%.2f inHg",myHighAlertValue ?? 0)
            self.switchAlertEnable.addTarget(self, action: #selector(switchColorStatusChanged), for: UIControl.Event.valueChanged)
        }
        self.lblThersHoldAIRPRESSUREDeviceName.text = self.selectedDeviceName
        self.lblThersHoldAIRPRESSURELowWarning.text = self.selectedLowWarning
        self.lblThersHoldAIRPRESSURELowAlert.text = self.selectedLowAlert
        self.lblThersHoldAIRPRESSUREHighWarning.text = self.selectedHighWarning
        self.lblThersHoldAIRPRESSUREHighAlert.text = self.selectedHighAlert
        self.altitudeValue = self.arrCurrentDevice[0].pressure_elevation
        self.altitudeMBARValue = self.arrCurrentDevice[0].pressure_elevation_deviation_mbr
        self.altitudeINHGRValue = self.arrCurrentDevice[0].pressure_elevation_deviation_ihg
        self.selectAltitudeApply = self.arrCurrentDevice[0].pressure_altitude_correction_status
        self.switchAltitude.isOn = self.selectAltitudeApply
        self.previousCopyconvertValuesAsPerUnits()
    }
}
extension ThersHoldAirPressureViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnDeviceNameThersHoldAIRPRESSURETap(_sender:UIButton) {
        self.showDropDownDeviceList(appDropDownType: .DropDownDeviceList)
    }
    
    @objc func btnThersHoldAIRPRESSURELowWarningTap(_sender:UIButton) {
        self.selectedType = .SelectedLowWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    @objc func btnThersHoldAIRPRESSUREHighWarningTap(_sender:UIButton) {
        self.selectedType = .SelectedHighWarning
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldAIRPRESSURELowAlertTap(_sender:UIButton) {
        self.selectedType = .SelectedLowAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldAIRPRESSUREHighAlertTap(_sender:UIButton) {
        self.selectedType = .SelectedHighAlert
        self.showDropDownDeviceList(appDropDownType: self.selectedDropDownType!)
    }
    
    @objc func btnThersHoldeAIRPRESSUREBtnApplyAllTap(_sender:UIButton) {
        if self.isThersAIRPRESSUREApplyAll == false {
            self.isThersAIRPRESSUREApplyAll = true
            self.imgViewThersHoldAIRPRESSUREApplyAllView.image = ThemeManager.currentTheme().cellSelectedCheckIconImage
        } else {
            self.imgViewThersHoldAIRPRESSUREApplyAllView.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage
            self.isThersAIRPRESSUREApplyAll = false
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
    
    @objc func btnThersHoldeAIRPRESSUREBtnReasetTap(_sender:UIButton) {
        self.readResetDataAirPressure()
    }
    @objc func btnThersHoldeAIRPRESSURESaveTap(_sender:UIButton) {
        if self.lblThersHoldAIRPRESSURELowWarning.text?.count != 0  && self.lblThersHoldAIRPRESSURELowAlert.text?.count != 0 && self.lblThersHoldAIRPRESSUREHighWarning.text?.count != 0 && self.lblThersHoldAIRPRESSUREHighAlert.text?.count != 0 {
            self.convertValuesAsPerUnits()
            self.writeAirPressureValueBle()
        }
    }
}

extension ThersHoldAirPressureViewController: LTDropDownThersHoldDelegate,LTDropDownDeviceListDelegate {
    
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int) {
        self.lblThersHoldAIRPRESSUREDeviceName?.text = selectedDeviceName
        self.selectedDeviceID = selectedDeviceID
        self.getDeviceThersHold(deviceID: self.selectedDeviceID)
        self.lblThersHoldAIRPRESSUREDeviceName.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
    }
    
    func selectedThresHoldValue(selectedValue:String){
        
        if self.selectedType == .SelectedLowWarning {
            self.lblThersHoldAIRPRESSURELowWarning.text = selectedValue
        }
        else if self.selectedType == .SelectedLowAlert {
            self.lblThersHoldAIRPRESSURELowAlert.text = selectedValue
        }
        else if self.selectedType == .SelectedHighWarning {
            self.lblThersHoldAIRPRESSUREHighWarning.text = selectedValue
        }
        else if self.selectedType == .SelectedHighAlert {
            self.lblThersHoldAIRPRESSUREHighAlert.text = selectedValue
        }
        else {
            self.lblThersHoldAIRPRESSUREDeviceName.text = selectedValue
        }
    }
    
    func readResetDataAirPressure()  {
        
        self.switchAltitude?.isOn = true
        self.selectAltitudeApply = true
        var entityName:String = TBL_AIR_INKG
        if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR {
            entityName = TBL_AIR_MBAR
        }
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let predicate = NSPredicate(format: "lowwarning == %@", NSNumber(value: true))
        fetch.predicate = predicate
        do {
            let result = try self.airContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR {
                    self.lblThersHoldAIRPRESSURELowWarning?.text = data.value(forKey: "mbarvalue") as? String
                }else {
                    self.lblThersHoldAIRPRESSURELowWarning?.text = data.value(forKey: "airpreinhgvalue") as? String
                }
            }
        } catch {
            print("Failed")
        }
        
        let predicate1 = NSPredicate(format: "lowalert == %@", NSNumber(value: true))
        fetch.predicate = predicate1
        do {
            let result = try self.airContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR {
                    self.lblThersHoldAIRPRESSURELowAlert?.text = data.value(forKey: "mbarvalue") as? String
                }else {
                    self.lblThersHoldAIRPRESSURELowAlert?.text = data.value(forKey: "airpreinhgvalue") as? String
                }
            }
        } catch {
            print("Failed")
        }
        let predicate2 = NSPredicate(format: "highwarning == %@", NSNumber(value: true))
        fetch.predicate = predicate2
        do {
            let result = try self.airContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR {
                    self.lblThersHoldAIRPRESSUREHighWarning?.text = data.value(forKey: "mbarvalue") as? String
                }else {
                    self.lblThersHoldAIRPRESSUREHighWarning?.text = data.value(forKey: "airpreinhgvalue") as? String
                }
            }
        } catch {
            print("Failed")
        }
        let predicate3 = NSPredicate(format: "highalert == %@", NSNumber(value: true))
        fetch.predicate = predicate3
        do {
            let result = try self.airContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR {
                    self.lblThersHoldAIRPRESSUREHighAlert?.text = data.value(forKey: "mbarvalue") as? String
                }else {
                    self.lblThersHoldAIRPRESSUREHighAlert?.text = data.value(forKey: "airpreinhgvalue") as? String
                }
            }
        } catch {
            print("Failed")
        }
    }
}

extension ThersHoldAirPressureViewController {
    
    func saveThresHoldAirpressurEAPINewGood(){
        
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating settings on cloud")
            var arrDevicedata:[UpdateDeviceSettingViewModel] = []
            if self.isThersAIRPRESSUREApplyAll == true {
                let deviceList = RealmDataManager.shared.readDeviceListDataValues()
                if deviceList.count != 0 {
                    for deviceData in deviceList {
                        if deviceData.wifi_status == true{
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AirpressureThresholdLowWarningLevel", value: self.selectedLowWarning, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AirpressureThresholdLowalertLevel", value: self.selectedLowAlert, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AirpressureThresholdHighWarningLevel", value: self.selectedHighWarning, deviceId: Int64(deviceData.device_id)))
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AirpressureThresholdHighalertLevel", value: self.selectedHighAlert, deviceId: Int64(deviceData.device_id)))
                            
                            arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AltitudeCorrectionStatus", value: String(format:"%d", self.selectAltitudeApply), deviceId: Int64(deviceData.device_id)))
                        }
                        
                    }
                    
                    SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                    DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                        self.hideActivityIndicator(self.view)
                        SwaggerClientAPI.basePath = getAPIBaseUrl()
                        if error == nil {
                            RealmDataManager.shared.updateAllThresHoldFilterData(pollutantType: self.pollutantType.rawValue, lowWarning: self.selectedLowWarning, highWarning: self.selectedHighWarning, lowAlert: self.selectedLowAlert, highAlert: self.selectedHighAlert, tempOffset:"")
                            RealmDataManager.shared.updateAllDeviceAltitudeStatus(altitudeStatus: self.selectAltitudeApply)
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
                
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AirpressureThresholdLowWarningLevel", value: self.selectedLowWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AirpressureThresholdLowalertLevel", value: self.selectedLowAlert, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AirpressureThresholdHighWarningLevel", value: self.selectedHighWarning, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AirpressureThresholdHighalertLevel", value: self.selectedHighAlert, deviceId: Int64(self.selectedDeviceID)))
                arrDevicedata.append(UpdateDeviceSettingViewModel.init(name: "AltitudeCorrectionStatus", value: String(format:"%d", self.selectAltitudeApply), deviceId: Int64(self.selectedDeviceID)))
                
                SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
                DeviceAPI.apiDeviceUpdateDeviceSettingDetailsPost(data: arrDevicedata, completion: { (error) in
                    self.hideActivityIndicator(self.view)
                    SwaggerClientAPI.basePath = getAPIBaseUrl()
                    if error == nil {
                        RealmDataManager.shared.updateThresHoldFilterData(deviceID: self.selectedDeviceID, pollutantType: self.pollutantType.rawValue, lowWarning: self.selectedLowWarning, highWarning: self.selectedHighWarning, lowAlert: self.selectedLowAlert, highAlert: self.selectedHighAlert, tempOffset: "")
                        RealmDataManager.shared.updateDeviceAltitudeStatus(deviceID: self.selectedDeviceID, altitudeStatus: self.selectAltitudeApply)
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
extension ThersHoldAirPressureViewController {
    
    override func thresHoldWriteStatus(writeStatus:Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isWriteCompleted = 1
            self.saveThresHoldAirpressurEAPINewGood()
        }
    }
    
    func writeAirPressureValueBle()  {
        self.convertValuesAsPerUnits()
        print(self.previousLowWarning)
        print(self.previousLowAlert)
        print(self.previousHighAlert)
        print(self.previousHighWarning)
        print(self.selectedLowWarning)
        print(self.selectedLowAlert)
        print(self.selectedHighAlert)
        print(self.selectedHighWarning)
        print("Before API")
        
        if self.arrCurrentDevice.count != 0 {
            if self.arrCurrentDevice[0].wifi_status == true || self.isThersAIRPRESSUREApplyAll == true {
                self.saveThresHoldAirpressurEAPINewGood()
            }else {
                print("ThresHold AirPressure")
                print(self.selectedLowWarning.toFloat())
                print(self.selectedHighWarning.toFloat())
                print(self.selectedLowAlert.toFloat())
                print(self.selectedHighAlert.toFloat())
                print(self.selectedDeviceID)
                print(self.arrCurrentDevice[0].serial_id)
                print("ThresHold AirPressure")
                self.serialDeviceName = self.arrCurrentDevice[0].serial_id
                self.scanCheckCount = 0
                self.isWriteCompleted = 0
                self.scanBLEDevices()
            }
        }
        
    }
}
// MARK: BLE Scanning
extension ThersHoldAirPressureViewController:CBCentralManagerDelegate{
    
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
                self.writeAirPressureValueViaBLE(selectedLowWarning: self.selectedLowWarning.toFloat() ?? 0.0, selectedHighWarning: self.selectedHighWarning.toFloat() ?? 0.0, selectedLowAlert: self.selectedLowAlert.toFloat() ?? 0.0, selectedHighAlert: self.selectedHighAlert.toFloat() ?? 0.0, deviceIDSetting: self.selectedDeviceID, deviceSerialID: self.arrCurrentDevice[0].serial_id)
            }
        }
    }
}
extension ThersHoldAirPressureViewController {
    
    func convertValuesAsPerUnits()  {
        if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR{
            self.selectedLowWarning = self.lblThersHoldAIRPRESSURELowWarning.text!.replacingOccurrences(of: "mbar", with: "")
            self.selectedLowAlert = self.lblThersHoldAIRPRESSURELowAlert.text!.replacingOccurrences(of: "mbar", with: "")
            if let floatWarning = Float(self.removeWhiteSpace(text: self.selectedLowWarning)) {
                self.selectedLowWarning = String(format: "%f", self.convertAirPressureMBARToINHG(value: floatWarning))
            }
            if let floatAlert = Float(self.removeWhiteSpace(text: self.selectedLowAlert)) {
                self.selectedLowAlert = String(format: "%f", self.convertAirPressureMBARToINHG(value: floatAlert))
            }
            
            self.selectedHighWarning = self.lblThersHoldAIRPRESSUREHighWarning.text!.replacingOccurrences(of: "mbar", with: "")
            self.selectedHighAlert = self.lblThersHoldAIRPRESSUREHighAlert.text!.replacingOccurrences(of: "mbar", with: "")
            if let floatHighWarning = Float(self.removeWhiteSpace(text: self.selectedHighWarning)) {
                self.selectedHighWarning = String(format: "%f", self.convertAirPressureMBARToINHG(value: floatHighWarning))
            }
            if let floatHighAlert = Float(self.removeWhiteSpace(text: self.selectedHighAlert)) {
                self.selectedHighAlert = String(format: "%f", self.convertAirPressureMBARToINHG(value: floatHighAlert))
            }
        }else {
            self.selectedLowWarning = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSURELowWarning.text!.replacingOccurrences(of: "inHg", with: ""))
            self.selectedLowAlert = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSURELowAlert.text!.replacingOccurrences(of: "inHg", with: ""))
            self.selectedHighWarning = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSUREHighWarning.text!.replacingOccurrences(of: "inHg", with: ""))
            self.selectedHighAlert = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSUREHighAlert.text!.replacingOccurrences(of: "inHg", with: ""))
        }
    }
    
    func compareConvertValuesAsPerUnits()  {
        if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR{
            self.selectedLowWarning = self.lblThersHoldAIRPRESSURELowWarning.text!.replacingOccurrences(of: "mbar", with: "")
            self.selectedLowAlert = self.lblThersHoldAIRPRESSURELowAlert.text!.replacingOccurrences(of: "mbar", with: "")
            self.selectedHighWarning = self.lblThersHoldAIRPRESSUREHighWarning.text!.replacingOccurrences(of: "mbar", with: "")
            self.selectedHighAlert = self.lblThersHoldAIRPRESSUREHighAlert.text!.replacingOccurrences(of: "mbar", with: "")
        }else {
            self.selectedLowWarning = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSURELowWarning.text!.replacingOccurrences(of: "inHg", with: ""))
            self.selectedLowAlert = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSURELowAlert.text!.replacingOccurrences(of: "inHg", with: ""))
            self.selectedHighWarning = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSUREHighWarning.text!.replacingOccurrences(of: "inHg", with: ""))
            self.selectedHighAlert = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSUREHighAlert.text!.replacingOccurrences(of: "inHg", with: ""))
        }
    }
    
    func previousCopyconvertValuesAsPerUnits()  {
        if self.selectedDropDownType == .DropDownAIRPRESSURE_MBAR{
            self.previousLowWarning = self.lblThersHoldAIRPRESSURELowWarning.text!.replacingOccurrences(of: "mbar", with: "")
            self.previousLowAlert = self.lblThersHoldAIRPRESSURELowAlert.text!.replacingOccurrences(of: "mbar", with: "")
            if let floatWarning = Float(self.removeWhiteSpace(text: self.selectedLowWarning)) {
                self.previousLowWarning = String(format: "%f", self.convertAirPressureMBARToINHG(value: floatWarning))
            }
            if let floatAlert = Float(self.removeWhiteSpace(text: self.selectedLowAlert)) {
                self.previousLowAlert = String(format: "%f", self.convertAirPressureMBARToINHG(value: floatAlert))
            }
            
            self.previousHighWarning = self.lblThersHoldAIRPRESSUREHighWarning.text!.replacingOccurrences(of: "mbar", with: "")
            self.previousHighAlert = self.lblThersHoldAIRPRESSUREHighAlert.text!.replacingOccurrences(of: "mbar", with: "")
            if let floatHighWarning = Float(self.removeWhiteSpace(text: self.selectedHighWarning)) {
                self.previousHighWarning = String(format: "%f", self.convertAirPressureMBARToINHG(value: floatHighWarning))
            }
            if let floatHighAlert = Float(self.removeWhiteSpace(text: self.selectedHighAlert)) {
                self.previousHighAlert = String(format: "%f", self.convertAirPressureMBARToINHG(value: floatHighAlert))
            }
        }else {
            self.previousLowWarning = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSURELowWarning.text!.replacingOccurrences(of: "inHg", with: ""))
            self.previousLowAlert = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSURELowAlert.text!.replacingOccurrences(of: "inHg", with: ""))
            self.previousHighWarning = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSUREHighWarning.text!.replacingOccurrences(of: "inHg", with: ""))
            self.previousHighAlert = self.removeWhiteSpace(text: self.lblThersHoldAIRPRESSUREHighAlert.text!.replacingOccurrences(of: "inHg", with: ""))
        }
        self.previousAltitudeApply = self.selectAltitudeApply
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
        if self.previousLowWarning != self.selectedLowWarning || self.previousLowAlert != self.selectedLowAlert  || self.previousHighAlert != self.selectedHighAlert || self.previousHighWarning != self.selectedHighWarning || self.isThersAIRPRESSUREApplyAll == true || self.previousAltitudeApply != self.selectAltitudeApply {
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
            self.writeAirPressureValueBle()
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
