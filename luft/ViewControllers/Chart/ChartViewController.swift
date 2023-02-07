//
//  ChartViewController.swift
//  luft
//
//  Created by iMac Augusta on 9/23/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import Charts
import CoreData
import Realm
import RealmSwift
import CoreBluetooth
import SwiftyJSON
import Alamofire
import Alamofire.Swift

let VOC_UNIT_STRING = "ppb"
let ECO2_UNIT_STRING = "ppm"
let HUMIDITY_UNIT_STRING = "%"


struct LineChartModel {
    var QuickSync: Int = 0
    var Device_ID: Int = 0
    var LogIndex: Int = 0
    var Temperature: Float = 0
    var CO2: Float = 0
    var Radon: Float = 0
    var AirPressure: Float = 0
    var VOC: Float = 0
    var date: Date = Date(timeIntervalSince1970: 1)
    var Humidity: Float = 0
    var dateTimeStamp: Int = 0
    var onlyDate: String = ""
    var WeekValue: String = ""
    var dummyValue: Int = 0
    
}

enum FilterTypeEnum: Int {
    case Overall = 1
    case Hours24 = 2
    case Days7 = 3
    case Month = 4
    case Year = 5
    case Unknown = 6
    
}
enum DataTypeFilterEnum: Int {
    case radon = 101
    case voc = 102
    case co2 = 103
    case temperature = 104
    case humidity = 105
    case airPressure = 106
}

enum DataTypeFilterTitle: String {
    case radon = "Radon"
    case voc = "VOC"
    case co2 = "ECO2"
    case temperature = "Temperature"
    case humidity = "Humidity"
    case airPressure = "AirPressure"
}

struct AverageValues{
    var radonAverage: Float
    var vocAverage: Float
    var co2Average: Float
    var humidityAverage: Float
    var airPressureAverage: Float
    var temperatureAverage: Float
}

var GlobalDeviceID = 0
var ChartFilterType: FilterTypeEnum = .Unknown
var BQM3Format = "Bq/m3"
var INHG = "inHg"
var PCIL = "pCi/l"

class ChartViewController: DemoBaseViewController, PeripheralDelegate, DashBoardDelegate, AddDevicelDelegate {
    // Chart Integration
    var chartDataValues:[LineChartModel] = []
    var chartMinimumVal: Double = 0.0
    var chartMaximumVal: Double = 0.0
    var isChartViewPresent: Bool = true
    
   
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var btnRadon: UIButton!
    @IBOutlet weak var btnVoc: UIButton!
    @IBOutlet weak var btnCo2: UIButton!
    @IBOutlet weak var btnTemperature: UIButton!
    @IBOutlet weak var btnHumidity: UIButton!
    @IBOutlet weak var btnAirPressure: UIButton!
    
    @IBOutlet weak var lblConnectedDevice: UILabel!
    
    @IBOutlet weak var lblNoDataAvailable: UILabel!
    
    @IBOutlet weak var btn24Hrs: UIButton!
    @IBOutlet weak var btn7Days: UIButton!
    @IBOutlet weak var btnMonths: UIButton!
    @IBOutlet weak var btnYear: UIButton!
    
    @IBOutlet weak var btnSelectedDevice: ViewBorderButton!
    @IBOutlet weak var imgSelectedDeviceWiFiBleStatus: UIImageView!
    @IBOutlet weak var tblDeviceCollection: UITableView!
    @IBOutlet weak var searchBackView: UIView!
    @IBOutlet weak var btnSunRadonLogo: UIButton!
    
    var chartLimitLineValue1: Double = 10.0
    var chartLimitLineValue2: Double = 50.0
    var strConnectDeviceName: String = ""
    var chartValues: [Int] = []
    var context: NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var filterTypeVal = FilterTypeEnum.Month
    var selectedDeviceID = "659"
    var typeVal = DataTypeFilterEnum.radon
    var arrCompletedReadDeviceData:[RealmDeviceList] = []
    var arrUpdateByDeviceList: [UpdateByDeviceList] = []
    var arrReadDeviceData:[RealmDeviceList] = []
    
    var isSelectedDeviceRow:Int = 0
    var luftSelectedDeviceID:Int = 0
    var isCurrentSlectedDevice:RealmDeviceList? = nil
    var isGridList:Bool = true
    var strConnectPeripheral: String = "LUFT"
    var centralManager: CBCentralManager!
    var mainPeripheral: CBPeripheral!
    var isLoadMe:Bool = false
    @IBOutlet weak var lblSelectedConnectDevice: UILabel!
    @IBOutlet weak var deviceListTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lastSyncLabel: UILabel!
    var arrCurrentIndexValue:[RealmPollutantValuesTBL] = []
    
    @IBOutlet weak var averageDataLabel: UILabel!
    @IBOutlet weak var btnBorder1: LTCellDashBoardBorderLabel!
    @IBOutlet weak var btnBorder2: LTCellDashBoardBorderLabel!
    var averageValues: AverageValues?
    
    var colorRadonType:ColorType = .ColorNone
    var colorTempType:ColorType = .ColorNone
    var colorHumidityType:ColorType = .ColorNone
    var colorAirpressureType:ColorType = .ColorNone
    var colorVocType:ColorType = .ColorNone
    var colorEco2Type:ColorType = .ColorNone
    
    var isMenuPressed:Int = 0
    var writeRemoveWifiIndex:Int = 0
    var strShareEmailID: String = ""
    var strRenameDevice: String = ""
    
    var luftChartDeviceIDPrevious:Int = 0
    
    @IBOutlet weak var chartBGView: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    
    @IBOutlet weak var tileBGView: UIView!
    @IBOutlet weak var appHeaderView: AppHeaderView!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var textSearch: UISearchBar!
    @IBOutlet weak var searchViewHeightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var lblAuto: LTCellSyncLabel!
    
    var searchDeviceViewController: SearchDeviceViewController?
    var isFromLoad:Bool = false
    var arrMyDeviceList: [MyDeviceModel]? = []
    var dashBrdRemoveWIFIIntailCheckCount:Int = 0
    
    //BLE
    var manager:CBCentralManager? = nil
    var peripherals:[CBPeripheral] = []
    var scanCheckCount:Int = 0
    var disCoverPeripheral:CBPeripheral!
    var wifiDeviceStatus:WIFIDEVICESTATUS = .WIFI_NOT_CONNECTED
    var isWifiUpdate:Int = 0
    
    @IBOutlet weak var addDeviceView: UIView!
    @IBOutlet weak var btnFindDeviceButton: UIButton!
    @IBOutlet weak var viewHeaderAddDevice: UIView!
    @IBOutlet weak var lblBorderTitle: LTCellDashBoardBorderLabel!
    @IBOutlet weak var lblUAT1: UILabel!
    @IBOutlet weak var lblUAT2: UILabel!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var switchScale: UISwitch!
    
    var isBackGroundAPICompleted:Bool = false
    var isWholeBackGroundAPICompleted:Bool = false
    
    var isBackGroundSyncStart:Bool = false
    
    var isShowData:Bool = false
    
    
    // default min max values based on db data
    var defaultMinValueFromDB: Double = 0
    var defaultMaxValueFromDB: Double = 0
    
    //BT Access permission-Gauri
    var intPermissionDisplay = 0
    var addDeviceDataDelegateStatus:AddNewDeviceDataDelegate? = nil

    var tappedButtonName: String = ""
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork() == true {
            self.showAct()
        }
        self.isSelectedDeviceRow = 0
        self.tblDeviceCollection.delegate = self
        self.tblDeviceCollection.dataSource = self
        self.tblDeviceCollection.rowHeight = UITableView.automaticDimension
        self.tblDeviceCollection.estimatedRowHeight = 115
        self.tblDeviceCollection.register(UINib(nibName: cellIdentity.luftDeviceTableViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.luftDeviceTableViewCell)
        
        seteCO2Text(color: .black)
        self.isFromLoad = true
        self.getDeviceList(isAPICall:false)
        self.tileBGView?.isHidden = true
        self.btnSunRadonLogo.addTarget(self, action: #selector(self.btnSunRadonLogoTapped(sender:)), for: .touchUpInside)
        self.lblSelectedConnectDevice?.font = UIFont.setSystemFontMedium(17)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: .postNotifiWholeDataSync, object: nil)
        self.isWholeBackGroundAPICompleted = false
        self.isShowData = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
//        if #available(iOS 13.0, *) {
//            if self.lineChartView.traitCollection.userInterfaceStyle == .dark {
//                self.lineChartView.noDataTextColor = .white
//            } else {
//                self.lineChartView.noDataTextColor = .black
//            }
//        }else{
//            self.lineChartView.noDataTextColor = .black
//        }
        
        //UserDefaults.standard.set(false, forKey: "genericSwitchChart")
        self.garyColorButtons()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Reachability.isConnectedToNetwork() == true {
            self.showAct()
        }
        self.isSelectedDeviceRow = 0
        self.tblDeviceCollection.delegate = self
        self.tblDeviceCollection.dataSource = self
        self.tblDeviceCollection.rowHeight = UITableView.automaticDimension
        self.tblDeviceCollection.estimatedRowHeight = 115
        self.tblDeviceCollection.register(UINib(nibName: cellIdentity.luftDeviceTableViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.luftDeviceTableViewCell)
        
        seteCO2Text(color: .black)
        self.isFromLoad = true
        self.getDeviceList(isAPICall:false)
        self.tileBGView?.isHidden = true
        self.btnSunRadonLogo.addTarget(self, action: #selector(self.btnSunRadonLogoTapped(sender:)), for: .touchUpInside)
        self.lblSelectedConnectDevice?.font = UIFont.setSystemFontMedium(17)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: .postNotifiWholeDataSync, object: nil)
        self.isWholeBackGroundAPICompleted = false
        self.isShowData = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetDeviceAlert(_:)), name: .postNotifiResetDevice, object: nil)
        if BackgroundDataAPIManager.shared.isWholeDataSyncCompleted == true {
            self.isWholeBackGroundAPICompleted = true
        }
        BackgroundBLEManager.shared.backGroundBleSyncCompletedDelegate = self
        self.isBackGroundAPICompleted = false
        dataBasePathChange = false
        self.isChartViewPresent = true
        self.removeSearchView()
        DispatchQueue.main.async(execute: {
            self.view.endEditing(true)
            self.tabBarController?.tabBar.isHidden = false
        })
        self.searchViewHeightConstant?.constant = 0.0
        self.strShareEmailID = ""
        self.strRenameDevice = ""
        self.writeRemoveWifiIndex = 0
        if isMenuPressed == 1{
            self.isMenuPressed = 0
            return
        }
        self.isSelectedDeviceRow = 0
        self.isMenuPressed = 0
        self.appHeaderView.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.btnMenu.setImage(ThemeManager.currentTheme().menuIconImage, for: .normal)
        self.chartBGView?.backgroundColor = ThemeManager.currentTheme().chartBGColor
        self.addDeviceView?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        //self.getDeviceList(isAPICall:self.isFromLoad)
        self.showSearchViewLIntial()
        self.isFromLoad = true
        self.searchBackView.isHidden = true
        self.customizeSearchBar()
        if  AppSession.shared.getUserSelectedTheme() == 2 {
            AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
        }else {
            AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
        }
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        //UIApplication.shared.statusBarView?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.setLatestStatusBar()
        self.view.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.tileBGView.backgroundColor = ThemeManager.currentTheme().chartTileBGViewColor
        self.tblDeviceCollection.backgroundColor = ThemeManager.currentTheme().chartTileBGViewColor
        self.viewHeaderAddDevice?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.btnBorder1?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
        self.btnBorder2?.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
        self.lineChartView?.noDataTextColor = ThemeManager.currentTheme().chartNoDataTextColor

        self.uatLBLTheme(lbl: self.lblUAT1)
        self.uatLBLTheme(lbl: self.lblUAT2)
        self.lblAuto.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.switchScale.addTarget(self, action: #selector(switchScaleStatusChanged), for: UIControl.Event.valueChanged)
        //self.switchScale.tintColor = UIColor.green
        self.scaleIsInfo()
        self.switchScale.layer.borderWidth = 1
        
        if AppSession.shared.getUserSelectedTheme() == 1 {
            self.switchScale.layer.borderColor = UIColor.lightGray.cgColor
        }else {
            self.switchScale.layer.borderColor = UIColor.white.cgColor
        }
        
        self.switchScale.layer.cornerRadius = 16
        self.switchScale.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        self.callUserMeApi()
        
        if AppSession.shared.getIsAddedNewDevice() == true {
            self.getDeviceList(isAPICall:false)
        }
        
        if AppSession.shared.getIsConnectedWifi() == true {
            AppSession.shared.setIsConnectedWifi(iswifi:false)
            self.callMyDeviceAPI()
        }
        self.tileBGView?.isHidden = false
        self.lblAuto?.text = "Trend chart auto-scale"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AppSession.shared.getIsAddedNewDevice() == true {
            self.getDeviceList(isAPICall:false)
        }
        
        if AppSession.shared.getIsConnectedWifi() == true {
            AppSession.shared.setIsConnectedWifi(iswifi:false)
            self.callMyDeviceAPI()
        }
        self.tileBGView?.isHidden = false
        self.lblAuto?.text = "Trend chart auto-scale"
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .postNotifiResetDevice, object: nil)
    }
    
    @objc func resetDeviceAlert(_ notification: NSNotification) {
        Helper.shared.showSnackBarAlertWithButton(message: LUFT_BLUETOOTH_RESET, type: .Failure)
    }
    @objc func showSpinningWheel(_ notification: NSNotification) {
        if BackgroundDataAPIManager.shared.isWholeDataSyncCompleted == true && self.isWholeBackGroundAPICompleted == false{
            self.getallBackGroundWifiReadingStatus(update: true)
        }
    }
    
    func seteCO2Text(color: UIColor) {
        let numberString = NSMutableAttributedString(string: "eCO", attributes: [.font: UIFont.setSystemFontMedium(17), .foregroundColor: color])
        numberString.append(NSAttributedString(string: "2", attributes: [.font: UIFont.setSystemFontMedium(14), .baselineOffset: -2, .foregroundColor: color]))
        btnCo2.setAttributedTitle(numberString, for: .normal)
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            lineChartView.data = nil
            //self.nodataView.isHidden = false
            return
        }
        self.setDataCountSets()
        //self.nodataView.isHidden = true
    }
    
    
    func scaleIsInfo()  {
        if AppSession.shared.getAutoScale() {
            self.switchScale.isOn = true
           // UserDefaults.standard.set(true, forKey: "genericSwitchChart")
        }else {
            self.switchScale.isOn = false
            //UserDefaults.standard.set(false, forKey: "genericSwitchChart")
        }
    }
    
    //
    func uatLBLTheme(lbl:UILabel)  {
        lbl.textColor = ThemeManager.currentTheme().titleTextColor
        lbl.font = UIFont.setAppFontBold(12)
        if AppSession.shared.getUserLiveState() == 2 {
            lbl.text = UAT_TEXT
        }else {
            lbl.text = ""
        }
    }
    
    
    
    @objc func switchScaleStatusChanged(mySwitch: UISwitch) {
        if  self.switchScale.isOn {
            AppSession.shared.setAutoScale(isAutoScale: true)
        }else{
            AppSession.shared.setAutoScale(isAutoScale: false)
        }
        self.scaleIsInfo()
        self.lineChartView.leftAxis.resetCustomAxisMin()
        self.lineChartView.leftAxis.resetCustomAxisMax()
        self.initializeChartDetails()
        
        switch self.typeVal{
        case .radon:
            self.btnDataTypeTapped(sender: self.btnRadon)
            break
        case .voc:
            self.btnDataTypeTapped(sender: self.btnVoc)
            break
        case .co2:
            self.btnDataTypeTapped(sender: self.btnCo2)
            break
        case .temperature:
            self.btnDataTypeTapped(sender: self.btnTemperature)
            break
        case .humidity:
            self.btnDataTypeTapped(sender: self.btnHumidity)
            break
        case .airPressure:
            self.btnDataTypeTapped(sender: self.btnAirPressure)
            break
        default:
            self.btnDataTypeTapped(sender: self.btnRadon)
            break
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
                    self.searchViewHeightConstant?.constant = 0.0
                }else {
                    self.searchViewHeightConstant?.constant = 50.0
                    self.searchView?.isHidden = false
                }
            }else {
                self.searchView?.isHidden = true
                self.searchViewHeightConstant?.constant = 0.0
            }
        }else  {
            self.addDeviceViewNewGood()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarTextColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.isChartViewPresent = false
        if let tabBarVC = self.tabBarController as? LuftTabbarViewController {
            if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
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
        self.isSelectedDeviceRow = 0
        NotificationCenter.default.removeObserver(self)
    }
    
    func backGroundDatafetch()  {
        if BackgroundDataAPIManager.shared.isCompleted == true {
            //BackgroundDataAPIManager.shared.individualData = self
            self.getDeviceBackSync()
            self.callSyncWifiChartBackGroundModeDeviceDetails()
        }else {
            self.hidelblLoading()
            return
        }
    }
    
    func callSyncWifiChartBackGroundModeDeviceDetails(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            DispatchQueue.global(qos: .background).async {
                //BackgroundDataAPIManager.shared.individualData = self
                BackgroundDataAPIManager.shared.callSyncBackGroundDeviceDetailsAPI()
                self.isShowData = true
                BackgroundDataAPIManager.shared.allReadingData = self
                DispatchQueue.main.async {
                }
            }
        }
    }
}

