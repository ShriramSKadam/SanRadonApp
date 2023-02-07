//
//  ViewController.swift
//  luft
//
//  Created by iMac Augusta on 9/19/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData
import CoreLocation
import SocketRocket
import SwiftyJSON
import Alamofire
import Realm
import SafariServices

import RealmSwift

let heartRateServiceCBUUID = CBUUID(string: "0x101f")

let LUFT_SERVICE = CBUUID(string: "626b87be-39ce-491b-a871-5b9a209eedc8")
//Device Service
let LUFT_WIFI_SERVICE_STATUS = CBUUID(string: "626b8800-39ce-491b-a871-5b9a209eedc8")
let LUFT_BACKGROUND_SERVICE = CBUUID(string: "626b8801-39ce-491b-a871-5b9a209eedc8")
let LUFT_NIGHT_LIGHT_SETTING_SERVICE = CBUUID(string: "626b8802-39ce-491b-a871-5b9a209eedc8")
let LUFT_SETTING_SERVICE = CBUUID(string: "626b8803-39ce-491b-a871-5b9a209eedc8")
let LUFT_TEMP_OFFSET_SERVICE = CBUUID(string: "626b8804-39ce-491b-a871-5b9a209eedc8")
//Firmware Service
let SERVICE_FWVERSION_CharacteristicCBUUID = CBUUID(string: "b2db29d4-64e8-11e8-adc0-fa7ae01bbebc")

let result_radon_CharacteristicCBUUID = CBUUID(string: "626B87D0-39CE-491B-A871-5B9A209EEDC8")
let result_air_voc_CharacteristicCBUUID = CBUUID(string: "626B87D4-39CE-491B-A871-5B9A209EEDC8")
let result_air_co2_CharacteristicCBUUID = CBUUID(string: "626b87d3-39ce-491b-a871-5b9a209eedc8")
let result_air_temp_CharacteristicCBUUID = CBUUID(string: "626b87d1-39ce-491b-a871-5b9a209eedc8")
let result_air_humidity_CharacteristicCBUUID = CBUUID(string: "626B87D2-39CE-491B-A871-5B9A209EEDC8")
let result_air_pressure_CharacteristicCBUUID = CBUUID(string: "626B87D5-39CE-491B-A871-5B9A209EEDC8")
let result_slc_hour_idx_CharacteristicCBUUID = CBUUID(string: "626B87cb-39CE-491B-A871-5B9A209EEDC8")
let result_slc_time_stamp_CharacteristicCBUUID = CBUUID(string: "626B87ce-39CE-491B-A871-5B9A209EEDC8")
let result_slc_NOTIFIY_stamp_CharacteristicCBUUID = CBUUID(string: "626b87cd-39ce-491b-a871-5b9a209eedc8")

let device_serial_CharacteristicCBUUID = CBUUID(string: "626b87c6-39ce-491b-a871-5b9a209eedc8")

let wifi_Connected_CharacteristicCBUUID = CBUUID(string: "626b87c0-39ce-491b-a871-5b9a209eedc8")
let wifi_SSID_Connected_CharacteristicCBUUID = CBUUID(string: "626b87c1-39ce-491b-a871-5b9a209eedc8")
let wifi_SSID_PASSWORD_Connected_CharacteristicCBUUID = CBUUID(string: "626b87c2-39ce-491b-a871-5b9a209eedc8")
let FWVERSION_CharacteristicCBUUID = CBUUID(string: "b2db29d5-64e8-11e8-adc0-fa7ae01bbebc")


let wifi_COULD_URL = CBUUID(string: "626b87e5-39ce-491b-a871-5b9a209eedc8")
let wifi_AUTH_TOKEN = CBUUID(string: "626b87e6-39ce-491b-a871-5b9a209eedc8")
let wifi_WEBSOCKET_URL = CBUUID(string: "626b87e7-39ce-491b-a871-5b9a209eedc8")

let result_UPPER_BOUND_time_stamp_CharacteristicCBUUID = CBUUID(string: "626b87c9-39ce-491b-a871-5b9a209eedc8")
let result_LOWER_BOUND_time_stamp_CharacteristicCBUUID = CBUUID(string: "626b87ca-39ce-491b-a871-5b9a209eedc8")

let time_STAMP_SSID_Connected_CharacteristicCBUUID = CBUUID(string: "626b87c5-39ce-491b-a871-5b9a209eedc8")
var macAddressSerialNo : String = ""


struct UpdateByDeviceList {
    var deviceData: RealmDeviceList
    var updateBy: Int
}

class LuftDeviceViewController: LTViewController, AddDevicelDelegate, PeripheralDelegate, DashBoardDelegate, LTIntialAGREEDelegate {
    func selectedIntialAGREE() {
    }
    
   
    
    
    var addDeviceDataDelegateStatus:AddNewDeviceDataDelegate? = nil

    var strConnectPeripheral: String = "LUFT"
    var centralManager: CBCentralManager!
    var mainPeripheral: CBPeripheral!
    let reuseIdentifier = "cell"
    var isGridList:Bool = true
    var isSelectedDeviceRow:Int = 0
    var luftSelectedDeviceID:Int = 0
    var isLoadMe:Bool = false
    
    var isCurrentSelectedDevice:RealmDeviceList? = nil
    var arrBackGroundIndexValue:[RealmPollutantValuesTBL] = []
    var arrUpdateByDeviceList: [UpdateByDeviceList] = []
    var arrReadDeviceData:[RealmDeviceList] = []
    var arrCompletedReadDeviceData:[RealmDeviceList] = []
    var arrMyLuftDeviceList: [MyDeviceModel]? = []
    
    var backGroundLogIndex: Int = 0
    var strShareEmailID: String = ""
    var strRenameDevice: String = ""
    var writeRemoveWifiIndex:Int = 0
    var isMenuPressed:Int = 0
    
    var luftDashBoardDeviceIDPrevious:Int = 0
    var readFromBLE:Bool = false
    var refreshControl: UIRefreshControl!
    let kRotationAnimationKey = "com.myapplication.rotationanimationkey" // Any key
    
    var isRemoveWifiCalledManually : Bool = false
    
    //@IBOutlet weak var lblSelectedConnectDevice: UILabel!
    @IBOutlet weak var headerViewDashBoard: AppHeaderView!
    @IBOutlet weak var lblHeaderDashBoard: LTHeaderTitleLabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var tblDeviceCollection: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var textSearch: UISearchBar!
    @IBOutlet weak var backViewStackView: UIStackView!
    var searchDeviceViewController: SearchDeviceViewController?
    var locationManager = CLLocationManager()
    //New API CALL
    var arrMyDeviceList: [MyDeviceModel]? = []
    var isFromLoad:Bool = false
    
    var webSocket: SRWebSocket? = nil
    var delegateSocket: SocketDelegate? = nil
    var isMsgReceived: Bool = false
    var isSocketSuccess: Bool = false
    var timerSynMsg = Timer()
    var dashBrdRemoveWIFIIntailCheckCount:Int = 0
    var isReMoveWifiStart:Int = 0
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    var isDashBoard:Bool = true
    
    @IBOutlet weak var lblCellRadon: UILabel!
    @IBOutlet weak var lblCellVOC: UILabel!
    @IBOutlet weak var lblCelleCo2: UILabel!
    @IBOutlet weak var lblCellValueRadon: UILabel!
    @IBOutlet weak var lblCellValueVOC: UILabel!
    @IBOutlet weak var lblCellValueeCo2: UILabel!
    
    @IBOutlet weak var buttonRadonGetMoreHelp: UIButton!
    
    @IBOutlet weak var lblCellTemp: UILabel!
    @IBOutlet weak var lblCellHumidity: UILabel!
    @IBOutlet weak var lblCellAirPressure: UILabel!
    @IBOutlet weak var lblCellValueTemp: UILabel!
    @IBOutlet weak var lblCellValueHumidity: UILabel!
    @IBOutlet weak var lblCellValueAirPressure: UILabel!
    @IBOutlet weak var showDataView: UIView!
    
    @IBOutlet weak var lblLastSyncHeader: LTCellSyncHeaderLabel!
    @IBOutlet weak var lblLastSync: LTCellSyncLabel!
    @IBOutlet weak var btnSync: LTCellSyncButton!
    @IBOutlet weak var logDataBorder: LTCellDashBoardBorderLabel!
    
    //No Data View
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var lblNodataLastSyncHeader: LTCellSyncHeaderLabel!
    @IBOutlet weak var lblNodataLastSync: LTCellSyncLabel!
    @IBOutlet weak var btnSync1: LTCellSyncButton!
    @IBOutlet weak var backLogView: UIView!
    
    @IBOutlet weak var addDeviceView: UIView!
    @IBOutlet weak var btnFindDeviceButton: UIButton!
    @IBOutlet weak var viewHeaderAddDevice: UIView!
    @IBOutlet weak var lblBorderAddDevice: LTCellDashBoardBorderLabel!
    @IBOutlet weak var lblBorderDashBoard: LTCellDashBoardBorderLabel!
    
    var arrCurrentIndexValue:[RealmPollutantValuesTBL] = []

    var strCurrentDeviceID:Int = 0
    var pollutantType:PollutantType = .PollutantAirPressure
    var selectedDropDownType:AppDropDownType? = .DropDownNone
    var isBackGroundSyncStart:Bool = false
    
    //Out Side Data
    var strOutSideLocation:String = "---"
    var strOutSideTemperature:String = "---"
    var strOutSideHumitiy:String = "---"
    var isCurrentDeviceLat:String = "0.0"
    var isCurrentDeviceLong:String = "0.0"
    var outSideDataAPI: OutSideDataBaseClass? = nil
    var outSideAirQualityIndex = -1
    var strSeasonImage: String? = ""
    var isRefreshSynTapped: Bool? = false
    
    var isReLoad: Bool? = false
    
    var imageWeather: UIImage = UIImage()
    
    @IBOutlet weak var lblUAT1: UILabel!
    @IBOutlet weak var lblUAT2: UILabel!
    
    var wifiDeviceStatus:WIFIDEVICESTATUS = .WIFI_NOT_CONNECTED
    var isWifiUpdate:Int = 0
    var isDeviceTimeDiffUpdate:Bool = false
    var currentTimeStampValue: Int = 0
    //Mold Risk
    @IBOutlet weak var dangerImageView: UIImageView!
    @IBOutlet weak var dangerousImageView: UIImageView!
    @IBOutlet weak var lblMoldRisk: UILabel!
    @IBOutlet weak var lblAlertRisk: UILabel!
    //BT Access permission
    var intPermissionDisplay = 0

    // MARK: - View Life cycle
    //Notifications
    @objc func reloadDashboardview(_ notification: Notification) {
        if self.getCurrentSelectedDevice() != nil {
//            self.isRefreshSynTapped = true
//            self.getOustideData()
//            self.deviceDataAPIStatus(update:true)
            self.callSyncWifiBackGroundModeDeviceDetails()
        }
    }
    
