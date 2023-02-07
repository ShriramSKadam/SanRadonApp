//
//  LuftDeviceTableViewCell.swift
//  luft
//
//  Created by iMac Augusta on 10/14/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

protocol DeviceSelectedDelegate:class {
    func deviceSelectedDevice(deviceID:Int)
}
protocol FliterSelectedDelegate:class {
    func fliterSelectedDelegate(deviceID:Int)
}

class LuftDeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tblCellHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var collectionViewDevice: UICollectionView!
    var isGrdiSelected:Bool = true
    var arrCollectionReadDeviceData:[RealmDeviceList] = []
    var deviceSelectedDelgate:DeviceSelectedDelegate?
    var fliterSelectedDelegate:FliterSelectedDelegate?
    var arrCurrentIndexValue:[RealmPollutantValuesTBL] = []
    var selectedDropDownType:AppDropDownType? = .DropDownNone
    
    var arrColorCodeData:[RealmColorSetting] = []
    var arrPollutantVOCData:[RealmThresHoldSetting] = []
    var strCurrentDeviceID:Int = 0
    
    var colorRadonType:ColorType = .ColorNone
    var colorTempType:ColorType = .ColorNone
    var colorHumidityType:ColorType = .ColorNone
    var colorAirpressureType:ColorType = .ColorNone
    var colorVocType:ColorType = .ColorNone
    var colorEco2Type:ColorType = .ColorNone
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.collectionViewDevice.register(UINib(nibName: cellIdentity.deviceCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: cellIdentity.deviceCollectionViewCell)
        let headerNib = UINib.init(nibName: "HeaderViewCollectionViewCell", bundle: nil)
        self.collectionViewDevice.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewCollectionViewCell")
        // self.collectionViewDevice.register(HeaderViewCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: "HeaderViewCollectionViewCell")
        
    }
    
    func reloadCollectionView(arrDevice:[RealmDeviceList],isDashBorad:Bool = false) -> Void {
        self.arrCollectionReadDeviceData.removeAll()
        self.arrCollectionReadDeviceData = arrDevice
        self.collectionViewDevice.reloadData()
        self.collectionViewDevice.isScrollEnabled = false
        self.isGrdiSelected = false
        if AppSession.shared.getUserSelectedLayout() == 2{
            self.isGrdiSelected = true
        }else {
            self.isGrdiSelected = false
        }
        if isDashBorad == true {
          self.tblCellHeightConstant?.constant = 10
        }else {
            self.tblCellHeightConstant?.constant = 0
        }
    }
}

