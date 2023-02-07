//
//  AddMyDeviceViewController.swift
//  luft
//
//  Created by user on 10/20/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

protocol AddDevicelDelegate:class {
    func addDevicelDelegateStatus(upadte:Bool)
}

class AddMyDeviceViewController: LTViewController, LTIntialAGREEDelegate {
    func selectedIntialAGREE() {
        print("ios")
    }
    
    @IBOutlet weak var txtDeviceName: LTCommonTextField!
    @IBOutlet weak var lblWifiData: LTHeavyTitleLabel!
    @IBOutlet weak var lblWifiSerialName: LTSettingHintLabel!
    @IBOutlet weak var connectWifiLater: LTGrayCommonButton!
    @IBOutlet weak var btnConnectWifi: LTCommonButton!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lblConnectWifiLater: LTAddDeviceSettingHintLabel!
    @IBOutlet weak var GetMoreHelp: UIButton!

    var macAddressSerialNo : String = ""
    var connectPeripheral: CBPeripheral!
    var wifiDeviceStatus:WIFIDEVICESTATUS = .WIFI_NOT_CONNECTED
    var defaultDeviceID: Int = 0
    var wifiCheckCount: Int = 0
    var defaultDeviceToken: String = ""
    var defaultDeviceSharedEMail: String = ""
    var adddeviceDelegate: AddDevicelDelegate? = nil
    var locationManager = CLLocationManager()
    var latCurrentValue:Double = 0.0
    var longCurrentValue:Double = 0.0
    var isConnectWIFIBTNState:WIFIButtonFeatureType = .WIFIButtonNone
    var strAPIFwVersion: String = ""
    var timer: Timer?
    var checkFwVersionCount: Int = 0
    var currentTimeStampValue: Int = 0
    var bleTimer: Timer?
    var bleTimerInvalid: Bool? = true
    var bleViewWillDis: Bool? = true
    var manager:CBCentralManager? = nil
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use in background
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self

        self.loadMyDeviceData()
        textLog.write("\(String(describing: connectPeripheral.name)) SELECTED DEVICE")
        
//        self.readSerialNumber()
     NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    
    @IBAction func GetMoreHelp(_ sender: Any) {
        self.moveToWebView()
    }
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
        webdataView.Urltodisplay = Adddevice_Url
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = "Adding Device"
        webdataView.strTitle = "Adding Device"
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .pageSheet
        self.present(webdataView, animated: false, completion: nil)
    }
    