    override func viewDidLoad() {
        //Set post notification get sync latest data- Gauri
        NotificationCenter.default.addObserver(self, selector: #selector(LuftDeviceViewController.reloadDashboardview(_:)), name: NSNotification.Name(rawValue: "ReloadDashboardNoti"), object: nil)
        //
        super.viewDidLoad()
        self.hideActivityIndicator(self.view)
        print("hide7")
        self.tblDeviceCollection.delegate = self
        self.tblDeviceCollection.dataSource = self
        self.tblDeviceCollection.register(UINib(nibName: cellIdentity.luftDeviceTableViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.luftDeviceTableViewCell)
        self.tblDeviceCollection.register(UINib(nibName: cellIdentity.deviceCollectionViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.deviceCollectionViewCell)
        self.tblDeviceCollection.register(UINib(nibName: cellIdentity.deviceDataTableViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.deviceDataTableViewCell)
        self.tblDeviceCollection.register(UINib(nibName: cellIdentity.deviceStatusTableViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.deviceStatusTableViewCell)
        self.tblDeviceCollection.register(UINib(nibName: cellIdentity.luftLogoTableViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.luftLogoTableViewCell)
        self.tblDeviceCollection.register(UINib(nibName: cellIdentity.outsideDataTableViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.outsideDataTableViewCell)
        
        self.callSyncWifiBackGroundModeDeviceDetails()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshPullDown), for: .valueChanged)
        self.tblDeviceCollection?.addSubview(refreshControl)
        self.backViewStackView?.isHidden = true
        self.isFromLoad = false
        self.isSelectedDeviceRow = 0
        // For use in background
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self

        // self.connectWebSocket()
        // self.checkLocationService()
        self.webSocket = nil
        self.setMyLabelText()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self.luftDashBoardDeviceIDPrevious = AppSession.shared.getPrevSelectedDeviceID()
            if Reachability.isConnectedToNetwork() == false {
                self.getDeviceList(isAPICall:false)
            }else {
                self.showAct()
                self.getDeviceList(isAPICall:true)
            }
        }
        dataBasePathChange = false
        self.moveToIntialSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
        self.setAllSwitchesOn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataBasePathChange = false
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        self.applyThemeDashboard()
        self.removeSearchView()
        if isMenuPressed == 1{
            self.isMenuPressed = 0
            return
        }
        self.isMenuPressed = 0
        self.isSelectedDeviceRow = 0
        self.strShareEmailID = ""
        self.strRenameDevice = ""
        self.writeRemoveWifiIndex = 0
        self.backViewStackView.isHidden = false
        self.showSearchViewLIntial()
        //self.getDeviceList(isAPICall:self.isFromLoad)
        self.isFromLoad = true
        self.isDashBoard = true
        self.uatLBLTheme(lbl: self.lblUAT1)
        self.uatLBLTheme(lbl: self.lblUAT2)
        self.isReMoveWifiStart = 0
      //  NotificationCenter.default.addObserver(self, selector: #selector(LuftDeviceViewController.reloadDashboardview(_:)), name: NSNotification.Name(rawValue: "ReloadDashboardNoti"), object: nil)
        /*
         self.isRefreshSynTapped = true
        self.getOustideData()
        self.deviceDataAPIStatus(update:true)
        self.getDeviceBackSync()
         */
        self.reloadLogData()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if AppSession.shared.getIsAddedNewDevice() == true {
            self.isReLoad = false
            self.getDeviceList(isAPICall:false)
        }
        if AppSession.shared.getIsConnectedWifi() == true {
            AppSession.shared.setIsConnectedWifi(iswifi:false)
            self.isReLoad = false
            self.callMyDeviceAPI()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.getFWVersionAPI(isFromIntial: true)
        }
        
        if self.isReLoad == true {
            self.isReLoad = false
            self.getDeviceList(isAPICall:false)
        }
       // self.getDeviceBackSync()
    }
    func setAllSwitchesOn(){
        UserDefaults.standard.set(true, forKey: "RadonSwitch")
        UserDefaults.standard.set(true, forKey: "TemperatureSwitch")
        UserDefaults.standard.set(true, forKey: "HumiditySwitch")
        UserDefaults.standard.set(true, forKey: "AirPressureSwitch")
        UserDefaults.standard.set(true, forKey: "ECO2Switch")
        UserDefaults.standard.set(true, forKey: "TVOCSwitch")
    }
    
    @IBAction func buttonGetMoreHelp(sender: UIButton) {
       
        if sender.tag == 5001{
            let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
            webdataView.Urltodisplay = buttonRadion_URL
            webdataView.isFromIntial = true
            webdataView.lblHeader?.text = UNITS
            webdataView.strTitle = UNITS
            webdataView.delegateIntailAgree = self
            webdataView.modalPresentationStyle = .pageSheet
            self.present(webdataView, animated: false, completion: nil)
        }
        else if sender.tag == 5002{
            let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
            webdataView.Urltodisplay = buttonTVoc_URL
            webdataView.isFromIntial = true
            webdataView.lblHeader?.text = UNITS
            webdataView.strTitle = UNITS
            webdataView.delegateIntailAgree = self
            webdataView.modalPresentationStyle = .pageSheet
            self.present(webdataView, animated: false, completion: nil)
            
        }
        else if sender.tag == 5003{
            let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
            webdataView.Urltodisplay = buttonEco2_URL
            webdataView.isFromIntial = true
            webdataView.lblHeader?.text = UNITS
            webdataView.strTitle = UNITS
            webdataView.delegateIntailAgree = self
            webdataView.modalPresentationStyle = .pageSheet
            self.present(webdataView, animated: false, completion: nil)
        }
        else if sender.tag == 5004{
            let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
            webdataView.Urltodisplay = buttonTemperature_URL
            webdataView.isFromIntial = true
            webdataView.lblHeader?.text = UNITS
            webdataView.strTitle = UNITS
            webdataView.delegateIntailAgree = self
            webdataView.modalPresentationStyle = .pageSheet
            self.present(webdataView, animated: false, completion: nil)
        }
        else if sender.tag == 5005{
            let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
            webdataView.Urltodisplay = buttonHumidity_URL
            webdataView.isFromIntial = true
            webdataView.lblHeader?.text = UNITS
            webdataView.strTitle = UNITS
            webdataView.delegateIntailAgree = self
            webdataView.modalPresentationStyle = .pageSheet
            self.present(webdataView, animated: false, completion: nil)
        }
        else if sender.tag == 5006{
            let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
            webdataView.Urltodisplay = buttonAirPressure_URL
            webdataView.isFromIntial = true
            webdataView.lblHeader?.text = UNITS
            webdataView.strTitle = UNITS
            webdataView.delegateIntailAgree = self
            webdataView.modalPresentationStyle = .pageSheet
            self.present(webdataView, animated: false, completion: nil)
        }
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
            //self.locationPremission()
        }
    }
   
    func locationPremission()  {
        let titleString = NSAttributedString(string: "Would you like to provide ZIP code only instead?", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let message = String(format: "")
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
            self.loadZipCode()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { action in
            self.loadOutdoorWeather()
        }))
        //alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        self.hideAct()
    }
    
    func loadZipCode() {
        let titleString = NSAttributedString(string: "Enter Zip Code", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let message = String(format: "")
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action in
            //self.loadZipCode()
        }))
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.default, handler: { action in
            self.locationPremission()
        }))
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        self.hideAct()
    }
   
    func loadOutdoorWeather() {
        let titleString = NSAttributedString(string: "The outdoor weather station and altitude correction features will be disabled as they require location access.", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let message = String(format: "")
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action in
            //self.loadZipCode()
        }))
        alert.addAction(UIAlertAction(title: "Back", style: UIAlertAction.Style.default, handler: { action in
            self.locationPremission()
        }))
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        self.hideAct()
    }
    
    func hideAct()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideActivityIndicator(self.view)
        }
        print("Hide 143")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    
    @objc func refreshBleTapped(sender:UIButton!) {
        //self.connectBlueTooth()
    }
    
    func moveToIntialSetup()  {
        if AppSession.shared.getShowAppleIsInfo() == 1 {
            var changeNameMobileUserSetting: AppUserMobileDetails? = nil
            changeNameMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
            print(changeNameMobileUserSetting?.firstName ?? "")
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewControllerMenu = mainStoryboard.instantiateViewController(withIdentifier: "InitialSettingViewController") as! InitialSettingViewController
            self.tabBarController?.tabBar.isHidden = true
            viewControllerMenu.isFromInitialAddDevice = false
            self.isReLoad = true
            self.navigationController?.pushViewController(viewControllerMenu, animated: false)
            
        }
        else if ((AppSession.shared.getMobileUserMeData()?.firstName?.count == 0 || AppSession.shared.getMobileUserMeData()?.lastName?.count == 0) ||  (AppSession.shared.getMobileUserMeData()?.buildingtypeid == nil || AppSession.shared.getMobileUserMeData()?.buildingtypeid == -1)) && AppSession.shared.getShowAppleIsInfo() == 2 {
                var changeNameMobileUserSetting: AppUserMobileDetails? = nil
                changeNameMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
                print(changeNameMobileUserSetting?.firstName ?? "")
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewControllerMenu = mainStoryboard.instantiateViewController(withIdentifier: "InitialSettingViewController") as! InitialSettingViewController
                self.tabBarController?.tabBar.isHidden = true
                viewControllerMenu.isFromInitialAddDevice = false
                self.isReLoad = true
                self.navigationController?.pushViewController(viewControllerMenu, animated: false)
        }else {
            
        }
    }
    
    func uatLBLTheme(lbl:UILabel)  {
        lbl.textColor = ThemeManager.currentTheme().titleTextColor
        lbl.font = UIFont.setAppFontBold(12)
        if AppSession.shared.getUserLiveState() == 2 {
            lbl.text = UAT_TEXT
        }else {
            lbl.text = ""
        }
    }
    
    func applyThemeDashboard()  {
        self.headerViewDashBoard.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.lblHeaderDashBoard.backgroundColor = ThemeManager.currentTheme().headerTitleTextColor
        self.btnMenu.setImage(ThemeManager.currentTheme().menuIconImage, for: .normal)
        if AppSession.shared.getUserSelectedLayout() == 2{
            self.isGridList = true
            self.searchView?.isHidden = true
            self.textSearch?.delegate = self
        }else {
            self.isGridList = false
            self.searchView?.isHidden = true
        }
        self.tblDeviceCollection?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.backLogView?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        //UIApplication.shared.statusBarView?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.setLatestStatusBar()
        self.tabBarController?.tabBar.barTintColor = ThemeManager.currentTheme().viewBackgroundColor
        self.lblHeaderDashBoard?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
        self.customizeSearchBar()
        self.addDeviceView?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.tabBarController?.tabBar.isHidden = false
        })
        self.viewHeaderAddDevice?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.lblBorderDashBoard?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
        self.lblBorderAddDevice?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let tabBarVC = self.tabBarController as? LuftTabbarViewController {
            tabBarVC.strTabbarSelectedPeripheral = self.strConnectPeripheral
            if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
                if RealmDataManager.shared.readDeviceListDataValues().count != 0 {
                    guard !deviceDataCurrent.isInvalidated else {
                        tabBarVC.deviceIDSelectedPrevious = -100
                        return
                    }
                    tabBarVC.deviceIDSelectedPrevious = deviceDataCurrent.device_id
                }
            }else {
                tabBarVC.deviceIDSelectedPrevious = -100
            }
        }
        self.view.layer.removeAllAnimations()
        self.timerSynMsg.invalidate()
        self.isDashBoard = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarTextColor
    }
    
    func reloadTbl(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            BackgroundDataAPIManager.shared.isCompleted = false
            BackgroundDataAPIManager.shared.isWholeDataSyncCompleted = false
            print("Device imple44")
            BackgroundDataAPIManager.shared.callSyncBackGroundDeviceDetailsAPI()
            BackgroundDataAPIManager.shared.allReadingData = self
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    print("Device imple45")
                }
            }
        }
    }
}

extension LuftDeviceViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationsObj = locations.last! as CLLocation
//        self.latCurrentValue = locationsObj.coordinate.latitude
//        self.longCurrentValue = locationsObj.coordinate.longitude
        self.locationManager.stopUpdatingLocation()
        if self.locationManager.delegate == nil {
            return
        }
        self.locationManager.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Helper.shared.showSnackBarAlert(message: "Failed to get GEO Location", type: .Failure)
    }
}

// MARK: - Device Data
extension LuftDeviceViewController {
    
    func callSyncWifiBackGroundModeDeviceDetails(){
        self.showAct()
        self.syncStatusMessageUpdate(message:"Loading data...")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            BackgroundDataAPIManager.shared.isCompleted = false
            BackgroundDataAPIManager.shared.isWholeDataSyncCompleted = false
            APIManager.shared.isAddDeviceAPICompleted = true
            print("background state1")
            BackgroundDataAPIManager.shared.callSyncBackGroundDeviceDetailsAPI()
            BackgroundDataAPIManager.shared.allReadingData = self
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    
//                    if ((self.arrMyLuftDeviceList?.count ?? 0) > 0) {
                        self.reloadDataCurrentIndexLogData(isFromAppdelgate: true)
//                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                        self.hideAct()
                        self.syncStatusMessageUpdate(message:"")
                    }
                }
            }
        }
    }
    
    
}
extension LuftDeviceViewController: ConnectPeripheralDelegate,AddNewDeviceDataDelegate {
    
    func addNewdeviceDataDelegateDelegateStatus(upadte: Bool) {
        self.isLoadMe = true
        self.getOustideData()
    }
    
    @IBAction func btnAddDeviceTapped(_ sender: Any) {
        //Checking BT access permission - Gauri
        if intPermissionDisplay == 0 {
            self.findDeviceBTScan()
        } else {
            self.moveToAddDevice(isfromDefault: false)
        }
        //self.moveToAddDevice(isfromDefault: false)
    }
    
    func findDeviceBTScan() {
        self.manager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    @IBAction func btnPresentMenuTapped(_ sender: Any) {
        self.removeSearchView()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerMenu = mainStoryboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        viewControllerMenu.menuDelegate = self
        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
            viewControllerMenu.isSelectedDevice = deviceDataCurrent
        }
        viewControllerMenu.modalPresentationStyle = .overFullScreen
        self.isMenuPressed = 1
        self.tabBarController?.present(viewControllerMenu, animated: true, completion: nil)
    }
    
    func connectedPeripheralDevice(peripheralDevice: CBPeripheral) {
        self.strConnectPeripheral = peripheralDevice.name ?? ""
        self.mainPeripheral = peripheralDevice
        self.getOustideData()
    }
    
    //Changes due to BT access on dashboard - Gauri
    func moveToAddDevice(isfromDefault:Bool)  {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "AddDeviceViewController") as! AddDeviceViewController
//        vc.connectedBleDeviceDelegate = self
//        vc.addDeviceDataDelegateStatus = self
//        vc.isfromDefaultAddDevice = isfromDefault
//        self.isReLoad = true
//        self.navigationController?.pushViewController(vc, animated: false)
        
        //Check BT connection & scan device
        if intPermissionDisplay == -1 {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ScanTableViewController") as! ScanTableViewController
        vc.connectBleDelegate = self
        vc.dashBoardDelegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        } else {
            // Please enable BT for device
            self.findDeviceBTScan()
        }
    }
    
    func connectpPeripheralDevice(peripheralDevice:CBPeripheral) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcMYDeviceData = storyboard.instantiateViewController(withIdentifier: "AddMyDeviceViewController") as! AddMyDeviceViewController
        vcMYDeviceData.connectPeripheral = peripheralDevice
        vcMYDeviceData.adddeviceDelegate = self
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vcMYDeviceData, animated: false)
    }
    
    func isDashBoardAddDevice(isdashBoard:Bool){
        //self.isfromScanView = false
    }
    
    func addDevicelDelegateStatus(upadte: Bool) {
        self.addDeviceDataDelegateStatus?.addNewdeviceDataDelegateDelegateStatus(upadte: true)
    }
    
    func showPresentFilter() {
        self.removeSearchView()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerMenu = mainStoryboard.instantiateViewController(withIdentifier: "FliterViewController") as! FliterViewController
        viewControllerMenu.fliterDelegate = self
        viewControllerMenu.modalPresentationStyle = .overFullScreen
        self.isMenuPressed = 1
        self.tabBarController?.present(viewControllerMenu, animated: true, completion: nil)
    }
}

extension LuftDeviceViewController:UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if RealmDataManager.shared.readDeviceListDataValues().count == 0 {
            return  0
        }
        return  4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if RealmDataManager.shared.readDeviceListDataValues().count == 0 {
            return  UITableViewCell()
        }
        
        //        if indexPath.row == 0 {
        //            let deviceTempDataCell:DeviceDataTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.deviceDataTableViewCell, for: indexPath) as! DeviceDataTableViewCell
        //            deviceTempDataCell.applyCellTempDataTheme()
        //            if let deviceDataCurrent:RealmDeviceList = self.isCurrentSelectedDevice {
        //                deviceTempDataCell.strCurrentDeviceID = deviceDataCurrent.device_id
        //                deviceTempDataCell.readDataCurrentIndex()
        //            }
        //            deviceTempDataCell.btnSync.addTarget(self, action: #selector(self.syncWithWIFIBLEData(sender:)), for: .touchUpInside)
        //            deviceTempDataCell.btnSync1.addTarget(self, action: #selector(self.syncWithWIFIBLEData(sender:)), for: .touchUpInside)
        //            deviceTempDataCell.imageViewBtnSync?.isHidden = true
        //            deviceTempDataCell.btnSync.isHidden = false
        //            return deviceTempDataCell
        //        }
        if indexPath.row == 0 {
            let statusCell:DeviceStatusTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.deviceStatusTableViewCell, for: indexPath) as! DeviceStatusTableViewCell
            statusCell.applyDeviceCellTheme()
            if let deviceDataCurrent:RealmDeviceList = getCurrentSelectedDevice() {
                if getCurrentSelectedDevice()?.wifi_status == true {
                    statusCell.imgViewBluWifi.image = UIImage.init(named: "wifiimg")
                    
                }else {
                    statusCell.imgViewBluWifi.image = UIImage.init(named: "bluetooth")
                    //Need to change data submit on API first-Gauri
                    self.getBluetoothUpdateDevice()
                }
                statusCell.strCurrentDeviceID = deviceDataCurrent.device_id
                statusCell.statusSelectedDeviceName.text = deviceDataCurrent.name
                statusCell.lblDeviceConnectStatus?.text = ""
                statusCell.btnSync?.addTarget(self, action: #selector(self.syncWithWIFIBLEData(sender:)), for: .touchUpInside)
                statusCell.readDataCurrentIndex()
            }
            return statusCell
        }
        if indexPath.row == 1 {
            let outSideDataCell:OutsideDataTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.outsideDataTableViewCell, for: indexPath) as! OutsideDataTableViewCell
            outSideDataCell.lblOutsideTempValue?.text = self.strOutSideTemperature
            outSideDataCell.lblOutsideTemp?.text = "Temperature"
            outSideDataCell.lblOutsideHumidityValue?.text = self.strOutSideHumitiy
            outSideDataCell.lblOutsideHumidity?.text = "Humidity"
            //outSideDataCell.lblHeaderName?.text = "Outside Conditions:"
            //outSideDataCell.lblLocationName?.text = "tyr"
            
            outSideDataCell.lblOutsideTemp?.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
            outSideDataCell.lblOutsideHumidity?.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
            outSideDataCell.lblHeaderName?.textColor = ThemeManager.currentTheme().ltCellOusideHeaderColor
            outSideDataCell.lblOutsideTempValue?.textColor = ThemeManager.currentTheme().ltCellOusideValueColor
            outSideDataCell.lblOutsideHumidityValue?.textColor = ThemeManager.currentTheme().ltCellOusideValueColor
            
            outSideDataCell.imgViewSeason.image = self.imageWeather
            //            if AppSession.shared.getUserLiveState() == 2 {
            //                outSideDataCell.imgViewSeason.imageFromUrl(url: NSURL.init(string:String(format:"%@%@.png",LIVE_OPEN_WEATHER_MAP_IMAGE_URL,self.strSeasonImage ?? "04d"))! as URL)
            //            }else {
            //                outSideDataCell.imgViewSeason.imageFromUrl(url: NSURL.init(string:String(format:"%@%@.png",UAT_OPEN_WEATHER_MAP_IMAGE_URL,self.strSeasonImage ?? "04d"))! as URL)
            //            }
            
            
            outSideDataCell.lblOutSideCellBorderStatusCell?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
            let attriString1 = NSAttributedString(string:"Local Weather:", attributes:
                [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellOusideHeaderColor,
                 NSAttributedString.Key.font: UIFont.setAppFontBold(17)])
