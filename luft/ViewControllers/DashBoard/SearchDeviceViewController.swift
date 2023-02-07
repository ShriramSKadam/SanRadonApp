//
//  SearchDeviceViewController.swift
//  Luft
//
//  Created by iMac Augusta on 11/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

protocol LTSearchDeviceDelegate:class {
    func selectedDeviceID(deviceID:Int)
}

class SearchDeviceViewController: LTSettingBaseViewController {

    @IBOutlet weak var collectionSearchViewDevice: UICollectionView!
    @IBOutlet weak var textSearchDevice: UISearchBar!
    
    var arrCollectionReadDeviceData:[RealmDeviceList] = []
    var sortArrReadDeviceData:[RealmDeviceList] = []
    var deviceSearchDelgate:LTSearchDeviceDelegate?
    var arrCurrentIndexValue:[RealmPollutantValuesTBL] = []
    var strCurrentDeviceID:Int = 0
    var colorRadonType:ColorType = .ColorNone
    var colorTempType:ColorType = .ColorNone
    var colorHumidityType:ColorType = .ColorNone
    var colorAirpressureType:ColorType = .ColorNone
    var colorVocType:ColorType = .ColorNone
    var colorEco2Type:ColorType = .ColorNone
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionSearchViewDevice?.delegate = self
        self.collectionSearchViewDevice?.dataSource = self
        self.collectionSearchViewDevice?.register(UINib(nibName: cellIdentity.deviceCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: cellIdentity.deviceCollectionViewCell)
        self.textSearchDevice?.delegate = self
        let headerNib = UINib.init(nibName: "HeaderViewCollectionViewCell", bundle: nil)
        self.collectionSearchViewDevice.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadArrayDeviceData()
        self.textSearchDevice?.becomeFirstResponder()
        self.customizeSearchBar()
    }
    
    func loadArrayDeviceData()  {
        if RealmDataManager.shared.readDeviceListDataValues().count
            != 0 {
            self.arrCollectionReadDeviceData.removeAll()
            self.arrCollectionReadDeviceData = RealmDataManager.shared.readDeviceListDataValues()
            self.reloadCollectionView(arrDevice: self.arrCollectionReadDeviceData)
        }
    }
    
    func reloadCollectionView(arrDevice:[RealmDeviceList]) -> Void {
        self.sortArrReadDeviceData.removeAll()
        self.sortArrReadDeviceData = arrDevice
        self.collectionSearchViewDevice.reloadData()
    }
}

// MARK: - UICollectionViewDataSource protocol
extension SearchDeviceViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderViewCollectionViewCell", for: indexPath) as! HeaderViewCollectionViewCell
            headerView.imgViewFliter.image = nil
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.sortArrReadDeviceData.count != 0 {
            return self.sortArrReadDeviceData.count
        }
        return 0
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellOfDeviceNameCollection = self.collectionSearchViewDevice.dequeueReusableCell(withReuseIdentifier: "DeviceCollectionViewCell", for: indexPath) as! DeviceCollectionViewCell
        cellOfDeviceNameCollection.lblDeviceName.textAlignment = .left
        if self.sortArrReadDeviceData.count > 0 {
            self.loadCellData(indexPath: indexPath, cell: cellOfDeviceNameCollection)
        }
        return cellOfDeviceNameCollection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:self.view.frame.size.width, height:50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 1.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.deviceSearchDelgate?.selectedDeviceID(deviceID: self.sortArrReadDeviceData[indexPath.row].device_id)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:self.collectionSearchViewDevice.frame.size.width, height:45)
    }
}
extension SearchDeviceViewController {
    