//    func readSerialNumber(){
//        let manager  = BluetoothManager.init()
//        manager.isBleManagerConnectState = false
//        manager.isBleManagerCharacteristicsState = false
//        manager.connectBlueTooth(blueToothName: connectPeripheral.name ?? "", bleFeature: .BluetoothReadSerial)
//        manager.serialNumberReadDelegate = self
//    }
    override func viewDidAppear(_ animated: Bool) {
        //BluetoothManager.shared.dispose()
        self.showAct()
        textLog.write("self.showAct() - 1001")
        BluetoothManager.shared.dispose()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.wifiCheckCount = 1
            self.wifiStatusCheck()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.viewBottom.backgroundColor = ThemeManager.currentTheme().ltAddDeviceHeaderViewBackgroudColor
        self.lblConnectWifiLater.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.bleViewWillDis = false
        //BackgroundBLEManager.shared.delegateBackGroundBleState = nil
        self.stopBleTimmer()
    }
    
    
    func loadMyDeviceData()  {
        textLog.writeAPI(String(format: "%@",connectPeripheral.name ?? ""))
        self.txtDeviceName?.text  = String(format: "%@",connectPeripheral.name ?? "")
        self.lblWifiSerialName?.text  = String(format: "Device ID:%@",connectPeripheral.name ?? "")
        self.lblWifiSerialName?.textColor = UIColor.lightGray
        self.btnConnectWifi.addTarget(self, action:#selector(self.btnConnectWifiTap(_sender:)), for: .touchUpInside)
        self.connectWifiLater.addTarget(self, action:#selector(self.connectWifiLaterTap(_sender:)), for: .touchUpInside)
    }
    
    func wifiStatusCheck()  {
        self.startBleFunctionTimer()
        textLog.write("\(String(describing: connectPeripheral.name)) SELECTED DEVICE WIFI STATUS CHECK START")
        Helper.shared.removeBleutoothConnection()
        BluetoothManager.shared.isBleManagerConnectState = false
        BluetoothManager.shared.isBleManagerCharacteristicsState = false
        BluetoothManager.shared.connectBlueTooth(blueToothName: connectPeripheral.name ?? "", bleFeature: .BlueToothFeatureWifiStatus)
        BluetoothManager.shared.deviceWifiStatusDelgate = self
        //self.bleStatesDelegate()
        BluetoothManager.shared.delegateBleManagerState = nil
        BackgroundBLEManager.shared.delegateBackGroundBleState = nil
        BluetoothManager.shared.delegateBleManagerState = self
        BluetoothManager.shared.serialNumberReadDelegate = self
       // BackgroundBLEManager.shared.delegateBackGroundBleState = self
    }
    
    func wifiStatusCheck(wifiDeviceStaus:String) {
        self.bleTimerInvalid = true
        if self.wifiCheckCount == 1 {
            if BluetoothManager.shared.mainPeripheral.state == .disconnected{
                textLog.write("checkWifiAgain")
                self.checkWifiAgain()
                return
            }else {
                textLog.write("checkWifiAgain - wifiCheckCount 2")
                self.wifiCheckCount = 2
                BluetoothManager.shared.blueToothFeatureType = .BlueToothFeatureWifiStatus
                BluetoothManager.shared.deviceWifiStatusDelgate = self
                BluetoothManager.shared.mainPeripheral.discoverServices([LUFT_WIFI_SERVICE_STATUS])
                return
            }
        }else {
            textLog.write("\(String(describing: connectPeripheral.name)) SELECTED DEVICE WIFI STATUS CHECK END")
            textLog.write("SELECTED DEVICE WIFI STATUS CHECK RESULT")
            self.wifiDeviceStatus = WIFIDEVICESTATUS(rawValue: wifiDeviceStaus) ?? .WIFI_NOT_CONNECTED
            switch self.wifiDeviceStatus {
            case .WIFI_CONNECTED,.WIFI_INTERNET,.ICD_WIFI_CONNECTED,.ICD_WIFI_INTERNET,.ICD_WIFI_CLOUD:
                textLog.write("SELECTED DEVICE WIFI CONNECTED")
                self.lblWifiData.text = WIFI_CONNECTED_TITLE_MESSAGE
                self.btnConnectWifi.setTitle(WIFI_CONNECTED_SAME_WIFI, for: .normal)
                self.connectWifiLater.setTitle(WIFI_CONNECTED_DIFFERENT_WIFI, for: .normal)
                self.lblConnectWifiLater.text = ""
            case .WIFI_NOT_CONNECTED,.WIFI_CONNECTING,.ICD_WIFI_CONNECTING,.ICD_WIFI_FAULT,.ICD_WIFI_AUTHENTICATED:
                textLog.write("SELECTED DEVICE WIFI NOT CONNECTED OR WIFI_CONNECTING STATE")
                self.lblConnectWifiLater.text = "(can connect to Wi-Fi later)"
                break
                
            }
            if wifiDeviceStaus == "-1.0" {
                // Helper.shared.showSnackBarAlert(message: "Device not get service", type: .Failure)
            }
            //self.getFwVersionViaBLE()
            
            self.deviceTimeStampUpdateBLE()
        }
        
        
    }
    
    func checkWifiAgain()  {
        self.wifiCheckCount = 2
        if BluetoothManager.shared.mainPeripheral.state == .disconnected{
            BluetoothManager.shared.connectBlueTooth(blueToothName: connectPeripheral.name ?? "", bleFeature: .BlueToothFeatureWifiStatus)
        }
    }
    
    func getFwVersionViaBLE()  {
        BluetoothManager.shared.blueToothFeatureType = .BlueToothFirmwareVersion
        BluetoothManager.shared.delegateFwVersion = self
        BluetoothManager.shared.mainPeripheral.discoverServices([])
    }
}
// MARK: - Buttons and  API Data's
extension AddMyDeviceViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationsObj = locations.last! as CLLocation
        self.latCurrentValue = locationsObj.coordinate.latitude
        self.longCurrentValue = locationsObj.coordinate.longitude
        self.locationManager.stopUpdatingLocation()
        if self.locationManager.delegate == nil {
            return
        }
        self.locationManager.delegate = nil
        self.bleStatesDelegate()
        self.addDeviceDataAPI()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Helper.shared.showSnackBarAlert(message: "Failed to get GEO Location", type: .Failure)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.stopTimmer()
        print("Stop POP")
    }
    
    func checkLocationService() {
//        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                if ((UIDevice.current.systemVersion as NSString).floatValue >= 8) {
                    //Repeat authorization added-commented due to that - Gauri
                    //self.locationManager.requestWhenInUseAuthorization()
                }
                self.locationManager.startUpdatingLocation()
                break
            case .notDetermined, .restricted, .denied:
                self.locationPremission()
                break
            default:
                break
            }
        }
        else
        {
            self.locationPremission()
        }
    }
    
    func locationPremission()  {
        let titleString = NSAttributedString(string: "Allow Location Access", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let message = String(format: "Luft app needs access to your location. Turn on Location Services in your device settings.")
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        self.hideAct()
    }
    
    func addDeviceDataAPI()  {
        self.showAct()
        textLog.write("self.showAct() - 1002")
        var wifiState:Bool = false
        if self.isConnectWIFIBTNState == .WIFIButtonConnectTOWIFISAME {
            wifiState = true
        }
        let addDeviceModel = AddDeviceViewModel.init(name: self.txtDeviceName?.text ?? "", serialId: self.connectPeripheral.name ?? "", latitude: self.latCurrentValue, longitude: self.longCurrentValue, isWifiOn: wifiState, timeDifference: Helper.shared.getTimeDiffBetweenTimeZone(), timeZone: self.getCurrentTimeZoneShortName(), firmwareVersion: self.strAPIFwVersion, deviceTimeZoneFullName: Helper.shared.getCurrentTimeZoneinIANAFormat(), macAddress: macAddressSerialNo)
        print("*****************API")
        print(self.txtDeviceName?.text ?? "")
        print(self.connectPeripheral.name ?? "")
        print(self.latCurrentValue)
        print(self.longCurrentValue)
        print(Helper.shared.getTimeDiffBetweenTimeZone())
        print(self.getCurrentTimeZoneShortName())
        print(self.strAPIFwVersion)
        print("*****************API")
        
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserAddDevicePost(model: addDeviceModel, completion: { (responses, error) in
            if error == nil {
                self.callMyDeviceAPI()
                textLog.write("NEW DEVICE ADDED SUCCESSFULLY - API")
                print("Device Added Successfully")
            }else {
                Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                textLog.write("NEW DEVICE ADDED Failure - API")
                self.hideAct()
                print("Hide 2")
            }
        })
    }
}
extension AddMyDeviceViewController: WIFIStatusDelegate,CurrentLogIndexDelegate,DeviceMEAPIDelegate {
    
