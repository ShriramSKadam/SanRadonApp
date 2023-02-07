//
//  AvilableNetworkViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/21/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import SystemConfiguration.CaptiveNetwork
import SystemConfiguration
import CoreTelephony
import Foundation

protocol AvilableAddDeviceDelegate:class {
    func addAvilableDeviceDelegateStatus(upadte:Bool)
}


class AvilableNetworkViewController: LTViewController, LTIntialAGREEDelegate {
    func selectedIntialAGREE() {
        print("ios")
        
    }
    
    
    var macAddressSerialNo : String = ""
    
    @IBOutlet weak var txtCurrentWifiName: LTCommonTextField!
    @IBOutlet weak var txtCurrentWifiPassword: LTCommonTextField!
    @IBOutlet weak var btnDifferentWifiLater: LTGrayCommonButton!
    @IBOutlet weak var btnContinueWifi: LTCommonButton!
    @IBOutlet weak var GetMoreHelp: UIButton!
    @IBOutlet weak var availableNetworks: UILabel!
    @IBOutlet weak var availableNetworksView: LTSettingHeaderView!
    @IBOutlet weak var selectedNetworkView: UIView!//LTSettingHeaderView

    @IBOutlet weak var tblList: UITableView!
    var connectSSIDPeripheral: CBPeripheral!
    var ssidWifiName:String? = ""
    var ssidPasswordName:String? = ""
    
    var ssidWifiNameAlert:String? = ""
    var ssidPasswordAlert:String? = ""
    
    var wifiDeviceStatus:WIFIDEVICESTATUS = .WIFI_NOT_CONNECTED
    var statusOfWifiConnection:String = ""
    var editedDeviceName:String = ""
    var serialDeviceName:String = ""
    var writeWifiIndex:Int = 0
    var avilableDeviceID:Int = 0
    var avilableDeviceToken:String = ""
    var avilableDeviceSharedEMail:String = ""
    var avilableAddDelegate:AvilableAddDeviceDelegate? = nil
    
    var locationManager = CLLocationManager()
    var latCurrentValue:Double = 0.0
    var longCurrentValue:Double = 0.0
    var isGetWifiName:Bool = false
    
    var wifiName: String = ""
    var wifiCheckState:Int = 0
    var writeWifiCheckCount:Int = 0
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    
    var isFromAdddevice:Bool = false
    var isAlertShow:Bool = false
    
    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //availableNetworksView.layer.cornerRadius = 5
       // availableNetworksView.layer.borderWidth = 1
        availableNetworksView.layer.borderColor = UIColor.red.cgColor
        availableNetworksView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        selectedNetworkView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        self.loadAvilableNetworkData()
        self.isGetWifiName = true
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self