//            let attriString2 = NSAttributedString(string:String(format: " \n%@", self.strOutSideLocation), attributes:
//                [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellOusideValueColor,
//                 NSAttributedString.Key.font: UIFont.setAppFontRegular(17)])
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(attriString1)
            //mutableAttributedString.append(attriString2)
            outSideDataCell.lblHeaderName?.numberOfLines = 0
            outSideDataCell.lblHeaderName?.attributedText = mutableAttributedString
            //Trailer Haven Mobile Home Park Erode

            let attriString2 = NSAttributedString(string:String(format: "%@", self.strOutSideLocation), attributes:
                [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellOusideValueColor,
                 NSAttributedString.Key.font: UIFont.setAppFontRegular(17)])
            
            outSideDataCell.lblLocationName?.numberOfLines = 2
            outSideDataCell.lblLocationName?.attributedText = attriString2
            //outSideDataCell.lblLocationName?.textColor = ThemeManager.currentTheme().ltCellOusideValueColor
            outSideDataCell.selectionStyle = .none

            ///
            outSideDataCell.lblAirQuality.textColor = ThemeManager.currentTheme().ltCellOusideValueColor
           
           var strAirQuality = ""
            outSideDataCell.imgeAirQualitytriangle1.isHidden = true
            outSideDataCell.imgeAirQualitytriangle2.isHidden = true
            outSideDataCell.imgeAirQualitytriangle3.isHidden = true
            outSideDataCell.imgeAirQualitytriangle4.isHidden = true
            outSideDataCell.imgeAirQualitytriangle5.isHidden = true

            switch outSideAirQualityIndex {
            case 1:
                strAirQuality = "Outdoor Air Quality - Good"
                outSideDataCell.imgeAirQualitytriangle1.isHidden = false
            case 2:
                strAirQuality = "Outdoor Air Quality - Fair"
                outSideDataCell.imgeAirQualitytriangle2.isHidden = false
            case 3:
                strAirQuality = "Outdoor Air Quality - Moderate"
                outSideDataCell.imgeAirQualitytriangle3.isHidden = false
            case 4:
                strAirQuality = "Outdoor Air Quality - Poor"
                outSideDataCell.imgeAirQualitytriangle4.isHidden = false
            case 5:
                strAirQuality = "Outdoor Air Quality - Very Poor"
                outSideDataCell.imgeAirQualitytriangle5.isHidden = false
            default:
                strAirQuality = "Outdoor Air Quality"
            }
            
            //outSideDataCell.lblAirQuality.text = "Air Quality - Good"
            //Airqulaity font
            let attriStringAirQ = NSAttributedString(string:String(format: "%@", strAirQuality), attributes:
                [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellOusideValueColor,
                 NSAttributedString.Key.font: UIFont.setAppFontRegular(17)])
            let mutableAttributedStringAirQ = NSMutableAttributedString()
            mutableAttributedStringAirQ.append(attriStringAirQ)
            outSideDataCell.lblAirQuality?.numberOfLines = 0
            outSideDataCell.lblAirQuality?.attributedText = mutableAttributedStringAirQ
           
            return outSideDataCell
        }
        if indexPath.row == 2 {
            let deivceNameCell:LuftDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.luftDeviceTableViewCell, for: indexPath) as! LuftDeviceTableViewCell
            if self.arrReadDeviceData.count > 0 {
                deivceNameCell.reloadCollectionView(arrDevice: self.arrReadDeviceData, isDashBorad: true)
            }
            deivceNameCell.deviceSelectedDelgate = self
            deivceNameCell.fliterSelectedDelegate = self
            return deivceNameCell
        }
        if indexPath.row == 3 {
            let luftLogoCell:LuftLogoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.luftLogoTableViewCell, for: indexPath) as! LuftLogoTableViewCell
            if self.arrReadDeviceData.count != 0 {
                luftLogoCell.lblCellBorderStatusCell?.isHidden = false
            }else {
                luftLogoCell.lblCellBorderStatusCell?.isHidden = true
            }
            luftLogoCell.lblCellBorderStatusCell?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
            luftLogoCell.selectionStyle = .none
            return luftLogoCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //        if indexPath.row == 0 {
        //            return 234
        //        }
        if indexPath.row == 0 {
            return 220
        }
        if indexPath.row == 1 {
            return 195
        }
        if indexPath.row == 2 {
            let arrayCount:Float = Float(self.arrReadDeviceData.count)
            if isGridList {
                if arrayCount == 0 {
                    return 0
                }
                return CGFloat(arrayCount * 60) + 45
            }else {
                let f: Float = Float(arrayCount / 3)
                let ivalue = Int(f.rounded(.up))
                return CGFloat((ivalue  * 115))
            }
        }
        if indexPath.row == 3 {
            return 100
        }
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            guard let url = URL(string: LIVE_SUN_RADON_URL) else { return }
            UIApplication.shared.open(url)
        }
    }
}


extension LuftDeviceViewController:DeviceSelectedDelegate,CurrentLogIndexDelegate {
    
    func getBluetoothCurrentIndexLogData(isConnectedBLE: Bool) {
        if self.isBackGroundSyncStart == true {
            return
        }
        if self.isDashBoard == false {
            if self.isDeviceTimeDiffUpdate == false {
                if isConnectedBLE == false {
                    let bleWifiStatus = UserDefaults.standard.object(forKey: "Selected_DeviceName_WIFI") as? Bool
                    if bleWifiStatus != nil && bleWifiStatus != true{
                        self.getBluetoothUpperBoundLogData()
                        return
                    }
                }
            }
            return
        }
        if isConnectedBLE == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.syncStatusMessageUpdate(message:"Receiving the latest data over Bluetooth")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.reloadDataCurrentIndexLogData()
                self.syncStatusMessageUpdate(message:"Data is Refreshed")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.syncStatusMessageUpdate(message:"")
                self.removeJifImage()
                if self.isDeviceTimeDiffUpdate == false {
                    self.backgroundBluetoothSync()
                }
            }
        }else {
            self.syncStatusMessageUpdate(message:"Device Connected in BLE")
        }
        
    }
    
    func getDeviceList(isAPICall:Bool)  {
        self.arrReadDeviceData.removeAll()
        self.arrReadDeviceData = RealmDataManager.shared.readDeviceListDataValues()
        if self.arrReadDeviceData.count > 0 {
            self.hideDeviceView()
            if AppSession.shared.getUserSelectedLayout() == 2 {
                self.arrReadDeviceData.removeAll()
                self.arrReadDeviceData = self.getSortArrayValues(arrayValue: RealmDataManager.shared.readDeviceListDataValues())
                self.arrReadDeviceData.removeAll()
                self.arrReadDeviceData.append(contentsOf: self.arrCompletedReadDeviceData)
                if self.arrReadDeviceData.count == 1 {
                    self.searchView?.isHidden = true
                }else {
                    self.searchView?.isHidden = false
                }
            }else{
                self.arrCompletedReadDeviceData.removeAll()
                self.arrCompletedReadDeviceData.append(contentsOf: self.arrReadDeviceData)
            }
            if self.arrReadDeviceData.count > 0 {
                if AppSession.shared.getIsAddedNewDevice() == true {
                    AppSession.shared.setIsAddedNewDevice(isAddedDevice:false)
                    if let tabBarVC = self.tabBarController as? LuftTabbarViewController {
                        self.luftDashBoardDeviceIDPrevious = tabBarVC.deviceIDSelectedPrevious
                    }
                }
                if self.arrReadDeviceData.contains(where: { $0.device_id == self.luftDashBoardDeviceIDPrevious }) == true && self.luftDashBoardDeviceIDPrevious != -100{
                    self.isSelectedDeviceRow = self.arrReadDeviceData.firstIndex(where: { (item) -> Bool in
                        item.device_id == self.luftDashBoardDeviceIDPrevious
                    }) ?? 0
                }else {
                    self.isSelectedDeviceRow = 0
                }
                self.isCurrentSelectedDevice = self.arrReadDeviceData[isSelectedDeviceRow]
                AppSession.shared.setPrevSelectedDeviceID(prevSelectedDevice: self.isCurrentSelectedDevice?.device_id ?? -100)
                self.arrReadDeviceData.remove(at: isSelectedDeviceRow)
                self.luftSelectedDeviceID = self.isCurrentSelectedDevice?.device_id ?? 0
                AppSession.shared.setCurrentDeviceToken(self.isCurrentSelectedDevice?.device_token ?? "")
                self.reloadTblData()
                self.getOustideData()
                if self.arrReadDeviceData.count > 0 {
                if self.arrReadDeviceData[0].wifi_status == false{
                    self.readSerialNumber()
                }
                }
            }
        }else  {
            self.addDeviceViewNewGood()
            BackgroundDataAPIManager.shared.isWholeDataSyncCompleted = true
        }
        if isAPICall == true {
            if Reachability.isConnectedToNetwork() == true {
                self.callMyDeviceAPI()
            }
            
        }
    }
    
    func showSearchViewLIntial()  {
        self.arrReadDeviceData.removeAll()
        self.arrReadDeviceData = RealmDataManager.shared.readDeviceListDataValues()
        if self.arrReadDeviceData.count > 0 {
            self.hideDeviceView()
            if AppSession.shared.getUserSelectedLayout() == 2 {
                if self.arrReadDeviceData.count == 1 {
                    self.searchView?.isHidden = true
                }else {
                    self.searchView?.isHidden = false
                }
            }
        }else  {
            self.addDeviceViewNewGood()
        }
    }
    
    func deviceSelectedDevice(deviceID:Int) {
        if deviceID == -100 {
            self.showAct()
            self.refreshControl.endRefreshing()
            self.callDeviceDetailsTypeApi(isUpdateDummy: false)
            return
        }
        self.arrReadDeviceData.removeAll()
        self.arrReadDeviceData.append(contentsOf: self.arrCompletedReadDeviceData)
        if self.arrReadDeviceData.count > 0 {
            if deviceID == -100 {
                self.callDeviceDetailsTypeApi(isUpdateDummy: false)
                return
            }else {
                self.isSelectedDeviceRow = self.arrReadDeviceData.firstIndex(where: { (item) -> Bool in
                    item.device_id == deviceID
                }) ?? 0
            }
            self.isCurrentSelectedDevice = self.arrReadDeviceData[self.isSelectedDeviceRow]
            AppSession.shared.setPrevSelectedDeviceID(prevSelectedDevice: self.isCurrentSelectedDevice?.device_id ?? -100)
            self.arrReadDeviceData.remove(at: self.isSelectedDeviceRow)
            self.luftSelectedDeviceID = self.isCurrentSelectedDevice?.device_id ?? 0
            AppSession.shared.setCurrentDeviceToken(self.isCurrentSelectedDevice?.device_token ?? "")
        }
        self.reloadTblData()
        self.getOustideData()
        if self.arrReadDeviceData[0].wifi_status == false{
            self.readSerialNumber()
        }
    }
    
    
    @objc func refreshPullDown(_ sender: Any) {
        if self.getCurrentSelectedDevice() != nil {
            self.isRefreshSynTapped = true
            self.getOustideData()
        }
    }
    
    @objc func syncWithWIFIBLEData(sender: UIButton) {
        self.isRefreshSynTapped = true
        self.getOustideData()
        //self.isBackGroundSyncStart = false
    }
    
    func syncingRefreshData() {
        self.timerSynMsg.invalidate()
        if self.webSocket == nil {
            self.checkSocketStatus()
        }else {
            self.WiFiBlELatestDataSync()
        }
        self.isSocketSuccess = false
    }
    
    func WiFiBlELatestDataSync()  {
        self.refreshControl.endRefreshing()
        Helper.shared.removeBleutoothConnection()
        self.addJifImage()
        if let deviceDataCurrent:RealmDeviceList = getCurrentSelectedDevice(),deviceDataCurrent.wifi_status == true {
            textLog.write("REQUEST LATEST DATA OVER INTERNET - 1 ")
            self.syncStatusMessageUpdate(message:"Requesting latest data over internet")
            print("API CALLING")
            self.hideActivityIndicator(self.view)
            AppSession.shared.setCurrentDeviceToken(getCurrentSelectedDevice()?.device_token ?? "")
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
            SwaggerClientAPI.basePath = getDeviceGetAPIBaseUrl()
            DeviceAPI.apiDeviceRequestLatestReadingsPost { (error) in
                SwaggerClientAPI.basePath = getAPIBaseUrl()
                if error == nil {
                    print("API CALLING SUCCESS")
                    textLog.write("REQUEST LATEST DATA OVER INTERNET - 2")
                    self.checkMessageReceivedTime()
                }else {
                    print("API CALLING error")
                    self.readFromBLE = false
                    if self.isBackGroundSyncStart == true {
                        self.isBackGroundSyncStart = false
                        self.syncStatusMessageUpdate(message:"Trying to Connect over Bluetooth")
                        self.readCurrentDeviceBleData()
                    }else {
                        self.isBackGroundSyncStart = false
                        self.readCurrentDeviceBleData()
                    }
                }
            }
        }else {
            self.hideActivityIndicator(self.view)
            // Helper.shared.removeBleutoothConnection()
            self.readFromBLE = false
            if self.isBackGroundSyncStart == true {
                self.isBackGroundSyncStart = false
                self.syncStatusMessageUpdate(message:"Trying to Connect over Bluetooth")
                self.readCurrentDeviceBleData()
            }else {
                self.isBackGroundSyncStart = false
                self.readCurrentDeviceBleData()
            }
            
        }
    }
    
    
    func reloadDataCurrentIndexLogData(isFromAppdelgate:Bool = false) {
        Helper.shared.removeBleutoothConnection()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.hideActivityIndicator(self.view)
            print("hide8")
        }
        
        if isFromAppdelgate == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.syncStatusMessageUpdate(message:"Data is Refreshed")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            if ((self.arrMyLuftDeviceList?.count ?? 0) > 0) {
                self.reloadTblData()
//            }
        }
        
        //self.tblDeviceCollection?.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        if isFromAppdelgate == true {
            self.syncStatusMessageUpdate(message:"Data is Refreshed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.syncStatusMessageUpdate(message:"")
                self.removeJifImage()
            }
        }
        
       
    }
    
    
    func bleDataStatusMessage(message:String = "") {
        self.syncStatusMessageUpdate(message:message)
    }
    
    func readCurrentDeviceBleData()  {
        if self.isDashBoard == false {
            return
        }
        self.syncStatusMessageUpdate(message:"Trying to Connect over Bluetooth")
        
        self.readFromBLE = true
        self.isDeviceTimeDiffUpdate = false
        Helper.shared.removeBleutoothConnection()
        BackgroundBLEManager.shared.centralManager?.stopScan()
        BackgroundBLEManager.shared.isFromAddDevice =  false
        BackgroundBLEManager.shared.centralManager = nil
        BackgroundBLEManager.shared.strDeviceSerialID = getCurrentSelectedDevice()?.serial_id ?? ""
        BackgroundBLEManager.shared.strDeviceID = self.getCurrentSelectedDevice()?.device_id ?? 0
        BackgroundBLEManager.shared.deviceLogIndexStatusDelgate = self
        BackgroundBLEManager.shared.didUpdate = 0
        BackgroundBLEManager.shared.isBleConnectState = false
        BackgroundBLEManager.shared.isBleCharacteristicsState = false
        BackgroundBLEManager.shared.connectBlueTooth(blueToothName: self.getCurrentSelectedDevice()?.serial_id ?? "", bleFeature: .BlueToothFeatureLogCurrentIndexWrite)
        BackgroundBLEManager.shared.isBleBackGroundSyncDevice = true
        if self.getCurrentSelectedDevice()?.wifi_status != true {
            UserDefaults.standard.set(self.getCurrentSelectedDevice()?.device_id, forKey: "Selected_DeviceID")
            UserDefaults.standard.set(self.getCurrentSelectedDevice()?.serial_id, forKey: "Selected_DeviceName")
            UserDefaults.standard.set(self.getCurrentSelectedDevice()?.wifi_status, forKey: "Selected_DeviceName_WIFI")
        }
        
        self.bleStatesDelegate()
    }
    
    func syncStatusMessageUpdate(message:String)  {
        
        if self.isDashBoard == false {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        if  self.tblDeviceCollection.cellForRow(at: indexPath) != nil {
            let statusCell: DeviceStatusTableViewCell = self.tblDeviceCollection.cellForRow(at: indexPath) as! DeviceStatusTableViewCell
            if message == "Trying to Connect over Bluetooth"{
                statusCell.imgViewBluWifi.image = UIImage.init(named: "bluetooth")
                statusCell.imgViewBluWifi.alpha = 0.5
            }
            
            if message == "Device Connected in BLE"{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    statusCell.imgViewBluWifi.image = UIImage.init(named: "bluetooth")
                    statusCell.imgViewBluWifi.alpha = 1.0
                }
            }
            
            if message == "Receiving the latest data over Bluetooth"{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    statusCell.imgViewBluWifi.image = UIImage.init(named: "bluetooth")
                    statusCell.imgViewBluWifi.alpha = 1.0
                }
            }
            if  message == "Data is Refreshed" {
                statusCell.imgViewBluWifi.alpha = 1.0
                if self.getCurrentSelectedDevice()?.wifi_status == true {
                    statusCell.imgViewBluWifi.image = UIImage.init(named: "wifiimg")
                }else {
                    statusCell.imgViewBluWifi.image = UIImage.init(named: "bluetooth")
                }
            }
            
            if  message == "Couldn't connect device over bluetooth. Try again later." {
                statusCell.imgViewBluWifi.alpha = 1.0
                if self.getCurrentSelectedDevice()?.wifi_status == true {
                    statusCell.imgViewBluWifi.image = UIImage.init(named: "wifiimg")
                }else {
                    statusCell.imgViewBluWifi.image = UIImage.init(named: "bluetooth")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.reloadTblData()
                }
                //self.tblDeviceCollection?.reloadData()
            }
            if  message == "BLE Not connect" {
                statusCell.lblDeviceConnectStatus.text = ""
                self.removeJifImage()
                return
            }
            statusCell.lblDeviceConnectStatus.text = message
        }
        
        
    }
}
extension LuftDeviceViewController: AllReadingDelegate {
    