// MARK: - UICollectionViewDataSource protocol
extension LuftDeviceTableViewCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderViewCollectionViewCell", for: indexPath) as! HeaderViewCollectionViewCell
            headerView.applyHeaderTheme()
            headerView.viewHeaderFliter?.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
            headerView.viewHeaderLbl?.textColor = ThemeManager.currentTheme().ltCellHeaderTitleColor
            headerView.btnFliter.addTarget(self, action:#selector(self.btnFliterIconTapped(_sender:)), for: .touchUpInside)
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if let cellCount:Int = self.arrCollectionReadDeviceData.count {
//            return cellCount
//        }
        return self.arrCollectionReadDeviceData.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellOfDeviceNameCollection = self.collectionViewDevice.dequeueReusableCell(withReuseIdentifier: "DeviceCollectionViewCell", for: indexPath) as! DeviceCollectionViewCell
        if isGrdiSelected  {
            cellOfDeviceNameCollection.lblDeviceName.textAlignment = .left
        }else {
            cellOfDeviceNameCollection.lblDeviceName.textAlignment = .center
        }
        if self.arrCollectionReadDeviceData.count > 0 {
            self.loadCellData(indexPath: indexPath, cell: cellOfDeviceNameCollection)
        }
        return cellOfDeviceNameCollection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGrdiSelected {
            return CGSize(width:self.frame.size.width, height:50)
        }else {
            let lay = collectionViewLayout as! UICollectionViewFlowLayout
            let widthPerItem = collectionView.frame.width / 3 - lay.minimumInteritemSpacing
            return CGSize(width:widthPerItem, height:100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 1.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
        //            guard let deviceData:RealmDeviceList = self.arrCollectionReadDeviceData[indexPath.row], !deviceData.isInvalidated else {
        //               // print(self.arrCollectionReadDeviceData[indexPath.row].device_id)
        //                self.deviceSelectedDelgate?.deviceSelectedDevice(deviceID: -100)
        //                return
        //            }
        //            self.deviceSelectedDelgate?.deviceSelectedDevice(deviceID: deviceData.device_id)
        //        }
        //        //self.deviceSelectedDelgate?.deviceSelectedDevice(deviceID: self.arrCollectionReadDeviceData[indexPath.row].device_id)
        
        guard !self.arrCollectionReadDeviceData[indexPath.row].isInvalidated else {
            // print(self.arrCollectionReadDeviceData[indexPath.row].device_id)
            self.deviceSelectedDelgate?.deviceSelectedDevice(deviceID: -100)
            return
        }
        self.deviceSelectedDelgate?.deviceSelectedDevice(deviceID: self.arrCollectionReadDeviceData[indexPath.row].device_id)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if isGrdiSelected {
            return CGSize(width:self.frame.size.width, height:45)
        }
        return CGSize(width: collectionView.frame.width, height: 0)
    }
    
    @objc func btnFliterIconTapped(_sender:UIButton) {
        self.fliterSelectedDelegate?.fliterSelectedDelegate(deviceID: 0)
    }
}
extension LuftDeviceTableViewCell {
    
    func loadCellData(indexPath:IndexPath,cell:DeviceCollectionViewCell)  {
        
        guard !self.arrCollectionReadDeviceData[indexPath.row].isInvalidated else {
            self.deviceSelectedDelgate?.deviceSelectedDevice(deviceID: -100)
            return
        }
        
        self.strCurrentDeviceID = self.arrCollectionReadDeviceData[indexPath.row].device_id
        cell.applyCellNameDataTheme()
        cell.imgViewBluWifi.alpha = 0.5
        
        if !self.isGrdiSelected {
            if self.arrCollectionReadDeviceData[indexPath.row].wifi_status == true {
                cell.imgViewBluWifi.image = UIImage.init(named: "wifiimg")
            }else {
                cell.imgViewBluWifi.image = UIImage.init(named: "bluetooth")
            }
        }else {
            cell.imgViewBluWifi.image = UIImage.init(named: "")
        }
        
        if !self.isGrdiSelected {
            cell.lblBottomBorder.isHidden = true
            cell.lblDeviceName?.textColor = UIColor.white
            cell.lblDeviceName?.text = self.arrCollectionReadDeviceData[indexPath.row].name
        }else {
            cell.lblBottomBorder.isHidden = false
            cell.lblDeviceName?.text = String(format: " %@",self.arrCollectionReadDeviceData[indexPath.row].name)
        }
        self.arrCurrentIndexValue.removeAll()
        self.arrCurrentIndexValue = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: self.strCurrentDeviceID)
        print("DeviceID's")
        print(self.strCurrentDeviceID)
        if self.arrCurrentIndexValue.count != 0 {
            self.colorRadonType = Helper.shared.getRadonColor(myValue: self.arrCurrentIndexValue[0].Radon, deviceId: self.strCurrentDeviceID).type
            self.colorVocType = Helper.shared.getVOCColor(myValue: self.arrCurrentIndexValue[0].VOC, deviceId: self.strCurrentDeviceID).type
            self.colorEco2Type = Helper.shared.getECO2Color(myValue: self.arrCurrentIndexValue[0].CO2, deviceId: self.strCurrentDeviceID).type
            self.colorTempType = Helper.shared.getTempeatureColor(myValue: self.arrCurrentIndexValue[0].Temperature, deviceId: self.strCurrentDeviceID).type
            self.colorAirpressureType = Helper.shared.getAirPressueColor(myValue: self.arrCurrentIndexValue[0].AirPressure, deviceId: self.strCurrentDeviceID).type
            self.colorHumidityType = Helper.shared.getHumidityColor(myValue: self.arrCurrentIndexValue[0].Humidity, deviceId: self.strCurrentDeviceID).type
            
            if self.colorRadonType == ColorType.ColorAlert || self.colorVocType == ColorType.ColorAlert || self.colorEco2Type == ColorType.ColorAlert || self.colorTempType == ColorType.ColorAlert || self.colorAirpressureType == ColorType.ColorAlert || self.colorHumidityType == ColorType.ColorAlert {
                
                if !self.isGrdiSelected {
                    cell.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorAlert))
                    cell.lblSideBorder.backgroundColor = UIColor.clear
                    
                }else {
                    cell.backgroundColor = UIColor.clear
                    cell.lblSideBorder.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorAlert))
                }
            }else if self.colorRadonType == ColorType.ColorWarning || self.colorVocType == ColorType.ColorWarning || self.colorEco2Type == ColorType.ColorWarning || self.colorTempType == ColorType.ColorWarning || self.colorAirpressureType == ColorType.ColorWarning || self.colorHumidityType == ColorType.ColorWarning {
                if !self.isGrdiSelected {
                    cell.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorWarning))
                    cell.lblSideBorder.backgroundColor = UIColor.clear
                    
                }else {
                    cell.backgroundColor = UIColor.clear
                    cell.lblSideBorder.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorWarning))
                }
            }else {
                if !self.isGrdiSelected {
                    cell.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
                    cell.lblSideBorder.backgroundColor = UIColor.clear
                    
                }else {
                    cell.backgroundColor = UIColor.clear
                    cell.lblSideBorder.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
                }
            }
            
        }else {
            if !self.isGrdiSelected {
                cell.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
                cell.lblSideBorder.backgroundColor = UIColor.clear
                
            }else {
                cell.backgroundColor = UIColor.clear
                cell.lblSideBorder.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
            }
        }
    }
    
}