    func callMyDeviceAPI()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.showAct()
            textLog.write("self.showAct() - 1003")
            RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
            APIManager.shared.myDeviceDelegate = self
            APIManager.shared.callDeviceDetailsTypeApi(isUpdateDummy: true)
            textLog.write("ADDED DEVICE (GET DEVICE DETAILS) - API START")
        }
    }
    
    func deviceDataAPIStatus(update:Bool) {
        print("Device imple1")
        if update == true {
            self.defaultDeviceID = RealmDataManager.shared.getFromTableDeviceID(serial_id: String(format:"%@", self.connectPeripheral.name ?? ""))
            self.defaultDeviceToken = RealmDataManager.shared.getDeviceData(deviceID:self.defaultDeviceID)[0].device_token
            self.defaultDeviceSharedEMail = RealmDataManager.shared.getDeviceData(deviceID:self.defaultDeviceID)[0].shared_user_email
            textLog.write("ADDED DEVICE (GET DEVICE DETAILS) - API END")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                RealmDataManager.shared.insertRealmPollutantDummyValuesTBLValues(strDate: Date(), deviceID: self.defaultDeviceID, co2: 0.0, air_pressure:  0.0, temperature:  0.0, humidity:  0.0, voc:  0.0, radon:  0.0, isWiFi: false, serialID: self.connectPeripheral.name!,logIndex:-1,timeStamp:0)
            }
            
            if let tabBarVC = self.tabBarController as? LuftTabbarViewController {
                tabBarVC.deviceIDSelectedPrevious = self.defaultDeviceID
                AppSession.shared.setIsAddedNewDevice(isAddedDevice:true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getBleBackdata()
                print("Device imple2")
            }
        }else {
            self.hideAct()
            print("Hide 3")
        }
    }
    
    func getBleBackdata()  {
       // self.startBleFunctionTimer()
        Helper.shared.removeBleutoothConnection()
        BackgroundBLEManager.shared.strDeviceSerialID = self.connectPeripheral.name ?? ""
        BackgroundBLEManager.shared.isFromAddDevice =  true
        BackgroundBLEManager.shared.didUpdate = 0
        BackgroundBLEManager.shared.strDeviceID = self.defaultDeviceID
        BackgroundBLEManager.shared.deviceLogIndexStatusDelgate = self
        BackgroundBLEManager.shared.isBleConnectState = false
        BackgroundBLEManager.shared.isBleCharacteristicsState = false
        BackgroundBLEManager.shared.connectBlueTooth(blueToothName: self.connectPeripheral.name!, bleFeature: .BlueToothFeatureLogCurrentIndexWrite)
        textLog.write("ADDED DEVICE (GET MAX LOG INDEX POLLUTANT VALUE) - VIA  BLUETOOTH START")
        self.bleStatesDelegate()
        self.showAct()
        textLog.write("self.showAct() - 1004")
    }
    
    func getBluetoothCurrentIndexLogData(isConnectedBLE: Bool) {
        self.bleTimerInvalid = true
        print("Device imple3")
        if isConnectedBLE == false {
            print("Device imple4")
            textLog.write("ADDED DEVICE (GET MAX LOG INDEX POLLUTANT VALUE) - VIA  BLUETOOTH COMPLETED")
            BluetoothManager.shared.centralManager = nil
            if RealmDataManager.shared.readDeviceListDataValues().count != 0 {
                self.showAct()
                textLog.write("self.showAct() - 1005")
                if self.defaultDeviceID != 0 {
                    if RealmDataManager.shared.getDeviceData(deviceID:self.defaultDeviceID).count != 0 {
                        DispatchQueue.main.async {
                            self.moveToNextStep()
                        }
                    }
                }
            }else{
                self.hideAct()
                print("Hide 4")
            }
        }else {
            // isConnectedBLE = true Bluetooth connection Start
            if BackgroundBLEManager.shared.blueToothFeatureType == .BlueToothFeatureLogCurrentIndexWrite {
                self.stopTimmer()
                self.startTimer() // Show Times Device Bluetooth not discover Characteristics SO we hide activity Timer Based
            }else {
                self.hideAct()
            }
            print("Hide 5")
            print("BLE")
        }
        
    }
    
    func startTimer() {
        print("Start Timer")
        guard self.timer == nil else { return }
        self.timer = Timer.scheduledTimer(timeInterval: 30.0,
                                          target: self,
                                          selector: #selector(eventWith(timer:)),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    // Timer expects @objc selector
    @objc func eventWith(timer: Timer!) {
        if self.timer != nil {
            self.hideAct()
        }
        print("Stop Timer1")
        self.stopTimmer()
        self.showBleNotConnectAlert()
    }
    
    func stopTimmer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func btnConnectWifiTap(_sender:UIButton) {
        if Reachability.isConnectedToNetwork() == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.showAct()
                textLog.write("self.showAct() - 1006")
                self.checkLocationService()
                if _sender.titleLabel?.text == WIFI_CONNECTED_SAME_WIFI {
                    textLog.write("TAP SELECTED DEVICE CONTINUE WITH SAME WIFI")
                    self.isConnectWIFIBTNState = .WIFIButtonConnectTOWIFISAME
                }else {
                    self.isConnectWIFIBTNState = .WIFIButtonConnectTOWIFI
                    textLog.write("TAP SELECTED DEVICE CONNECT TO WIFI")
                }
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    @objc func connectWifiLaterTap(_sender:UIButton) {
        if Reachability.isConnectedToNetwork() == true {
            if _sender.titleLabel?.text == WIFI_CONNECTED_DIFFERENT_WIFI {
                self.isConnectWIFIBTNState = .WIFIButtonConnectTOWIFIANOTHER
                self.checkLocationService()
                textLog.write("TAP SELECTED DEVICE DIFFERENT WIFI")
            }else {
                self.isConnectWIFIBTNState = .WIFIButtonConnectTOWIFILATER
                self.showAlertWifiLater()
                textLog.write("TAP SELECTED DEVICE CONNECT TO WIFI-LATER")
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    func showAlertWifiLater()  {
        let titleString = NSAttributedString(string: WIFI_CONNECTED_LATER, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: "Are you sure you want to connect Wi-Fi later?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.checkLocationService()
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.present(alert, animated: true)
    }
}
extension AddMyDeviceViewController: MAXINDEXDataAPIDelegate,AvilableAddDeviceDelegate {
    
    func addAvilableDeviceDelegateStatus(upadte: Bool) {
        self.adddeviceDelegate?.addDevicelDelegateStatus(upadte: true)
        self.navigationController?.popToRootViewController(animated: true)
        self.stopTimmer()
        print("Stop POP")
    }
    
    func updateMaxIdex(updateStatus: Bool) {
        
        if let val = BluetoothManager.shared.mainPeripheral{
            if BluetoothManager.shared.mainPeripheral.state == .disconnected{
                textLog.write("Bluetooth.disconnecte upadte max index")
            }
            print("Hide 6")
        }
        
    }
    
    func moveToNextStep() {
        print("Stop PUSH")
        self.stopTimmer()
        switch self.isConnectWIFIBTNState {
        case .WIFIButtonConnectTOWIFI:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.moveToAvilableNetwork()
                textLog.write("ADDED DEVICE (NAVIGATE WIFI SCREEN)")
            }
            break
        case .WIFIButtonConnectTOWIFILATER:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.moveToIntialThresHold()
                }
                textLog.write("ADDED DEVICE (NAVIGATE DASHBOARD SCREEN WITH WIFI-LATER)")
            }
            break
        case .WIFIButtonConnectTOWIFISAME:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.moveToIntialThresHold()
                }
                textLog.write("ADDED DEVICE (NAVIGATE DASHBOARD SCREEN WITH SAME WIFI)")
            }
            break
        case .WIFIButtonConnectTOWIFIANOTHER:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.moveToAvilableNetwork()
                textLog.write("ADDED DEVICE (NAVIGATE WIFI SCREEN)")
            }
            break
        default:
            break
        }
    }
    
    func getBackGroundDataAPIWithDeviceBasedAddDevice()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            APIManager.shared.isAddDeviceAPICompleted = false
            DispatchQueue.global(qos: .background).async {
                print("BackGround Start2")
                textLog.write("ADDED DEVICE (GET ALL LOG INDEX POLLUTANT VALUE) - API")
                APIManager.shared.callMAXINDEXDeviceData(deviceToken: RealmDataManager.shared.getDeviceData(deviceID:self.defaultDeviceID)[0].device_token, maxLogIndex:0, deviceSerialID: self.connectPeripheral.name ?? "", isFromIntial: false)
                APIManager.shared.maxIndexDelegate = self
                DispatchQueue.main.async {
                }
            }
        }
    }
    
    func moveToIntialThresHold()  {
        self.moveToThersHolds()
        self.hideAct()
        print("Hide 7")
        print("BackGround Start1")
        self.getBackGroundDataAPIWithDeviceBasedAddDevice()
    }
    
    
    /*
     func moveToIntialThresHold()  {
         let networkType = NetworkDeviceFinder.getConnectionType()
         if networkType == .fiveG {
             _ = self.alertIfNetworkIs5GHZ()
         } else{
             self.moveToThersHolds()
             self.hideAct()
             print("Hide 7")
             print("BackGround Start1")
             self.getBackGroundDataAPIWithDeviceBasedAddDevice()
         }
     }
     */
    
    func moveToThersHolds() {

        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SensorAlertViewController") as! SensorAlertViewController
        mainTabbar.isFromInitialAddDevice = true
        mainTabbar.isFromInitialSelectedDeviceID = self.defaultDeviceID
        mainTabbar.avilableDeviceSharedEMailIsfromAddDeviceThres = self.defaultDeviceSharedEMail
        mainTabbar.isFromInitialSelectedDeviceTokenThres = self.defaultDeviceToken
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    func moveToAvilableNetwork()  {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcMYDeviceData = storyboard.instantiateViewController(withIdentifier: "AvilableNetworkViewController") as! AvilableNetworkViewController
        vcMYDeviceData.editedDeviceName = self.txtDeviceName?.text ?? ""
        vcMYDeviceData.connectSSIDPeripheral = connectPeripheral
        vcMYDeviceData.avilableDeviceID = self.defaultDeviceID
        vcMYDeviceData.avilableDeviceToken = self.defaultDeviceToken
        vcMYDeviceData.avilableAddDelegate = self
        vcMYDeviceData.serialDeviceName = connectPeripheral.name ?? ""
        vcMYDeviceData.isFromAdddevice = true
        vcMYDeviceData.avilableDeviceSharedEMail = self.defaultDeviceSharedEMail
        AppSession.shared.setCurrentDeviceToken(self.defaultDeviceToken)
        self.navigationController?.pushViewController(vcMYDeviceData, animated: false)
        self.hideAct()
        print("Hide 8")
    }
}