    func getallBackGroundWifiReadingStatus(update:Bool){
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
        //            self.hideActivityIndicator(self.view)
        //        }
        //self.reloadDataCurrentIndexLogData()
        //BackgroundDataAPIManager.shared.isCompleted = true
        //self.getBluetoothUpperBoundLogData()
        BackgroundDataAPIManager.shared.isCompleted = true
        self.reloadDataCurrentIndexLogData()
    }
    
}
//Slide Menu
extension LuftDeviceViewController: LTSideMenuDelegate,SSIDWriteDelegate {
    
    func writeSSIDSocketURL() {
        //Helper.shared.showSnackBarAlert(message: "Write Inprogress", type: .InfoOrNotes)
        //self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        //if self.writeRemoveWifiIndex == 5 {
        // self.reMoveWifiStatus()
        //}
    }
    
    func writeSSIDCloudWebURL() {
        // Helper.shared.showSnackBarAlert(message: "Wi-Fi Connection Inprogress", type: .InfoOrNotes)
        //self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        //if self.writeRemoveWifiIndex == 5 {
        // self.reMoveWifiStatus()
        //}
    }
    
    func writeSSIDSocketAuthToken() {
        //Helper.shared.showSnackBarAlert(message: "Wi-Fi Connection Inprogress", type: .InfoOrNotes)
        //self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        //if self.writeRemoveWifiIndex == 5 {
        //self.reMoveWifiStatus()
        //}
    }
    
    func writeSSIDName() {
        //Helper.shared.showSnackBarAlert(message: "Wi-Fi Connection Inprogress", type: .InfoOrNotes)
        self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        if self.writeRemoveWifiIndex == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
            }
            self.reMoveWifiStatus()
        }
        print("Message sent")
    }
    func writeSSIDPassword(){
        self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        if self.writeRemoveWifiIndex == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
            }
            self.reMoveWifiStatus()
        }
        print("Message sent")
    }
    
    func reMoveWifiStatus()  {
        textLog.write("BLE VIA - REMOVE SSID PROCESS COMPLETED")
        
        self.isReMoveWifiStart = 0
        self.updateDeviceState(isWifi: false)
    }
    
    func selectedMenuID(sideMenuType: SideMenuType) {
        self.isMenuPressed = 0
        switch sideMenuType{
        case SideMenuType.SideMenuRename:
            self.showMenuRenameDevice()
            break
        case SideMenuType.SideMenuNotification:
            self.showToNotificationDashBoard()
            break
        case SideMenuType.SideMenuFrimware:
            self.getFWVersionAPI(isFromIntial: false)
            break
        case SideMenuType.SideMenuRemoveDevice:
            self.showToRemoveDevice()
            break
        case SideMenuType.SideMenuConnectToWifi:
            self.showToConnecetToWiFi()
            break
        case SideMenuType.SideMenuRemoveToWifi:
            self.showToRemoveWifi()
            break
        case SideMenuType.SideMenuShareData:
            if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
                if deviceDataCurrent.shared_user_email == ""{
                    self.showToShareDataAlert()
                }else {
                    self.moveToShareEMailView()
                }
            }
            break
        case SideMenuType.SideMenuTempOffset:
            self.showToTempoffset()
            break
        case SideMenuType.SideMenuFAQ:
            self.showToFAQ()
            break
        case SideMenuType.SideMenuContactSupport:
            UIApplication.shared.open(URL(string: CONTACT_SUPPORT)!)
            
            break
        default:
            break
        }
        
    }
    
    func showMenuRenameDevice()  {
        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
            let titleString = NSAttributedString(string: "Rename your Device", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let message = String(format: "Enter a new new name for the device %@", deviceDataCurrent.name)
            let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.setValue(titleString, forKey: "attributedTitle")
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Device Name"
            }
            alert.setValue(messageString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Save", style: .default, handler: { action in
                if (alert.textFields ?? []).count > 0 {
                    let firstTextField = alert.textFields![0]
                    let deviceName = self.removeWhiteSpace(text: firstTextField.text ?? "")
                    self.strRenameDevice = deviceName
                    self.renameDeviceAPI()
                }
            })
            alert.addAction(ok)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            })
            alert.addAction(cancel)
            alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }
    }
    
    func showToFirmWare() {
        
        if self.getCurrentSelectedDevice()?.firmware_version.lowercased().filter("1234567890".contains) == strFirmwareVesrion.lowercased().filter("1234567890".contains) {
            let titleString = NSAttributedString(string: "Your Device is Up to Date!", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let messageString = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
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
        }else if self.getCurrentSelectedDevice()?.wifi_status == true {
            let titleString = NSAttributedString(string: "Firmware Update Available", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let messageString = NSAttributedString(string: "Update Now?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.setValue(titleString, forKey: "attributedTitle")
            alert.setValue(messageString, forKey: "attributedMessage")
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.updateFirmWare()
            })
            alert.addAction(yes)
            let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
                
            })
            alert.addAction(cancel)
            alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }else {
            let titleString = NSAttributedString(string: "Firmware Update Available", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let messageString = NSAttributedString(string: "Please, connect following devices to Wi-Fi first to enable Firmware Update.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
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
        }
    }
    
    func updateFirmWare() {
        if Reachability.isConnectedToNetwork() == true {
            self.showAct()
            SwaggerClientAPI.basePath =  getDeviceGetAPIBaseUrl()
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
            var arr:[UpdateFirmware] = []
            arr.append(UpdateFirmware.init(deviceID: Int64(self.getCurrentSelectedDevice()?.device_id ?? 0)))
            DeviceAPI.apiDeviceInitiativeFirewareVserionPost(deviceDetails: arr, completion: { (error) in
                self.hideActivityIndicator(self.view)
                SwaggerClientAPI.basePath =  getAPIBaseUrl()
                print("hide18")
                if error == nil {
                    self.fwIntiatedMsg()
                    //Helper.shared.showSnackBarAlert(message: FW_COMPLETED_UPDATE_INITIATED, type: .Success)
                }else {
                    Helper.shared.showSnackBarAlert(message: error.debugDescription, type: .Failure)
                }
            })
        }else {
            SwaggerClientAPI.basePath =  getAPIBaseUrl()
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    
    func showToNotificationDashBoard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcLTDashBoard = storyboard.instantiateViewController(withIdentifier: "LTDashBoardNotificationViewController") as! LTDashBoardNotificationViewController
        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
            vcLTDashBoard.isSelectDeviceID = deviceDataCurrent.device_id
            self.luftDashBoardDeviceIDPrevious = deviceDataCurrent.device_id
        }
        self.isReLoad = true
        self.navigationController?.pushViewController(vcLTDashBoard, animated: true)
    }
    
    func showToConnecetToWiFi() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcMYDeviceData = storyboard.instantiateViewController(withIdentifier: "AvilableNetworkViewController") as! AvilableNetworkViewController
        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
            vcMYDeviceData.avilableDeviceID = deviceDataCurrent.device_id
            vcMYDeviceData.serialDeviceName = deviceDataCurrent.serial_id
            self.luftDashBoardDeviceIDPrevious = deviceDataCurrent.device_id
        }
        self.isReLoad = true
        self.isReMoveWifiStart = 1
        self.navigationController?.pushViewController(vcMYDeviceData, animated: false)
        
        /*Future New Good
         vcMYDeviceData.editedDeviceName = self.txtDeviceName?.text ?? ""
         vcMYDeviceData.connectSSIDPeripheral = connectPeripheral
         vcMYDeviceData.avilableDeviceID = self.defaultDeviceID
         vcMYDeviceData.avilableAddDelegate = self*/
    }
    
    func showToTempoffset() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcTempOffset = storyboard.instantiateViewController(withIdentifier: "TempOffsetViewController") as! TempOffsetViewController
        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
            vcTempOffset.isDeviceSelected = deviceDataCurrent
            self.luftDashBoardDeviceIDPrevious = deviceDataCurrent.device_id
        }
        self.isReLoad = true
        self.navigationController?.pushViewController(vcTempOffset, animated: false)
    }
    
    func showToFAQ() {
        guard let url = URL(string: LIVE_SUN_RADON_FAQ_URL) else { return }
        UIApplication.shared.open(url)
    }
    
    func showToShareDataAlert() {
        let titleString = NSAttributedString(string: "Share Data", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let message = String(format: "Enter the email address of the professional tester you would like to share data with.")
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Email Address"
            
        }
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Add", style: .default, handler: { action in
            if (alert.textFields ?? []).count > 0 {
                let firstTextField = alert.textFields![0]
                self.strShareEmailID = self.removeWhiteSpace(text: firstTextField.text ?? "")
                let password = self.removeWhiteSpace(text:"Augusta@123")
                let isValidated = self.validate(emailId: self.strShareEmailID, password: password)
                if isValidated.0 == true  {
                    self.callShareEmailIDapi()
                }else {
                    Helper.shared.showSnackBarAlert(message: isValidated.1, type: .Failure)
                }
            }
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func showToRemoveWifi() {
        let titleString = NSAttributedString(string: "Remove Wi-Fi", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor]) //"Are you sure you Remove wifi."
        
        let messageString = NSAttributedString(string:"Are you sure you want to remove Wi-Fi?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.isRemoveWifiCalledManually = true;
            self.dashBrdRemoveWIFIIntailCheckCount = 0
            self.scanCheckCount = 0
            self.scanBLEDevices()
            
            if macAddressSerialNo == ""{
                self.readSerialNumber()
            }

        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
        
        
    }
    
    func validate(emailId: String, password: String) -> (Bool, String) {
        var isValidationSuccess = true
        var message:String = ""
        if emailId.count == 0{
            message = CONTENT_EMPTY_USERNAME
            isValidationSuccess = false
        } else if Helper.shared.isValidEmailAddress(strValue: emailId) == false {
            message = CONTENT_INVALID_EMAIL
            isValidationSuccess = false
        } else if password.count == 0{
            message = CONTENT_EMPTY_PASSWPRD
            isValidationSuccess = false
        }
        else if Helper.shared.isValidPassword(strValue: password) == false {
            message = CONTENT_CHAR_PASSWORD
            isValidationSuccess = false
        }
        else if Helper.shared.isCharValidPassword(password: password) == false {
            message = CONTENT_CHAR_PASSWORD
            isValidationSuccess = false
        }
        return (isValidationSuccess, message)
    }
    
    func moveToShareEMailView()  {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcShareDataEmail = storyboard.instantiateViewController(withIdentifier: "ShareDataEmailViewController") as! ShareDataEmailViewController
        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
            vcShareDataEmail.currentDeviceID = deviceDataCurrent.device_id
            vcShareDataEmail.currentEmailID = deviceDataCurrent.shared_user_email
            self.luftDashBoardDeviceIDPrevious = deviceDataCurrent.device_id
        }
        self.isReLoad = true
        self.navigationController?.pushViewController(vcShareDataEmail, animated: false)
    }
    
    func showToRemoveDevice() {
        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
            let titleString = NSAttributedString(string: "Remove Device", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let msg = String(format:"Are you sure you would like to remove this device - %@?",deviceDataCurrent.name)
            let messageString = NSAttributedString(string: msg, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.setValue(titleString, forKey: "attributedTitle")
            alert.setValue(messageString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.removeDeviceAPI()
            })
            alert.addAction(ok)
            let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
                
            })
            alert.addAction(cancel)
            alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }
        
    }
    
    func renameDeviceAPI() {
        self.showActivityIndicator(self.view)
        if self.strRenameDevice.count != 0 {
            if Reachability.isConnectedToNetwork() == true {
                SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
                AppUserAPI.apiAppUserRenamePost(model: RenameDeviceViewModel.init(name:self.strRenameDevice, deviceId: Int64(self.getCurrentSelectedDevice()?.device_id ?? 0)), completion: {(error) in
                    self.hideActivityIndicator(self.view)
                    print("hide19")
                    if error == nil {
                        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
                            self.luftDashBoardDeviceIDPrevious = deviceDataCurrent.device_id
                        }
                        Helper().showSnackBarAlert(message: "Rename device sucessfully", type: .Success)
                        self.callMyDeviceAPI()
                    }else {
                        Helper().showSnackBarAlert(message: "Rename device Failure", type: .Failure)
                    }
                })
            }else {
                Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
                UIApplication.shared.endIgnoringInteractionEvents()
                self.hideActivityIndicator(self.view)
                print("hide20")
            }
        }else {
            Helper.shared.showSnackBarAlert(message: "Invalid device name", type: .Failure)
        }
    }
    
    func callShareEmailIDapi(){
        self.showActivityIndicator(self.view)
        if Reachability.isConnectedToNetwork() == true {
            AppSession.shared.setCurrentDeviceToken(self.getCurrentSelectedDevice()?.device_token ?? "")
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            MobileApiAPI.apiMobileApiSharedHomeDevicePost(email: self.strShareEmailID, deviceId: Int64(self.getCurrentSelectedDevice()?.device_id ?? 0)) { (responses, error) in
                self.hideActivityIndicator(self.view)
                print("hide21")
                if responses?.success == true {
                    self.callMyDeviceAPI()
                    self.showShareDataAlert(message: responses?.message ?? "")
                }else {
                    self.showShareDataAlert(message: responses?.message ?? "")
                }
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            UIApplication.shared.endIgnoringInteractionEvents()
            self.hideActivityIndicator(self.view)
            print("hide22")
        }
    }
    
    func removeDeviceAPI()  {
        self.showAct()
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserRemoveDelete(deviceId: Int64(self.getCurrentSelectedDevice()?.device_id ?? 0), completion:  { (error) in
            if error == nil {
                Helper.shared.showSnackBarAlert(message: "Device removed Succesfully", type: .Success)
                self.isSelectedDeviceRow = 0
                AppSession.shared.setPrevSelectedDeviceID(prevSelectedDevice: -100)
                RealmDataManager.shared.removeDeviceUpdate(deviceID: self.getCurrentSelectedDevice()?.device_id ?? 0)
                self.callDeviceDetailsTypeApi(isUpdateDummy: false)
            }else {
                self.hideActivityIndicator(self.view)
                print("hide23")
                Helper.shared.showSnackBarAlert(message: "Device removed faliure", type: .Failure)
            }
        })
    }
    
    func getBluetoothUpperBoundLogData() {
        
        Helper.shared.removeBleutoothConnection()
        let deviceDataID = UserDefaults.standard.object(forKey: "Selected_DeviceID")
        let deviceDataNameID = UserDefaults.standard.object(forKey: "Selected_DeviceName")
        
        if deviceDataNameID != nil && deviceDataID != nil {
            BackgroundBLEManager.shared.isFromAddDevice =  false
            BackgroundBLEManager.shared.strDeviceSerialID = deviceDataNameID as! String
            BackgroundBLEManager.shared.strDeviceID = deviceDataID as! Int
            BackgroundBLEManager.shared.didUpdate = 0
            BackgroundBLEManager.shared.blueToothFeatureType = .BlueToothUpperBound
            BackgroundBLEManager.shared.mainPeripheral.discoverServices([])
            BackgroundBLEManager.shared.connectBlueTooth(blueToothName: deviceDataNameID as! String, bleFeature: .BlueToothLowerBound)
            BackgroundBLEManager.shared.backGroundBleSyncCompletedDelegate = self
            BackgroundBLEManager.shared.isBleBackGroundSyncDevice = false
            textLog.write("Background Sync Get App Upper log index - 1")
            self.bleStatesDelegate()
        }
        
    }
    
    func updateDeviceState(isWifi:Bool)  {
        self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
        let updateWifiState = UpdateDeviceModel.init(deviceId: Int64(self.getCurrentSelectedDevice()?.device_id ?? 0), wifiStatus: isWifi, timeDifference: Helper.shared.getTimeDiffBetweenTimeZone(), timeZone: self.getCurrentTimeZoneShortName(), deviceTimeZoneFullName: Helper.shared.getCurrentTimeZoneinIANAFormat(), macAddress: macAddressSerialNo)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
        MobileApiAPI.apiMobileApiUpdateWifiStatusPost(model: updateWifiState, completion: { (respones, error) in
            if respones?.success == true {
                if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
                    self.luftDashBoardDeviceIDPrevious = deviceDataCurrent.device_id
                }
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.checkWithWifiBLE()
                }
            }else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.hideActivityIndicator(self.view)
                    print("hide24")
                }
                Helper().showSnackBarAlert(message: "Failed to remove Wi-Fi settings", type: .Failure)
            }
        })
    }
    
    func checkWithWifiBLE()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
        }
        
        if BluetoothManager.shared.mainPeripheral.state == .disconnected{
            self.isWifiUpdate = 0
            BluetoothManager.shared.connectBlueTooth(blueToothName: self.getCurrentSelectedDevice()?.serial_id ?? "", bleFeature: .BlueToothFeatureWifiStatus)
            BluetoothManager.shared.deviceWifiStatusDelgate = self
        }else {
            if BluetoothManager.shared.mainPeripheral != nil {
                self.isWifiUpdate = 0
                BluetoothManager.shared.blueToothFeatureType = .BlueToothFeatureWifiStatus
                BluetoothManager.shared.deviceWifiStatusDelgate = self
                BluetoothManager.shared.mainPeripheral.discoverServices([LUFT_WIFI_SERVICE_STATUS])
            }
        }
        
    }
    
}

