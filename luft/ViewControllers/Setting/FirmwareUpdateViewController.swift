//
//  FirmwareUpdateViewController.swift
//  Luft
//
//  Created by iMac Augusta on 12/31/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Alamofire.Swift

class FirmwareUpdateViewController: LTSettingBaseViewController {

    @IBOutlet weak var tblFWUViewDevice: UITableView!
    //Back Button Alerts
    @IBOutlet weak var btnFWBack: UIButton!
    //Update Button Alerts
    @IBOutlet weak var btnUpdateFW: UIButton!
    var arrSectionTilte: [String] = []
    var strCurrentDeviceID:Int = 0
    var arrCurrentIndexValue:[RealmPollutantValuesTBL] = []
    var arrCollectionReadDeviceData:[RealmDeviceList] = []
    var arrFWWillUpdateDeviceData:[FWDeviceData] = []
    var arrBLEDeviceData:[FWDeviceData] = []
    var arrFWCompletedDeviceData:[FWDeviceData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnUpdateFW?.isHidden = true
        self.tblFWUViewDevice?.delegate = self
        self.tblFWUViewDevice?.dataSource = self
        self.tblFWUViewDevice?.register(UINib(nibName: cellIdentity.settingHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.settingHeaderCellIdentifier)
         self.tblFWUViewDevice?.register(UINib(nibName: cellIdentity.firmwareTableViewCell, bundle: nil), forCellReuseIdentifier: cellIdentity.firmwareTableViewCell)
        self.btnFWBack.addTarget(self, action:#selector(self.btnFWBackTap(_sender:)), for: .touchUpInside)
        self.btnUpdateFW.addTarget(self, action:#selector(self.btnUpdateFWTap(_sender:)), for: .touchUpInside)
        self.tblFWUViewDevice?.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getFWVersionAPI()
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.tblFWUViewDevice?.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
    }
    
    func loadArrayDeviceData()  {
        if RealmDataManager.shared.readDeviceListDataValues().count
            != 0 {
            self.arrCollectionReadDeviceData.removeAll()
            self.arrSectionTilte.removeAll()
            self.arrCollectionReadDeviceData = RealmDataManager.shared.readDeviceListDataValues()
            for deviceData in self.arrCollectionReadDeviceData {
                
//                print(deviceData.firmware_version)
//                let result = deviceData.firmware_version.lowercased().filter("1234567890.".contains)
//                print(result)
                //if deviceData.firmware_version == strFirmwareVesrion {
                if deviceData.firmware_version.lowercased().filter("1234567890".contains) == strFirmwareVesrion.lowercased().filter("1234567890".contains) {
                    self.arrFWCompletedDeviceData.append(FWDeviceData.init(deviceName: deviceData.name, deviceID: deviceData.device_id, isSelected: false, deviceVersion: deviceData.firmware_version))
                }
                else if deviceData.wifi_status == true {
                    self.arrFWWillUpdateDeviceData.append(FWDeviceData.init(deviceName: deviceData.name, deviceID: deviceData.device_id, isSelected: true, deviceVersion: deviceData.firmware_version))
                }
                else if deviceData.wifi_status != true {
                    self.arrBLEDeviceData.append(FWDeviceData.init(deviceName: deviceData.name, deviceID: deviceData.device_id, isSelected: false, deviceVersion: deviceData.firmware_version))
                }else {
                    
                }
            }
            if self.arrFWWillUpdateDeviceData.count != 0 {
                self.arrSectionTilte.append(FW_WILL_UPDATE)
                self.btnUpdateFW?.isHidden = false
            }
            if self.arrBLEDeviceData.count != 0 {
                self.arrSectionTilte.append(FW_BLE_DEVICE)
            }
            if self.arrFWCompletedDeviceData.count != 0 {
                self.arrSectionTilte.append(FW_COMPLETED_UPDATE)
            }
        }else {
            self.arrSectionTilte.append("No Devices")
        }
        self.tblFWUViewDevice?.reloadData()
    }

    @objc func btnFWBackTap(_sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnUpdateFWTap(_sender:UIButton) {
        if Reachability.isConnectedToNetwork() == true {
            self.updateFirmWare()
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    
}

// MARK: - Table View Data's
extension FirmwareUpdateViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrSectionTilte.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.settingHeaderCellIdentifier) as? LTSettingHeaderViewTableViewCell
        cell?.lblHeaderTilte.text = self.arrSectionTilte[section]
        cell?.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        
        if self.arrSectionTilte[section] == FW_WILL_UPDATE {
            let attriString1 = NSAttributedString(string:"Firmware Update Available\n", attributes:
                [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellHeaderTitleColor,
                 NSAttributedString.Key.font: UIFont.setAppFontBold(17)])
            let attriString2 = NSAttributedString(string:String(format: "%@", self.arrSectionTilte[section]), attributes:
                [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellHeaderTitleColor.withAlphaComponent(0.9),
                 NSAttributedString.Key.font: UIFont.setSystemFontRegular(15)])
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(attriString1)
            mutableAttributedString.append(attriString2)
            cell?.lblHeaderTilte?.attributedText = mutableAttributedString
        }
        
        if self.arrSectionTilte[section] == FW_BLE_DEVICE {
            if self.arrFWWillUpdateDeviceData.count != 0 {
                cell?.lblHeaderTilte.textColor.withAlphaComponent(0.9)
                cell?.lblHeaderTilte.font = UIFont.setSystemFontRegular(15)
            }else {
                let attriString1 = NSAttributedString(string:"Firmware Update Available\n", attributes:
                    [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellHeaderTitleColor,
                     NSAttributedString.Key.font: UIFont.setAppFontBold(17)])
                let attriString2 = NSAttributedString(string:String(format: "%@", self.arrSectionTilte[section]), attributes:
                    [NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme().ltCellHeaderTitleColor.withAlphaComponent(0.9),
                     NSAttributedString.Key.font: UIFont.setSystemFontRegular(15)])
                let mutableAttributedString = NSMutableAttributedString()
                mutableAttributedString.append(attriString1)
                mutableAttributedString.append(attriString2)
                cell?.lblHeaderTilte?.attributedText = mutableAttributedString
            }
        }
        
        if self.arrSectionTilte[section] == FW_COMPLETED_UPDATE {
            cell?.lblHeaderTilte.font = UIFont.setAppFontBold(17)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.arrSectionTilte[section] == FW_COMPLETED_UPDATE {
            return 45
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.arrSectionTilte[section] == FW_WILL_UPDATE {
            return self.arrFWWillUpdateDeviceData.count
        }
        if self.arrSectionTilte[section] == FW_BLE_DEVICE {
            return self.arrBLEDeviceData.count
        }
        if self.arrSectionTilte[section] == FW_COMPLETED_UPDATE {
            return self.arrFWCompletedDeviceData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.arrSectionTilte.count != 0 {
            let cell:FirmwareTableViewCell = self.tblFWUViewDevice.dequeueReusableCell(withIdentifier: cellIdentity.firmwareTableViewCell, for: indexPath) as! FirmwareTableViewCell
            return self.themeCellSetting(cellValue: cell, index: indexPath)
        }else {
            return UITableViewCell()
        }
    
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.arrSectionTilte[indexPath.section] == FW_WILL_UPDATE {
            if self.arrFWWillUpdateDeviceData[indexPath.row].isSelected == true {
                self.arrFWWillUpdateDeviceData[indexPath.row].isSelected = false
            }else {
                self.arrFWWillUpdateDeviceData[indexPath.row].isSelected = true
            }
        }
        self.tblFWUViewDevice?.reloadData()
    }
}

extension FirmwareUpdateViewController {
    
    func themeCellSetting(cellValue:FirmwareTableViewCell,index:IndexPath) -> FirmwareTableViewCell {
 
        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltFWCellTitleColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltFWCellSubtitleColor
        
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleCell.isHidden = false
        cellValue.lblTitleCell.textAlignment = .left
        cellValue.lblSubTitleCell.textAlignment = .left

        cellValue.selectionStyle = .none
        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleCell.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        
        if self.arrSectionTilte[index.section] == FW_WILL_UPDATE {
            cellValue.lblTitleCell.text = self.arrFWWillUpdateDeviceData[index.row].deviceName
            cellValue.lblSubTitleCell.text = String(format: "Current version: %@", self.arrFWWillUpdateDeviceData[index.row].deviceVersion ?? "")
            if self.arrFWWillUpdateDeviceData[index.row].isSelected == true {                cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellSelectedCheckIconImage

                //cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            }else {
                cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellNonSelectedCheckIconImage

//                cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            }
            cellValue.lblTitleView.alpha = 1.0
            cellValue.lblSubTitleCell.alpha = 1.0
      
        }
        
        if self.arrSectionTilte[index.section] == FW_BLE_DEVICE {
            cellValue.lblTitleView.alpha = 0.5
            cellValue.lblSubTitleCell.alpha = 0.5
            cellValue.imgViewDisclosureCell.image = nil
            cellValue.lblTitleCell.text = self.arrBLEDeviceData[index.row].deviceName
            cellValue.lblSubTitleCell.text = String(format: "Current version: %@", self.arrBLEDeviceData[index.row].deviceVersion ?? "")
        }
        
        if self.arrSectionTilte[index.section] == FW_COMPLETED_UPDATE {
            cellValue.lblTitleView.alpha = 0.5
            cellValue.lblSubTitleCell.alpha = 0.5
            cellValue.imgViewDisclosureCell.image = nil
            cellValue.lblTitleCell.text = self.arrFWCompletedDeviceData[index.row].deviceName
            cellValue.lblSubTitleCell.text = String(format: "Current version: %@", self.arrFWCompletedDeviceData[index.row].deviceVersion ?? "")
        }
        return cellValue
    }
}

extension FirmwareUpdateViewController {
    
    func getFWVersionAPI() {
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
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
                            self.loadArrayDeviceData()
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
    
    func updateFirmWare() {
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            SwaggerClientAPI.basePath =  getDeviceGetAPIBaseUrl()
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getCurrentDeviceTokenDetails()
            var arr:[UpdateFirmware] = []
            for isUpdateDevice in self.arrFWWillUpdateDeviceData {
                if isUpdateDevice.isSelected == true {
                    arr.append(UpdateFirmware.init(deviceID: Int64(isUpdateDevice.deviceID ?? 0)))
                }
            }
            if arr.count != 0 {
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
                self.hideActivityIndicator(self.view)
                Helper.shared.showSnackBarAlert(message: "Please select atleast one Device", type: .Failure)
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}

extension Array where Element:Equatable {
    
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        return result
    }
}
