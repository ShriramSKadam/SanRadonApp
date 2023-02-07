//
//  AddDeviceViewController.swift
//  luft
//
//  Created by iMac Augusta on 9/19/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ConnectPeripheralDelegate:class {
    func connectedPeripheralDevice(peripheralDevice:CBPeripheral)
}
protocol AddNewDeviceDataDelegate:class {
    func addNewdeviceDataDelegateDelegateStatus(upadte:Bool)
}

class AddDeviceViewController: LTViewController {

    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var connectBleDelegate:PeripheralDelegate? = nil
    var dashBoardDelegate:DashBoardDelegate? = nil
    
    var connectedBleDeviceDelegate:ConnectPeripheralDelegate? = nil
    var addDeviceDataDelegateStatus:AddNewDeviceDataDelegate? = nil
    var isfromDefaultAddDevice:Bool? = true
    var isfromScanView:Bool? = true
    
    @IBOutlet weak var lblTitle: LTHeaderTitleLabel!
    @IBOutlet weak var lblBorderTitle: LTHeaderBorderLabel!
    @IBOutlet weak var lblLogoImage: UIImageView!
    @IBOutlet weak var btnBack: LTBackImageButton!
    @IBOutlet weak var btnAddBack: UIButton!
    @IBOutlet weak var viewHeaderAddDevice: UIView!
    
    var intPermissionDisplay = 0
    
    // MARK: View Life Cycle
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideActivityIndicator(self.view)
        self.isfromScanView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lblBorderTitle.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
        self.viewHeaderAddDevice?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        if self.isfromDefaultAddDevice == true {
            if self.isfromScanView == true {
                self.navigationController?.popViewController(animated: false)
            }else {
                self.btnFindBLEDeviceTapped(self.btnAddBack)
            }
        }else {
            self.lblLogoImage.isHidden = true
            self.btnBack.isHidden = false
            self.lblTitle.isHidden = false
            self.lblBorderTitle.isHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
//        if RealmDataManager.shared.readDeviceListDataValues().count == 0 {
//            DispatchQueue.main.async(execute: {
//                self.tabBarController?.tabBar.isHidden = false
//                self.lblBorderTitle.isHidden = false
//            })
//            self.lblTitle.isHidden = true
//            self.btnBack.isHidden = true
//            self.lblLogoImage.isHidden = false
//
//        }else{
//            if self.isfromDefaultAddDevice == true {
//                if RealmDataManager.shared.readDeviceListDataValues().count != 0 {
//                    self.navigationController?.popViewController(animated: true)
//                }else {
//                    self.lblLogoImage.isHidden = true
//                    self.btnBack.isHidden = false
//                    self.lblTitle.isHidden = false
//                    self.lblBorderTitle.isHidden = false
//                    self.tabBarController?.tabBar.isHidden = true
//                }
//            }else {
//                self.lblLogoImage.isHidden = true
//                self.btnBack.isHidden = false
//                self.lblTitle.isHidden = false
//                self.lblBorderTitle.isHidden = true
//                self.tabBarController?.tabBar.isHidden = true
//            }
//
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        intPermissionDisplay = 0
        scanBLEDevices()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isfromDefaultAddDevice == true {
            self.tabBarController?.tabBar.isHidden = false
        }else {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
}

// MARK: BLE Scanning
extension AddDeviceViewController : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state {
        case .poweredOn:
            intPermissionDisplay = -1
            central.scanForPeripherals(withServices: nil, options: nil)
            textLog.write("BLE Scanning - Start")
        default:
            print("Please turn on bluetooth")
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
          
            //Helper.shared.showSnackBarAlert(message: "Please turn on bluetooth", type: .Failure)
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
       
        let arrDeviceList = RealmDataManager.shared.readDeviceListDataValues()
        if arrDeviceList.count > 0{
            for deviceData in arrDeviceList {
                if let index = peripherals.firstIndex(where: {$0.name == deviceData.serial_id}) {
                    peripherals.remove(at: index)
                }
            }
        }
    }
    
  
  func scanBLEDevices() {
    self.manager = CBCentralManager(delegate: self, queue: nil, options: nil)
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


extension AddDeviceViewController: PeripheralDelegate,AddDevicelDelegate,DashBoardDelegate {
    
    func isDashBoardAddDevice(isdashBoard:Bool){
        self.isfromScanView = true
    }
    
    func addDevicelDelegateStatus(upadte: Bool) {
        self.addDeviceDataDelegateStatus?.addNewdeviceDataDelegateDelegateStatus(upadte: true)
    }
    
    @IBAction func btnFindBLEDeviceTapped(_ sender: Any) {
        if intPermissionDisplay == -1 {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ScanTableViewController") as! ScanTableViewController
        vc.connectBleDelegate = self
        vc.dashBoardDelegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        } else {
            // Please enable BT for device
            self.scanBLEDevices()
        }
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func connectpPeripheralDevice(peripheralDevice:CBPeripheral) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcMYDeviceData = storyboard.instantiateViewController(withIdentifier: "AddMyDeviceViewController") as! AddMyDeviceViewController
        vcMYDeviceData.connectPeripheral = peripheralDevice
        vcMYDeviceData.adddeviceDelegate = self
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(vcMYDeviceData, animated: false)
    }
}

public class BtnBigHealthJigborder: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.titleLabel?.textColor = UIColor.white
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1.0
    }
}


public class IMGViewCornerRadius: UIImageView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1.0
        self.backgroundColor = UIColor.white
    }
}