extension LuftDeviceViewController: UISearchBarDelegate,LTSearchDeviceDelegate,WIFIStatusDelegate {
    
    
    
    func wifiStatusCheck(wifiDeviceStaus:String) {
        if self.isWifiUpdate == 0{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
            }
            self.isWifiUpdate = 1
            self.wifiDeviceStatus = WIFIDEVICESTATUS(rawValue: wifiDeviceStaus) ?? .WIFI_NOT_CONNECTED
            switch self.wifiDeviceStatus {
            case .WIFI_CONNECTED,.WIFI_INTERNET,.ICD_WIFI_CONNECTED,.ICD_WIFI_INTERNET,.ICD_WIFI_CLOUD:
                break
            case .WIFI_NOT_CONNECTED,.WIFI_CONNECTING,.ICD_WIFI_CONNECTING,.ICD_WIFI_FAULT,.ICD_WIFI_AUTHENTICATED:
                break
            }
            if wifiDeviceStaus == "-1.0" {
            }
            print(self.wifiDeviceStatus)
            self.callMyDeviceAPI()
            Helper().showSnackBarAlert(message: "Wi-Fi Removed Successfully", type: .Success)
        }
        
    }
    
    func selectedDeviceID(deviceID: Int) {
        self.removeSearchView()
        if deviceID != -100 {
            self.deviceSelectedDevice(deviceID: deviceID)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.showSearchView()
        return false
    }
    
    func showSearchView()  {
        self.textSearch?.isHidden = true
        self.tblDeviceCollection?.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.searchDeviceViewController = storyboard.instantiateViewController(withIdentifier: "SearchDeviceViewController") as? SearchDeviceViewController
        self.searchDeviceViewController?.view.frame.size.height = self.backViewStackView.bounds.size.height
        self.searchDeviceViewController?.view.frame.size.width = self.backViewStackView.bounds.size.width
        self.searchDeviceViewController?.deviceSearchDelgate = self
        self.backViewStackView.addSubview((self.searchDeviceViewController?.view)!)
        
    }
    
    func removeSearchView()  {
        self.textSearch?.isHidden = false
        self.tblDeviceCollection?.isHidden = false
        self.textSearch?.text = ""
        self.searchDeviceViewController?.view.removeFromSuperview()
        if self.searchDeviceViewController != nil{
            self.searchDeviceViewController = nil
            self.searchDeviceViewController?.view.removeFromSuperview()
        }
    }
    
    func customizeSearchBar()  {
        self.textSearch?.setTextField(color: ThemeManager.currentTheme().ltSearchViewBackGroundColor)
        self.textSearch?.setTextFieldColor(color: ThemeManager.currentTheme().ltSettingTxtColor)
        self.textSearch?.setSearchBorderTextFieldColor(color: ThemeManager.currentTheme().searchBorderColor)
        self.textSearch?.setPlaceholderTextFieldColor(color: ThemeManager.currentTheme().ltSearchPlaceHolderTextColor)
        self.textSearch?.setSearchBorderImageColor(color:ThemeManager.currentTheme().ltSearchPlaceHolderTextColor)
        self.textSearch?.barTintColor = ThemeManager.currentTheme().viewBackgroundColor
    }
}

extension LuftDeviceViewController: LTFliterDelegate,FliterSelectedDelegate {
    
    func fliterSelectedDelegate(deviceID:Int){
        self.showPresentFilter()
    }
    
    func selectedFliter(fliterMenuType:Int) {
        self.luftDashBoardDeviceIDPrevious = -100
        self.getDeviceList(isAPICall: false)
    }
    
    func getSortArrayValues(arrayValue:[RealmDeviceList]) -> [RealmDeviceList] {
        
        self.arrCompletedReadDeviceData.removeAll()
        let sortFilterType: Int = AppSession.shared.getUserSortFilterType()
        switch sortFilterType {
        case SortFilterTypeEnum.SortDeviceNameAscending.rawValue:
            self.arrCompletedReadDeviceData = arrayValue.sorted(by: {
                $0.name < $1.name })
            return self.arrCompletedReadDeviceData
            
        case SortFilterTypeEnum.SortDeviceNameDescending.rawValue:
            self.arrCompletedReadDeviceData = arrayValue.sorted(by: {
                $0.name > $1.name })
            return self.arrCompletedReadDeviceData
            
        case SortFilterTypeEnum.SortUpdateByNameAscending.rawValue:
            self.arrUpdateByDeviceList.removeAll()
            for arrData in arrayValue {
                let polluTantData:[RealmPollutantValuesTBL] = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: arrData.device_id)
                self.arrUpdateByDeviceList.append(UpdateByDeviceList.init(deviceData: arrData, updateBy: polluTantData[0].timeStamp))
            }
            self.arrUpdateByDeviceList = arrUpdateByDeviceList.sorted(by: {
                $0.updateBy < $1.updateBy })
            
            for arrDeviceData in self.arrUpdateByDeviceList {
                self.arrCompletedReadDeviceData.append(arrDeviceData.deviceData)
            }
            return self.arrCompletedReadDeviceData
            
        case SortFilterTypeEnum.SortUpdateByNameDescending.rawValue:
            self.arrUpdateByDeviceList.removeAll()
            for arrData in arrayValue {
                let polluTantData:[RealmPollutantValuesTBL] = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: arrData.device_id)
                self.arrUpdateByDeviceList.append(UpdateByDeviceList.init(deviceData: arrData, updateBy: polluTantData[0].timeStamp))
            }
            self.arrUpdateByDeviceList = arrUpdateByDeviceList.sorted(by: {
                $0.updateBy > $1.updateBy })
            for arrDeviceData in self.arrUpdateByDeviceList {
                self.arrCompletedReadDeviceData.append(arrDeviceData.deviceData)
            }
            return self.arrCompletedReadDeviceData
            
        default:
            self.arrCompletedReadDeviceData = arrayValue.sorted(by: {
                $0.name < $1.name })
            return self.arrCompletedReadDeviceData
        }
    }
}

extension LuftDeviceViewController: DeviceMEAPIDelegate {
    
    func callMyDeviceAPI()  {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.showAct()
        self.callDeviceDetailsTypeApi(isUpdateDummy: false)
    }
    
    func deviceDataAPIStatus(update:Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideActivityIndicator(self.view)
            print("hide25")
        }
        UIApplication.shared.endIgnoringInteractionEvents()
        self.backGroundDatafetch()
        BackgroundDataAPIManager.shared.individualData = nil
        BackgroundDataAPIManager.shared.individualData = self
    }
    
    func backGroundDatafetch()  {
        if BackgroundDataAPIManager.shared.isCompleted == true {
            //BackgroundDataAPIManager.shared.individualData = self
            self.getDeviceBackSync()
            self.callSyncWifiBackGroundModeDeviceDetails()
        }else {
            self.hideActivityIndicator(self.view)
            return
        }
    }
    
}

extension LuftDeviceViewController : IndividualDeviceReadingDelegate {
    func indDeviceReadingDelegate(){
        self.getDeviceBackSync()
    }
    
    func getDeviceBackSync() {
        if  let deviceDataSerialNameID = UserDefaults.standard.object(forKey: "Selected_DeviceName_SerialID") {
            if (RealmDataManager.shared.getDataDeviceDataValues(deviceSerialID: deviceDataSerialNameID as! String)) {
//                self.hidelblLoading()
//                if self.isShowData == true {
//                    self.showDataValues()
//                    self.isShowData = false
//                }
            }else {
                //self.lblLoadingData()
            }
        }
    }
}



