//
//  LTDropDownViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/16/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData

protocol LTDropDownDelegate:class {
    func selectedHomeBuildType(userDataSetting:AppUser)
}

protocol LTDropDownMitigationBuildingType:class {
    func selectedHomeBuildType(id:Int,idvalue:String)
}

protocol LTDropDownThersHoldDelegate:class {
    func selectedThresHoldValue(selectedValue:String)
}

protocol LTDropDownDeviceListDelegate:class {
    func selectedDeviceList(selectedDeviceName:String,selectedDeviceID:Int)
}

protocol LTDropDownColorDelegate:class {
    func selectedColor(selectedColor:String,selectedColorCode:String)
}

struct SettingBuildTypeData {
    public var description: String?
    public var name: String?
    public var createdBy: String?
    public var id: String?
    public var updatedBy: String?
    public var datecreated: String?
    public var datemodified: String?
    
    
    init(description: String?, name: String?,datecreated: String?, datemodified: String?, createdBy: String?, id: String?, updatedBy: String?) {
        self.description = description
        self.name = name
        self.createdBy = createdBy
        self.id = id
        self.updatedBy = updatedBy
        self.datecreated = datecreated
        self.datecreated = datemodified
    }
}

struct ColorData {
    public var colorName: String?
    public var colorCode: String?
   
    
    init(colorName: String?, colorCode: String?) {
        self.colorName = colorName
        self.colorCode = colorCode
    }
}

struct FWDeviceData {
    public var deviceName: String?
    public var deviceID: Int?
    public var isSelected: Bool? = false
    public var deviceVersion: String?
    
    init(deviceName: String?, deviceID: Int?, isSelected: Bool, deviceVersion: String?) {
        self.deviceName = deviceName
        self.deviceID = deviceID
        self.isSelected = isSelected
        self.deviceVersion = deviceVersion
    }
}

struct FWHeaderData {
    public var titleName: String?
    public var orderID: Int?
    
    init(titleName: String?, orderID: Int?) {
        self.titleName = titleName
        self.orderID = orderID
    }
}

class LTDropDownViewController: UIViewController {
    
    @IBOutlet weak var btnClosMenu: UIButton!
    @IBOutlet weak var btnTitleMenu: UIButton!
    @IBOutlet weak var tblMenu: UITableView!
    