extension AddMyDeviceViewController: BleManagerStateDelegate,BackGroundBleStateDelegate,FirmwareDelegate {
    
    func getBleManagerBleState(isConnectedBLEState: Bool) {
        self.bleTimerInvalid = true
        textLog.write("\(String(describing: BluetoothManager.shared.blueToothFeatureType)) getBleManagerBleState")

        if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureWifiStatus {
            self.hideAct()
            print("Hide 9")
            self.showBleNotConnectAlert()
        }
        else if BluetoothManager.shared.blueToothFeatureType == .BlueToothTimeStampWrite {
            self.hideAct()
            print("Hide 9")
        }
        else if BluetoothManager.shared.blueToothFeatureType == .BlueToothFirmwareVersion {
            if self.strAPIFwVersion != ""{
                checkFwVersionCount = 2
            }else {
                self.hideAct()
                print("Hide 10")
            }
        }else {
            self.hideAct()
            print("Hide 11")
            self.showBleNotConnectAlert()
        }
    }
    
    func getBackGroundBleState(isConnectedBLEState: Bool) {
        self.bleTimerInvalid = true
        if isConnectedBLEState == true {
            if self.bleViewWillDis == false {
                return
            }else {
                self.showAct()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
                if self.bleViewWillDis == false {
                    return
                }else{
                    self.hideActivityIndicator(self.view)
                }
            }
            textLog.write("self.showAct() - 1007")
            print("showAct Hide 12")
        }else {
            self.hideAct()
            print("Hide 12")
            self.showBleNotConnectAlert()
        }
    }
    