extension LuftDeviceViewController {
    
    
    func callDeviceDetailsTypeApi(isUpdateDummy:Bool){
        if Reachability.isConnectedToNetwork() == true {
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            AppUserAPI.apiAppUserGetMyDevicesGet { (response, error) in
                if error == nil {
                    if let responseValue = response,responseValue.count > 0 {
                        self.arrMyDeviceList?.removeAll()
                        self.arrMyDeviceList = responseValue
                        RealmDataManager.shared.deleteDeviceRelamDataBase()
                        //RealmDataManager.shared.deleteRelamSettingColorDataBase()
                        RealmDataManager.shared.insertDeviceDataValues(arrDeviceData: self.arrMyDeviceList!)
                        if isUpdateDummy ==  true {
                            RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
                            RealmDataManager.shared.insertDummyDeviceDataValues(arrDeviceData: self.arrMyDeviceList!)
                            RealmDataManager.shared.insertCoreDataDeviceDataValues(arrDeviceData: self.arrMyDeviceList!)
                        }
                        RealmDataManager.shared.insertRadonValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertTemperatureValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertHumidityValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertAirPressureValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertVOCValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertECO2Values(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertOKColorValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertWarningColorValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertAlertColorValues(arrDeviceData: self.arrMyDeviceList!)
                        RealmDataManager.shared.insertNightLightColorValues(arrDeviceData: self.arrMyDeviceList!)
                    }else {
                        //                            RealmDataManager.shared.deleteDeviceRelamDataBase()
                        //                            RealmDataManager.shared.deleteRelamSettingColorDataBase()
                        //                            RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
                    }
                    self.getDeviceList(isAPICall: false)
                    self.deviceDataAPIStatus(update: true)
                    
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    self.hideActivityIndicator(self.view)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
        else{
            self.hideActivityIndicator(self.view)
            print("hide26")
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
//Mark: - SRWebSocketdelegate
extension LuftDeviceViewController : SRWebSocketDelegate {
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        self.webSocket = webSocket
        delegateSocket?.connectionSuccessfull(sucess: true)
        textLog.write("WEB SOCKET MESSAGE - CONNECTION OPEN")
        print("WEB SOCKET MESSAGE - CONNECTION OPEN")
    }
    
    func connectWebSocket()  {
        if (self.webSocket == nil){
            
            DispatchQueue.main.async(execute: {
                self.webSocket?.delegate = nil;
                self.webSocket = nil
                let strSocketUrl = String(format: "%@=%@", getSocketBaseUrl(), AppSession.shared.getAccessToken().stringByAddingPercentEncodingForRFC3986()!)
                let url = URL(string: strSocketUrl)!
                print("User Token")
                print(AppSession.shared.getAccessToken())
                let requestSocket = URLRequest(url: url)
                self.webSocket = SRWebSocket(urlRequest: requestSocket)
                self.webSocket?.delegate = self
                self.webSocket?.open()
                textLog.write("WEB SOCKET MESSAGE - CONNECTION OPEN")
            })
            
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        
        print(message ?? "")
        let msgValue1 = message as! String
//        if let msgValue1:String  = message as! String {
            if msgValue1 == "Welcome to Sun Nuclear Web Engine"{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.WiFiBlELatestDataSync()
                }
            }else {
                DispatchQueue.main.async(execute: {() -> Void in
                    if UIApplication.shared.applicationState == .active {
                        
                        if self.isDashBoard == false {
                            return
                        }
                        
                        let data = (message as AnyObject).data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
                        let jsonData = (try? JSONSerialization.jsonObject(with: data ?? Data(), options: [])) as? NSDictionary
                        var dataValue : JSON = JSON(jsonData as AnyObject)
                        let msgValue:String  = WebSocketReceivedType(rawValue: dataValue["Message"].stringValue)?.rawValue ?? ""
                        if msgValue == "" {
                            textLog.write("WEB SOCKET MESSAGE EMPTY or NIl")
                            return
                        }
                        switch msgValue{
                        case WebSocketReceivedType.latestreadingsavailable.rawValue:
                            if (self.webSocket != nil){
                                self.timerSynMsg.invalidate()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                                    self.syncStatusMessageUpdate(message:"Receiving the latest data")
                                }
                                APIManager.shared.latestReadingDelegate = self
                                APIManager.shared.callDeviceLatestReadingAPI()
                                //self.webSocket = nil
                                self.isMsgReceived = true
                                textLog.write("WEB SOCKET MESSAGE RECEIVED")
                            }
                            break
                        case WebSocketReceivedType.updatesettings.rawValue:
                            if (self.webSocket != nil){
                                self.timerSynMsg.invalidate()
                                self.showActivityIndicator(self.view)
                                self.callMyDeviceAPI()
                                //self.webSocket = nil
                                self.isMsgReceived = false
                                textLog.write("WEB SOCKET MESSAGE RECEIVED - DEVICE UPDATE")
                            }
                            break
                        case WebSocketReceivedType.updatefirmware.rawValue:
                            textLog.write("WEB SOCKET MESSAGE RECEIVED - FIRMWARE")
                            return
                            break
                        default:
                            textLog.write("WEB SOCKET MESSAGE RECEIVED - FAIL")
                            self.isMsgReceived = false
                            break
                        }
                        let message = (try? JSONSerialization.jsonObject(with: data ?? Data(), options: [])) as? [AnyHashable: Any]
                        print(message ?? "")
                    }
                    } as @convention(block) () -> Void);
            }
//        }
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        print(error.localizedDescription + "didFailWithError")
        textLog.write("WEB SOCKET MESSAGE - CONNECTION FailWithError")
        //self.connectWebSocket()
        self.webSocket = nil
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("code: %ld reason: %@ wasClean:",code,reason ?? "")
        textLog.write("WEB SOCKET MESSAGE - CONNECTION CLOSE")
        
        //webSocket.close()
        self.webSocket = nil
        //self.connectWebSocket()
    }
    
    func checkSocketStatus() {
        //self.webSocket = nil
        if (webSocket?.readyState.hashValue == 2 || webSocket?.readyState.hashValue ==  3 || webSocket == nil)
        {
            //webSocket?.close()
            self.webSocket = nil
            self.connectWebSocket()
        }
        else if (webSocket?.readyState.hashValue == 0) {
            //self.webSocket?.open()
            print("Connecting")
        }else if webSocket?.readyState.hashValue ==  1 {
            print("Open")
        }else {
            if self.webSocket != nil{
                
            }else {
                //  self.connectWebSocket()
            }
        }
        //print(webSocket?.readyState.hashValue)
    }
    
    func checkMessageReceivedTime() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.syncStatusMessageUpdate(message:"Waiting for response from device")
            textLog.write("REQUEST LATEST DATA OVER INTERNET - Waiting for response")
        }
        self.timerSynMsg.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.timerSynMsg = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: false)
            self.isSocketSuccess = true
        })
    }
    
    @objc func timerAction() {
        self.timerSynMsg.invalidate()
        if self.isMsgReceived == true {
            if self.isSocketSuccess != true {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.isMsgReceived == true{
                }else {
                    self.bleDataStatusMessage(message: "Couldn't reach Device over Internet.")
                }
                //self.webSocket = nil
                self.isBackGroundSyncStart = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                    textLog.write("FAIL INTERNET - CONNECT BLE AFTER 20 Secs")
                    self.readCurrentDeviceBleData()
                }
            }
        }else {
            if self.isSocketSuccess != true {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.bleDataStatusMessage(message: "Couldn't reach Device over Internet.")
                //self.webSocket = nil
                self.isBackGroundSyncStart = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                    textLog.write("FAIL INTERNET - CONNECT BLE AFTER 20 Secs")
                    self.readCurrentDeviceBleData()
                }
            }
        }
    }
}
extension LuftDeviceViewController: LatestReadingDelegate {
    
    
    func getLatestReadingStatus(update: Bool) {
        if self.isDashBoard == false {
            return
        }
        if update == true {
            self.reloadDataCurrentIndexLogData(isFromAppdelgate:true)
        }else {
            self.isBackGroundSyncStart = false
            self.readCurrentDeviceBleData()
        }
    }
    
    func showAct() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.showActivityIndicator(self.view)
        }
    }
}
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}

// MARK: BLE Scanning
extension LuftDeviceViewController:CBCentralManagerDelegate,BLEWriteStateDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .poweredOn:
            intPermissionDisplay = -1
            central.scanForPeripherals(withServices: nil, options: nil)
        default:
            print("Please turn on bluetooth")
            if intPermissionDisplay == 0 {
                //Make new alert message for allow permission
                let titleString = NSAttributedString(string: "Bluetooth Permission", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
                let message = String(format: "The app requires Bluetooth for initial device setup, Wi-Fi configuration, and as backup to transfer data when Wi-Fi is not available.")
                let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
                let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                alert.setValue(titleString, forKey: "attributedTitle")
                alert.setValue(messageString, forKey: "attributedMessage")
                
                alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                        
                    }))

                alert.addAction(UIAlertAction(title: "SETTINGS", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                    UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }))
                alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
                self.present(alert, animated: true, completion: nil)
              
            } else {
                Helper.shared.showSnackBarAlert(message: "Please turn on bluetooth", type: .Success)
            }
            break
        }
    }
    
    func scanBLEDevices() {
        self.peripherals.removeAll()
        Helper.shared.removeBleutoothConnection()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Trying to connect device via BLE")
        }
        self.manager = CBCentralManager(delegate: self, queue: nil)
        self.isReMoveWifiStart = 1
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if self.scanCheckCount != 30 {
                self.hideActivityIndicator(self.view)
                print("hide27")
                self.stopScanForBLEDevices()
                self.bluetoothConnectionErrorAlert()
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
        
      
        if self.peripherals.contains(where: { $0.name == self.getCurrentSelectedDevice()?.serial_id }) == true {
            self.scanCheckCount = 30
            self.stopScanForBLEDevices()
            debugPrint("remove wifi area called")
            if isRemoveWifiCalledManually{
                debugPrint("remove wifi not called")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.removeWifiNameToDevice()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.showActivityIndicator(self.view, isShow: false, isShowText: "Removing Wi-Fi details on device")
                }
            }
        }
        
        
    }
    
    func getBLEWriteStateDelegate(bleWriteType: BlueToothFeatureType) {
        if bleWriteType == .BlueToothFeatureRemoveSSIDWrite {
            self.showAct()
            if BluetoothManager.shared.mainPeripheral == nil {
                self.removeConnectionState()
                return
            }
            self.dashBrdRemoveWIFIIntailCheckCount = self.dashBrdRemoveWIFIIntailCheckCount + 1
            if self.dashBrdRemoveWIFIIntailCheckCount < 3{
                textLog.write("DASHBOARD REMOVE WIFI  RETRY CHECK - COUNT\(String(describing: dashBrdRemoveWIFIIntailCheckCount)) ")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.removeWifiNameToDevice()
                }
            }else {
                print("Not connect ble da")
                self.dashBrdRemoveWIFIIntailCheckCount = 100
                self.bluetoothConnectionErrorAlert()
            }
        }
        if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureWifiStatus {
            if self.isWifiUpdate == 0 {
                print("Not connect ble da")
                self.bluetoothConnectionErrorAlert()
            }
        }
    }
    
    func removeConnectionState()  {
        self.bluetoothConnectionErrorAlert()
    }
}
extension LuftDeviceViewController: BleManagerStateDelegate,BackGroundBleStateDelegate {
    
    func getBleManagerBleState(isConnectedBLEState: Bool) {
        if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureRemoveSSIDWrite{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hideActivityIndicator(self.view)
            }
            if self.isWifiUpdate == 0 {
                self.getBLEWriteStateDelegate(bleWriteType: BlueToothFeatureType.BlueToothFeatureRemoveSSIDWrite)
            }else {
                if self.isWifiUpdate == 0 {
                    self.bluetoothConnectionErrorAlert()
                }
            }
        }
        else if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureWifiStatus {
            if self.isWifiUpdate == 0 {
                self.bluetoothConnectionErrorAlert()
            }else {
                if self.isWifiUpdate == 0 {
                    self.bluetoothConnectionErrorAlert()
                }
            }
        }
        else {
            self.bluetoothConnectionErrorAlert()
        }
    }
    
    func bluetoothConnectionErrorAlert()  {
        self.dashBrdRemoveWIFIIntailCheckCount = 100
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideActivityIndicator(self.view)
            print("hide28")
        }
        Helper.shared.removeBleutoothConnection()
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
        
    }
    
    func getBackGroundBleState(isConnectedBLEState: Bool) {
        self.bleNotConnectAlert()
    }
    
    func bleNotConnectAlert()  {
        if self.isDashBoard == false {
            return
        }
        if self.readFromBLE == true {
            self.syncStatusMessageUpdate(message: "Couldn't connect device over bluetooth. Try again later.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.syncStatusMessageUpdate(message: "BLE Not connect")
            }
        }else {
            
        }
        Helper.shared.removeBleutoothConnection()
    }
    
    func bleStatesDelegate(){
        self.hideActivityIndicator(self.view)
        print("hide29")
        BluetoothManager.shared.delegateBleManagerState = self
        BackgroundBLEManager.shared.delegateBackGroundBleState = self
    }
    
    func removeWifiNameToDevice() {
        self.showAct()
        BluetoothManager.shared.centralManager?.stopScan()
        Helper.shared.removeBleutoothConnection()
        textLog.write("BLE VIA - REMOVE SSID PROCESS START (DASHBOARD)")
        BluetoothManager.shared.delegateBleManagerState = nil
        BluetoothManager.shared.isBleManagerConnectState = false
        BluetoothManager.shared.connectBlueTooth(blueToothName: self.getCurrentSelectedDevice()?.serial_id ?? "", bleFeature: .BlueToothFeatureRemoveSSIDWrite)
        BluetoothManager.shared.deviceWriteStatusDelgate = self
        BluetoothManager.shared.delegateBleManagerState = self
        self.isRemoveWifiCalledManually = false
    }
}

extension LuftDeviceViewController {
    