        self.checkLocationService()
        self.tblList.register(UINib(nibName: cellIdentity.blinkingCellIndentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.blinkingCellIndentifier)
        self.tblList.register(UINib(nibName: cellIdentity.settingCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.settingCellIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
      //  AvilableNetworkViewController.getConnectionType()
        //NetworkDeviceFinder.getConnectionType()
//        self.readSerialNumber()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    
    @IBAction func GetMoreHelp(_ sender: Any) {
        self.moveToWebView()
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    
//    func readSerialNumber(){
//        let manager  = BluetoothManager.init()
//        manager.isBleManagerConnectState = false
//        manager.isBleManagerCharacteristicsState = false
//        manager.connectBlueTooth(blueToothName: serialDeviceName, bleFeature: .BluetoothReadSerial)
//        manager.serialNumberReadDelegate = self
//    }
    
    func loadAvilableNetworkData()  {
        self.btnContinueWifi.addTarget(self, action:#selector(self.btnContinueWifiTap(_sender:)), for: .touchUpInside)
        self.btnDifferentWifiLater.addTarget(self, action:#selector(self.btnDifferentWifiLaterTap(_sender:)), for: .touchUpInside)
        self.ssidWifiName = self.txtCurrentWifiName?.text
        self.ssidPasswordName = self.txtCurrentWifiPassword?.text
        
        //        self.txtCurrentWifiName?.text = "JioFi3_674114"
        //        self.txtCurrentWifiPassword?.text = "74kmmmnpt9"
        
        self.txtCurrentWifiName?.delegate = self
        self.txtCurrentWifiPassword?.delegate = self
    }
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
        webdataView.Urltodisplay = Addwifi_Url
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = "Wifi"
        webdataView.strTitle = "wifi"
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .pageSheet
        self.present(webdataView, animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.writeWifiIndex = 0
        self.wifiCheckState = 0
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.ssidWifiName = self.txtCurrentWifiName?.text ?? ""
        self.ssidPasswordName = self.txtCurrentWifiName?.text ?? ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideAct()
        print("Hide Act7")
        self.tabBarController?.tabBar.isHidden = true
    }
}

extension AvilableNetworkViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
    }
    
//    @IBAction func btnBackTapped(_ sender: Any) {
//        print("btnBackTapped")
//        if self.isFromAdddevice == true {
//            //self.getBackGroundDataAPIWithDeviceBasedConnectWiFi()
//            //self.navigationController?.popToRootViewController(animated: true)
//            self.moveToIntialThresHold()
//        }else {
//            self.navigationController?.popToRootViewController(animated: true)
//        }
//    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        print("btnBackTapped")
        self.navigationController?.popViewController(animated: true)
//        if self.isFromAdddevice == true {
//            //self.getBackGroundDataAPIWithDeviceBasedConnectWiFi()
//            //self.navigationController?.popToRootViewController(animated: true)
//            self.moveToIntialThresHold()
//        }else {
//            self.navigationController?.popToRootViewController(animated: true)
//        }
    }
    
    
    func moveToIntialThresHold()  {
        self.moveToThersHolds()
        self.getBackGroundDataAPIWithDeviceBasedConnectWiFi()
    }
    
    func moveToThersHolds() {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SensorAlertViewController") as! SensorAlertViewController
        mainTabbar.isFromInitialAddDevice = true
        mainTabbar.isFromInitialSelectedDeviceID = self.avilableDeviceID
        mainTabbar.avilableDeviceSharedEMailIsfromAddDeviceThres = self.avilableDeviceSharedEMail
        mainTabbar.isFromInitialSelectedDeviceTokenThres = self.avilableDeviceToken
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    @objc func btnContinueWifiTap(_sender:UIButton) {
        Helper.shared.removeBleutoothConnection()
        self.checkLocationService()
    }
    
    @objc func btnDifferentWifiLaterTap(_sender:UIButton) {
        
        let titleString = NSAttributedString(string: "Add New Network", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let message = String(format: "")
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Network Name"
            textField.autocorrectionType = .default
        }
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Network Password"
            textField.isSecureTextEntry = true
            textField.autocorrectionType = .default
        }
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Save", style: .default, handler: { action in
            let firstTextField = alert.textFields![0] as UITextField
            let secondTextField = alert.textFields![1] as UITextField
            
            //            firstTextField.text = "JioFi4_07A12F"
            //            secondTextField.text = "Coginfo@123"
            if firstTextField.text?.count == 0 {
                Helper.shared.showSnackBarAlert(message: "Invalid Network Name", type: .Failure)
            }else if secondTextField.text?.count == 0 {
                Helper.shared.showSnackBarAlert(message: "Invalid Network Passowrd", type: .Failure)
            }else {
                self.ssidWifiName = firstTextField.text ?? ""
                self.ssidPasswordName = secondTextField.text ?? ""
                self.btnContinueWifiTap(_sender: self.btnContinueWifi)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension AvilableNetworkViewController: WIFIStatusDelegate,SSIDWriteDelegate,CLLocationManagerDelegate {
    
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
        if self.isGetWifiName == true {
            let ssid = self.getAllWiFiNameList()
            self.wifiName = ssid ?? ""
            self.isGetWifiName = false
            self.tblList?.reloadData()
        }else {
            self.scanCheckCount = 0
            self.scanBLEDevices()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Helper.shared.showSnackBarAlert(message: "Get Location failed", type: .Failure)
    }
    
    func writeSSIDSocketURL() {
        // Helper.shared.showSnackBarAlert(message: "Write Inprogress", type: .InfoOrNotes)
        self.writeWifiIndex = self.writeWifiIndex + 1
        if self.writeWifiIndex == 5 {
            self.checkWifiStatusBlueTooth()
        }
    }
    
    func writeSSIDCloudWebURL() {
        //Helper.shared.showSnackBarAlert(message: "Wi-Fi Connection Inprogress", type: .InfoOrNotes)
        self.writeWifiIndex = self.writeWifiIndex + 1
        if self.writeWifiIndex == 5 {
            self.checkWifiStatusBlueTooth()
        }
    }
    
    func writeSSIDSocketAuthToken() {
        self.writeWifiIndex = self.writeWifiIndex + 1
        if self.writeWifiIndex == 5 {
            self.checkWifiStatusBlueTooth()
        }
    }
    
    func writeSSIDName() {
        self.writeWifiIndex = self.writeWifiIndex + 1
        if self.writeWifiIndex == 5 {
            self.checkWifiStatusBlueTooth()
        }
    }
    func writeSSIDPassword(){
        self.writeWifiIndex = self.writeWifiIndex + 1
        if self.writeWifiIndex == 5 {
            self.checkWifiStatusBlueTooth()
        }
    }
    
    func checkWifiStatusBlueTooth()  {
        self.showActivityIndicator(self.view, isShow: false, isShowText: "Wi-Fi details updated successfully")
        textLog.write("WIFI WRITE PROCESS COMPLETED (WIFI SCREEN)")
        // self.writeWifiCheckCount = 100
        self.wifiCheckState = 0
        self.deviceWifiConnectState()
    }
    
    func deviceWifiConnectState()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
           // if !self.alertIfNetworkIs5GHZ() {
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Checking Wi-Fi Status on device")
            //}
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.avilableDeviceID == 0 {
                self.hideAct()
                print("Hide Act1")
                return
            }
            self.checkWithWifi()
        }
    }
    
    func checkWithWifi()  {
        self.isAlertShow = false
        
        if BluetoothManager.shared.mainPeripheral == nil {
            BluetoothManager.shared.deviceWifiStatusDelgate = self
            BluetoothManager.shared.serialNumberReadDelegate = self
            BluetoothManager.shared.connectBlueTooth(blueToothName: self.serialDeviceName, bleFeature: .BlueToothFeatureWifiStatus)
            textLog.write("BlueToothFeatureWifiStatusHide7")
            print("BlueToothFeatureWifiStatusHide7")
        }else {
            BluetoothManager.shared.blueToothFeatureType = .BlueToothFeatureWifiStatus
            BluetoothManager.shared.deviceWifiStatusDelgate = self
            BluetoothManager.shared.serialNumberReadDelegate = self
            BluetoothManager.shared.mainPeripheral.discoverServices([LUFT_WIFI_SERVICE_STATUS])
            textLog.write("BlueToothFeatureWifiStatusHide8")
            print("BlueToothFeatureWifiStatusHide8")
        }
        
        //BluetoothManager.shared.connectBlueTooth(blueToothName: self.serialDeviceName, bleFeature: .BlueToothFeatureWifiStatus)
        
        //        Helper.shared.removeBleutoothConnection()
        //        BluetoothManager.shared.delegateBleManagerState = nil
        //        BluetoothManager.shared.isBleManagerConnectState = false
        //
        //        textLog.write("UPDATED WIFI STATUS CHECK START (WIFI SCREEN)")
        //        self.bleStatesDelegate()
        //Helper.shared.showSnackBarAlert(message: "Checking with WiFi Status", type: .Success)
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
        else {
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
    
}

extension AvilableNetworkViewController {
    
    func wifiStatusCheck(wifiDeviceStaus:String) {
        Helper.shared.removeBleutoothConnection()
        self.wifiDeviceStatus = WIFIDEVICESTATUS(rawValue: wifiDeviceStaus) ?? .WIFI_NOT_CONNECTED
        switch self.wifiDeviceStatus {
        case .WIFI_CONNECTED,.WIFI_INTERNET,.ICD_WIFI_CONNECTED,.ICD_WIFI_INTERNET,.ICD_WIFI_CLOUD:
            self.statusOfWifiConnection = "Connected"
            textLog.write("UPDATED WIFI STATUS - CONNECTED (WIFI SCREEN)")
            textLog.write("WIFI STATUS \(String(describing: WIFIDEVICESTATUS.WIFI_CONNECTED))")
            textLog.write("WIFI STATUS \(String(describing: WIFIDEVICESTATUS.WIFI_INTERNET))")
            print("Wifi Connection Successfully")
            self.updateDeviceState(isWifi:true)
            return
        case .WIFI_NOT_CONNECTED,.WIFI_CONNECTING,.ICD_WIFI_CONNECTING,.ICD_WIFI_FAULT,.ICD_WIFI_AUTHENTICATED:
            self.statusOfWifiConnection = "Not connected"
            self.wifiCheckState = self.wifiCheckState + 1
            textLog.write("TRYING COUNT \(String(describing: self.wifiCheckState)) - UPDATED WIFI STATUS CHECK")
            textLog.write("WIFI STATUS \(String(describing: WIFIDEVICESTATUS.WIFI_NOT_CONNECTED))")
            textLog.write("WIFI STATUS \(String(describing: WIFIDEVICESTATUS.WIFI_CONNECTING))")
            if self.wifiCheckState > 2 {
                self.updateDeviceState(isWifi:false)
                textLog.write("UPDATED WIFI STATUS - NOT CONNECTED")
            }else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    //BluetoothManager.shared.centralManager?.stopScan()
                    //BluetoothManager.shared.centralManager?.connect(BluetoothManager.shared.mainPeripheral, options: [:])
                    if BluetoothManager.shared.mainPeripheral.state == .disconnected{
                        BluetoothManager.shared.connectBlueTooth(blueToothName: self.serialDeviceName, bleFeature: .BlueToothFeatureWifiStatus)
                    }
                }
            }
            return
        }
    }
    
    func updateDeviceState(isWifi:Bool)  {
        //self.showAct()
        let updateWifiState = UpdateDeviceModel.init(deviceId: Int64(self.avilableDeviceID), wifiStatus: isWifi, timeDifference: Helper.shared.getTimeDiffBetweenTimeZone(), timeZone: self.getCurrentTimeZoneShortName(), deviceTimeZoneFullName: Helper.shared.getCurrentTimeZoneinIANAFormat(), macAddress: macAddressSerialNo)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
        print("WIFI OR BLE - API")
        print(Int64(self.avilableDeviceID))
        print(isWifi)
        print(Helper.shared.getTimeDiffBetweenTimeZone())
        print(self.getCurrentTimeZoneShortName())
        MobileApiAPI.apiMobileApiUpdateWifiStatusPost(model: updateWifiState, completion: { (respones, error) in
            if respones?.success == true {
                textLog.write("UPDATED DEVICE CONNECT WIFI OR BLE - API")
                self.updateGeoLocationDeviceState(isWifi: isWifi)
                RealmDataManager.shared.updateDeviceWifiStatus(deviceID: self.avilableDeviceID, wifiStatus: isWifi)
            }else {
                self.hideAct()
                print("Hide Act2")
                Helper().showSnackBarAlert(message: "Please check the Wi-Fi credentials.Please make sure you are connected to a 2.4GHz Wi-Fi network.For more information please click on the Get More Help link.", type: .Failure)
                textLog.write("UPDATED DEVICE CONNECT WIFI OR BLE - API Failure")
                print("UPDATED DEVICE CONNECT WIFI OR BLE - API Failure")
            }
        })
    }
    
    func updateGeoLocationDeviceState(isWifi:Bool)  {
        let deviceLocation = DeviceLocation.init(serialnumber: self.serialDeviceName, latitude: self.latCurrentValue , longitude: self.longCurrentValue)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
        DeviceAPI.apiDeviceUpdateDeviceGeoCodePost(model: deviceLocation) { (error) in
            if error == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    textLog.write("UPDATED DEVICE CONNECT LOCATION - API SUCCESS")
                    if isWifi == true {
                        AppSession.shared.setIsConnectedWifi(iswifi:true)
                        Helper().showSnackBarAlert(message: "Wi-Fi Connected Successfully", type: .Success)
                        if self.isFromAdddevice == true {
                            self.moveToIntialThresHold()
                        }else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }else {
                        self.hideAct()
                        print("Hide Act3")
                        if self.isFromAdddevice == true {
                            self.moveToIntialThresHold()
                        }else {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        Helper().showSnackBarAlert(message: "Please check the Wi-Fi credentials.Please make sure you are connected to a 2.4GHz Wi-Fi network.For more information please click on the Get More Help link.", type: .Failure)
                    }
                }
            }else {
                self.hideAct()
                print("Hide Act4")
                Helper().showSnackBarAlert(message: "Please check the Wi-Fi credentials.Please make sure you are connected to a 2.4GHz Wi-Fi network.For more information please click on the Get More Help link.", type: .Failure)
            }
        }
    }
    
}
extension AvilableNetworkViewController {
    
    enum NetworkType{
        case twoG
        case threeG
        case fourG
        case fiveG
        case wifi
        case unknown
        case notReachable
    }
    
    func getAllWiFiNameList() -> String? {
        var ssid: String? = ""
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    class func getConnectionType() -> NetworkType {
        guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
            return NetworkType.notReachable
        }
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if isReachable {
            let networkInfo = CTTelephonyNetworkInfo()
            let carrierType = networkInfo.serviceCurrentRadioAccessTechnology
            
            guard let carrierTypeName = carrierType?.first?.value else {
                return NetworkType.unknown
            }
            if isWWAN {
                
                switch carrierTypeName {
                case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                    print("Reachable Via 2G")
                    return NetworkType.twoG
                    
                case CTRadioAccessTechnologyWCDMA,
                    CTRadioAccessTechnologyHSDPA,
                    CTRadioAccessTechnologyHSUPA,
                    CTRadioAccessTechnologyCDMAEVDORev0,
                    CTRadioAccessTechnologyCDMAEVDORevA,
                    CTRadioAccessTechnologyCDMAEVDORevB,
                CTRadioAccessTechnologyeHRPD:
                    print("Reachable Via 3G")
                    return NetworkType.threeG
                case CTRadioAccessTechnologyLTE:
                    print("Reachable Via 4G is WWAN")
                    return NetworkType.fourG
                default:
                    print("Reachable Via 4G default is WWAN")
                    return NetworkType.fourG
                }
            } else {
                print("Reachable Via WIFI")
                if #available(iOS 14.1, *) {
                    switch carrierTypeName {
                    case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                        print("Reachable Via 2G")
                        return NetworkType.twoG
                        
                    case CTRadioAccessTechnologyWCDMA,
                        CTRadioAccessTechnologyHSDPA,
                        CTRadioAccessTechnologyHSUPA,
                        CTRadioAccessTechnologyCDMAEVDORev0,
                        CTRadioAccessTechnologyCDMAEVDORevA,
                        CTRadioAccessTechnologyCDMAEVDORevB,
                    CTRadioAccessTechnologyeHRPD:
                        print("Reachable Via 3G")
                        return NetworkType.threeG
                    case CTRadioAccessTechnologyLTE:
                        print("Reachable Via 4G is WIFI")
                        return NetworkType.fourG // if selected wi-fi 5Ghz
                        
                    case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
                        print("Reachable Via 5G")
                        return NetworkType.fiveG
                        
                    default:
                        return NetworkType.wifi
                        
                    }
                } else {
                    // Fallback on earlier versions
                    switch carrierTypeName {
                    case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                        print("Reachable Via 2G")
                        return NetworkType.twoG
                        
                    case CTRadioAccessTechnologyWCDMA,
                        CTRadioAccessTechnologyHSDPA,
                        CTRadioAccessTechnologyHSUPA,
                        CTRadioAccessTechnologyCDMAEVDORev0,
                        CTRadioAccessTechnologyCDMAEVDORevA,
                        CTRadioAccessTechnologyCDMAEVDORevB,
                    CTRadioAccessTechnologyeHRPD:
                        print("Reachable Via 3G")
                        return NetworkType.threeG
                    case CTRadioAccessTechnologyLTE:
                        print("Reachable Via 4G from else PART")
                        return NetworkType.fourG
                    default:
                        return NetworkType.wifi
                    }
                }
            }
        } else {
            return NetworkType.notReachable
        }
    }
}


extension AvilableNetworkViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 0
        }
        else{
            return 60

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
           // let cell = UITableViewCell()
            
         /*   let cellValue:BlinkingViewTableViewCell = self.tblList.dequeueReusableCell(withIdentifier: cellIdentity.blinkingCellIndentifier, for: indexPath) as! BlinkingViewTableViewCell
            cellValue.startAnimation()
            cellValue.selectionStyle = .none
            cellValue.isUserInteractionEnabled = false*/
            return UITableViewCell()
        }
        else{
            let cellValue:LTSettingListTableViewCell = self.tblList.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            if self.wifiName == "" || self.wifiName.count == 0 {
                cellValue.lblTitleCell.text = "Please connect your phone to Wi-Fi"
                cellValue.imgViewDisclosureCell.image = UIImage.init(named:"")
                cellValue.isUserInteractionEnabled = false
            }else {
                cellValue.lblTitleCell.text = self.wifiName
                cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellDisclousreIconImage
                cellValue.isUserInteractionEnabled = true
            }
            cellValue.lblSubTitleCell.text = ""
            cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
            cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
            cellValue.lblTitleView.isHidden = false
            cellValue.lblSubTitleView.isHidden = true
            cellValue.lblTitleCell.textAlignment = .left
            cellValue.lblSubTitleCell.textAlignment = .right
            cellValue.selectionStyle = .none
            cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
            cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
            cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
            cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
            cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
            return cellValue
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            return
        }
        self.ssidPasswordName = ""
        let titleString = NSAttributedString(string: "Sign in to \(wifiName)", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let message = String(format: "Enter the password for the Wi-Fi network so your device can connect")
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            // textField.text = self.ssidPasswordAlert
            textField.autocorrectionType = .default
        }
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Join", style: .default, handler: { action in
            if let firstTextField:UITextField = alert.textFields![0] as? UITextField {
                self.ssidPasswordName = ""
               // self.peripherals.removeAll()
                self.ssidPasswordName = (alert.textFields![0] as UITextField).text
                self.ssidWifiName = self.wifiName
                self.btnContinueWifiTap(_sender: self.btnContinueWifi)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.present(alert, animated: true, completion: nil)
        
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
    }
}