    func bleStatesDelegate(){
        BluetoothManager.shared.delegateBleManagerState = nil
        BackgroundBLEManager.shared.delegateBackGroundBleState = nil
        BluetoothManager.shared.delegateBleManagerState = self
        BackgroundBLEManager.shared.delegateBackGroundBleState = self
    }
    
    func showBleNotConnectAlert()  {
        let titleString = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string:"Device not connected over Bluetooth. It could be due to Device is not in Bluetooth range or Device is already connected with another phone. Please try again later.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "Ok", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        Helper.shared.removeBleutoothConnection()
        self.hideAct()
        print("Hide 13")
    }
    
    func showAct()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showActivityIndicator(self.view)
        }
    }
    
    func hideAct()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideActivityIndicator(self.view)
        }
        print("Hide 143")
    }
    
    func firmwareVesrion(fwVersion: String) {
        BluetoothManager.shared.centralManager.stopScan()
        self.strAPIFwVersion = fwVersion
        print(self.strAPIFwVersion)
        self.hideAct()
        print("Hide 1")
    }
    
}
extension AddMyDeviceViewController:TIMEStampWriteDelegate {
    
    func writeTIMEStampWrite() {
        print("SELECTED DEVICE WRITE TIME UPDATE COMPLETED")
        textLog.write("SELECTED DEVICE WRITE TIME UPDATE COMPLETED")
        self.getFwVersionViaBLE()
    }
    