    func setMyLabelText() {
        let numberString = NSMutableAttributedString(string: "eCO", attributes: [.font: UIFont.setSystemFontRegular(17)])
        numberString.append(NSAttributedString(string: "2", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: -2]))
        self.lblCelleCo2.attributedText = numberString
    }
    
    func applyCellTempDataTheme()  {
        
        if UserDefaults.standard.bool(forKey: "RadonSwitch") == true {
            self.lblCellRadon.textColor = ThemeManager.currentTheme().ltCellTitleColor
        }else {
            self.lblCellRadon.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "TemperatureSwitch") == true {
            self.lblCellTemp.textColor = ThemeManager.currentTheme().ltCellTitleColor
        }else {
            self.lblCellTemp.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "HumiditySwitch") == true {
            self.lblCellHumidity.textColor = ThemeManager.currentTheme().ltCellTitleColor
        }else {
            self.lblCellHumidity.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "AirPressureSwitch") == true {
            self.lblCellAirPressure.textColor = ThemeManager.currentTheme().ltCellTitleColor
        }else {
            self.lblCellAirPressure.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "ECO2Switch") == true {
            self.lblCelleCo2.textColor = ThemeManager.currentTheme().ltCellTitleColor
        }else {
            self.lblCelleCo2.textColor = .gray
        }
        
        if UserDefaults.standard.bool(forKey: "TVOCSwitch") == true {
            self.lblCellVOC.textColor = ThemeManager.currentTheme().ltCellTitleColor
        }else {
            self.lblCellVOC.textColor = .gray
        }
        
        self.noDataView?.isHidden = false
        self.showDataView.isHidden = true
        self.lblLastSync.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblLastSyncHeader.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblNodataLastSyncHeader.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.lblNodataLastSync.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.btnSync.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)
        self.btnSync1.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)
        self.logDataBorder?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
        attributedTextForMoldAlertTitle()
    }
    
    func attributedTextForMoldAlertTitle(){
        self.dangerImageView.image = ThemeManager.currentTheme().moldAlertIconImage
        self.dangerousImageView.image = ThemeManager.currentTheme().moldAlertIconImage
//        let moldTitleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 17)]
//        let partTwo = NSMutableAttributedString(string: lblMoldRisk.text ?? "", attributes: moldTitleAttributes)
        if lblMoldRisk.text == MoldRisk.MoldRiskVeryHigh.rawValue || lblMoldRisk.text == MoldRisk.MoldRiskHigh.rawValue{
//            let alertAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: ThemeManager.currentTheme().moldAlertTextColor, .font: UIFont.boldSystemFont(ofSize: 17)]
//            let partOne = NSMutableAttributedString(string: "Alert: ", attributes: alertAttributes)
//            partOne.append(partTwo)
//            lblMoldRisk.attributedText = partOne
            
            lblAlertRisk.isHidden = false
        }else{
            lblAlertRisk.isHidden = true
//            lblMoldRisk.attributedText = partTwo
        }
    }
    
    func readDataCurrentIndex() {
        self.arrCurrentIndexValue.removeAll()
        self.arrCurrentIndexValue = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: self.strCurrentDeviceID)
        if self.arrCurrentIndexValue.count != 0 {
            let moldValue = Helper.shared.getMoldDataValue(temperature: Int((self.arrCurrentIndexValue[0].Temperature.rounded())), humidity: Int(self.arrCurrentIndexValue[0].Humidity))
            let textMold = Helper.shared.getMoldDataText(moldValue: moldValue)
//            lblMoldRisk.text = textMold
//            textMold = MoldRisk.MoldRiskVeryHigh.rawValue
            lblMoldRisk.text = textMold
            self.attributedTextForMoldAlertTitle()
            if textMold == MoldRisk.MoldRiskVeryHigh.rawValue {
                dangerImageView.isHidden = false
                dangerousImageView.isHidden = false
            }else if textMold == MoldRisk.MoldRiskHigh.rawValue {
                dangerImageView.isHidden = false
                dangerousImageView.isHidden = true
            }else{
                dangerImageView.isHidden = true
                dangerousImageView.isHidden = true
            }
            
            var timeValue:Int = 0
            var timeDiff:Int = 0
            if self.arrCurrentIndexValue[0].timeStamp == 0 {
                let dateAtMidnight = Date()
                let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
                let currentTimeValue = Int(secondsSince1970)
                timeDiff = RealmDataManager.shared.getDeviceData(deviceID: self.strCurrentDeviceID)[0].timeDiffrence.toInt() ?? 0
                timeValue = (currentTimeValue / 1000) + timeDiff
            } else {
                let dateAtMidnight = Date()
                let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
                let currentTimeValue = Int(secondsSince1970)
                let arrDevice = RealmDataManager.shared.getDeviceData(deviceID: self.luftSelectedDeviceID)
            if arrDevice.count > 0 {
                timeDiff = RealmDataManager.shared.getDeviceData(deviceID: self.luftSelectedDeviceID)[0].timeDiffrence.toInt() ?? 0
                timeValue = (currentTimeValue / 1000) + timeDiff
            }
        }
            
            if self.getCurrentSelectedDevice()?.wifi_status != true && self.readFromBLE == true {
                self.setTimeStampValue(timeValueSet: self.arrCurrentIndexValue[0].timeStamp)
            }
            
            let date1 = Date(timeIntervalSince1970: TimeInterval(timeValue))
            let dateFormatter1 = DateFormatter()
            dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter1.locale = NSLocale.current
            dateFormatter1.dateFormat = "MM/dd/yyyy"
            let dateValue = dateFormatter1.string(from: date1)
            
            let date = Date(timeIntervalSince1970: TimeInterval(timeValue))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "h:mm a"
            let strTimeValue = dateFormatter.string(from: date)
            
            self.lblLastSync.text = String(format: "%@ at %@", dateValue,strTimeValue)
            self.noDataView?.isHidden = true
            self.showDataView.isHidden = false
            
            if let colorSettings = RealmDataManager.shared.readColorDataValues(deviceID: self.luftSelectedDeviceID, colorType: ColorType.ColorOk.rawValue).first{
                if colorSettings.color_code == "#F7F9F9" {
                    self.showDataView.backgroundColor = UIColor(red: 226/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                        let statusCell: DeviceStatusTableViewCell = self.tblDeviceCollection.cellForRow(at: indexPath) as! DeviceStatusTableViewCell
                    
                   // statusCell.btnSelectedDevice.backgroundColor = UIColor(red: 226/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1)
                    
                }else{
                    self.showDataView.backgroundColor = .clear
                }
            }
 
            
            self.lblCellValueRadon.text = self.updateRadonvalues(values: self.arrCurrentIndexValue[0].Radon)
            self.lblCellValueVOC.text = self.updateVOCvalues(values: self.arrCurrentIndexValue[0].VOC)
            self.lblCellValueeCo2.text = self.updateEco2values(values: self.arrCurrentIndexValue[0].CO2)
            self.lblCellValueTemp.text = self.updateTempraturevalues(values: self.arrCurrentIndexValue[0].Temperature)
            self.lblCellValueHumidity.text = self.updateHumidityvalues(values: self.arrCurrentIndexValue[0].Humidity)
            self.lblCellValueAirPressure.text = self.updateAirPressurevalues(values: self.arrCurrentIndexValue[0].AirPressure)
            if AppSession.shared.getMobileUserMeData()?.radonUnitTypeId == 1{
                let valueStr = String(format: "%@ Bq/m" , self.lblCellValueRadon.text ?? "")
                let numberString = NSMutableAttributedString(string: valueStr, attributes: [.font: UIFont.setAvnierNextAppFontMedium(17)])
                numberString.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setAvnierNextAppFontMedium(14), .baselineOffset: 7]))
                self.lblCellValueRadon.attributedText = numberString
            }
        }else {
            self.noDataView?.isHidden = false
            self.showDataView.isHidden = true
            self.lblLastSync.text = String(format: "No data available")
        }
    }
    
    func updateRadonvalues(values:Float = 0.0) -> String  {
       // self.lblCellValueRadon.textColor = Helper.shared.getRadonColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        if UserDefaults.standard.bool(forKey: "RadonSwitch") == true {
            self.lblCellValueRadon.textColor = Helper.shared.getRadonColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        }else {
            self.lblCellValueRadon.textColor = .gray
        }
        
        if AppSession.shared.getMobileUserMeData()?.radonUnitTypeId == 2{
            self.selectedDropDownType = .DropDownRadonPCII
            if let myRadonValue = Float(String(format: "%.1f", values)) {
                
                let numberOfPlaces = 1.0
                let multiplier = pow(10.0, numberOfPlaces)
                let num = myRadonValue
                let rounded = round(Double(num) * multiplier) / multiplier
                // print(rounded)
                
                //print(String(format: "%.1f pCi/I",myRadonValue.rounded()))
                return String(format: "%.1f pCi/I",rounded)
            }
            return String(format: "%@ pCi/I",values )
        }else {
            return String(format: "%d", String(format:"%f", Helper.shared.convertRadonPCILToBQM3(value: values).rounded()).toInt() ?? 0)
        }
    }
    
    func updateVOCvalues(values:Float = 0.0) -> String  {
        var myVOCValue:Int = 0
//        self.lblCellValueVOC.textColor = Helper.shared.getVOCColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        if UserDefaults.standard.bool(forKey: "TVOCSwitch") == true {
            self.lblCellValueVOC.textColor = Helper.shared.getVOCColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        }else {
            self.lblCellValueVOC.textColor = .gray
        }
        myVOCValue = String(format: "%f",values.rounded()).toInt() ?? 0
        return String(format: "%d ppb",myVOCValue)
    }
    
    func updateEco2values(values:Float = 0.0) -> String  {
        var myECOValue:Int = 0
//        self.lblCellValueeCo2.textColor = Helper.shared.getECO2Color(myValue: values, deviceId: self.strCurrentDeviceID).color
        if UserDefaults.standard.bool(forKey: "ECO2Switch") == true {
            self.lblCellValueeCo2.textColor = Helper.shared.getECO2Color(myValue: values, deviceId: self.strCurrentDeviceID).color
        }else {
            self.lblCellValueeCo2.textColor = .gray
        }
        myECOValue = String(format: "%f",values.rounded()).toInt() ?? 0
        return String(format: "%d ppm",myECOValue)
    }
    
    func updateTempraturevalues(values:Float = 0.0) -> String  {
        if UserDefaults.standard.bool(forKey: "TemperatureSwitch") == true {
            self.lblCellValueTemp.textColor = Helper.shared.getTempeatureColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        }else {
            self.lblCellValueTemp.textColor = .gray
        }
//        self.lblCellValueTemp.textColor = Helper.shared.getTempeatureColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        self.selectedDropDownType = .DropDownTEMPERATURE_CELSIUS
        if AppSession.shared.getMobileUserMeData()?.temperatureUnitTypeId == 1{
            self.selectedDropDownType = .DropDownTEMPERATURE_FAHRENHEIT
            return String(format: "%d F",Int((values.rounded())))
        }else {
            return String(format: "%d C",String(format: "%f", Helper.shared.convertTemperatureFahrenheitToCelsius(value:values).rounded()).toInt() ?? 0)
        }
    }
    
    func updateAirPressurevalues(values:Float = 0.0) -> String  {
        var airPressureValue:Float = values
        var isLocalAltitudeINHG: Float = 0.0
        if Helper.shared.getDeviceDataAltitude(deviceID: self.strCurrentDeviceID).isAltitude == true {
            isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: self.strCurrentDeviceID).isLocalAltitudeINHG
            airPressureValue = values + isLocalAltitudeINHG
        }
        