final class myCustomLabel: IAxisValueFormatter {
    
    var typeVal : DataTypeFilterEnum?
    
    init(typeData: DataTypeFilterEnum){
        self.typeVal = typeData
    }
    
//    func `init`(typeVal: DataTypeFilterEnum){
//        self.typeVal = typeVal
//    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        debugPrint("value is \(value)")
        var string = balloonMarkerData.unitString
        if balloonMarkerData.unitString == BQM3Format{
            string =  "Bq/m\u{00B3}"
        }
        if AppSession.shared.getAutoScale(){
            switch self.typeVal {
            case .co2:
                //0
                return String(format: "%@ %@", String(format: "%.0f", round(value)), string)
            case .temperature:
                // baloon both c n f show 1 precision, no changes in y axis
                //1
                return String(format: "%@ %@", value.string(maximumFractionDigits: 1), string)
            case .voc:
                //0
                return String(format: "%@ %@", String(format: "%.0f", round(value)), string)
            case .airPressure:
                // inhg
                   // 2 precision y axis, no changes in balloon
               //mbar
                // 0 precision y axis, no changes in balloon
                //0
                if balloonMarkerData.unitString == INHG{
                    return String(format: "%@ %@", value.string(maximumFractionDigits: 2), string)
                }
                else{
                    //0
                    return String(format: "%@ %@", value.string(maximumFractionDigits: 1), string)
                }
                
            case .humidity:
                //1
               return String(format: "%@ %@", String(format: "%.0f", round(value)), string)
            case .radon:
                if balloonMarkerData.unitString == PCIL{
                    return String(format: "%@ %@", value.string(maximumFractionDigits: 2), string)
                }
                else{
                    return String(format: "%@ %@", String(format: "%.0f", round(value)), string)
                }
                
            default:
                return ""
            }
            
            
        }
        else{
            return String(format: "%@ %@", value.string(maximumFractionDigits: 1), string)
        }
        
    }
}

// UIButton UI and Methods
extension ChartViewController{
    
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
    
    func moveToAddDevice(isfromDefault:Bool)  {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "AddDeviceViewController") as! AddDeviceViewController
//        vc.connectedBleDeviceDelegate = self
//        vc.addDeviceDataDelegateStatus = self
//        vc.isfromDefaultAddDevice = isfromDefault
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
    
    func initialButtonsetups(){
        
        self.btn24Hrs.titleLabel?.font = UIFont.setAppFontMedium(12)
        self.btn24Hrs.backgroundColor = UIColor.clear
        self.btn24Hrs.setTitleColor(ThemeManager.currentTheme().chartButtonTitleColor, for: .normal)
        self.btn24Hrs.layer.borderColor = ThemeManager.currentTheme().chartBorderColor.cgColor
        self.btn24Hrs.layer.borderWidth = 1.0
        self.btn24Hrs.clipsToBounds = true
        self.btn24Hrs.layer.cornerRadius = 18
        
        self.btn7Days.titleLabel?.font = UIFont.setAppFontMedium(12)
        self.btn7Days.backgroundColor = UIColor.clear
        self.btn7Days.setTitleColor(ThemeManager.currentTheme().chartButtonTitleColor, for: .normal)
        self.btn7Days.layer.borderColor = ThemeManager.currentTheme().chartBorderColor.cgColor
        self.btn7Days.clipsToBounds = true
        self.btn7Days.layer.borderWidth = 1.0
        self.btn7Days.layer.cornerRadius = 18
        
        self.btnMonths.titleLabel?.font = UIFont.setAppFontMedium(12)
        self.btnMonths.backgroundColor = UIColor.clear
        self.btnMonths.setTitleColor(ThemeManager.currentTheme().chartButtonTitleColor, for: .normal)
        self.btnMonths.layer.borderColor = ThemeManager.currentTheme().chartBorderColor.cgColor
        self.btnMonths.layer.borderWidth = 1.0
        self.btnMonths.layer.cornerRadius = 18
        
        self.btnYear.titleLabel?.font = UIFont.setAppFontMedium(12)
        self.btnYear.backgroundColor = UIColor.clear
        self.btnYear.setTitleColor(ThemeManager.currentTheme().chartButtonTitleColor, for: .normal)
        self.btnYear.layer.borderColor = ThemeManager.currentTheme().chartBorderColor.cgColor
        self.btnYear.layer.cornerRadius = 18
        self.btnYear.layer.borderWidth = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.btnYear.contentHorizontalAlignment = .center;
            self.btnMonths.contentHorizontalAlignment = .center;
            self.btn7Days.contentHorizontalAlignment = .center;
            self.btn24Hrs.contentHorizontalAlignment = .center;
        }
        

        
        
    }
    
    @IBAction func btnHourDaysYearButtonsTapped(sender: UIButton) {
        self.btnHoursDayYearReset()
        //        lineChartView.marker = nil
        lineChartView.highlightValue(nil, callDelegate: false)
        // self.showAct()
        
        if sender.tag == 2001{
            self.btnFilterTypeEnabled(btn: self.btn24Hrs)
            self.filterTypeVal = FilterTypeEnum.Hours24
            balloonMarkerData.dateFormat = "h:mm a"
            ChartFilterType = self.filterTypeVal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.hideActivityIndicator(self.view)
                self.readChartDataFromDB()
            }
        }
        else if sender.tag == 2002{
            self.btnFilterTypeEnabled(btn: self.btn7Days)
            self.filterTypeVal = FilterTypeEnum.Days7
            balloonMarkerData.dateFormat = "E, h a"
            ChartFilterType = self.filterTypeVal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.hideActivityIndicator(self.view)
                self.readChartDataFromDB()
            }
        }
        else if sender.tag == 2003{
            self.btnFilterTypeEnabled(btn: self.btnMonths)
            self.filterTypeVal = FilterTypeEnum.Month
            balloonMarkerData.dateFormat = "MMM d"
            ChartFilterType = self.filterTypeVal
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.hideActivityIndicator(self.view)
                self.readChartDataFromDB()
            }
        }
        else if sender.tag == 2004{
            self.showAct()
            self.btnFilterTypeEnabled(btn: self.btnYear)
            self.filterTypeVal = FilterTypeEnum.Year
            balloonMarkerData.dateFormat = "MMM d, yyyy"
            ChartFilterType = self.filterTypeVal
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hideActivityIndicator(self.view)
                self.readChartDataFromDB()
            }
        }
    }
    
    @IBAction func btnDataTypeTapped(sender: UIButton) {
        self.buttonDataTypeReset()
        lineChartView.highlightValue(nil, callDelegate: false)
        if sender.tag == 1001{
            self.tappedButtonName = "RadonSwitch"
            self.btnDataTypeFilterTypeEnabled(btn: self.btnRadon)
            self.typeVal = DataTypeFilterEnum.radon
            
            let temp = AppSession.shared.getMobileUserMeData()
            
            if temp?.radonUnitTypeId == 2{
                balloonMarkerData.unitString = "pCi/l"
                balloonMarkerData.numberPrecision = 1
            }
            else if temp?.radonUnitTypeId == 1{
                balloonMarkerData.unitString = BQM3Format
                balloonMarkerData.numberPrecision = 0
            }
            updateButtonColorsBasedOnAverage()
        }
        else if sender.tag == 1002{
            self.tappedButtonName = "TVOCSwitch"
            self.btnDataTypeFilterTypeEnabled(btn: self.btnVoc)
            self.typeVal = DataTypeFilterEnum.voc
            balloonMarkerData.unitString = "ppb"
            balloonMarkerData.numberPrecision = 0
            updateButtonColorsBasedOnAverage()
        }
        else if sender.tag == 1003{
            self.tappedButtonName = "ECO2Switch"
            
            self.btnDataTypeFilterTypeEnabled(btn: self.btnCo2)
            self.typeVal = DataTypeFilterEnum.co2
            balloonMarkerData.unitString = "ppm"
            balloonMarkerData.numberPrecision = 0
            
            updateButtonColorsBasedOnAverage()
        }
        else if sender.tag == 1004{
           
            self.tappedButtonName = "TemperatureSwitch"
            
            self.btnDataTypeFilterTypeEnabled(btn: self.btnTemperature)
            self.typeVal = DataTypeFilterEnum.temperature
            let temp = AppSession.shared.getMobileUserMeData()
            
            if temp?.temperatureUnitTypeId == 1{
                balloonMarkerData.unitString = "F"
            }
            else{
                balloonMarkerData.unitString = "C"
            }
            if AppSession.shared.getAutoScale(){
                balloonMarkerData.numberPrecision = 1
            }
            else{
                balloonMarkerData.numberPrecision = 0
            }
            updateButtonColorsBasedOnAverage()
            
        }
        else if sender.tag == 1005{
            self.tappedButtonName = "HumiditySwitch"
            self.btnDataTypeFilterTypeEnabled(btn: self.btnHumidity)
            self.typeVal = DataTypeFilterEnum.humidity
            balloonMarkerData.unitString = "%"
            balloonMarkerData.numberPrecision = 0
            updateButtonColorsBasedOnAverage()
        }
        else if sender.tag == 1006 {
            
            self.tappedButtonName = "AirPressureSwitch"
            self.btnDataTypeFilterTypeEnabled(btn: self.btnAirPressure)
            self.typeVal = DataTypeFilterEnum.airPressure
            
            let temp = AppSession.shared.getMobileUserMeData()
            
            if temp?.pressureUnitTypeId == 2{
                balloonMarkerData.unitString = "inHg"
                balloonMarkerData.numberPrecision = 2
            }
            else {
                balloonMarkerData.unitString = "mbar"
                balloonMarkerData.numberPrecision = 0
            }
            updateButtonColorsBasedOnAverage()
            
        }
        self.readChartDataFromDB()
    }
    func btnHoursDayYearReset(){
        self.initialButtonsetups()
        
    }
    func btnFilterTypeEnabled(btn:UIButton){
        //        btn.layer.borderColor = UIColor.init(hexString: "#007AFF").cgColor
        btn.backgroundColor = UIColor.init(hexString: "#007AFF")
        btn.titleLabel?.textColor = ThemeManager.currentTheme().selectionButtonTextColor
        
        
        
        //        self.btnYear.titleLabel?.font = UIFont.setAppFontMedium(12)
        //        self.btnYear.backgroundColor = UIColor.clear
        //        self.btnYear.setTitleColor(ThemeManager.currentTheme().chartButtonTitleColor, for: .normal)
        //        self.btnYear.layer.borderColor = ThemeManager.currentTheme().chartBorderColor.cgColor
        //        self.btnYear.layer.cornerRadius = 16.5
    }
    
    func buttonDataTypeReset()  {
        self.btnRadon.backgroundColor = UIColor.clear
        self.btnVoc.backgroundColor = UIColor.clear
        self.btnCo2.backgroundColor = UIColor.clear
        self.btnTemperature.backgroundColor = UIColor.clear
        self.btnHumidity.backgroundColor = UIColor.clear
        self.btnAirPressure.backgroundColor = UIColor.clear
    }
    func btnDataTypeFilterTypeEnabled(btn:UIButton){
        btn.backgroundColor = ThemeManager.currentTheme().chartButtonSelectionColor
    }
}

extension ChartViewController {
    
    func addm3CubeToString(label: UILabel, value: String) {
        if balloonMarkerData.unitString == BQM3Format{
            let numberString = NSMutableAttributedString(string: "\(value) Bq/m\u{00B3}", attributes: [.font: UIFont.setSystemFontBold(20)])
            label.attributedText = numberString
        }
        else{
            
        }
    }
    