    var arrSectionTilte: [String] = ["DeviceName","Rename","Notification","Check for firmware update","Remove device","Connect Wi-Fi","Share data"]
    var dropDownType:AppDropDownType? = .DropDownNone
    var dropDownThersHoldDelegate:LTDropDownThersHoldDelegate? = nil
    var dropDownColorDelegate:LTDropDownColorDelegate? = nil
    var dropDownBuildingMititgationDelegate:LTDropDownMitigationBuildingType? = nil
    var dropDownDeviceList:LTDropDownDeviceListDelegate? = nil
    
    
    var settingContext: NSManagedObjectContext!
    var arrHomeBuildingTypeData: [SettingBuildTypeData?] = []
    var arrMtigationData: [SettingBuildTypeData?] = []
    var arrDeviceNameList: [RealmDeviceList] = []
    var arrThersHoldsNameList: [String] = []
    var arrColorCodeList: [ColorData] = []
    var selectedDropType:SelectedFieldType? = .SelectedNone
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblMenu.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.settingContext = appDelegate.persistentContainer.viewContext
        self.arrDeviceNameList.removeAll()
        self.arrThersHoldsNameList.removeAll()
        self.arrHomeBuildingTypeData.removeAll()
        self.arrMtigationData.removeAll()
        self.arrColorCodeList.removeAll()
        if AppSession.shared.getUserSelectedTheme() == 2{
           self.btnTitleMenu.setTitleColor(UIColor.white, for: .normal)
        }else {
           self.btnTitleMenu.setTitleColor(UIColor.black, for: .normal)
        }
        self.btnTitleMenu.titleLabel?.font = UIFont.setAppFontBold(17)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tblMenu?.delegate = self
        self.tblMenu?.dataSource = self
        self.tblMenu.register(UINib(nibName: cellIdentity.settingCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.settingCellIdentifier)
        self.tabBarController?.tabBar.isHidden = true
        if self.selectedDropType == .SelectedWarning{
            self.btnTitleMenu?.setTitle("Warning", for: .normal)
        }
        if self.selectedDropType == .SelectedAlert{
            self.btnTitleMenu?.setTitle("Alert", for: .normal)
        }
        if self.selectedDropType == .SelectedLowWarning{
            self.btnTitleMenu?.setTitle("Warning (Low Warning)", for: .normal)
        }
        
        if self.selectedDropType == .SelectedAlertsEnabledWarning{
            self.btnTitleMenu?.setTitle("Warning (Alerts Enabled)", for: .normal)
        }
        
        if self.selectedDropType == .SelectedLowAlert{
            self.btnTitleMenu?.setTitle("Alert (Low Warning)", for: .normal)
        }
        if self.selectedDropType == .SelectedHighWarning{
            self.btnTitleMenu?.setTitle("Warning (High Warning)", for: .normal)
        }
        if self.selectedDropType == .SelectedHighAlert{
            self.btnTitleMenu?.setTitle("Alert (High Warning)", for: .normal)
        }
        if(self.dropDownType == .DropDownHomeBuildingType){
            self.readDataFromDBHomeBuilding()
            self.btnTitleMenu.setTitle("Building Type", for: .normal)
        }
        else if(self.dropDownType == .DropDownMitigationType){
            self.readDataFromDBMitication()
            self.btnTitleMenu.setTitle("Mitigation System", for: .normal)
        }
        else if(self.dropDownType == .DropDownDeviceList){
            self.readDataFromDBDeviceList()
            self.btnTitleMenu.setTitle("Device Name", for: .normal)
        }
        else if(self.dropDownType == .DropDownRadonBQM){
            self.readDataFromDBRadonBQMList()
        }
        else if(self.dropDownType == .DropDownRadonPCII){
            self.readDataFromDBRadonPCIIList()
        }
        else if(self.dropDownType == .DropDownVOC){
            self.readDataFromDBRadonVOCList()
        }
        else if(self.dropDownType == .DropDownECO2){
            self.readDataFromDBRadonECO2List()
        }
        else if(self.dropDownType == .DropDownHUMIDITY){
            self.readDataFromDBRadonHUMIDITYList()
        }
        else if(self.dropDownType == .DropDownAIRPRESSURE_INHG){
            self.readDataFromDBRadonAIRINHGList()
        }
        else if(self.dropDownType == .DropDownAIRPRESSURE_KPA){
            self.readDataFromDBRadonAIRKPAList() 
        }
        else if(self.dropDownType == .DropDownAIRPRESSURE_MBAR){
            self.readDataFromDBRadonAIRMBARList()
        }
        else if(self.dropDownType == .DropDownTEMPERATURE_CELSIUS){
            self.readDataFromDBTemperatureCelsiusList()
        }
        else if(self.dropDownType == .DropDownTEMPERATURE_FAHRENHEIT){
            self.readDataFromDBTemperatureFahrenheitList()
        }
        else if(self.dropDownType == .DropDownCOLOR_CODE){
            self.btnTitleMenu.setTitle("Color options", for: .normal)
            self.readDataFromDBTemperatureColorList()
        }
        else{
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
}

extension LTDropDownViewController {
    
    @IBAction func btnTapClose(_sender:UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension LTDropDownViewController:UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.dropDownType == .DropDownHomeBuildingType) {
            return self.arrHomeBuildingTypeData.count
        }
        if(self.dropDownType == .DropDownMitigationType) {
            return self.arrMtigationData.count
        }
        else if(self.dropDownType == .DropDownDeviceList) {
            return self.arrDeviceNameList.count
        }
        else if(self.dropDownType == .DropDownRadonBQM ||
            self.dropDownType == .DropDownRadonPCII ||
            self.dropDownType == .DropDownVOC ||
            self.dropDownType == .DropDownECO2 ||
            self.dropDownType == .DropDownHUMIDITY ||
            self.dropDownType == .DropDownAIRPRESSURE_INHG ||
            self.dropDownType == .DropDownAIRPRESSURE_KPA ||
            self.dropDownType == .DropDownAIRPRESSURE_MBAR ||
            self.dropDownType == .DropDownTEMPERATURE_CELSIUS ||
            self.dropDownType == .DropDownTEMPERATURE_FAHRENHEIT) {
            return self.arrThersHoldsNameList.count
        }else if(self.dropDownType == .DropDownCOLOR_CODE){
            return self.arrColorCodeList.count
        }else {
            return self.arrSectionTilte.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellValue = tableView.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier) as! LTSettingListTableViewCell
        
        cellValue.lblSubTitleCell.text = ""
//        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().dropDownltCellTitleColor
//        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleView.isHidden = true
        cellValue.lblTitleCell.textAlignment = .left
        cellValue.lblSubTitleCell.textAlignment = .right
        cellValue.imgViewDisclosureCell.image = nil
        cellValue.selectionStyle = .none
//        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
//        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
//        cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
//        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
//        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
//        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().dropDownCellBackgroundColor
//
//        cell.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor

        cellValue.lblTitleCell.textAlignment = .center
        
        if(self.dropDownType == .DropDownHomeBuildingType)
        {
            cellValue.lblTitleCell.text = self.arrHomeBuildingTypeData[indexPath.row]?.name
        }
        if(self.dropDownType == .DropDownMitigationType) {
            cellValue.lblTitleCell.text = self.arrMtigationData[indexPath.row]?.name
        }
        if(self.dropDownType == .DropDownDeviceList)
        {
            cellValue.lblTitleCell.text = self.arrDeviceNameList[indexPath.row].name
        }
        if(self.dropDownType == .DropDownRadonBQM ||
            self.dropDownType == .DropDownRadonPCII ||
            self.dropDownType == .DropDownVOC ||
            self.dropDownType == .DropDownECO2 ||
            self.dropDownType == .DropDownHUMIDITY ||
            self.dropDownType == .DropDownAIRPRESSURE_INHG ||
            self.dropDownType == .DropDownAIRPRESSURE_KPA ||
            self.dropDownType == .DropDownAIRPRESSURE_MBAR ||
            self.dropDownType == .DropDownTEMPERATURE_CELSIUS ||
            self.dropDownType == .DropDownTEMPERATURE_FAHRENHEIT) {
             cellValue.lblTitleCell.text = self.arrThersHoldsNameList[indexPath.row]
            
            if self.dropDownType == .DropDownRadonBQM {
                let valueStr = String(format: "%@ Bq/m" , self.arrThersHoldsNameList[indexPath.row])
                let numberString = NSMutableAttributedString(string: valueStr, attributes: [.font: UIFont.setSystemFontRegular(17)])
                numberString.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 8]))
                cellValue.lblTitleCell.attributedText = numberString
            }
           
        }else if(self.dropDownType == .DropDownCOLOR_CODE){
            cellValue.lblTitleCell.text = self.arrColorCodeList[indexPath.row].colorName
        }else {
            //cellValue.lblTitleCell.text = self.arrSectionTilte[indexPath.row]
        }
        return cellValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(self.dropDownType == .DropDownNone)
        {

        }
        else if(self.dropDownType == .DropDownHomeBuildingType) {
            if let idType:Int =  Int(self.arrHomeBuildingTypeData[indexPath.row]?.id ?? "0"){
                self.dropDownBuildingMititgationDelegate?.selectedHomeBuildType(id: idType, idvalue: self.arrHomeBuildingTypeData[indexPath.row]?.name ?? "")
            }else {
                self.dropDownBuildingMititgationDelegate?.selectedHomeBuildType(id: 0, idvalue: self.arrHomeBuildingTypeData[indexPath.row]?.name ?? "")
            }
        }
        else if(self.dropDownType == .DropDownMitigationType) {
            if let idType:Int = Int(self.arrMtigationData[indexPath.row]?.id ?? "0") {
                self.dropDownBuildingMititgationDelegate?.selectedHomeBuildType(id: idType, idvalue: self.arrMtigationData[indexPath.row]?.name ?? "")
            }else {
                self.dropDownBuildingMititgationDelegate?.selectedHomeBuildType(id: 0, idvalue: self.arrMtigationData[indexPath.row]?.name ?? "")
            }
        }
        else if(self.dropDownType == .DropDownDeviceList) {
            self.dropDownDeviceList?.selectedDeviceList(selectedDeviceName: self.arrDeviceNameList[indexPath.row].name, selectedDeviceID: self.arrDeviceNameList[indexPath.row].device_id)
        }
        else if(self.dropDownType == .DropDownRadonBQM ||
            self.dropDownType == .DropDownRadonPCII ||
            self.dropDownType == .DropDownVOC ||
            self.dropDownType == .DropDownECO2 ||
            self.dropDownType == .DropDownHUMIDITY ||
            self.dropDownType == .DropDownAIRPRESSURE_INHG ||
            self.dropDownType == .DropDownAIRPRESSURE_KPA ||
            self.dropDownType == .DropDownAIRPRESSURE_MBAR ||
            self.dropDownType == .DropDownTEMPERATURE_CELSIUS ||
            self.dropDownType == .DropDownTEMPERATURE_FAHRENHEIT) {
            self.dropDownThersHoldDelegate?.selectedThresHoldValue(selectedValue: self.arrThersHoldsNameList[indexPath.row])
        }
        else if(self.dropDownType == .DropDownCOLOR_CODE ) {
            self.dropDownColorDelegate?.selectedColor(selectedColor: self.arrColorCodeList[indexPath.row].colorName ?? "", selectedColorCode: self.arrColorCodeList[indexPath.row].colorCode ?? "")
        }
        
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}