    func deviceTimeStampUpdateBLE()  {
        self.getTodayTimeValue()
    }
    
    func getTodayTimeValue()  {
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
        let dateAtMidnight = Date()
        let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
        self.currentTimeStampValue = 0
        self.currentTimeStampValue = Int(secondsSince1970)
        self.getServerTime()
    }
    
    func getServerTime() {
        if Reachability.isConnectedToNetwork() == true {
           let strTimeZone = TimeZone.current.localizedName(for: .standard, locale: .current) ?? ""
            MobileApiAPI.apiMobileApiGetServerTimeGet(timeZone: strTimeZone) { (response, error) in
                self.hideActivityIndicator(self.view)
                if response?.success == true {
                    self.currentTimeStampValue = Int(response?.data ?? "0") ?? 0
                    self.writeTimeStampBLEAPITODEVICE()
                }else { // New Good
                    Helper().showSnackBarAlert(message: response?.message ?? "", type: .Failure)
                    self.writeTimeStampBLEAPITODEVICE()
                }
            }
        }else {
            self.hideActivityIndicator(self.view)
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    func writeTimeStampBLEAPITODEVICE()  {
        print("SELECTED DEVICE WRITE TIME UPDATE START")
        textLog.write("SELECTED DEVICE WRITE TIME UPDATE START")
        BluetoothManager.shared.timeStampValue = self.currentTimeStampValue
        BluetoothManager.shared.connectBlueTooth(blueToothName: self.connectPeripheral.name ?? "", bleFeature: .BlueToothTimeStampWrite)
        BluetoothManager.shared.delegateTimeStampVersion = self
    }
}
extension AddMyDeviceViewController {
    
    func startBleFunctionTimer() {
        self.bleTimerInvalid = false
        self.bleViewWillDis = true
        guard self.bleTimer == nil else { return }
        self.bleTimer = Timer.scheduledTimer(timeInterval: 10.0,
                                          target: self,
                                          selector: #selector(eventBleTimer(timer:)),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    @objc func eventBleTimer(timer: Timer!) {
        if self.bleTimerInvalid == true {
            self.stopBleTimmer()
        }else {
            if self.bleTimer != nil {
                if self.bleViewWillDis == true {
                    self.hideAct()
                }
            }
            self.stopBleTimmer()
            self.showBleTimerConnectAlert()
        }
    }
    
    func stopBleTimmer() {
        self.bleTimer?.invalidate()
        self.bleTimer = nil
        self.bleTimerInvalid = true
    }
    
    func showBleTimerConnectAlert()  {
        let titleString = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string:"Device not responding", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "Ok", style: .default, handler: { action in
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        Helper.shared.removeBleutoothConnection()
        self.hideAct()
        print("Hide 13")
    }
}

extension AddMyDeviceViewController: DeviceSerialNumberReadDelegate{
    func didReadSerialNumber(serialNumber: String) {
        print("serial numberof device : " + serialNumber)
        macAddressSerialNo = serialNumber
        textLog.writeAPI("serial numberof device : " + serialNumber)
    }
    
    func stopScanForBLEDevices() {
        manager?.stopScan()
    }
    
    /*
    func alertIfNetworkIs5GHZ()-> Bool{
        let networkType = AvilableNetworkViewController.getConnectionType()
        //let networkType = NetworkDeviceFinder.getConnectionType()
        if networkType != .fiveG {
            let alert = UIAlertController(title: "Luft", message: "Please connect to a 2.4GHz network Band.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            self.stopScanForBLEDevices()
            self.hideAct()
            return true
        }
        return false
    }
     */
}
