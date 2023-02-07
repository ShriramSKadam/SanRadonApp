//
//  ScanTableViewController.swift
//  BLEDemo
//
//  Created by Rick Smith on 13/07/2016.
//  Copyright © 2016 Rick Smith. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol PeripheralDelegate:class {
  func connectpPeripheralDevice(peripheralDevice:CBPeripheral)
}
protocol DashBoardDelegate:class {
    func isDashBoardAddDevice(isdashBoard:Bool)
}

class ScanTableViewController: LTSettingBaseViewController, LTIntialAGREEDelegate {
    func selectedIntialAGREE() {
        
    }
    

    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var connectBleDelegate:PeripheralDelegate? = nil
    var dashBoardDelegate:DashBoardDelegate? = nil
    @IBOutlet weak var tblBluetooth: UITableView!
    @IBOutlet weak var btnRefersh: UIButton!
  
    //Bluetooth access permission
    @IBOutlet weak var viewBTPermission: UIView!
    @IBOutlet weak var viewBTPermissionOK: UIView!
    @IBOutlet weak var viewBTPermissionCancel: UIView!
    @IBOutlet weak var GetMoreHelp: UIButton!


  override func viewDidLoad() {
    super.viewDidLoad()
    self.tblBluetooth.register(UINib(nibName: cellIdentity.settingHeaderCellIdentifierNew, bundle: nil), forCellReuseIdentifier: cellIdentity.settingHeaderCellIdentifierNew)
     self.tblBluetooth.register(UINib(nibName: cellIdentity.blinkingCellIndentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.blinkingCellIndentifier)
    self.tblBluetooth.register(UINib(nibName: cellIdentity.addDeviceCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.addDeviceCellIdentifier)
    self.tblBluetooth?.delegate = self
    self.tblBluetooth?.dataSource = self
    self.tblBluetooth.addSubview(self.refreshControl)
    self.btnRefersh.addTarget(self, action:#selector(self.btnTapRefersh(_sender:)), for: .touchUpInside)
    self.view.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
    self.tblBluetooth?.backgroundColor = UIColor.clear
  }
    
    @IBAction func btnClosetapped(_ sender: Any) {
        self.dashBoardDelegate?.isDashBoardAddDevice(isdashBoard: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Helper.shared.removeBleutoothConnection()
        self.peripherals.removeAll()
    }
    override func viewDidAppear(_ animated: Bool) {
        scanBLEDevices()
    }
    
    @IBAction func GetMorehelp(_ sender: Any) {
        self.moveToWebView()
    }
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
        webdataView.Urltodisplay = AddDeviceScreen_URL
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = UNITS
        webdataView.strTitle = UNITS
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .pageSheet
        self.present(webdataView, animated: false, completion: nil)
    }
    
    //MARK:- Pull to Refresh Controller
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = ThemeManager.currentTheme().ltCellHeaderTitleColor
        
        let attributes = [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellHeaderTitleColor]
        refreshControl.attributedTitle = NSAttributedString(string: CONTENT_PLEASE_WAIT_LOADING, attributes: attributes)
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.peripherals.removeAll()
        self.scanBLEDevices()
    }
    
    @objc func btnTapRefersh(_sender:UIButton) {
        self.peripherals.removeAll()
        self.stopScanForBLEDevices()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.scanBLEDevices()
        }
    }

}

extension ScanTableViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.settingHeaderCellIdentifier) as! LTSettingHeaderViewTableViewCell
//        cell.lblHeaderTilte.text = "Select device from list below. \n \nAVAILABLE DEVICES"
//        cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
//        return cell
//    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.settingHeaderCellIdentifierNew) as? LTSettingHeaderViewNewTableViewCell
//        cell.lblHeaderTilte.text = "Select device from list below. \n \nAVAILABLE DEVICES"
        cell?.lblHeaderTilte.text = " Select Device From List"
        cell?.lblHeaderTilte.font = .systemFont(ofSize: 17, weight: .bold)
        cell?.lblHeaderTilte.textColor = .black
        cell?.lblHeaderSubTitle.text = "    Available Devices"
        cell?.lblHeaderSubTitle.font = .systemFont(ofSize: 17, weight: .medium)
   //     cell?.lblHeaderSubTitle.layer.cornerRadius = 5
        //cell?.lblHeaderSubTitle.layer.borderWidth = 1
       // cell?.lblHeaderSubTitle.layer.borderColor = UIColor.gray.cgColor
        cell?.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        //scanAvailableNetworkView
        //cell?.cellHeaderBackView.backgroundColor  = ThemeManager.currentTheme().chartNoDataTextColor
       // cell?.separator(hide: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 0
        }
        else{
            return 48

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
           if indexPath.row  != 0{
            let cellValue:AddDeviceTableViewCell = self.tblBluetooth.dequeueReusableCell(withIdentifier: cellIdentity.addDeviceCellIdentifier, for: indexPath) as! AddDeviceTableViewCell
           if peripherals.count > 0 {
               
                let peripheral = peripherals[indexPath.row-1]
                cellValue.lblTitleCell.text = peripheral.name
                cellValue.lblSubTitleCell.text = ""
                cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
                cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
                cellValue.lblTitleView.isHidden = false
                cellValue.lblSubTitleView.isHidden = true
                cellValue.lblTitleCell.textAlignment = .left
                cellValue.lblSubTitleCell.textAlignment = .right
                cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellDisclousreIconImage
                cellValue.selectionStyle = .none
                cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
                cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
                cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
                cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
                cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
            }
            return cellValue
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        self.stopScanForBLEDevices()
        let peripheral = peripherals[indexPath.row - 1]
        self.manager = nil
        self.connectBleDelegate?.connectpPeripheralDevice(peripheralDevice: peripheral)
        self.dismiss(animated: true, completion: nil)
        
        //Get connection and sync data at same point
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
            textLog.write("BLE Scanning - Start")
        default:
            print("Please turn on bluetooth")
            //Make new alert message for allow permission
            
            Helper.shared.showSnackBarAlert(message: "Please turn on bluetooth", type: .Failure)
            textLog.write("Please turn on bluetooth")
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        if(!peripherals.contains(peripheral)) {
            if peripheral.name != nil {
                if peripheral.name?.lowercased().contains("luft") == true{
                    peripherals.append(peripheral)
                }
                textLog.write("\(String(describing: peripheral.name))")
            }
        }
        if self.refreshControl.isRefreshing{
            self.refreshControl.endRefreshing()
        }
        let arrDeviceList = RealmDataManager.shared.readDeviceListDataValues()
        if arrDeviceList.count > 0{
            for deviceData in arrDeviceList {
                if let index = peripherals.firstIndex(where: {$0.name == deviceData.serial_id}) {
                    peripherals.remove(at: index)
                }
            }
        }
        self.tblBluetooth?.reloadData()
    }
    
}
// MARK: BLE Scanning
extension ScanTableViewController:CBCentralManagerDelegate {
  
  func scanBLEDevices() {
    self.manager = CBCentralManager(delegate: self, queue: nil, options: nil)
    //stop scanning after 3 seconds
//    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
//      self.stopScanForBLEDevices()
//        textLog.write("BLE Scanning - Stop")
//    }
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

    func loadLuftDeviceData() {
        
    }
}