//        self.lblCellValueAirPressure.textColor = Helper.shared.getAirPressueColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        if UserDefaults.standard.bool(forKey: "AirPressureSwitch") == true {
            self.lblCellValueAirPressure.textColor = Helper.shared.getAirPressueColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        }else {
            self.lblCellValueAirPressure.textColor = .gray
        }
        if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
            var myAirPressureINHGValue:Float = 0.0
            myAirPressureINHGValue = Float(String(format: "%.2f", airPressureValue)) ?? 0.0
            return String(format: "%.2f inHg",myAirPressureINHGValue)
            
        }else {
            self.selectedDropDownType = .DropDownAIRPRESSURE_MBAR
            var myAirPressureMBARValue:Int = 0
            myAirPressureMBARValue = String(format: "%f", Helper.shared.convertAirPressureINHGToMBAR(value: airPressureValue).rounded()).toInt() ?? 0
            return String(format: "%d mbar",myAirPressureMBARValue)
        }
    }
    
    func updateHumidityvalues(values:Float = 0.0) -> String  {
//        self.lblCellValueHumidity.textColor = Helper.shared.getHumidityColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        if UserDefaults.standard.bool(forKey: "HumiditySwitch") == true {
            self.lblCellValueHumidity.textColor = Helper.shared.getHumidityColor(myValue: values, deviceId: self.strCurrentDeviceID).color
        }else {
            self.lblCellValueHumidity.textColor = .gray
        }
        var myHumidityvalue:Int = 0
        myHumidityvalue = String(format: "%f",values.rounded()).toInt() ?? 0
        return String(format: "%d %%",myHumidityvalue)
    }
    
    func reloadLogData() {
        self.applyCellTempDataTheme()
        if let deviceDataCurrent:RealmDeviceList = self.getCurrentSelectedDevice() {
            self.strCurrentDeviceID = deviceDataCurrent.device_id
            self.readDataCurrentIndex()
        }
        self.btnSync.addTarget(self, action: #selector(self.syncWithWIFIBLEData(sender:)), for: .touchUpInside)
        self.btnSync1.addTarget(self, action: #selector(self.syncWithWIFIBLEData(sender:)), for: .touchUpInside)
    }
    func removeJifImage()  {
        //        if self.noDataView?.isHidden == false {
        //            self.btnSync1.imageView?.layer.removeAnimation(forKey: "transform.rotation.z")
        //            self.btnSync1.imageView?.layer.removeAllAnimations()
        //            self.btnSync1.layer.removeAllAnimations()
        //            self.btnSync1.setImage(nil, for: .normal)
        //            self.btnSync1.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)
        //        }else {
        //            self.btnSync.imageView?.layer.removeAnimation(forKey: "transform.rotation.z")
        //            self.btnSync.imageView?.layer.removeAllAnimations()
        //            self.btnSync.layer.removeAllAnimations()
        //            self.btnSync.setImage(nil, for: .normal)
        //            self.btnSync.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)
        //        }
        
        if self.isDashBoard == false {
            return
        }
        let indexPath = IndexPath(row: 0, section: 0)
        if  self.tblDeviceCollection.cellForRow(at: indexPath) != nil {
            let statusCell: DeviceStatusTableViewCell = self.tblDeviceCollection.cellForRow(at: indexPath) as! DeviceStatusTableViewCell
            statusCell.btnSync?.imageView?.layer.removeAnimation(forKey: "transform.rotation.z")
            statusCell.btnSync?.imageView?.layer.removeAllAnimations()
            statusCell.btnSync?.layer.removeAllAnimations()
            statusCell.btnSync?.setImage(nil, for: .normal)
            statusCell.btnSync?.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)
        }
    }
    
    func addJifImage()  {
        
        if self.isDashBoard == false {
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        if  self.tblDeviceCollection.cellForRow(at: indexPath) != nil {
            let statusCell: DeviceStatusTableViewCell = self.tblDeviceCollection.cellForRow(at: indexPath) as! DeviceStatusTableViewCell
            let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = Double.pi * 0.2
            rotation.duration = 0.25
            rotation.isCumulative = true
            rotation.repeatCount = Float.greatestFiniteMagnitude
            statusCell.btnSync?.imageView?.layer.add(rotation, forKey: "rotationAnimation")
        }
        
        //        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        //        rotation.toValue = Double.pi * 0.2
        //        rotation.duration = 0.25
        //        rotation.isCumulative = true
        //        rotation.repeatCount = Float.greatestFiniteMagnitude
        //        if self.noDataView?.isHidden == false {
        //            self.btnSync1.imageView?.layer.add(rotation, forKey: "rotationAnimation")
        //        }else {
        //            self.btnSync.imageView?.layer.add(rotation, forKey: "rotationAnimation")
        //        }
    }
    
    func reloadTblData() {
        self.tblDeviceCollection?.reloadData()
        self.reloadLogData()
        
        if self.arrReadDeviceData.count > 0{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.tblDeviceCollection?.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: false)
            }
        }
        
        
    }
    
    func addDeviceViewNewGood()  {
        self.addDeviceView?.isHidden = false
        self.btnFindDeviceButton.addTarget(self, action: #selector(self.addDeviceViewPage(sender:)), for: .touchUpInside)
    }
    
    @objc func addDeviceViewPage(sender: UIButton) {
        //checking BT access - Gauri
        if intPermissionDisplay == 0 {
            self.findDeviceBTScan()
        } else {
            self.moveToAddDevice(isfromDefault: true)
        }
    }
    
    func hideDeviceView()  {
        self.addDeviceView?.isHidden = true
    }
    
    func getCurrentSelectedDevice() -> RealmDeviceList? {
        guard let device = isCurrentSelectedDevice, !device.isInvalidated else {
            return .none
        }
        return isCurrentSelectedDevice
    }
    
    func getOustideData()  {
        print("self.getCurrentSelectedDevice()#$%$%%%%%%%%%%%%$##%^$#%^$^&$^&$^&$^&$^&$")
        print(self.getCurrentSelectedDevice()?.device_id)
        self.isCurrentDeviceLat = self.getCurrentSelectedDevice()?.deviceLat ?? "0.0"
        self.isCurrentDeviceLong = self.getCurrentSelectedDevice()?.deviceLong ?? "0.0"
        self.showAct()
        if Reachability.isConnectedToNetwork() == false || self.isCurrentDeviceLat == "0.0" || self.isCurrentDeviceLong == "0.0" {
            self.hideActivityIndicator(self.view)
            print("hide1")
            self.strOutSideLocation = "---"
            UserDefaults.standard.set(self.strOutSideLocation, forKey: "Location")
            self.strOutSideTemperature = "---"
            self.strOutSideHumitiy = "---"
            self.setOutSideData()
        }else {
            getOutsideAirQualityIndex()
            HttpManager.sharedInstance.getOutsideDataAPI(latValue: self.isCurrentDeviceLat, longValue: self.isCurrentDeviceLong, successBlock: {[unowned self] (success, message, responseObject) in
                
                if success {
                    if let dataValue:JSON = Helper.shared.getOptionalJson(response: responseObject as AnyObject) {
                        do {
                            self.outSideDataAPI = try OutSideDataBaseClass.init(json:dataValue)
                            self.strOutSideLocation = self.outSideDataAPI?.name ?? "---"
                            UserDefaults.standard.set(self.strOutSideLocation, forKey: "Location")
                            self.strSeasonImage = self.outSideDataAPI?.weather?[0].icon ?? "---"
                            
                            if AppSession.shared.getMobileUserMeData()?.temperatureUnitTypeId == 1{
                                var myTempFarhetValue:Int = 0
                                myTempFarhetValue = String(format: "%f", self.convertKelvinToFarehit(value: self.outSideDataAPI?.main?.temp ?? 0.0).rounded()).toInt() ?? 0
                                self.strOutSideTemperature = String(format: "%d F", myTempFarhetValue)
                            }else {
                                var myTempCelisusValue:Int = 0
                                myTempCelisusValue = String(format: "%f", self.convertKelvinToCelsius(value: self.outSideDataAPI?.main?.temp ?? 0.0).rounded()).toInt() ?? 0
                                self.strOutSideTemperature = String(format: "%d C", myTempCelisusValue)
                            }
                            self.strOutSideHumitiy = String(format: "%d %%", Int(self.outSideDataAPI?.main?.humidity ?? 0))
                            print("!!!!!!!!!!!!!!!!!!")
                            print(self.strOutSideHumitiy)
                            print(self.strOutSideTemperature)
                            print("!!!!!!!!!!!!!!!!!!")
                            self.setOutSideData()
                            
                        }
                        catch {
                            print("err")
                            self.setOutSideData()
                        }
                    }else {
                        Helper().showSnackBarAlert(message: message, type: .Failure)
                        self.setOutSideData()
                    }
                }
                }, failureBlock: {[unowned self] (errorMesssage) in
                    self.hideActivityIndicator(self.view)
                    print("hide2")
                    Helper.shared.showSnackBarAlert(message: errorMesssage.description, type: .Failure)
                    self.setOutSideData()
            });
        }
    }
    
    func getOutsideAirQualityIndex(){
        HttpManager.sharedInstance.getOutsideAirQualityAPI(latValue: self.isCurrentDeviceLat, longValue: self.isCurrentDeviceLong, successBlock: {[unowned self] (success, message, responseObject) in
            
            if success {
                if let dataValue:JSON = Helper.shared.getOptionalJson(response: responseObject as AnyObject) {
                    self.outSideAirQualityIndex = (dataValue["list"][0]["main"]["aqi"]).intValue
                    self.setOutSideData()
                }else {
                    Helper().showSnackBarAlert(message: message, type: .Failure)
                    self.setOutSideData()
                }
            }
            }, failureBlock: {[unowned self] (errorMesssage) in
                self.hideActivityIndicator(self.view)
                print("hide2")
                Helper.shared.showSnackBarAlert(message: errorMesssage.description, type: .Failure)
                self.setOutSideData()
        });
    }
    
    func convertKelvinToCelsius(value: Float) -> Float{
        return (value - 273.15)
    }
    
    func convertKelvinToFarehit(value: Float) -> Float{
        return ((value * 9 / 5) - 459.67)
    }
    
    func setOutSideData() {
        
        if RealmDataManager.shared.readDeviceListDataValues().count != 0 {
            var weatherUrl:String = ""
            if AppSession.shared.getUserLiveState() != 2 {
                weatherUrl = String(format:"%@%@.png",LIVE_OPEN_WEATHER_MAP_IMAGE_URL,self.strSeasonImage ?? "04d")
            }else {
                weatherUrl = String(format:"%@%@.png",UAT_OPEN_WEATHER_MAP_IMAGE_URL,self.strSeasonImage ?? "04d")
            }
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: NSURL.init(string:String(format:"%@",weatherUrl))! as URL) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.imageWeather = image
                            self?.tblDeviceCollection?.reloadData()
                            if self?.isReMoveWifiStart == 1{
                                
                            }else {
                                print("hide3")
                                if self?.isRefreshSynTapped ==  true {
                                    self?.syncingRefreshData()
                                    self?.isRefreshSynTapped = false
                                }else {
                                    self?.hideActivityIndicator(self?.view ?? UIView())
                                }
                            }
                            
                        }
                    }
                }
            }
        }else {
            self.hideActivityIndicator(self.view)
            print("hide4")
            if self.isRefreshSynTapped ==  true {
                self.syncingRefreshData()
                self.isRefreshSynTapped = false
            }
        }
        
        
    }
}

extension LuftDeviceViewController {
    func getFWVersionAPI(isFromIntial:Bool) {
        if Reachability.isConnectedToNetwork() == true {
            self.showAct()
            var getFWVersionStr:String = ""
            if AppSession.shared.getUserLiveState() == 2 {
                getFWVersionStr = FW_VERSION_UAT_URL
            }else {
                getFWVersionStr = FW_VERSION_LIVE_URL
            }
            Alamofire.request(getFWVersionStr,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                self.hideActivityIndicator(self.view)
                print("hide5")
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let data : JSON = Helper.shared.getOptionalJson(response: response.result.value as AnyObject) {
                            print("hide6")
                            self.hideActivityIndicator(self.view)
                            strFirmwareVesrion =  data["LuftFWVersion"].stringValue
                            
                            if isFromIntial == true {
                                self.chechFWInterval()
                            }else {
                                self.showToFirmWare()
                            }
                            
                        }
                    }
                    break
                case .failure(let error):
                    Helper.shared.showSnackBarAlert(message: error.localizedDescription, type: .Failure)
                    break
                }
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    func fwIntiatedMsg() {
        let titleString = NSAttributedString(string: "Firmware Update", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: FW_COMPLETED_UPDATE_INITIATED, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}

extension LuftDeviceViewController {
    
    func chechFWInterval() {
        if AppSession.shared.getIntervalTimeStamp() == 0 || (((Int(Date().timeIntervalSince1970) - AppSession.shared.getIntervalTimeStamp()) / 3600) >= 24) {
            if self.loadArrayDeviceData() {
                self.showFWUpdateAlert()
            }
            AppSession.shared.setIntervalTimeStamp(intervalTime: Int(Date().timeIntervalSince1970))
        }
    }
    
    func showFWUpdateAlert() {
        let titleString = NSAttributedString(string: "Firmware Update", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: FW_UPDATE_ALERT, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
            
        })
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.moveToFirmWareVW()
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func loadArrayDeviceData() -> Bool  {
        var isFWAvaliable: Bool = false
        if self.arrReadDeviceData.count > 0 {
            for deviceData in self.arrReadDeviceData {
                if deviceData.firmware_version.lowercased().filter("1234567890".contains) != strFirmwareVesrion.lowercased().filter("1234567890".contains) {
                    isFWAvaliable = true
                }
            }
        }
        return isFWAvaliable
    }
    
    func moveToFirmWareVW()  {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirmwareUpdateViewController") as! FirmwareUpdateViewController
        self.tabBarController?.tabBar.isHidden = true
        self.isReLoad = true
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
}


extension UIImageView {
    
    func imageFromUrl(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension LuftDeviceViewController: BackGroundBleSyncCompletedDelegate {
    func getWholebackGroundBleSyncCompletedDelegate()  {
        
    }
    
    func setTimeStampValue(timeValueSet:Int)  {
        guard let currentTimeStamp = Date().toMillis() else { return  }
        let timeDiffValue = Int(currentTimeStamp) - timeValueSet
        if  timeDiffValue > 360000{
            self.isDeviceTimeDiffUpdate = true
           // self.showDeviceTimeUpdateAlert()
            self.deviceTimeStampUpdateBLE()
        }else {
            print("Show non alert")
        }
    }
    func backgroundBluetoothSync()  {
        if BackgroundDataAPIManager.shared.isWholeDataSyncCompleted == true && APIManager.shared.isAddDeviceAPICompleted == true {
            self.isBackGroundSyncStart = true
            if self.getCurrentSelectedDevice()?.wifi_status != true {
                self.getBluetoothUpperBoundLogData()
            }
        }
    }
    
    func showDeviceTimeUpdateAlert() {
        let titleString = NSAttributedString(string: "Device Time Update", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: DEVICE_TIME_UPDATE_ALERT, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
            self.isDeviceTimeDiffUpdate = false
            self.backgroundBluetoothSync()
        })
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.deviceTimeStampUpdateBLE()
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
}

extension LuftDeviceViewController:TIMEStampWriteDelegate {
    
    func writeTIMEStampWrite() {
        print("SELECTED DEVICE WRITE TIME UPDATE COMPLETED")
        self.isDeviceTimeDiffUpdate = false
        self.readCurrentDeviceBleData()
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
        BluetoothManager.shared.timeStampValue = self.currentTimeStampValue
        BluetoothManager.shared.connectBlueTooth(blueToothName: self.getCurrentSelectedDevice()?.serial_id ?? "", bleFeature: .BlueToothTimeStampWrite)
        BluetoothManager.shared.delegateTimeStampVersion = self
    }
    
    func showShareDataAlert(message:String) {
        let titleString = NSAttributedString(string: LUFT_APP_NAME, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            
        })
        alert.addAction(ok)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}

extension LuftDeviceViewController {
    
    func getLastSyncDate() -> Int {
        self.arrCurrentIndexValue.removeAll()
        self.arrCurrentIndexValue = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: self.strCurrentDeviceID)
        var timeValue:Int = 0
        var timeDiff:Int = 0
        
        if self.arrCurrentIndexValue.count != 0 {
            if self.arrCurrentIndexValue[0].timeStamp == 0 {
                let dateAtMidnight = Date()
                let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
                let currentTimeValue = Int(secondsSince1970)
                timeDiff = RealmDataManager.shared.getDeviceData(deviceID: self.strCurrentDeviceID)[0].timeDiffrence.toInt() ?? 0
                timeValue = (currentTimeValue / 1000) + timeDiff
            } else {
                timeDiff = RealmDataManager.shared.getDeviceData(deviceID: self.strCurrentDeviceID)[0].timeDiffrence.toInt() ?? 0
                timeValue = (self.arrCurrentIndexValue[0].timeStamp / 1000) // + timeDiff
            }
        } else {
                let dateAtMidnight = Date()
                let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
                let currentTimeValue = Int(secondsSince1970)
                timeDiff = RealmDataManager.shared.getDeviceData(deviceID: self.strCurrentDeviceID)[0].timeDiffrence.toInt() ?? 0
                timeValue = (currentTimeValue / 1000) + timeDiff
        }
        return timeValue
    }
    
        func getBluetoothUpdateDevice()  {
            if Reachability.isConnectedToNetwork() == true {
                // self.showAct()
                SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
                var calendar = NSCalendar.current
                calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
                //Last sync date from DB -LastSyncDate- Gauri
                
//                let dateAtMidnight = Date()
//                let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
//                let currentTimeValue = Int(secondsSince1970)
                let currentTimeValue = getLastSyncDate()//Int(secondsSince1970)

                DeviceAPI.apiDeviceUpdateBluetoothDataSyncPost(model: SNAirQualityWebViewModelsUpdateBluetoothSync.init(timeStampUtc: Int64(currentTimeValue), deviceId: Int64(self.getCurrentSelectedDevice()?.device_id ?? 0)), completion: { (response, error) in
                    // self.hideActivityIndicator(self.view)
                    if error == nil  {
                        print("Success UpdateBluetoothDataSync")
                        self.readDataCurrentIndex()
                    }else {
                        print("UpdateBluetoothDataSync API CALLING error")
                    }
                })
            }else {
                Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            }
        }
        
    }

extension LuftDeviceViewController: DeviceSerialNumberReadDelegate{
    func didReadSerialNumber(serialNumber: String) {
        print("serial number of device in Luft device VC : " + serialNumber)
        macAddressSerialNo = serialNumber
    }
    
    func readSerialNumber(){
        macAddressSerialNo = "";
        let manager  = BluetoothManager.init()
        manager.isBleManagerConnectState = false
        manager.isBleManagerCharacteristicsState = false
        manager.connectBlueTooth(blueToothName: self.getCurrentSelectedDevice()?.serial_id ?? "", bleFeature: .BluetoothReadSerial)
        manager.serialNumberReadDelegate = self
    }
}