// MARK: - Core Data
extension LTDropDownViewController {
    

    func readDataFromDBHomeBuilding()  {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_BUILDING_TYPE)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.returnsObjectsAsFaults = false
        do {
            let result = try settingContext.fetch(request)
            for datavalue in result{
                let dataType : NSManagedObject? = datavalue as? NSManagedObject
                let descValue = dataType?.value(forKey: "descriptionValue") as? String ?? ""
                let name = dataType?.value(forKey: "name") as? String ?? ""
                let datecreated = dataType?.value(forKey: "datecreated") as? String ?? ""
                let datemodified = dataType?.value(forKey: "datemodified") as? String ?? ""
                let id = dataType?.value(forKey: "id") as? String ?? ""
                let updatedBy = dataType?.value(forKey: "updatedBy") as? String ?? ""
                let createdBy = dataType?.value(forKey: "createdBy") as? String ?? ""
                let storeData = SettingBuildTypeData.init(description: descValue, name: name, datecreated: datecreated, datemodified: datemodified, createdBy: createdBy, id: id, updatedBy: updatedBy)
                self.arrHomeBuildingTypeData.append(storeData)
            }
            self.tblMenu?.reloadData()
        } catch {
            print("Failed")
        }
    }
    
    func readDataFromDBMitication()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.settingContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_MITIGATION_TYPE)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.returnsObjectsAsFaults = false
        do {
            let result = try settingContext.fetch(request)
            for datavalue in result{
                let dataType : NSManagedObject? = datavalue as? NSManagedObject
                let descValue = dataType?.value(forKey: "descriptionValue") as? String ?? ""
                let name = dataType?.value(forKey: "name") as? String ?? ""
                let datecreated = dataType?.value(forKey: "datecreated") as? String ?? ""
                let datemodified = dataType?.value(forKey: "datemodified") as? String ?? ""
                let id = dataType?.value(forKey: "id") as? String ?? ""
                let updatedBy = dataType?.value(forKey: "updatedBy") as? String ?? ""
                let createdBy = dataType?.value(forKey: "createdBy") as? String ?? ""
                let storeData = SettingBuildTypeData.init(description: descValue, name: name, datecreated: datecreated, datemodified: datemodified, createdBy: createdBy, id: id, updatedBy: updatedBy)
                self.arrMtigationData.append(storeData)
            }
            self.tblMenu?.reloadData()
        } catch {
            print("Failed")
        }
    }
    //Device List
    func readDataFromDBDeviceList()  {
        self.arrDeviceNameList = RealmDataManager.shared.readDeviceListDataValues()
        if self.arrDeviceNameList.count > 0 {
            self.arrDeviceNameList = self.arrDeviceNameList.sorted(by: { $0.name < $1.name })
            self.tblMenu?.reloadData()
        }else {
            self.dismiss(animated: false, completion: nil)
            Helper.shared.showSnackBarAlert(message: "No device in your account", type: .Failure)
        }
    }
    //Radon PCII List
    func readDataFromDBRadonPCIIList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_RADON_PCII)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "pcii") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    //Radon BQM List
    func readDataFromDBRadonBQMList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_RADON_BQM)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "bqm3") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    //VOC List
    func readDataFromDBRadonVOCList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_VOC)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "vocvalue") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    //ECO2 List
    func readDataFromDBRadonECO2List()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_ECO2)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "eco2") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    //HUMIDITY List
    func readDataFromDBRadonHUMIDITYList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_HUMIDITY)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "humidityvalue") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    
    //AIRKPA List
    func readDataFromDBRadonAIRKPAList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_AIR_KPA)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "airprekpavalue") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    //MBAR List
    func readDataFromDBRadonAIRMBARList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_AIR_MBAR)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "mbarvalue") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    //AIRINHG List
    func readDataFromDBRadonAIRINHGList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_AIR_INKG)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "airpreinhgvalue") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    //TEMPERATURE Celsius List
    func readDataFromDBTemperatureCelsiusList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_TEMP_CELSIUS)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "temperaturecelsiusvalue") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    //TEMPERATURE Fahrenheit List
    func readDataFromDBTemperatureFahrenheitList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_TEMP_FAHRENHEIT)
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                    if let deviceName = datavalue.value(forKey: "tempfahrenheitvalue") as? String {
                        self.arrThersHoldsNameList.append(deviceName)
                        if self.arrThersHoldsNameList.count > 0 {
                            self.arrThersHoldsNameList.localizedStandardSort(.orderedAscending)
                            self.tblMenu?.reloadData()
                        }
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    //TEMPERATURE Fahrenheit List
    func readDataFromDBTemperatureColorList()  {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_COLORS)
        request.sortDescriptors = [NSSortDescriptor(key: "colorname", ascending: true)]
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.settingContext.fetch(request)
            if let resultData = result as? [NSManagedObject] {
                for datavalue in resultData {
                     let colorName = datavalue.value(forKey: "colorname") as? String
                     let colorCode = datavalue.value(forKey: "colorcode") as? String
                    self.arrColorCodeList.append(ColorData.init(colorName: colorName, colorCode: colorCode))
                }
                self.tblMenu?.reloadData()
            }
        } catch {
            print("Failed")
        }
    }
    
}

extension MutableCollection where Element: StringProtocol, Self: RandomAccessCollection {
    public mutating func localizedStandardSort(_ result: ComparisonResult) {
        sort { $0.localizedStandardCompare($1) == result }
    }
}