    func readChartDataFromDB() {
        if self.isChartViewPresent == false {
            return
        }
        self.chartDataValues.removeAll()
        var newListVal : [RealmPollutantValuesTBL]? = nil
        
        var result:(array: [RealmPollutantValuesTBL], average: AverageValues)?
        if filterTypeVal == .Hours24{
            
            result = RealmDataManager.shared.getRealMPollutantValues24HoursFiltered(deviceID: selectedDeviceID, endDate: Date())
            
        }else if filterTypeVal == .Overall{
            result = RealmDataManager.shared.getRealMPollutantValues1YearFiltered(deviceID: selectedDeviceID, endDate: Date())
            
        }
        else if filterTypeVal == .Days7{
            result = RealmDataManager.shared.getRealMPollutantValues7DaysFiltered(deviceID: selectedDeviceID, endDate: Date())
            
        }
        else if filterTypeVal == .Month{
            result = RealmDataManager.shared.getRealMPollutantValues1MonthFiltered(deviceID: selectedDeviceID, endDate: Date())
            
        }
        else if filterTypeVal == .Year{
            result = RealmDataManager.shared.getRealMPollutantValues1YearFiltered(deviceID: selectedDeviceID, endDate: Date())
            
        }
        
        newListVal = result?.array ?? []
        
        averageValues = result?.average
        
       // self.updateButtonColorsBasedOnAverage()
        
        
        
        
        
        if let newList = newListVal{
            for item in newList{
                if item.dummyValue != -1000{
                    let tempUserData  = AppSession.shared.getMobileUserMeData()
                    var airPressure = item.AirPressure
                    var temperature = item.Temperature
                    var radon = item.Radon
                    if tempUserData?.pressureUnitTypeId == 1 || tempUserData?.pressureUnitTypeId == 0 || tempUserData?.pressureUnitTypeId == nil{
                        //                        airPressure = item.AirPressure *  3.38639 // inHg to mBar
                        airPressure = Float(Helper.shared.convertAirPressureINHGToMBAR(value: item.AirPressure))
                    }
                    
                    if tempUserData?.temperatureUnitTypeId == 2{
                        //                        temperature = (item.Temperature - 32) / 1.8 // f to celsius
                        temperature = Helper.shared.convertTemperatureFahrenheitToCelsius(value: item.Temperature)
                    }
                    
                    if tempUserData?.radonUnitTypeId == 1{
                        
                        radon = Helper.shared.convertRadonPCILToBQM3(value: item.Radon)
                    }
                    
                    
                    chartDataValues.append(LineChartModel(QuickSync: 0, Device_ID: item.Device_ID, LogIndex: item.LogIndex, Temperature: temperature, CO2: item.CO2, Radon: radon, AirPressure: airPressure, VOC: item.VOC, date: item.date, Humidity: item.Humidity, dateTimeStamp: Int(item.date.toMillis()), onlyDate: item.onlyDate, WeekValue: item.WeekValue, dummyValue: item.dummyValue))
                }
            }
            
            
            // unit convert average values
            let tempUserData  = AppSession.shared.getMobileUserMeData()
            
            let airPressure = averageValues?.airPressureAverage
            let temperature = averageValues?.temperatureAverage
            let radon = averageValues?.radonAverage
            if tempUserData?.pressureUnitTypeId == 1 || tempUserData?.pressureUnitTypeId == 0 || tempUserData?.pressureUnitTypeId == nil{
                averageValues?.airPressureAverage = Float(Helper.shared.convertAirPressureINHGToMBAR(value: airPressure ?? 0.0))
            }
            
            if tempUserData?.temperatureUnitTypeId == 2{
                averageValues?.temperatureAverage = Helper.shared.convertTemperatureFahrenheitToCelsius(value: temperature ?? 0.0)
            }
            
            if tempUserData?.radonUnitTypeId == 1{
                averageValues?.radonAverage = Helper.shared.convertRadonPCILToBQM3(value: radon ?? 0.0)
            }
            
            switch typeVal {
            case DataTypeFilterEnum.radon:
                let minVal = chartDataValues.min { $0.Radon < $1.Radon }
                self.chartMinimumVal = (Double(minVal?.Radon ?? 0.0)) // * 0.9
                let maxVal = chartDataValues.max { $0.Radon < $1.Radon }
                self.chartMaximumVal = (Double(maxVal?.Radon ?? 0.0)) //* 1.5
                
                
                var value = averageValues?.radonAverage ?? 0.0
                if value.isNaN{
                    value = 0.00
                }
                
                let valueString: String = getStringBasedOnPrecision(value: value)
                averageDataLabel.text = String.init(format: "%@ %@", valueString, balloonMarkerData.unitString)
                self.addm3CubeToString(label: averageDataLabel,value: valueString)
                break
            case  DataTypeFilterEnum.voc:
                let minVal = chartDataValues.min { $0.VOC < $1.VOC }
                self.chartMinimumVal = (Double(minVal?.VOC ?? 0.0))
                let maxVal = chartDataValues.max { $0.VOC < $1.VOC }
                self.chartMaximumVal = (Double(maxVal?.VOC ?? 0.0))
                
                var value = averageValues?.vocAverage ?? 0.0
                if value.isNaN{
                    value = 0.00
                }
                
                let valueString: String = getStringBasedOnPrecision(value: value)
                averageDataLabel.text = String.init(format: "%@ %@", valueString, balloonMarkerData.unitString)
                
                break
            case  DataTypeFilterEnum.co2:
                let minVal = chartDataValues.min { $0.CO2 < $1.CO2 }
                self.chartMinimumVal = (Double(minVal?.CO2 ?? 0.0))
                let maxVal = chartDataValues.max { $0.CO2 < $1.CO2 }
                self.chartMaximumVal = (Double(maxVal?.CO2 ?? 0.0))
                
                var value = averageValues?.co2Average ?? 0.0
                if value.isNaN{
                    value = 0.00
                }
                
                let valueString: String = getStringBasedOnPrecision(value: value)
                averageDataLabel.text = String.init(format: "%@ %@", valueString, balloonMarkerData.unitString)
                
                break
            case  DataTypeFilterEnum.temperature:
                let minVal = chartDataValues.min { $0.Temperature < $1.Temperature }
                self.chartMinimumVal = (Double(minVal?.Temperature ?? 0.0))
                let maxVal = chartDataValues.max { $0.Temperature < $1.Temperature }
                self.chartMaximumVal = (Double(maxVal?.Temperature ?? 0.0))
                
                var value = averageValues?.temperatureAverage ?? 0.0
                if value.isNaN{
                    value = 0.00
                }
                
                let valueString: String = getStringBasedOnPrecision(value: value)
                averageDataLabel.text = String.init(format: "%@ %@", valueString, balloonMarkerData.unitString)
                
                break
            case  DataTypeFilterEnum.humidity:
                let minVal = chartDataValues.min { $0.Humidity < $1.Humidity }
                self.chartMinimumVal = (Double(minVal?.Humidity ?? 0.0))
                let maxVal = chartDataValues.max { $0.Humidity < $1.Humidity }
                self.chartMaximumVal = (Double(maxVal?.Humidity ?? 0.0))
                
                var value = averageValues?.humidityAverage ?? 0.0
                if value.isNaN{
                    value = 0.00
                }
                
                let valueString: String = getStringBasedOnPrecision(value: value)
                averageDataLabel.text = String.init(format: "%@ %@", valueString, balloonMarkerData.unitString)
                
                break
            case  DataTypeFilterEnum.airPressure:
                let minVal = chartDataValues.min { $0.AirPressure < $1.AirPressure }
                self.chartMinimumVal = (Double(minVal?.AirPressure ?? 0.0))
                let maxVal = chartDataValues.max { $0.AirPressure < $1.AirPressure }
                self.chartMaximumVal = (Double(maxVal?.AirPressure ?? 0.0))
                
                var value = averageValues?.airPressureAverage ?? 0.0
                if value.isNaN{
                    value = 0.00
                }else {
                    var isLocalAltitudeINHG: Float = 0.0
                    var isLocalAltitudeMBAR: Float = 0.0
                    if Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isAltitude == true {
                        isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeINHG
                        isLocalAltitudeMBAR = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeMBAR
                        if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
                            value = value + isLocalAltitudeINHG
                            self.chartMinimumVal = self.chartMinimumVal + Double(isLocalAltitudeINHG)
                            self.chartMaximumVal = self.chartMaximumVal + Double(isLocalAltitudeINHG)
                            
                        }else {
                            self.chartMinimumVal = self.chartMinimumVal + Double(isLocalAltitudeMBAR)
                            self.chartMaximumVal = self.chartMaximumVal + Double(isLocalAltitudeMBAR)
                            value = value + isLocalAltitudeMBAR
                        }
                        
                    }
                }
                
                let valueString: String = getStringBasedOnPrecision(value: value)
//                print(valueString)
                averageDataLabel.text = String.init(format: "%@ %@", valueString, balloonMarkerData.unitString)
                
                break
            default:
                let minVal = chartDataValues.min { $0.Radon < $1.Radon }
                self.chartMinimumVal = (Double(minVal?.Radon ?? 0.0))
                let maxVal = chartDataValues.max { $0.Radon < $1.Radon }
                self.chartMaximumVal = (Double(maxVal?.Radon ?? 0.0))
                break
            }
            
            defaultMinValueFromDB = self.chartMinimumVal
            defaultMaxValueFromDB = self.chartMaximumVal
            
            self.initializeChartDetails()
        }
        self.lineChartView.noDataFont = UIFont.setAppFontRegular(14)
        if  let deviceDataSerialNameID = UserDefaults.standard.object(forKey: "Selected_DeviceName_SerialID") {
            if (RealmDataManager.shared.getDataDeviceDataValues(deviceSerialID: deviceDataSerialNameID as! String)) {
                self.hidelblLoading()
                if (newListVal ?? []).count == 0{
                    if BackgroundDataAPIManager.shared.isWholeDataSyncCompleted == true{
                        self.lineChartView.noDataText = "No data available to display. If this device was recently added to your account, it will take up to 90 minutes before the first data point is available. If device was previously connected, verify device connection status. If necessary, reconnect or repower your device."
                        
                    }else {
                        self.lineChartView.noDataText = "Loading Data..."
                    }
                    self.lineChartView.noDataTextAlignment = .center
                    self.lineChartView.data = nil
                    return
                }
            }else if self.isWholeBackGroundAPICompleted == false && BackgroundDataAPIManager.shared.isWholeDataSyncCompleted == false  {
                self.lineChartView.noDataText = "Loading Data..."
                self.lineChartView.noDataTextAlignment = .center
                self.lineChartView.data = nil
                self.hidelblLoading()
                return
            }else if BackgroundDataAPIManager.shared.isCompleted == true && self.isBackGroundAPICompleted == true {
                if (newListVal ?? []).count == 0{
                    
                    if BackgroundDataAPIManager.shared.isWholeDataSyncCompleted == true{
                        if BackgroundDataAPIManager.shared.isCompleted == true {
                            self.lineChartView.noDataText = "No data available to display. If this device was recently added to your account, it will take up to 90 minutes before the first data point is available. If device was previously connected, verify device connection status. If necessary, reconnect or repower your device."
                        }
                    }else {
                        self.lineChartView.noDataText = "Loading Data..."
                    }
                    self.lineChartView.noDataTextAlignment = .center
                    self.lineChartView.data = nil
                    return
                }
                else{
                    //            noChartDataLabel.isHidden = true
                }
            }
        }
    }
    
    
    func getStringBasedOnPrecision(value: Float)-> String{
        switch balloonMarkerData.numberPrecision {
        case 0:
            return String.init(format: "%.0f", round(value))
        case 1:
            return String.init(format: "%.1f", value)
            
        case 2:
            return String.init(format: "%.2f", value)
            
        default:
            break
        }
        
        return ""
    }
    
    func refreshTileColor(color: UIColor){
        self.btnSelectedDevice.backgroundColor = color
    }
    
    
    func garyColorButtons(){
        if UserDefaults.standard.bool(forKey: "RadonSwitch") ==  false {
            self.btnRadon.setTitleColor(.gray, for: .normal)
        }else{
            self.btnRadon.setTitleColor(Helper.shared.getRadonColor(myValue: averageValues?.radonAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
        }
        
        if UserDefaults.standard.bool(forKey: "TemperatureSwitch") ==  false {
            self.btnTemperature.setTitleColor(.gray, for: .normal)
        }else{
            self.btnTemperature.setTitleColor( Helper.shared.getTempeatureColor(myValue: averageValues?.temperatureAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
        }
        
        if UserDefaults.standard.bool(forKey: "HumiditySwitch") ==  false {
            self.btnHumidity.setTitleColor(.gray, for: .normal)
        }else{
            self.btnHumidity.setTitleColor( Helper.shared.getHumidityColor(myValue: averageValues?.humidityAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
        }
        
        if UserDefaults.standard.bool(forKey: "AirPressureSwitch") ==  false {
            self.btnAirPressure.setTitleColor(.gray, for: .normal)
        }else{
            self.btnAirPressure.setTitleColor(Helper.shared.getAirPressueColor(myValue: averageValues?.airPressureAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
        }
        
        if UserDefaults.standard.bool(forKey: "ECO2Switch") ==  false {
            self.btnCo2.setTitleColor(.gray, for: .normal)
        }else{
            self.seteCO2Text(color: Helper.shared.getECO2Color(myValue: averageValues?.co2Average ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color)
        }
        
        if UserDefaults.standard.bool(forKey: "TVOCSwitch") ==  false {
            self.btnVoc.setTitleColor(.gray, for: .normal)
        }else{
            self.btnVoc.setTitleColor( Helper.shared.getVOCColor(myValue: averageValues?.vocAverage ?? 0.0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
        }
        
    }
    
    func updateButtonColorsBasedOnAverage(){
        
        if UserDefaults.standard.bool(forKey:  self.tappedButtonName) == true {
            self.btnTemperature.setTitleColor( Helper.shared.getTempeatureColor(myValue: averageValues?.temperatureAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
        }
        else{
            self.garyColorButtons()
//            self.btnTemperature.setTitleColor(.gray, for: .normal)
            if self.btnRadon.currentTitleColor == .gray && self.tappedButtonName == "RadonSwitch"{
                self.switchScale.isOn =  true
                AppSession.shared.setAutoScale(isAutoScale: true)
            }else{
                self.switchScale.isOn =  false
            }
            
            if self.btnTemperature.currentTitleColor == .gray && self.tappedButtonName == "TemperatureSwitch"{
                self.switchScale.isOn =  true
                AppSession.shared.setAutoScale(isAutoScale: true)
            }else{
                self.switchScale.isOn =  false
            }
            
            if self.btnHumidity.currentTitleColor == .gray && self.tappedButtonName == "HumiditySwitch"{
                self.switchScale.isOn =  true
                AppSession.shared.setAutoScale(isAutoScale: true)
            }else{
                self.switchScale.isOn =  false
            }
            
            if self.btnAirPressure.currentTitleColor == .gray && self.tappedButtonName == "AirPressureSwitch"{
                self.switchScale.isOn =  true
                AppSession.shared.setAutoScale(isAutoScale: true)
            }else{
                self.switchScale.isOn =  false
            }
            
            if self.btnCo2.currentTitleColor == .gray && self.tappedButtonName == "ECO2Switch"{
                self.switchScale.isOn =  true
                AppSession.shared.setAutoScale(isAutoScale: true)
            }else{
                self.switchScale.isOn =  false
            }
            
            if self.btnVoc.currentTitleColor == .gray && self.tappedButtonName == "TVOCSwitch"{
                self.switchScale.isOn =  true
                AppSession.shared.setAutoScale(isAutoScale: true)
            }else{
                self.switchScale.isOn =  false
            }
            
//            if UserDefaults.standard.bool(forKey: "genericSwitchChart") == true {
//                AppSession.shared.setAutoScale(isAutoScale: false)
//            }else{
//                AppSession.shared.setAutoScale(isAutoScale: true)
//            }
        }
     
        self.garyColorButtons()
        
        
        
//        UserDefaults.standard.set(false, forKey: "genericSwitchChart")
        
//        if UserDefaults.standard.bool(forKey: "RadonSwitch") == true {
//            self.btnRadon.setTitleColor(Helper.shared.getRadonColor(myValue: averageValues?.radonAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
//        }else{
//            self.btnRadon.setTitleColor(.gray, for: .normal)
//            self.switchScale.isOn = true
//        }
        
//       self.btnRadon.setTitleColor(Helper.shared.getRadonColor(myValue: averageValues?.radonAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
//        self.btnVoc.setTitleColor( Helper.shared.getVOCColor(myValue: averageValues?.vocAverage ?? 0.0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
////        self.btnTemperature.setTitleColor( Helper.shared.getTempeatureColor(myValue: averageValues?.temperatureAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
//        self.btnHumidity.setTitleColor( Helper.shared.getHumidityColor(myValue: averageValues?.humidityAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
//        self.btnAirPressure.setTitleColor(Helper.shared.getAirPressueColor(myValue: averageValues?.airPressureAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color, for: .normal)
//        self.seteCO2Text(color: Helper.shared.getECO2Color(myValue: averageValues?.co2Average ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color)
        
        
        switch self.typeVal {
        case DataTypeFilterEnum.radon:
            refreshTileColor(color: Helper.shared.getRadonColor(myValue: averageValues?.radonAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color)
            break
        case DataTypeFilterEnum.voc:
            refreshTileColor(color: Helper.shared.getVOCColor(myValue: averageValues?.vocAverage ?? 0.0, deviceId: self.selectedDeviceID.toInt() ?? 0).color)
            break
        case DataTypeFilterEnum.co2:
            refreshTileColor(color: Helper.shared.getECO2Color(myValue: averageValues?.co2Average ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color)
            break
        case DataTypeFilterEnum.temperature:
            refreshTileColor(color: Helper.shared.getTempeatureColor(myValue: averageValues?.temperatureAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color)
            break
        case DataTypeFilterEnum.humidity:
            refreshTileColor(color: Helper.shared.getHumidityColor(myValue: averageValues?.humidityAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color)
            break
        case DataTypeFilterEnum.airPressure:
            refreshTileColor(color: Helper.shared.getAirPressueColor(myValue: averageValues?.airPressureAverage ?? 0, deviceId: self.selectedDeviceID.toInt() ?? 0).color)
            break
        default:
            print("DB")
            break
            //            limit = Double(self.chartDataValues[index].Radon)
            
            break
        }
        
        
        //        self.colorRadonType = Helper.shared.getRadonColor(myValue: averageValues?.radonAverage ?? 0, deviceId: GlobalDeviceID).type
        //        self.colorVocType = Helper.shared.getVOCColor(myValue: averageValues?.vocAverage ?? 0.0, deviceId: GlobalDeviceID).type
        //        self.colorEco2Type = Helper.shared.getECO2Color(myValue: averageValues?.co2Average ?? 0, deviceId: GlobalDeviceID).type
        //        self.colorTempType = Helper.shared.getTempeatureColor(myValue: averageValues?.temperatureAverage ?? 0, deviceId: GlobalDeviceID).type
        //        self.colorAirpressureType = Helper.shared.getAirPressueColor(myValue: averageValues?.airPressureAverage ?? 0, deviceId: GlobalDeviceID).type
        //        self.colorHumidityType = Helper.shared.getHumidityColor(myValue: averageValues?.humidityAverage ?? 0, deviceId: GlobalDeviceID).type
        //
        //        if self.colorRadonType == ColorType.ColorAlert || self.colorVocType == ColorType.ColorAlert || self.colorEco2Type == ColorType.ColorAlert || self.colorTempType == ColorType.ColorAlert || self.colorAirpressureType == ColorType.ColorAlert || self.colorHumidityType == ColorType.ColorAlert {
        //            self.btnSelectedDevice.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: GlobalDeviceID, colorType: .ColorAlert))
        //
        //        }else if self.colorRadonType == ColorType.ColorWarning || self.colorVocType == ColorType.ColorWarning || self.colorEco2Type == ColorType.ColorWarning || self.colorTempType == ColorType.ColorWarning || self.colorAirpressureType == ColorType.ColorWarning || self.colorHumidityType == ColorType.ColorWarning {
        //            self.btnSelectedDevice.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: GlobalDeviceID, colorType: .ColorWarning))
        //        }else {
        //            self.btnSelectedDevice.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: GlobalDeviceID, colorType: .ColorOk))
        //        }
    }
    
    
    
    func chartType(type:Int) {
        switch type {
        case 1:
            break
        default:
            print("No data")
        }
    }
}

extension Double {
    func string(maximumFractionDigits: Int = 2) -> String {
        let s = String(format: "%.\(maximumFractionDigits)f", self)
        var offset = -maximumFractionDigits - 1
        for i in stride(from: 0, to: -maximumFractionDigits, by: -1) {
            if s[s.index(s.endIndex, offsetBy: i - 1)] != "0" {
                offset = i
                break
            }
        }
        return String(s[..<s.index(s.endIndex, offsetBy: offset)])
    }
}

// MARK: - Extensions
extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    public func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
//MARK: Chart Data
extension ChartViewController{
    
    
    func luftMateFullDateFormat(dateStr:String) -> String
    {
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss" //Your date format
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        if date == nil {
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let date1 = dateFormatter.date(from: dateStr)
            if date1 == nil{
                return ""
            }else {
                dateFormatter.dateFormat = "HH"
                let newDateString = dateFormatter.string(from: date1!)
                
                return newDateString
            }
        }
        //Convert String to Date
        dateFormatter.dateFormat = "HH"
        let newDateString = dateFormatter.string(from: date!)
        
        return newDateString
    }
    func setChartValues(_ count : Int = 20) {
        let values = (0..<count).map { (i) -> ChartDataEntry in
            let val = Double(self.chartValues[i])
            return ChartDataEntry(x: Double(i), y: val)
        }
        let dataSet =  LineChartDataSet(entries: values, label: "")
        let data = LineChartData(dataSet: dataSet)
        
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 4
        dataSet.colors = [UIColor.green]
        dataSet.circleRadius = 0
        dataSet.circleColors = [UIColor.green]
        dataSet.drawCircleHoleEnabled = false
        dataSet.fillColor = UIColor.green
        dataSet.fillAlpha = 0.5
        
        //        let leftAxis = self.lineChartView.leftAxis
        //        leftAxis.labelCount = self.chartValues.count
        //        leftAxis.valueFormatter = myCustomLabel()
        self.lineChartView.rightAxis.enabled = false

        
        
        self.lineChartView.data = data
        self.lineChartView.xAxis.enabled = false
        
        self.lineChartView.rightAxis.drawLabelsEnabled = false
        self.lineChartView.rightAxis.drawAxisLineEnabled = false
        self.lineChartView.legend.enabled = false
        self.lineChartView.chartDescription?.text = ""
        
        self.lineChartView!.leftAxis.drawLabelsEnabled = true
        self.lineChartView!.leftAxis.drawAxisLineEnabled = false
        self.lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        dataSet.drawValuesEnabled = false
        
        self.setLimitLine(limitValue: self.chartLimitLineValue1, chartView: self.lineChartView, lineColor: UIColor.red)
        self.setLimitLine(limitValue: self.chartLimitLineValue2, chartView: self.lineChartView, lineColor: UIColor.red)
        self.lineChartView.backgroundColor = UIColor.init(hexString: "#F0F3F5")
    }
    
    func setLimitLine(limitValue:Double,chartView:LineChartView,lineColor: UIColor)  {
        let limit1 = ChartLimitLine(limit: limitValue, label: "")
        limit1.lineColor = lineColor
        limit1.lineDashLengths = [4.0, 2.0]
        self.lineChartView.leftAxis.addLimitLine(limit1)
    }
    
    func initializeChartDetails(){
        lineChartView.clear()
        lineChartView.clearValues()
        lineChartView.notifyDataSetChanged()
        lineChartView.fitScreen()
        
        self.options = [.toggleValues,
                        .toggleFilled,
                        .toggleCircles,
                        .toggleCubic,
                        .toggleHorizontalCubic,
                        .toggleIcons,
                        .toggleStepped,
                        .toggleHighlight,
                        .animateX,
                        .animateY,
                        .animateXY,
                        .saveToGallery,
                        .togglePinchZoom,
                        .toggleAutoScaleMinMax,
                        .toggleData]
        
        lineChartView.delegate = self
        lineChartView.data = nil
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(false)
        lineChartView.pinchZoomEnabled = false
        lineChartView.autoScaleMinMaxEnabled = false
        
        
        let deviceData = RealmDataManager.shared.getDeviceDetails(deviceID: selectedDeviceID)
        var lav = 0.0
        var hav = 0.0
        var lwv = 0.0
        var hwv = 0.0
        var data: RealmThresHoldSetting?
        switch self.typeVal {
        case DataTypeFilterEnum.radon:
            data = (deviceData.first { $0.pollutant == DataTypeFilterTitle.radon.rawValue})
            break
        case DataTypeFilterEnum.voc:
            data = (deviceData.first { $0.pollutant == DataTypeFilterTitle.voc.rawValue})
            break
        case DataTypeFilterEnum.co2:
            data = (deviceData.first { $0.pollutant == DataTypeFilterTitle.co2.rawValue})
            break
        case DataTypeFilterEnum.temperature:
            data = (deviceData.first { $0.pollutant == DataTypeFilterTitle.temperature.rawValue})
            break
        case DataTypeFilterEnum.humidity:
            data = (deviceData.first { $0.pollutant == DataTypeFilterTitle.humidity.rawValue})
            break
        case DataTypeFilterEnum.airPressure:
            data = (deviceData.first { $0.pollutant == DataTypeFilterTitle.airPressure.rawValue})
            break
        default:
            print("DB")
            break
            //            limit = Double(self.chartDataValues[index].Radon)
            
            break
        }
        
        
        lav = Double(data?.low_alert_value ?? "0") ?? 0.0
        hav = Double(data?.high_alert_value ?? "0") ?? 0.0
        lwv = Double(data?.low_waring_value ?? "0") ?? 0.0
        hwv = Double(data?.high_waring_value ?? "0") ?? 0.0
        
        let tempUserData  = AppSession.shared.getMobileUserMeData()
        switch self.typeVal {
        case DataTypeFilterEnum.radon:
            if tempUserData?.radonUnitTypeId == 1{
                lav = Double(Helper.shared.convertRadonPCILToBQM3(value: Float(lav)))
                hav = Double(Helper.shared.convertRadonPCILToBQM3(value: Float(hav)))
                lwv = Double(Helper.shared.convertRadonPCILToBQM3(value: Float(lwv)))
                hwv = Double(Helper.shared.convertRadonPCILToBQM3(value: Float(hwv)))
            }
            break
            
        case DataTypeFilterEnum.temperature:
            if tempUserData?.temperatureUnitTypeId == 2{
                lav = Double(Helper.shared.convertTemperatureFahrenheitToCelsius(value: Float(lav)))// f to celsius
                hav =  Double(Helper.shared.convertTemperatureFahrenheitToCelsius(value: Float(hav)))
                lwv = Double(Helper.shared.convertTemperatureFahrenheitToCelsius(value: Float(lwv)))
                hwv =  Double(Helper.shared.convertTemperatureFahrenheitToCelsius(value: Float(hwv)))
                
            }
            break
            
        case DataTypeFilterEnum.airPressure:
            if tempUserData?.pressureUnitTypeId == 1 || tempUserData?.pressureUnitTypeId == 0 || tempUserData?.pressureUnitTypeId == nil {
                lav = Helper.shared.convertAirPressureINHGToMBAR(value: Float(lav))
                hav = Helper.shared.convertAirPressureINHGToMBAR(value: Float(hav))
                lwv = Helper.shared.convertAirPressureINHGToMBAR(value: Float(lwv))
                hwv = Helper.shared.convertAirPressureINHGToMBAR(value: Float(hwv))
            }
            break
        default:
            print("DB")
            break
            
            
        }
        
        var maxVal: Double
        var minVal: Double
        
        if(hwv == 0 || hav == 0)
        {
            maxVal = max(lwv, lav)
            minVal = min(lwv, lav)
        }
        else{
            maxVal = max(lwv, lav, hwv, hav)
            minVal = min(lwv, lav, hwv, hav)
        }
        
        if AppSession.shared.getAutoScale() == false{
            if(self.chartMinimumVal > minVal)
                   {
                       self.chartMinimumVal = minVal
                   }
                   if(self.chartMaximumVal < maxVal)
                   {
                       self.chartMaximumVal = maxVal
                   }
            self.chartMinimumVal = self.getYAxisMinValue(pollutant: self.typeVal, minValue: self.chartMinimumVal, maxValue: self.chartMaximumVal)
            self.chartMaximumVal = self.getYAxisMaxValue(pollutant: self.typeVal, minValue: self.chartMinimumVal, maxValue: self.chartMaximumVal)
        }
        else{
            self.chartMinimumVal = self.defaultMinValueFromDB
            self.chartMaximumVal = self.defaultMaxValueFromDB
        }
        
        
        let colorWarningValue = RealmDataManager.shared.readColorDataValues(deviceID: self.isCurrentSlectedDevice?.device_id ?? 0, colorType: ColorType.ColorWarning.rawValue)
        let colorAlertValue = RealmDataManager.shared.readColorDataValues(deviceID: self.isCurrentSlectedDevice?.device_id ?? 0, colorType: ColorType.ColorAlert.rawValue)
        
        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
            if deviceDataCurrent.wifi_status == true {
                self.imgSelectedDeviceWiFiBleStatus.image = UIImage.init(named: "wifiimg")
            }else {
                self.imgSelectedDeviceWiFiBleStatus.image = UIImage.init(named: "bluetooth")
            }
        }
        
        
        if colorAlertValue.count > 0 && colorWarningValue.count > 0 {
            
            let ll1 = ChartLimitLine(limit: lav, label: "")
            ll1.lineWidth = 4
            ll1.lineDashLengths = [2, 2]
            ll1.lineColor = UIColor.init(hexString:  colorAlertValue[0].color_code)
            ll1.valueFont = .systemFont(ofSize: 8)
            
            let ll2 = ChartLimitLine(limit: hav, label: "")
            ll2.lineWidth = 4
            ll2.lineDashLengths = [2,2]
            ll2.lineColor =  UIColor.init(hexString:  colorAlertValue[0].color_code)
            ll2.valueFont = .systemFont(ofSize: 8)
            
            let ll3 = ChartLimitLine(limit: lwv, label: "")
            ll3.lineWidth = 4
            ll3.lineDashLengths = [2, 2]
            ll3.lineColor = UIColor.init(hexString:  colorWarningValue[0].color_code)
            ll3.valueFont = .systemFont(ofSize: 8)
            
            let ll4 = ChartLimitLine(limit: hwv, label: "")
            ll4.lineWidth = 4
            ll4.lineDashLengths = [2,2]
            ll4.lineColor = UIColor.init(hexString:  colorWarningValue[0].color_code)
            ll4.valueFont = .systemFont(ofSize: 8)
            
            let leftAxis = lineChartView.leftAxis
            leftAxis.removeAllLimitLines()
            
            if(lav != 0.0){
                leftAxis.addLimitLine(ll1)
            }
            
            if(hav != 0.0){
                leftAxis.addLimitLine(ll2)
            }
            
            if(lwv != 0.0){
                leftAxis.addLimitLine(ll3)
            }
            
            if(hwv != 0.0){
                leftAxis.addLimitLine(ll4)
            }
            
            if AppSession.shared.getAutoScale() {
                ll1.lineColor = UIColor.clear
                ll2.lineColor = UIColor.clear
                ll3.lineColor = UIColor.clear
                ll4.lineColor = UIColor.clear
            }else {
                ll1.lineWidth = 2
                ll2.lineWidth = 2
                ll3.lineWidth = 2
                ll4.lineWidth = 2
            }

            
            if AppSession.shared.getAutoScale() {
                let round = chartMaximumVal - chartMinimumVal
                debugPrint("minimum is \(chartMinimumVal)")
                debugPrint("maximum is \(chartMaximumVal)")
                debugPrint("round is \(round)")
                
               
                var maxValueToSet = 0.0
                var minValueToSet = 0.0
                
                if round == 0.0{
                    maxValueToSet = chartMaximumVal + 1
                    minValueToSet = chartMinimumVal
                }
                
                else if round < 1{
                    
                    let minimumValue = chartMinimumVal - (chartMinimumVal * 0.0005)
                    let maximumValue = chartMaximumVal + (chartMaximumVal * 0.0005)
                    maxValueToSet = (maximumValue.getTwoDeicmalValue())
                    minValueToSet = (minimumValue.getTwoDeicmalValue())
                }
                else if round < 2{
                    let minimumValue = chartMinimumVal - (chartMinimumVal * 0.001)
                    let maximumValue = chartMaximumVal + (chartMaximumVal * 0.001)
                    maxValueToSet = ceil(maximumValue)
                    minValueToSet = floor(minimumValue)
                }
                else if round < 10{
                    let minimumValue = chartMinimumVal - (chartMinimumVal * 0.025)
                    let maximumValue = chartMaximumVal + (chartMaximumVal * 0.025)
                    maxValueToSet = ceil(maximumValue)
                    minValueToSet = floor(minimumValue)
                }
                else  if round >= 10 && round < 50{
                    let minimumValue = chartMinimumVal - (chartMinimumVal * 0.05)
                    let maximumValue = chartMaximumVal + (chartMaximumVal * 0.05)
                    maxValueToSet = ceil(maximumValue)
                    minValueToSet = floor(minimumValue)
                }
                else  if round >= 50 && round <= 100{
                    let minimumValue = chartMinimumVal - (chartMinimumVal * 0.1)
                    let maximumValue = chartMaximumVal + (chartMaximumVal * 0.1)
                    maxValueToSet = ceil(maximumValue)
                    minValueToSet = floor(minimumValue)
                }
                else{
                    let minimumValue = chartMinimumVal - (chartMinimumVal * 0.2)
                    let maximumValue = chartMaximumVal + (chartMaximumVal * 0.2)
                    maxValueToSet = ceil(maximumValue)
                    minValueToSet = floor(minimumValue)
                }
                
                if (self.typeVal == .airPressure && AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 1/*mBAR*/) {
                           
                    let tuple = self.getMinMaxValueForAirPressureMBar(minValue:  chartMinimumVal, maxValue: chartMaximumVal)
                    leftAxis.axisMaximum = tuple.1
                    leftAxis.axisMinimum = tuple.0
                          
                }
                else  if (self.typeVal == .radon && AppSession.shared.getMobileUserMeData()?.radonUnitTypeId == 2){ // radon and pcil

                    let tuple = self.getMinMaxValueForRadonPcil(minValue: chartMinimumVal, maxValue: chartMaximumVal)
                    leftAxis.axisMinimum = tuple.0
                    leftAxis.axisMaximum = tuple.1
                                       
                }
                else{
                    leftAxis.axisMaximum = maxValueToSet
                    leftAxis.axisMinimum = minValueToSet
                }
                
                
                
                debugPrint("plotted max is \(leftAxis.axisMaximum)")
                debugPrint("plotted min is \(leftAxis.axisMinimum)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    leftAxis.setLabelCount(6, force: true)
                }
                
            }
            else{
                leftAxis.axisMaximum = chartMaximumVal
                leftAxis.axisMinimum = chartMinimumVal
            }
            
            
            leftAxis.gridColor = ThemeManager.currentTheme().ltChartGridColor
            //            leftAxis.gridLineDashLengths = [1, 1]
            leftAxis.drawZeroLineEnabled = false
            
            lineChartView.xAxis.enabled = false
            lineChartView.rightAxis.enabled = false
            lineChartView.leftAxis.labelTextColor = ThemeManager.currentTheme().chartLabelTextColor
            lineChartView.leftAxis.valueFormatter = myCustomLabel(typeData: self.typeVal)
            lineChartView.leftAxis.axisLineColor = UIColor.clear
            
            let marker = BalloonMarker(color: UIColor.init(netHex: 0x007AFF),
                                       font: .systemFont(ofSize: 12),
                                       textColor: .white,
                                       insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
            marker.chartView = lineChartView
            marker.minimumSize = CGSize(width: 80, height: 40)
            lineChartView.marker = marker
            
            lineChartView.legend.form = .none
            
            self.updateChartData()
            lineChartView.animate(xAxisDuration: 1.0)
        }
        
    }
    
    func getMinMaxValueForRadonPcil(minValue: Double, maxValue: Double)-> (Double, Double){
        
        var valueArray:[Double] = []
        var maxNumber = Int(ceil(maxValue) * 2)
        
        var  multiplyValue = 0.0
        if maxValue < 10{
            multiplyValue = 0.5
        }
        else{
            multiplyValue = 5
        }
       
        maxNumber = Int(ceil(maxValue) * 20)
        
        if maxNumber < 1{
            maxNumber = 1000
        }
        
        
        for item in 1...maxNumber {
            valueArray.append(Double(item) * multiplyValue)
        }
        
        var maxValueToReturn = 0.0
        for item in valueArray{
            if maxValue < item{
                maxValueToReturn = item
                break
            }
        }
        
        var minValueToReturn = 0.0
        for item in valueArray{
            if minValue < item{
                break
            }
            else{
                minValueToReturn = item
                continue
            }
           
        }
        return (minValueToReturn, maxValueToReturn)
    }
    
    func getMinMaxValueForAirPressureMBar(minValue: Double, maxValue: Double)-> (Double, Double){
        var maxValueToReturn = 0.0
        let difference = maxValue - minValue
        
        if difference < 4.5{
            return (floor(minValue), floor(minValue+5))
        }
        else{
            
            var newArray:[Double] = []
            let minValueLow = Int(floor(minValue))
            let maxNumber = Int(ceil(maxValue))
            let minNumber = Int(floor(minValue))
            var index = 1
            for _ in 1...(maxNumber-minNumber){
                newArray.append( Double(minValueLow + (5 * index)) )
                index = index + 1
            }
            for item in newArray{
                if maxValue < item{
                    maxValueToReturn = item
                    break
                }
            }
        }
        
        
        return (Double(Int(minValue)), maxValueToReturn)
    }
    
    func getYAxisMinValue(pollutant: DataTypeFilterEnum, minValue: Double, maxValue: Double)-> Double {
        
        
        
        if (pollutant == DataTypeFilterEnum.radon  || pollutant == DataTypeFilterEnum.co2 || pollutant == DataTypeFilterEnum.voc) {
            return 0.0
        }
        
        var result : Double = minValue
        
        let round = Int(maxValue - minValue)
        let lenght = String.init(format: "%d", round).count
        switch lenght{
        case 2:
            result -= (result.truncatingRemainder(dividingBy: 10))
        case 3:
            result -= (result.truncatingRemainder(dividingBy: 100))
        case 4:
            result -= (result.truncatingRemainder(dividingBy: 100))
        default:
            break
        }
        
        
        //        if (pollutant == DataTypeFilterEnum.airPressure){
        //            if((maxValue - minValue) <= 50){
        //                result = minValue - (minValue * 0.01)
        //            }else if((maxValue - minValue) <= 100){
        //                result = minValue - (minValue * 0.02)
        //            } else if ((maxValue - minValue) <= 500) {
        //                result = minValue - (minValue * 0.1)
        //            } else if ((maxValue - minValue) > 500) {
        //                result = minValue - (minValue * 0.2)
        //            } else {
        //                result = minValue - (minValue * 0.1)
        //            }
        //        } else {
        //            /* if (minValue <= 30) {
        //             result = minValue - (minValue * 0.5f)
        //             } else*/  if (minValue <= 500) {
        //                result = minValue - (minValue * 0.2)
        //             } else {
        //                result = minValue - (minValue * 0.1)
        //            }
        //
        //            let round = Int(result)
        //            let lenght = String.init(format: "%d", round).count
        //
        //
        //            switch lenght{
        //            case 2:
        //                 result -= (result.truncatingRemainder(dividingBy: 10))
        //            case 3:
        //                result -= (result.truncatingRemainder(dividingBy: 100))
        //            case 4:
        //                result -= (result.truncatingRemainder(dividingBy: 100))
        //            default:
        //                break
        //            }
        //
        //
        //        }
        
        return floor(result)
        
    }
    
    func getYAxisMaxValue(pollutant: DataTypeFilterEnum, minValue: Double, maxValue: Double)-> Double {
        
        
        var result : Double = maxValue
        
        let round = Int(maxValue - minValue)
        let lenght = String.init(format: "%d", round).count
        
        switch lenght{
        case 1:
            if (maxValue.truncatingRemainder(dividingBy: 1) != 0) {
                result += 1 - (maxValue.truncatingRemainder(dividingBy: 1))
            }
        case 2:
            if (maxValue.truncatingRemainder(dividingBy: 10) != 0) {
                result += 10 - (maxValue.truncatingRemainder(dividingBy: 10))
            }
            
        default:
            if (maxValue.truncatingRemainder(dividingBy: 100) != 0) {
                result += 100 - (maxValue.truncatingRemainder(dividingBy: 100))
            }
        }
        
        if (result < 6){
            result = 6
        }else if (round > 500){
            result += ((result/7).truncatingRemainder(dividingBy: 100)) + (100 - ((result/7).truncatingRemainder(dividingBy: 100)))
        }
        
        return ceil(result)
        
        //        when(lenght){
        //            1 -> {
        //                if (maxValue % 1 != 0f) {
        //                    result += 1 - (maxValue % 1)
        //                }
        //            }
        //            2 ->{
        //                if (maxValue % 10 != 0f) {
        //                    result += 10 - (maxValue % 10)
        //                }
        //            }
        //            else ->{
        //
        //                if (maxValue % 100 != 0f) {
        //                    result += 100 - (maxValue % 100)
        //                }
        //            }
        //        }
        
        
        
        //        switch pollutant {
        //        case .airPressure:
        //            if((maxValue - minValue) <= 50){
        //                result = maxValue * 1.01
        //            }else if((maxValue - minValue) <= 100){
        //                result = maxValue * 1.02
        //            } else if ((maxValue - minValue) <= 500) {
        //                result = maxValue * 1.1
        //            } else if ((maxValue - minValue) > 500) {
        //                result = maxValue * 1.2
        //            } else {
        //                result = maxValue * 1.1
        //            }
        //        default:
        //            if (maxValue <= 30) {
        //                result = maxValue * 1.3
        //            } else if (maxValue <= 2500) {
        //                result = maxValue * 1.2
        //            } else if (maxValue <= 5000) {
        //                result = maxValue * 1.1
        //            } else {
        //                result = maxValue * 1.1
        //            }
        //
        //            let round = Int(result - minValue)
        //            let lenght = String.init(format: "%d", round).count
        //
        //            switch lenght{
        //            case 2:
        //                result += 10 - (result.truncatingRemainder(dividingBy: 10))
        //            case 3:
        //                result += 100 - (result.truncatingRemainder(dividingBy: 100))
        //            case 4:
        //               result += 1000 - (result.truncatingRemainder(dividingBy: 1000))
        //            default:
        //                break
        //            }
        
        //            when(lenght){
        //                2 ->{
        //                    result += 10 -(result % 10)
        //                }
        //                3 ->{
        //                    result += 100 -(result % 100)
        //                }
        //                4 ->{
        //                    result += 1000 -(result % 1000)
        //                }
        //            }
        //        }
        //        when (pollutant) {
        //            PollutantEnum.AIR_PRESSURE.pollutant -> {
        //                if((maxValue - minValue) <= 50){
        //                    result = maxValue * 1.01
        //                }else if((maxValue - minValue) <= 100){
        //                    result = maxValue * 1.02
        //                } else if ((maxValue - minValue) <= 500) {
        //                    result = maxValue * 1.1
        //                } else if ((maxValue - minValue) > 500) {
        //                    result = maxValue * 1.2
        //                } else {
        //                    result = maxValue * 1.1
        //                }
        //            }
        //            else -> {
        //                if (maxValue <= 30) {
        //                    result = maxValue * 1.3
        //                } else if (maxValue <= 2500) {
        //                    result = maxValue * 1.2
        //                } else if (maxValue <= 5000) {
        //                    result = maxValue * 1.1
        //                } else {
        //                    result = maxValue * 1.1
        //                }
        //
        //                var round = (result - minValue).roundToInt()
        //                var lenght = round.toString().length
        //                when(lenght){
        //                    2 ->{
        //                        result += 10 -(result % 10)
        //                    }
        //                    3 ->{
        //                        result += 100 -(result % 100)
        //                    }
        //                    4 ->{
        //                        result += 1000 -(result % 1000)
        //                    }
        //                }
        //
        //            }
        //        }
        
        
        
    }
    
    func luftDateFormat(dateStr:String) -> String
    {
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" //Your date format
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date1 = dateFormatter.date(from: dateStr)
            if date1 == nil{
                return ""
            }else {
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let newDateString = dateFormatter.string(from: date1!)
                
                return newDateString
            }
        }
        //Convert String to Date
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let newDateString = dateFormatter.string(from: date!)
        debugPrint("newDateString\(newDateString)")
        return newDateString
    }
    
    func setDataCountSets() {
        
        var yVals2 : [ChartDataEntry] = [ChartDataEntry]()
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        chartDataValues = chartDataValues.sorted(by: { $0.LogIndex < $1.LogIndex })
        for i in 0..<chartDataValues.count{
            let xVal = Double(self.chartDataValues[i].LogIndex)//Double(i)
            _ = Double(self.chartDataValues[i].dummyValue)//Double(i)
            
            var yVal:Double = 0.0
            var data : LineChartModel?
            if let index = self.chartDataValues.firstIndex(where: {$0.LogIndex == chartDataValues[i].LogIndex}) {
                data = self.chartDataValues[index]
                switch self.typeVal {
                case DataTypeFilterEnum.radon:
                    yVal = Double(self.chartDataValues[index].Radon)
                    break
                case  DataTypeFilterEnum.voc:
                    yVal = Double(self.chartDataValues[index].VOC)
                    break
                case  DataTypeFilterEnum.co2:
                    yVal = Double(self.chartDataValues[index].CO2)
                    break
                case  DataTypeFilterEnum.temperature:
                    yVal = Double(self.chartDataValues[index].Temperature)
                    break
                case  DataTypeFilterEnum.humidity:
                    yVal = Double(self.chartDataValues[index].Humidity)
                    break
                case  DataTypeFilterEnum.airPressure:
                    yVal = Double(self.chartDataValues[index].AirPressure)
                    var isLocalAltitudeINHG: Float = 0.0
                    var isLocalAltitudeMBAR: Float = 0.0
                    if Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isAltitude == true {
                        isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeINHG
                        isLocalAltitudeMBAR = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeMBAR
                        if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
                            yVal = yVal + Double(isLocalAltitudeINHG)
                        }else {
                            yVal = yVal + Double(isLocalAltitudeMBAR)
                        }
                    }
                    break
                default:
                    print("DB")
                    yVal = Double(self.chartDataValues[index].Radon)
                    break
                }
            }
            
//            if self.typeVal == .radon{
//                yVals2.append(ChartDataEntry(x: xVal, y: yVal, data:data))
//            }
//            else{
                yVals2.append(ChartDataEntry(x: xVal, y: yVal, data:data))
//            }
            
        }
        dataSets.append(formDataSets(chartDataEntry: yVals2, firstLine: true))
        
        var logIndexArr : [Int] = []
        for indexVal in self.chartDataValues{
            logIndexArr.append(indexVal.LogIndex)
        }
        let grouped = logIndexArr.consecutivelyGrouped
        debugPrint("grouped\(grouped)")
        for groupedVal in grouped{
            var tempEntry : [ChartDataEntry] = [ChartDataEntry]()
            for i in 0..<groupedVal.count{
                let xVal:Double = Double(groupedVal[i])
                var yVal:Double = 0.0
                var data : LineChartModel?
                if let index = self.chartDataValues.firstIndex(where: {$0.LogIndex == groupedVal[i]}) {
                    data = self.chartDataValues[index]
                    switch self.typeVal {
                    case  DataTypeFilterEnum.radon:
                        yVal = Double(self.chartDataValues[index].Radon)
                        break
                    case  DataTypeFilterEnum.voc:
                        yVal = Double(self.chartDataValues[index].VOC)
                        break
                    case  DataTypeFilterEnum.co2:
                        yVal = Double(self.chartDataValues[index].CO2)
                        break
                    case  DataTypeFilterEnum.temperature:
                        yVal = Double(self.chartDataValues[index].Temperature)
                        break
                    case  DataTypeFilterEnum.humidity:
                        yVal = Double(self.chartDataValues[index].Humidity)
                        break
                    case  DataTypeFilterEnum.airPressure:
                        yVal = Double(self.chartDataValues[index].AirPressure)
                        var isLocalAltitudeINHG: Float = 0.0
                        var isLocalAltitudeMBAR: Float = 0.0
                        if Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isAltitude == true {
                            isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeINHG
                            isLocalAltitudeMBAR = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeMBAR
                            if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
                                yVal = yVal + Double(isLocalAltitudeINHG)
                            }else {
                                yVal = yVal + Double(isLocalAltitudeMBAR)
                            }
                        }
                        break
                    default:
                        print("DB")
                        yVal = Double(self.chartDataValues[index].Radon)
                        
                        break
                    }
                }
                tempEntry.append(ChartDataEntry(x: xVal, y: yVal, data: data))
            }
            dataSets.append(formDataSets(chartDataEntry: tempEntry, firstLine: false))
        }
        let data = LineChartData(dataSets: dataSets)
        lineChartView.data?.clearValues()
        lineChartView.resetZoom()
        lineChartView.data = data
    }
    func formDataSets(chartDataEntry:[ChartDataEntry], firstLine:Bool)->LineChartDataSet{
        
        
        
        let set1 = LineChartDataSet(entries: chartDataEntry, label: "")
        set1.drawIconsEnabled = false
        set1.mode = .linear
        set1.setColor(UIColor.init(netHex: 0x007AFF))
        set1.setCircleColor(UIColor.init(netHex: 0x007AFF))
        
        var circleColors: [NSUIColor] = []
        if chartDataEntry.count != 0 {
            for i in 0...(chartDataEntry.count-1) {
                
                let entry = chartDataEntry[i].data as? LineChartModel
                if entry?.dummyValue == -12345 ||  entry?.dummyValue == -123456{
                    circleColors.append(.clear)
                }
                else{
                    circleColors.append(UIColor.init(netHex: 0x007AFF))
                }
                
            }
        }
        set1.circleColors = circleColors
        if firstLine == true{
            set1.lineDashLengths = [5, 2.5]
            set1.highlightLineDashLengths = [5, 2.5]
            set1.setCircleColor(.clear)
        }
        
        
        
        
        set1.lineWidth = 4
        set1.circleRadius = 0
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 7)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 10
        set1.drawValuesEnabled = false
        return set1
    }
    
}

extension BidirectionalCollection where Element: BinaryInteger, Index == Int {
    var consecutivelyGrouped: [[Element]] {
        return reduce(into: []) {
            $0.last?.last?.advanced(by: 1) == $1 ?
                $0[index(before: $0.endIndex)].append($1) :
                $0.append([$1])
        }
    }
}
extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}



extension ChartViewController: UITableViewDataSource, UITableViewDelegate, DeviceSelectedDelegate, CurrentLogIndexDelegate{
    
    func getBluetoothCurrentIndexLogData(isConnectedBLE: Bool) {
        if isConnectedBLE == true {
            return
        }
         //self.reloadDataCurrentIndexLogData()
        self.getBluetoothUpperBoundLogData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let deivceNameCell:LuftDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.luftDeviceTableViewCell, for: indexPath) as! LuftDeviceTableViewCell
        if self.arrReadDeviceData.count > 0 {
            deivceNameCell.reloadCollectionView(arrDevice: self.arrReadDeviceData)
        }
        deivceNameCell.fliterSelectedDelegate = self
        deivceNameCell.deviceSelectedDelgate = self
        return deivceNameCell
        
        //        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let arrayCount:Float = Float(self.arrReadDeviceData.count)
        if AppSession.shared.getUserSelectedLayout() == 2 {
            if arrayCount == 0 {
                return 0
            }
            return CGFloat(arrayCount * 60) + 45
        }else {
            if arrayCount == 0 {
                return 0
            }else {
                let f: Float = Float(arrayCount / 3)
                let ivalue = Int(f.rounded(.up))
                return CGFloat((ivalue  * 115))
            }
        }
    }
    
    func deviceSelectedDevice(deviceID:Int) {
        
        self.getDeviceBackSync()
        if self.isBackGroundSyncStart == true {
            if  let deviceDataNameID = UserDefaults.standard.object(forKey: "Selected_DeviceName") {
                let message = String(format: "%@ device sync is inprogress, please try later.", deviceDataNameID as! CVarArg)
                self.showBleSyncUpdateAlert(message: message)
            }
        }else {
            //self.isSelectedDeviceRow = selectedRow + 1
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
                self.isCurrentSlectedDevice = self.arrReadDeviceData[self.isSelectedDeviceRow]
                AppSession.shared.setPrevSelectedDeviceID(prevSelectedDevice: self.isCurrentSlectedDevice?.device_id ?? -100)
                self.arrReadDeviceData.remove(at: self.isSelectedDeviceRow)
                self.lblSelectedConnectDevice?.text = self.isCurrentSlectedDevice?.name
                self.luftSelectedDeviceID = self.isCurrentSlectedDevice?.device_id ?? 0
                self.selectedDeviceID = String.init(format: "%d", self.luftSelectedDeviceID)
                GlobalDeviceID = self.luftSelectedDeviceID
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    self.initialButtonsetups()
                    self.buttonDataTypeReset()
                    
                    self.btnHoursDayYearReset()
                    
                    switch self.filterTypeVal{
                    case .Days7:
                        self.btnFilterTypeEnabled(btn: self.btn7Days)
                        self.btnHourDaysYearButtonsTapped(sender: self.btn7Days)
                        break
                    case .Month:
                        self.btnFilterTypeEnabled(btn: self.btnMonths)
                        self.btnHourDaysYearButtonsTapped(sender: self.btnMonths)
                    case .Hours24:
                        self.btnFilterTypeEnabled(btn: self.btn24Hrs)
                        self.btnHourDaysYearButtonsTapped(sender: self.btn24Hrs)
                    case .Year:
                        self.btnFilterTypeEnabled(btn: self.btnYear)
                        self.btnHourDaysYearButtonsTapped(sender: self.btnYear)
                    default:
                        self.btnFilterTypeEnabled(btn: self.btn24Hrs)
                        self.btnHourDaysYearButtonsTapped(sender: self.btn24Hrs)
                        break
                        
                    }
                    
                    switch self.typeVal{
                    case .radon:
                        self.btnDataTypeTapped(sender: self.btnRadon)
                        break
                    case .voc:
                        self.btnDataTypeTapped(sender: self.btnVoc)
                        break
                    case .co2:
                        self.btnDataTypeTapped(sender: self.btnCo2)
                        break
                    case .temperature:
                        self.btnDataTypeTapped(sender: self.btnTemperature)
                        break
                    case .humidity:
                        self.btnDataTypeTapped(sender: self.btnHumidity)
                        break
                    case .airPressure:
                        self.btnDataTypeTapped(sender: self.btnAirPressure)
                        break
                    default:
                        self.btnDataTypeTapped(sender: self.btnRadon)
                        break
                    }
                }
            }
            self.tblDeviceCollection?.reloadData()
            if self.arrReadDeviceData.count > 0 {
            if self.arrReadDeviceData[0].wifi_status == false{
                self.readSerialNumber()
            }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.backgroundBluetoothSyncTrends()
            }
        }
    }
    
    func getDeviceList(isAPICall:Bool)  {
        self.arrReadDeviceData.removeAll()
        self.arrReadDeviceData = RealmDataManager.shared.readDeviceListDataValues()
        if self.arrReadDeviceData.count > 0 {
            self.hideDeviceView()
            if AppSession.shared.getUserSelectedLayout() == 2{
                self.arrReadDeviceData.removeAll()
                self.arrReadDeviceData = self.getSortArrayValues(arrayValue: RealmDataManager.shared.readDeviceListDataValues())
                self.arrReadDeviceData.removeAll()
                self.arrReadDeviceData.append(contentsOf: self.arrCompletedReadDeviceData)
                if self.arrReadDeviceData.count == 1 {
                    self.searchView?.isHidden = true
                    self.searchViewHeightConstant?.constant = 0.0
                }else {
                    if AppSession.shared.getUserSelectedLayout() == 2{
                        self.isGridList = true
                        self.searchView?.isHidden = false
                        self.textSearch?.delegate = self
                        self.searchViewHeightConstant?.constant = 50.0
                    }
                }
                if AppSession.shared.getUserSelectedLayout() == 2{
                    
                }else {
                    self.isGridList = false
                    self.searchView?.isHidden = true
                    self.searchViewHeightConstant?.constant = 0.0
                }
            }else{
                self.arrCompletedReadDeviceData.removeAll()
                self.arrCompletedReadDeviceData.append(contentsOf: self.arrReadDeviceData)
            }
            
            if AppSession.shared.getIsAddedNewDevice() == true {
                AppSession.shared.setIsAddedNewDevice(isAddedDevice:false)
                if let tabBarVC = self.tabBarController as? LuftTabbarViewController {
                    self.luftChartDeviceIDPrevious = tabBarVC.deviceIDSelectedPrevious
                }
            }
            if self.arrReadDeviceData.contains(where: { $0.device_id == self.luftChartDeviceIDPrevious }) == true && self.luftChartDeviceIDPrevious != -100{
                self.isSelectedDeviceRow = self.arrReadDeviceData.firstIndex(where: { (item) -> Bool in
                    item.device_id == self.luftChartDeviceIDPrevious
                }) ?? 0
            }else {
                self.isSelectedDeviceRow = 0
            }
            
            self.isCurrentSlectedDevice = self.arrReadDeviceData[isSelectedDeviceRow]
            AppSession.shared.setPrevSelectedDeviceID(prevSelectedDevice: self.isCurrentSlectedDevice?.device_id ?? -100)
            
            self.arrReadDeviceData.remove(at: isSelectedDeviceRow)
            self.lblSelectedConnectDevice?.text = self.isCurrentSlectedDevice?.name
            self.luftSelectedDeviceID = self.isCurrentSlectedDevice?.device_id ?? 0
            self.selectedDeviceID = String.init(format: "%d", self.luftSelectedDeviceID)
            GlobalDeviceID = self.luftSelectedDeviceID
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.initialButtonsetups()
                self.buttonDataTypeReset()
                
                self.btnHoursDayYearReset()
                self.btnFilterTypeEnabled(btn: self.btn24Hrs)
                
                self.btnHourDaysYearButtonsTapped(sender: self.btn24Hrs)
                self.btnDataTypeTapped(sender: self.btnRadon)
                
            }
            self.tblDeviceCollection?.reloadData()
            if self.arrReadDeviceData.count > 0 {
            if macAddressSerialNo == "" && self.arrReadDeviceData[0].wifi_status == false{
                self.readSerialNumber()
            }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let arrayCount:Float = Float(self.arrReadDeviceData.count)
                if AppSession.shared.getUserSelectedLayout() == 2 {
                    self.deviceListTableViewHeightConstraint.constant = CGFloat(arrayCount * 60) + 45
                }else {
                    let f: Float = Float(arrayCount / 3)
                    let ivalue = Int(f.rounded(.up))
                    self.deviceListTableViewHeightConstraint.constant = CGFloat((ivalue  * 115))
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
    
    @IBAction func syncButtonAction(sender: UIButton) {
        
        
    }
    
    func reloadDataCurrentIndexLogData() {
        Helper.shared.removeBleutoothConnection()
        self.hideActivityIndicator(self.view)
        self.tblDeviceCollection?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.tblDeviceCollection?.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: false)
        }
    }
    
    
}

// MARK: - Device Data
extension ChartViewController:DeviceMEAPIDelegate {
    
    //    func callSyncWifiBackGroundModeDeviceDetails(){
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    //            BackgroundDataAPIManager.shared.callSyncBackGroundDeviceDetailsAPI()
    //            BackgroundDataAPIManager.shared.allReadingData = self
    //            DispatchQueue.global(qos: .background).async {
    //                DispatchQueue.main.async {
    //                }
    //            }
    //        }
    //    }
    
    
}

extension ChartViewController: ConnectPeripheralDelegate,AddNewDeviceDataDelegate {
    
    func connectedPeripheralDevice(peripheralDevice: CBPeripheral) {
        self.strConnectPeripheral = peripheralDevice.name ?? ""
        self.mainPeripheral = peripheralDevice
    }
    
    func addNewdeviceDataDelegateDelegateStatus(upadte: Bool) {
        self.isLoadMe = true
    }
    
    
}

extension ChartViewController: AllReadingDelegate {
    
    func getallBackGroundWifiReadingStatus(update:Bool){
        //self.hideActivityIndicator(self.view)
        //BackgroundDataAPIManager.shared.isCompleted = true
        //self.deviceSelectedDevice(deviceID: self.luftSelectedDeviceID)
        self.isBackGroundAPICompleted = true
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        // self.lblLoading?.isHidden = true
        // }
        
    }
    
    
    func showDataValues()  {
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            if self.isShowData{
                if self.filterTypeVal == .Hours24{
                               self.btnHourDaysYearButtonsTapped(sender: self.btn24Hrs)
                           }else if self.filterTypeVal == .Overall{
                               self.btnHourDaysYearButtonsTapped(sender: self.btn7Days)
                           }
                           else if self.filterTypeVal == .Days7{
                               self.btnHourDaysYearButtonsTapped(sender: self.btn7Days)
                           }
                           else if self.filterTypeVal == .Month{
                               self.btnHourDaysYearButtonsTapped(sender: self.btnMonths)
                           }
                           else if self.filterTypeVal == .Year{
                               self.btnHourDaysYearButtonsTapped(sender: self.btnYear)
                           }
                           self.backgroundBluetoothSyncTrends()
            }
           
        }
        
        print("Loding completed...")
    }
    
    
    func hidelblLoading() {
        DispatchQueue.main.async {
            self.lblLoading.textColor = UIColor.clear
            self.lblLoading.backgroundColor = UIColor.clear
            self.view.sendSubviewToBack(self.lblLoading)
        }
    }
    
}

extension ChartViewController: LTSideMenuDelegate{
    @IBAction func btnPresentMenuTapped(_ sender: Any) {
        self.removeSearchView()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerMenu = mainStoryboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        viewControllerMenu.menuDelegate = self
        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
            viewControllerMenu.isSelectedDevice = deviceDataCurrent
        }
        viewControllerMenu.modalPresentationStyle = .overFullScreen
        self.isMenuPressed = 1
        self.tabBarController?.present(viewControllerMenu, animated: true, completion: nil)
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
            self.getFWVersionAPI()
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
            if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice,deviceDataCurrent.shared_user_email == ""{
                self.showToShareDataAlert()
            }else {
                self.moveToShareEMailView()
            }
            break
        case SideMenuType.SideMenuTempOffset:
            self.showToTempoffset()
            break
        case SideMenuType.SideMenuFAQ:
            self.showToFAQ()
            break
        case SideMenuType.SideMenuContactSupport:
            //self.showToFAQ()
            UIApplication.shared.open(URL(string: CONTACT_SUPPORT)!)

            break
        default:
            break
        }
        
    }
    
    func moveToShareEMailView()  {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcShareDataEmail = storyboard.instantiateViewController(withIdentifier: "ShareDataEmailViewController") as! ShareDataEmailViewController
        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
            vcShareDataEmail.currentDeviceID = deviceDataCurrent.device_id
            vcShareDataEmail.currentEmailID = deviceDataCurrent.shared_user_email
            self.luftChartDeviceIDPrevious = deviceDataCurrent.device_id
        }
        self.navigationController?.pushViewController(vcShareDataEmail, animated: false)
    }
    
    
    func showMenuRenameDevice()  {
        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
            let titleString = NSAttributedString(string: "Rename your Device", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let message = String(format: "Enter a new new name for the device %@", deviceDataCurrent.name )
            let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.setValue(titleString, forKey: "attributedTitle")
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Device Name"
            }
            alert.setValue(messageString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Save", style: .default, handler: { action in
                
                if (alert.textFields?.count ?? 0) > 0{
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
    
    func renameDeviceAPI() {
        self.showActivityIndicator(self.view)
        if self.strRenameDevice.count != 0 {
            if Reachability.isConnectedToNetwork() == true {
                SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
                AppUserAPI.apiAppUserRenamePost(model: RenameDeviceViewModel.init(name:self.strRenameDevice, deviceId: Int64(self.isCurrentSlectedDevice?.device_id ?? 0)), completion: {(error) in
                    self.hideActivityIndicator(self.view)
                    if error == nil {
                        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
                            self.luftChartDeviceIDPrevious = deviceDataCurrent.device_id
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
            }
        }else {
            Helper.shared.showSnackBarAlert(message: "Invalid device name", type: .Failure)
        }
    }
    
    func getCurrentSelectedDevice() -> RealmDeviceList? {
        guard let device = isCurrentSlectedDevice, !device.isInvalidated else {
            return .none
        }
        return isCurrentSlectedDevice
    }
    
    func showToFirmWare() {
        
        if self.getCurrentSelectedDevice()?.firmware_version.lowercased().filter("1234567890".contains) == strFirmwareVesrion.lowercased().filter("1234567890".contains) {
            // if self.getCurrentSelectedDevice()?.firmware_version == strFirmwareVesrion {
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
    
    func showToRemoveDevice() {
        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
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
    
    func removeDeviceAPI()  {
        self.showAct()
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        AppUserAPI.apiAppUserRemoveDelete(deviceId: Int64(self.isCurrentSlectedDevice?.device_id ?? 0), completion:  { (error) in
            if error == nil {
                Helper.shared.showSnackBarAlert(message: "Device removed Succesfully", type: .Success)
                self.isSelectedDeviceRow = 0
                AppSession.shared.setPrevSelectedDeviceID(prevSelectedDevice: -100)
                RealmDataManager.shared.removeDeviceUpdate(deviceID: self.isCurrentSlectedDevice?.device_id ?? 0)
                self.callDeviceDetailsTypeApi(isUpdateDummy: false)
            }else {
                self.hideActivityIndicator(self.view)
                Helper.shared.showSnackBarAlert(message: "Device removed faliure", type: .Failure)
            }
        })
    }
    
    func callMyDeviceAPI()  {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.showAct()
        self.callDeviceDetailsTypeApi(isUpdateDummy: false)
    }
    
    func deviceDataAPIStatus(update:Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.hideActivityIndicator(self.view)
        }
        UIApplication.shared.endIgnoringInteractionEvents()
        self.backGroundDatafetch()
        BackgroundDataAPIManager.shared.individualData = nil
        BackgroundDataAPIManager.shared.individualData = self
    }
    
    func showToNotificationDashBoard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcLTDashBoard = storyboard.instantiateViewController(withIdentifier: "LTDashBoardNotificationViewController") as! LTDashBoardNotificationViewController
        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
            vcLTDashBoard.isSelectDeviceID = deviceDataCurrent.device_id
            self.luftChartDeviceIDPrevious = deviceDataCurrent.device_id
        }
        self.navigationController?.pushViewController(vcLTDashBoard, animated: true)
    }
    
    func showToConnecetToWiFi() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcMYDeviceData = storyboard.instantiateViewController(withIdentifier: "AvilableNetworkViewController") as! AvilableNetworkViewController
        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
            vcMYDeviceData.avilableDeviceID = deviceDataCurrent.device_id
            vcMYDeviceData.serialDeviceName = deviceDataCurrent.serial_id
            self.luftChartDeviceIDPrevious = deviceDataCurrent.device_id
        }
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
        if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
            vcTempOffset.isDeviceSelected = deviceDataCurrent
            self.luftChartDeviceIDPrevious = deviceDataCurrent.device_id
        }
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
            if (alert.textFields?.count ?? 0) > 0{
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
    
    func callShareEmailIDapi(){
        self.showActivityIndicator(self.view)
        if Reachability.isConnectedToNetwork() == true {
            AppSession.shared.setCurrentDeviceToken(self.isCurrentSlectedDevice?.device_token ?? "")
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            MobileApiAPI.apiMobileApiSharedHomeDevicePost(email: self.strShareEmailID, deviceId: Int64(self.isCurrentSlectedDevice?.device_id ?? 0)) { (responses, error) in
                self.hideActivityIndicator(self.view)
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
        }
    }
    
    func showToRemoveWifi() {
        let titleString = NSAttributedString(string: "Remove Wi-Fi", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: "Are you sure you want to remove Wi-Fi?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
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
}


extension ChartViewController: SSIDWriteDelegate{
    
    func writeSSIDSocketURL() {
        //        Helper.shared.showSnackBarAlert(message: "Write Inprogress", type: .InfoOrNotes)
        //        self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        //        if self.writeRemoveWifiIndex == 5 {
        //            self.reMoveWifiStatus()
        //        }
    }
    
    func writeSSIDCloudWebURL() {
        //        Helper.shared.showSnackBarAlert(message: "Wi-Fi Connection Inprogress", type: .InfoOrNotes)
        //        self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        //        if self.writeRemoveWifiIndex == 5 {
        //            self.reMoveWifiStatus()
        //        }
    }
    
    func writeSSIDSocketAuthToken() {
        //        Helper.shared.showSnackBarAlert(message: "Wi-Fi Connection Inprogress", type: .InfoOrNotes)
        //        self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        //        if self.writeRemoveWifiIndex == 5 {
        //            self.reMoveWifiStatus()
        //        }
    }
    
    func writeSSIDName() {
        self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        if self.writeRemoveWifiIndex == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
            }
            self.reMoveWifiStatus()
        }
    }
    func writeSSIDPassword(){
        self.writeRemoveWifiIndex = self.writeRemoveWifiIndex + 1
        if self.writeRemoveWifiIndex == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
            }
            self.reMoveWifiStatus()
        }
    }
    
    func reMoveWifiStatus()  {
       
        textLog.write("BLE VIA - REMOVE SSID PROCESS COMPLETED")
        self.updateDeviceState(isWifi: false)
    }
    
    func updateDeviceState(isWifi:Bool)  {
        self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
        let updateWifiState = UpdateDeviceModel.init(deviceId: Int64(self.isCurrentSlectedDevice?.device_id ?? 0), wifiStatus: isWifi, timeDifference: Helper.shared.getTimeDiffBetweenTimeZone(), timeZone: self.getCurrentTimeZoneShortName(), deviceTimeZoneFullName: Helper.shared.getCurrentTimeZoneinIANAFormat(), macAddress: macAddressSerialNo)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
        MobileApiAPI.apiMobileApiUpdateWifiStatusPost(model: updateWifiState, completion: { (respones, error) in
            if respones?.success == true {
                //self.showActivityIndicator(self.view, isShow: false, isShowText: "Wi-Fi Removed Successfully")
                if let deviceDataCurrent:RealmDeviceList = self.isCurrentSlectedDevice {
                    self.luftChartDeviceIDPrevious = deviceDataCurrent.device_id
                }
                self.showActivityIndicator(self.view, isShow: false, isShowText: "Please wait")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.checkWithWifiBLE()
                }
            }else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.hideActivityIndicator(self.view)
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

extension ChartViewController: BleManagerStateDelegate,BackGroundBleStateDelegate,WIFIStatusDelegate {
    
    
    func wifiStatusCheck(wifiDeviceStaus:String) {
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
    
    func getBleManagerBleState(isConnectedBLEState: Bool) {
        if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureRemoveSSIDWrite{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hideActivityIndicator(self.view)
            }
            if self.isWifiUpdate == 0 {
                self.getBLEWriteStateDelegate(bleWriteType: BlueToothFeatureType.BlueToothFeatureRemoveSSIDWrite)
            }else {
                if self.isWifiUpdate == 0 {
                    self.bleNotConnectAlert()
                }
            }
        }
        else if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureWifiStatus {
            if self.isWifiUpdate == 0 {
                self.bleNotConnectAlert()
            }else {
                if self.isWifiUpdate == 0 {
                    self.bleNotConnectAlert()
                }
            }
        }
        else {
            self.bleNotConnectAlert()
        }
    }
    
    func bleNotConnectAlert()  {
        self.dashBrdRemoveWIFIIntailCheckCount = 100
        self.hideActivityIndicator(self.view)
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
        
        if isConnectedBLEState == false && BackgroundBLEManager.shared.blueToothFeatureType == .BlueToothFeatureLogCurrentIndexWrite{
            self.isBackGroundSyncStart = false
            self.hidelblLoading()
        }
        //Helper.shared.showSnackBarAlert(message: "Device not connected over Bluetooth. It could be due to Device is not in Bluetooth range or Device is already connected with another phone. Please try again later.", type: .Failure)
    }
    
    func bleStatesDelegate(){
        BluetoothManager.shared.delegateBleManagerState = self
        BackgroundBLEManager.shared.delegateBackGroundBleState = self
    }
}
extension ChartViewController: UISearchBarDelegate,LTSearchDeviceDelegate {
    
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
        self.searchBackView.isHidden = false
        self.textSearch?.isHidden = true
        self.tblDeviceCollection?.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.searchDeviceViewController = storyboard.instantiateViewController(withIdentifier: "SearchDeviceViewController") as? SearchDeviceViewController
        self.searchDeviceViewController?.view.frame.size.height = self.searchBackView.bounds.size.height
        self.searchDeviceViewController?.view.frame.size.width = self.searchBackView.bounds.size.width
        self.searchDeviceViewController?.deviceSearchDelgate = self
        self.searchBackView.addSubview((self.searchDeviceViewController?.view)!)
        
    }
    
    func removeSearchView()  {
        self.searchBackView.isHidden = true
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


extension ChartViewController: LTFliterDelegate,FliterSelectedDelegate {
    
    func fliterSelectedDelegate(deviceID:Int){
        self.showPresentFilter()
    }
    
    func selectedFliter(fliterMenuType:Int) {
        self.luftChartDeviceIDPrevious = -100
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

extension ChartViewController {
    
    
    func callDeviceDetailsTypeApi(isUpdateDummy:Bool){
        if Reachability.isConnectedToNetwork() == true {
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            AppUserAPI.apiAppUserGetMyDevicesGet { (response, error) in
                if error == nil {
                    self.lblLoadingData()
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
                        //                        RealmDataManager.shared.deleteDeviceRelamDataBase()
                        //                        RealmDataManager.shared.deleteRelamSettingColorDataBase()
                        //                        RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
                    }
                    self.getDeviceList(isAPICall: false)
                    self.deviceDataAPIStatus(update: true)
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.hideActivityIndicator(self.view)
                }
            }
        }
        else{
            self.hideActivityIndicator(self.view)
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            UIApplication.shared.endIgnoringInteractionEvents()
            self.hidelblLoading()
        }
    }
    
    func showAct() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.showActivityIndicator(self.view)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.removeWifiNameToDevice()
                }
            }else {
                self.dashBrdRemoveWIFIIntailCheckCount = 100
                self.bleNotConnectAlert()
            }
        }
        if BluetoothManager.shared.blueToothFeatureType == .BlueToothFeatureWifiStatus {
            if self.isWifiUpdate == 0 {
                self.bleNotConnectAlert()
            }
        }
    }
    
    func removeConnectionState()  {
        self.bleNotConnectAlert()
    }
}

// MARK: BLE Scanning
extension ChartViewController:CBCentralManagerDelegate {
    
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
        self.showAct()
        self.peripherals.removeAll()
        self.manager = CBCentralManager(delegate: self, queue: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.showActivityIndicator(self.view, isShow: false, isShowText: "Trying to connect device via BLE")
        }        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if self.scanCheckCount != 30 {
                self.hideActivityIndicator(self.view)
                self.stopScanForBLEDevices()
                self.bleNotConnectAlert()
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
        if self.peripherals.contains(where: { $0.name == self.isCurrentSlectedDevice?.serial_id }) == true{
            self.scanCheckCount = 30
            self.stopScanForBLEDevices()
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                textLog.write("CHART Trying to Connect over Bluetooth")
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.removeWifiNameToDevice()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    self.showActivityIndicator(self.view, isShow: false, isShowText: "Removing Wi-Fi details on device")
                }
            }
        }
    }
    func removeWifiNameToDevice() {
        self.showAct()
        textLog.write("BLE VIA - REMOVE SSID PROCESS START (CHART)")
        BluetoothManager.shared.centralManager?.stopScan()
        Helper.shared.removeBleutoothConnection()
        BluetoothManager.shared.delegateBleManagerState = nil
        BluetoothManager.shared.selectedWifiName = ""
        BluetoothManager.shared.selectedWifiPassword = ""
        BluetoothManager.shared.isBleManagerConnectState = false
        BluetoothManager.shared.connectBlueTooth(blueToothName: self.isCurrentSlectedDevice?.serial_id ?? "", bleFeature: .BlueToothFeatureRemoveSSIDWrite)
        BluetoothManager.shared.deviceWriteStatusDelgate = self
        BluetoothManager.shared.delegateBleManagerState = self
    }
    
    func addDeviceViewNewGood()  {
        self.hidelblLoading()
        self.addDeviceView?.isHidden = false
        self.btnFindDeviceButton?.addTarget(self, action: #selector(self.addDeviceViewPage(sender:)), for: .touchUpInside)
    }
    
    @objc func addDeviceViewPage(sender: UIButton) {
        //checking BT access - Gauri
        if intPermissionDisplay == 0 {
            self.findDeviceBTScan()
        } else {
            self.moveToAddDevice(isfromDefault: true)
        }
        //self.moveToAddDevice(isfromDefault: true)
    }
    
    @objc func btnSunRadonLogoTapped(sender: UIButton) {
        guard let url = URL(string: LIVE_SUN_RADON_URL) else { return }
        UIApplication.shared.open(url)
    }
    
    func hideDeviceView()  {
        self.addDeviceView?.isHidden = true
    }
}
extension ChartViewController {
    
   
    
    func getFWVersionAPI() {
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
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let data : JSON = Helper.shared.getOptionalJson(response: response.result.value as AnyObject) {
                            self.hideActivityIndicator(self.view)
                            strFirmwareVesrion =  data["LuftFWVersion"].stringValue
                            self.showToFirmWare()
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
    
    func lblLoadingData() {
        self.lineChartView.noDataText = ""
        self.lineChartView.noDataTextAlignment = .center
        self.lblLoading?.text = "Loading Data..."
        self.lblLoading?.font = UIFont.setAppFontRegular(12)
        self.lblLoading?.textAlignment = .center
        self.lblLoading?.backgroundColor = UIColor.lightGray
        self.lblLoading?.textColor = .white
        self.lblLoading?.layer.cornerRadius = 10.0
        self.lblLoading?.layer.masksToBounds = true
        self.lblLoading?.alpha = 0.8
        self.view.bringSubviewToFront(self.lblLoading)
    }
}

extension ChartViewController:BackGroundBleSyncCompletedDelegate {
    func getWholebackGroundBleSyncCompletedDelegate() {
        self.isBackGroundSyncStart = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            if self.filterTypeVal == .Hours24{
                self.btnHourDaysYearButtonsTapped(sender: self.btn24Hrs)
            }else if self.filterTypeVal == .Overall{
                self.btnHourDaysYearButtonsTapped(sender: self.btn7Days)
            }
            else if self.filterTypeVal == .Days7{
                self.btnHourDaysYearButtonsTapped(sender: self.btn7Days)
            }
            else if self.filterTypeVal == .Month{
                self.btnHourDaysYearButtonsTapped(sender: self.btnMonths)
            }
            else if self.filterTypeVal == .Year{
                self.btnHourDaysYearButtonsTapped(sender: self.btnYear)
            }
        }
    }
    
    
    func backgroundBluetoothSyncTrends()  {
        if BackgroundDataAPIManager.shared.isWholeDataSyncCompleted == true && APIManager.shared.isAddDeviceAPICompleted == true {
            if self.getCurrentSelectedDevice()?.wifi_status != true || self.getCurrentSelectedDevice()?.isBluetoothSync == true {
                self.readCurrentDeviceBleData()
            }else {
                self.hidelblLoading()
            }
        }else {
            self.hidelblLoading()
        }
    }
    
    func getBluetoothUpperBoundLogData() {
        
        // Helper.shared.removeBleutoothConnection()
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
            self.isBackGroundSyncStart = true
            self.bleStatesDelegate()
        }
        
    }
    
    func showBleSyncUpdateAlert(message:String) {
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
    
    func readCurrentDeviceBleData()  {
        
        if self.getCurrentSelectedDevice()?.wifi_status != true || self.getCurrentSelectedDevice()?.isBluetoothSync == true{
            UserDefaults.standard.set(self.getCurrentSelectedDevice()?.device_id, forKey: "Selected_DeviceID")
            UserDefaults.standard.set(self.getCurrentSelectedDevice()?.serial_id, forKey: "Selected_DeviceName")
            UserDefaults.standard.set(self.getCurrentSelectedDevice()?.wifi_status, forKey: "Selected_DeviceName_WIFI")
        }
        self.getBluetoothUpdateDevice()
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
        //self.isBackGroundSyncStart = true
        self.bleStatesDelegate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lblLoadingData()
            self.lineChartView.noDataText = "No data available to display. If this device was recently added to your account, it will take up to 90 minutes before the first data point is available. If device was previously connected, verify device connection status. If necessary, reconnect or repower your device."
        }
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

extension ChartViewController: IndividualDeviceReadingDelegate{
    func indDeviceReadingDelegate(){
        self.getDeviceBackSync()
    }
    
    func getDeviceBackSync() {
        if  let deviceDataSerialNameID = UserDefaults.standard.object(forKey: "Selected_DeviceName_SerialID") {
            if (RealmDataManager.shared.getDataDeviceDataValues(deviceSerialID: deviceDataSerialNameID as! String)) {
                self.hidelblLoading()
                if self.isShowData == true {
                    self.showDataValues()
                    self.isShowData = false
                }
            }else {
                self.lblLoadingData()
            }
        }
    }
}

extension ChartViewController {
    
    func getLastSyncDate() -> Int {
        self.arrCurrentIndexValue.removeAll()
        self.arrCurrentIndexValue = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: self.luftSelectedDeviceID)
        var timeValue:Int = 0
        var timeDiff:Int = 0
        
        if self.arrCurrentIndexValue.count != 0 {
            if self.arrCurrentIndexValue[0].timeStamp == 0 {
                let dateAtMidnight = Date()
                let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
                let currentTimeValue = Int(secondsSince1970)
                timeDiff = RealmDataManager.shared.getDeviceData(deviceID: self.luftSelectedDeviceID)[0].timeDiffrence.toInt() ?? 0
                timeValue = (currentTimeValue / 1000) + timeDiff
            } else {
                timeDiff = RealmDataManager.shared.getDeviceData(deviceID: self.luftSelectedDeviceID)[0].timeDiffrence.toInt() ?? 0
                timeValue = (self.arrCurrentIndexValue[0].timeStamp / 1000) + timeDiff
            }
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
        return timeValue
    }
   
    func getBluetoothUpdateDevice()  {
        if Reachability.isConnectedToNetwork() == true {
            // self.showAct()
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
            var calendar = NSCalendar.current
            calendar.timeZone = NSTimeZone(abbreviation: "UTC")! as TimeZone
            //Last sync date from DB -LastSyncDate
            
//            let dateAtMidnight = Date()
//            let secondsSince1970: TimeInterval = dateAtMidnight.timeIntervalSince1970
//            let currentTimeValue = Int(secondsSince1970)
            
            let currentTimeValue =  self.getLastSyncDate()
            
            DeviceAPI.apiDeviceUpdateBluetoothDataSyncPost(model: SNAirQualityWebViewModelsUpdateBluetoothSync.init(timeStampUtc: Int64(currentTimeValue), deviceId: Int64(self.getCurrentSelectedDevice()?.device_id ?? 0)), completion: { (response, error) in
                // self.hideActivityIndicator(self.view)
                if error == nil  {
                    print("Success UpdateBluetoothDataSync")
                }else {
                    print("UpdateBluetoothDataSync API CALLING error")
                }
            })
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
}

extension Double {
    func decimalCount() -> Int {
        if self == Double(Int(self)) {
            return 0
        }

        let integerString = String(Int(self))
        let doubleString = String(Double(self))
        let decimalCount = doubleString.count - integerString.count - 1

        return decimalCount
    }
    
    func getTwoDeicmalValue() -> Double{
        if self.decimalCount() > 2{
            return Double(String(format: "%0.2f", self)) ?? 0
        }
        return 0.0
    }
}

extension ChartViewController: DeviceSerialNumberReadDelegate{
    func didReadSerialNumber(serialNumber: String) {
        print("serial numberof device in chart VC : " + serialNumber)
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

extension ChartViewController{
    
    @IBAction func downloadBtnAction(_ sender: Any) {
        // create csv file from data
        
        let temp = AppSession.shared.getMobileUserMeData()
        var radonUnitString = ""
        if temp?.radonUnitTypeId == 2{
            radonUnitString = "pCi/l"
        }
        else if temp?.radonUnitTypeId == 1{
            radonUnitString = BQM3Format
           
        }
        
        var tempUnitString = ""
        if temp?.temperatureUnitTypeId == 1{
            tempUnitString = "F"
        }
        else{
            tempUnitString = "C"
        }
        
        var airPressureUnitString = ""
        if temp?.pressureUnitTypeId == 2{
            airPressureUnitString = "inHg"
        }
        else {
            airPressureUnitString = "mbar"
        }
        
        let emailUser = AppSession.shared.getMEAPIData()?.email ?? ""
        let locValue = UserDefaults.standard.value(forKey: "Location")

        var line1 = "\("Serial ID"),\(isCurrentSlectedDevice?.serial_id ?? ""),\("Name"),\(isCurrentSlectedDevice?.name ?? ""),\("Location"),\(locValue ?? ""),\("Device TimeZone"),\(isCurrentSlectedDevice?.time_zone ?? "" ),\("Email"),\(emailUser)\n"
        
        let line2 = "\("Units"),\(radonUnitString),\(ECO2_UNIT_STRING),\(VOC_UNIT_STRING),\(tempUnitString),\(airPressureUnitString),\(HUMIDITY_UNIT_STRING)\n"
        let line3 = "\("SyncDate"),\(PollutantType.PollutantRadon.rawValue),\("eCO2"),\("tVOC"),\(PollutantType.PollutantTemperature.rawValue),\(PollutantType.PollutantAirPressure.rawValue),\(PollutantType.PollutantHumidity.rawValue)\n"
        
        line1.append(line2)
        line1.append(line3)
        
        if AppSession.shared.getAutoScale(){
            for item in chartDataValues {
                if item.LogIndex != -1 {
                    var radonValue = ""
                    if temp?.radonUnitTypeId == 2{
                        radonValue = String(format: "%@", Double(item.Radon).string(maximumFractionDigits: 1))
                    }
                    else{
                        radonValue = String(format: "%@", String(format: "%.0f", round(item.Radon)))
                    }
                    
                    var isLocalAltitudeINHG: Float = 0.0
                    var isLocalAltitudeMBAR: Float = 0.0
                    var airPressureValueInDouble: Float = item.AirPressure;
                    if Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isAltitude == true {
                        isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeINHG
                        isLocalAltitudeMBAR = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeMBAR
                        if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
                            airPressureValueInDouble = airPressureValueInDouble + Float(Double(isLocalAltitudeINHG))
                        }else {
                            airPressureValueInDouble = airPressureValueInDouble + Float(Double(isLocalAltitudeMBAR))
                        }
                    }
                    
                    var airPressureValue = ""
                    if temp?.pressureUnitTypeId == 2{
                        airPressureValue = String(format: "%@", Double(airPressureValueInDouble).string(maximumFractionDigits: 2))
                    }
                    else{
                        airPressureValue = String(format: "%@", round(Double(airPressureValueInDouble)).string(maximumFractionDigits: 1))
                    }
                    
                    let co2Value = String(format: "%.0f", round(item.CO2))
                    let vocValue = String(format: "%.0f", round(item.VOC))
                    let tempValue = Double(item.Temperature).string(maximumFractionDigits: 1)
                    let humidityValue = String(format: "%.0f", round(item.Humidity))
                    
                    
                    line1 = line1.appending("\(Helper.shared.getCSVDateTime(timeResult: item.date)),\(radonValue),\(co2Value),\(vocValue),\(tempValue),\(airPressureValue),\(humidityValue)\n")
                }
            }
        }
        else{
            
            for item in chartDataValues {
                if item.LogIndex != -1 {
                    
                    var radonValue = ""
                    let co2Value = String.init(format: "%.0f", round(Double(item.CO2)))//Double(item.CO2).string(maximumFractionDigits: 1)
                    let vocValue = String.init(format: "%.0f", round(Double(item.VOC)))//Double(item.VOC).string(maximumFractionDigits: 1)
                    let tempValue = String.init(format: "%.0f", round(Double(item.Temperature)))
                    let humidityValue = String(format: "%.0f", round(item.Humidity))
                    
                    var isLocalAltitudeINHG: Float = 0.0
                    var isLocalAltitudeMBAR: Float = 0.0
                    var airPressureValueInDouble: Float = item.AirPressure;
                    if Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isAltitude == true {
                        isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeINHG
                        isLocalAltitudeMBAR = Helper.shared.getDeviceDataAltitude(deviceID: selectedDeviceID.toInt() ?? 0).isLocalAltitudeMBAR
                        if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
                            airPressureValueInDouble = airPressureValueInDouble + Float(Double(isLocalAltitudeINHG))
                        }else {
                            airPressureValueInDouble = airPressureValueInDouble + Float(Double(isLocalAltitudeMBAR))
                        }
                    }
                    
                    if temp?.radonUnitTypeId == 2{
                        radonValue = String(format: "%@", Double(item.Radon).string(maximumFractionDigits: 1))
                    }
                    else{
                        radonValue = String(format: "%@", String(format: "%.0f", round(item.Radon)))
                    }
                    
                    var airPressureValue = ""
                    if temp?.pressureUnitTypeId == 2{
                        airPressureValue = String(format: "%@", Double(airPressureValueInDouble).string(maximumFractionDigits: 2))
                    }
                    else{
                        airPressureValue = String(format: "%@", round(Double(airPressureValueInDouble)).string(maximumFractionDigits: 1))
                    }
                    
                    line1 = line1.appending("\(Helper.shared.getCSVDateTime(timeResult: item.date)),\(radonValue),\(co2Value),\(vocValue),\(tempValue),\(airPressureValue),\(humidityValue)\n")
                }
            }
        }
        
        
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            print(path)
            let fileURL = path.appendingPathComponent("SunRadon_Data.csv")
            try line1.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let objectsToShare = [fileURL]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

//            activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        } catch {
            print("error creating file")
        }
    }
    
}

extension ChartViewController {
    
    func callUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            if  AppSession.shared.getAccessToken() == ""{
                return
            }
            AppUserAPI.apiAppUserMeGet { (response, error) in
                if error == nil {
                    if let responseValue = response {
                        //Save User default data's
                        self.hideActivityIndicator(self.view)
                        AppSession.shared.setMEAPIData(userSettingData: responseValue)
                    }
                }else {
                    self.hideActivityIndicator(self.view)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
        else{
            self.hideActivityIndicator(self.view)
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
}