// MARK: BLE Scanning
extension AvilableNetworkViewController:CBCentralManagerDelegate,BLEWriteStateDelegate,BleManagerStateDelegate {
    
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
        self.showActivityIndicator(self.view, isShow: false, isShowText: "Trying to connect device via BLE")
        self.peripherals.removeAll()
        self.manager = CBCentralManager(delegate: self, queue: nil)
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if self.scanCheckCount != 30 {
                self.hideAct()
                print("Hide Act5")
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.writeWifiCheckCount = 0
                self.writeWifiNameToDevice()
                textLog.write("writeWifiNameToDevice")
               // if !self.alertIfNetworkIs5GHZ() {
                    self.showActivityIndicator(self.view, isShow: false, isShowText: "Updating Wi-Fi details on device")
                //}
            }
        }
    }
    
    func writeWifiNameToDevice() {
        //self.showAct()
        if self.isFromAdddevice {
            textLog.write("WIFI WRITE PROCESS START (WIFI SCREEN)")
            print("isFromAdddevice WIFI WRITE PROCESS START (WIFI SCREEN)")
            Helper.shared.removeBleutoothConnection()
            BluetoothManager.shared.strDeviceToken = self.avilableDeviceToken
            BluetoothManager.shared.selectedWifiName = self.removeWhiteSpace(text: self.ssidWifiName ?? "")
            BluetoothManager.shared.selectedWifiPassword = self.removeWhiteSpace(text: self.ssidPasswordName ?? "")
            BluetoothManager.shared.serialNumberReadDelegate = self
            BluetoothManager.shared.connectBlueTooth(blueToothName: self.serialDeviceName, bleFeature: .BlueToothFeatureSSIDWrite)
            
            BluetoothManager.shared.delegateBleManagerState = nil
            BluetoothManager.shared.isBleManagerConnectState = false
            BluetoothManager.shared.deviceWriteStatusDelgate = self
            self.bleStatesDelegate()
            self.writeWifiIndex = 0
            self.isAlertShow = false
        }else {
            if self.avilableDeviceID != 0 {
                if RealmDataManager.shared.getDeviceData(deviceID:self.avilableDeviceID).count != 0 {
                    textLog.write("WIFI WRITE PROCESS START (WIFI SCREEN)")
                    Helper.shared.removeBleutoothConnection()
                    BluetoothManager.shared.strDeviceToken = RealmDataManager.shared.getDeviceData(deviceID:self.avilableDeviceID)[0].device_token
                    BluetoothManager.shared.selectedWifiName = self.removeWhiteSpace(text: self.ssidWifiName ?? "")
                    BluetoothManager.shared.selectedWifiPassword = self.removeWhiteSpace(text: self.ssidPasswordName ?? "")
                    BluetoothManager.shared.serialNumberReadDelegate = self
                    BluetoothManager.shared.connectBlueTooth(blueToothName: self.serialDeviceName, bleFeature: .BlueToothFeatureSSIDWrite)
                    
                    BluetoothManager.shared.delegateBleManagerState = nil
                    BluetoothManager.shared.isBleManagerConnectState = false
                    BluetoothManager.shared.deviceWriteStatusDelgate = self
                    self.bleStatesDelegate()
                    self.writeWifiIndex = 0
                }
                self.isAlertShow = false
            }
        }
        
        
    }
    
    func getBLEWriteStateDelegate(bleWriteType: BlueToothFeatureType) {
        if bleWriteType == .BlueToothFeatureSSIDWrite {
            self.writeWifiCheckCount = self.writeWifiCheckCount + 1
            if self.writeWifiCheckCount >= 100 {
                print("Pakka Fail")
            }else if self.writeWifiCheckCount < 3 {
                textLog.write("CONNECT WIFI WRITE RETRY - COUNT\(String(describing: writeWifiCheckCount)) ")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.writeWifiNameToDevice()
                    textLog.write("writeWifiNameToDevice")
                }
                print("Pakka Fail @")
                print(writeWifiCheckCount)
            }
            else {
                print("Pakka Fail4")
                self.showBleNotConnectAlert()
            }
        }else if bleWriteType == .BlueToothFeatureWifiStatus {
            if self.wifiCheckState > 2 {
                self.showBleNotConnectAlert()
                textLog.write("CONNECT WIFI WRITE RETRY - COUNT FAIL\(String(describing: writeWifiCheckCount)) ")
                print("Pakka Fail @@")
                print(writeWifiCheckCount)
            }
        }
        print("fail1")
    }
    
    func getBleManagerBleState(isConnectedBLEState: Bool) {
        if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureWifiStatus{
            self.wifiStatusCheck(wifiDeviceStaus: WIFIDEVICESTATUS.WIFI_NOT_CONNECTED.rawValue)
            print("Pakka Fail $")
            print(writeWifiCheckCount)
        }else if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureSSIDWrite{
            self.getBLEWriteStateDelegate(bleWriteType: BlueToothFeatureType.BlueToothFeatureSSIDWrite)
            print("Pakka Fail $$")
        }else {
            self.showBleNotConnectAlert()
            print("Pakka Fail $$##$")
        }
        print("fail2")
    }
    
    func bleStatesDelegate(){
        BluetoothManager.shared.delegateBleManagerState = self
        BluetoothManager.shared.isBleManagerConnectState = false
    }
    
    func showBleNotConnectAlert()  {
        if self.isAlertShow == true {
            return
        }
        self.hideAct()
        print("Hide Act6")
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
        BluetoothManager.shared.dispose()
        self.isAlertShow = true
    }
    
    
}
extension AvilableNetworkViewController: MAXINDEXDataAPIDelegate {
    