    func loadCellData(indexPath:IndexPath,cell:DeviceCollectionViewCell)  {
        
        self.strCurrentDeviceID = self.sortArrReadDeviceData[indexPath.row].device_id
        cell.applyCellNameDataTheme()
        cell.imgViewBluWifi.alpha = 0.5
        cell.imgViewBluWifi.image = UIImage.init(named: "")
        cell.lblBottomBorder.isHidden = false
        cell.lblDeviceName?.text = String(format: " %@",self.sortArrReadDeviceData[indexPath.row].name)
        //cell.lblDeviceName?.text = self.sortArrReadDeviceData[indexPath.row].name
        self.arrCurrentIndexValue.removeAll()
        self.arrCurrentIndexValue = RealmDataManager.shared.readCurrentIndexPollutantDataValues(device_ID: self.strCurrentDeviceID)
        
        print(self.strCurrentDeviceID)
        if self.arrCurrentIndexValue.count != 0 {
            self.colorRadonType = Helper.shared.getRadonColor(myValue: self.arrCurrentIndexValue[0].Radon, deviceId: self.strCurrentDeviceID).type
            self.colorVocType = Helper.shared.getVOCColor(myValue: self.arrCurrentIndexValue[0].VOC, deviceId: self.strCurrentDeviceID).type
            self.colorEco2Type = Helper.shared.getECO2Color(myValue: self.arrCurrentIndexValue[0].CO2, deviceId: self.strCurrentDeviceID).type
            self.colorTempType = Helper.shared.getTempeatureColor(myValue: self.arrCurrentIndexValue[0].Temperature, deviceId: self.strCurrentDeviceID).type
            self.colorAirpressureType = Helper.shared.getAirPressueColor(myValue: self.arrCurrentIndexValue[0].AirPressure, deviceId: self.strCurrentDeviceID).type
            self.colorHumidityType = Helper.shared.getHumidityColor(myValue: self.arrCurrentIndexValue[0].Humidity, deviceId: self.strCurrentDeviceID).type
            
            if self.colorRadonType == ColorType.ColorAlert || self.colorVocType == ColorType.ColorAlert || self.colorEco2Type == ColorType.ColorAlert || self.colorTempType == ColorType.ColorAlert || self.colorAirpressureType == ColorType.ColorAlert || self.colorHumidityType == ColorType.ColorAlert {
                
                cell.backgroundColor = UIColor.clear
                cell.lblSideBorder.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorAlert))
                
            }else if self.colorRadonType == ColorType.ColorWarning || self.colorVocType == ColorType.ColorWarning || self.colorEco2Type == ColorType.ColorWarning || self.colorTempType == ColorType.ColorWarning || self.colorAirpressureType == ColorType.ColorWarning || self.colorHumidityType == ColorType.ColorWarning {
                cell.backgroundColor = UIColor.clear
                cell.lblSideBorder.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorWarning))
            }else {
                cell.backgroundColor = UIColor.clear
                cell.lblSideBorder.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
            }
            
        }else {
            cell.backgroundColor = UIColor.clear
            cell.lblSideBorder.backgroundColor = UIColor.init(hexString: Helper.shared.getDeviceDataAlertColor(deviceID: self.strCurrentDeviceID, colorType: .ColorOk))
        }
    }
}

extension  SearchDeviceViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.deviceSearchDelgate?.selectedDeviceID(deviceID: -100)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = self.removeWhiteSpace(text: searchText)
        if searchString != "", searchString.count > 0 {
            self.sortArrReadDeviceData.removeAll()
            self.sortArrReadDeviceData = self.arrCollectionReadDeviceData.filter {
                return $0.name.range(of: searchString, options: .caseInsensitive) != nil
            }
            self.collectionSearchViewDevice?.reloadData()
        }else {
            self.loadArrayDeviceData()
        }
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
           self.loadArrayDeviceData()
        }
    }
    
    func customizeSearchBar()  {
//        self.textSearchDevice.setTextField(color: ThemeManager.currentTheme().ltSearchViewBackGroundColor)
//        self.textSearchDevice.setTextFieldColor(color: ThemeManager.currentTheme().ltSettingTxtColor)
//        self.textSearchDevice.setPlaceholderTextFieldColor(color: ThemeManager.currentTheme().ltSearchPlaceHolderTextColor)
//        self.textSearchDevice.setShowsCancelButton(false, animated: true)
//        self.textSearchDevice.showsCancelButton = false
//        self.collectionSearchViewDevice?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
//        self.textSearchDevice.barTintColor = ThemeManager.currentTheme().viewBackgroundColor
        
        self.textSearchDevice.setTextField(color: ThemeManager.currentTheme().ltSearchViewBackGroundColor)
        self.textSearchDevice.setTextFieldColor(color: ThemeManager.currentTheme().ltSettingTxtColor)
        self.textSearchDevice.setSearchBorderTextFieldColor(color: ThemeManager.currentTheme().searchBorderColor)
        self.textSearchDevice.setPlaceholderTextFieldColor(color: ThemeManager.currentTheme().ltSearchPlaceHolderTextColor)
        self.textSearchDevice.showsCancelButton = false
    self.textSearchDevice.setSearchBorderImageColor(color:ThemeManager.currentTheme().ltSearchPlaceHolderTextColor)
        self.textSearchDevice.barTintColor = ThemeManager.currentTheme().viewBackgroundColor
        self.collectionSearchViewDevice?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.textSearchDevice.barTintColor = ThemeManager.currentTheme().viewBackgroundColor
        
        let view: UIView = self.textSearchDevice.subviews[0] as UIView
        let subViewsArray = view.subviews
        for subView: UIView in subViewsArray {
            if let cancelButt = subView as? UIButton{
                cancelButt.setTitleColor(UIColor.blue, for: .normal)
            }
        }
    }
}