    func updateMaxIdex(updateStatus: Bool) {
        print("Hide 66")
    }
    
    func getBackGroundDataAPIWithDeviceBasedConnectWiFi()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            APIManager.shared.isAddDeviceAPICompleted = false
            DispatchQueue.global(qos: .background).async {
                print("BackGround Start22")
                textLog.write("ADDED DEVICE (GET ALL LOG INDEX POLLUTANT VALUE) - API22")
                APIManager.shared.callMAXINDEXDeviceData(deviceToken: RealmDataManager.shared.getDeviceData(deviceID:self.avilableDeviceID)[0].device_token, maxLogIndex:0, deviceSerialID: self.connectSSIDPeripheral.name ?? "", isFromIntial: false)
                APIManager.shared.maxIndexDelegate = self
                DispatchQueue.main.async {
                }
            }
        }
    }
}

extension AvilableNetworkViewController: DeviceSerialNumberReadDelegate{
    func didReadSerialNumber(serialNumber: String) {
        print("serial numberof device in available network VC : " + serialNumber)
        textLog.writeAPI("serial numberof device in available network VC : " + serialNumber)
        macAddressSerialNo = serialNumber
    }
    /*
    func alertIfNetworkIs5GHZ()-> Bool{
        let networkType = AvilableNetworkViewController.getConnectionType()
        if networkType == .fiveG {
            let alert = UIAlertController(title: "Luft", message: "Please connect to a 2.4GHz network Band.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: {Timer.scheduledTimer(withTimeInterval: 1, repeats:false, block: {_ in
                        self.dismiss(animated: true, completion: nil)
                    })})
            
//            let alertController = UIAlertController(title:"Luft",message:"Please connect to a 2.4GHz network Band.",preferredStyle:.alert)
//            self.present(alertController,animated:true,completion:{Timer.scheduledTimer(withTimeInterval: 2, repeats:false, block: {_ in
//                self.dismiss(animated: true, completion: nil)
//            })})
            
            self.stopScanForBLEDevices()
            self.hideAct()
            return true
        }
        return false
    }
    */
}
