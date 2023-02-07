//
//  initialSettingViewController.swift
//  Luft
//
//  Created by iMac Augusta on 2/7/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import Realm
import RealmSwift

class InitialSettingViewController:  LTViewController {
    
    @IBOutlet weak var tblSetting: UITableView!
    @IBOutlet weak var headerView: AppHeaderView!
    @IBOutlet weak var lblHeader: LTHeaderTitleLabel!
    @IBOutlet weak var lblUAT: UILabel!
    @IBOutlet weak var btnSaveSetting: UIButton!
    @IBOutlet weak var btnBackSetting: UIButton!
    
    var isFromInitialAddDevice:Bool = false
    var luftSettingTabbar:Int = 0
    var arrSectionTilte: [String] = ["ACCOUNT","APP THEME"]
    var arrAccountSetting: [SettingData] = []
    var arrThemeSetting: [SettingData] = []
    
    //API'S data
    var tempMobileUserSetting: AppUserMobileDetails? = nil
    var selectedType:SelectedFieldType? = .SelectedNone
    var pollutantType:PollutantType? = .PollutantNone
    var isUpadteTempPassword:Bool = false
    
    //New API CALL
    var appUserSettingData: AppUser? = nil
    var saveMobileUserSetting: AppUserMobileDetails? = nil
    var arrMyDeviceList: [MyDeviceModel]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblSetting?.delegate = self
        self.tblSetting?.dataSource = self
        self.tblSetting.register(UINib(nibName: cellIdentity.settingCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.settingCellIdentifier)
        self.tblSetting.register(UINib(nibName: cellIdentity.settingHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.settingHeaderCellIdentifier)
        self.view?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.btnSaveSetting.addTarget(self, action: #selector(self.btnSaveSettingTapped(sender:)), for: .touchUpInside)
        self.btnBackSetting.addTarget(self, action: #selector(self.btnBackSettingTapped(sender:)), for: .touchUpInside)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromInitialAddDevice == true {
            self.btnSaveSetting.isHidden = true
            self.loadArrayData()
        }else {
            self.callUserMeApi()
        }
        self.uatLBLTheme(lbl: self.lblUAT)
        //UIApplication.shared.statusBarView?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.setLatestStatusBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarTextColor
    }
    
    @objc func btnSaveSettingTapped(sender: UIButton) {
        
        if self.isFromInitialAddDevice == false {
            if AppSession.shared.getShowAppleIsInfo() == 1{
                AppSession.shared.setShowAppleIsInfo(isAppleLogin:3)
                self.moveToInitialAccount()
            }else {
                if AppSession.shared.getMobileUserMeData()?.firstName?.count == 0 || AppSession.shared.getMobileUserMeData()?.firstName == nil {
                    Helper.shared.showSnackBarAlert(message: CONTENT_NAME, type: .Failure)
                }
                else if AppSession.shared.getMobileUserMeData()?.lastName?.count == 0 || AppSession.shared.getMobileUserMeData()?.lastName == nil {
                    Helper.shared.showSnackBarAlert(message: CONTENT_NAME, type: .Failure)
                }
                else if self.tempMobileUserSetting?.buildingtypeid == 999 {
                    Helper.shared.showSnackBarAlert(message: INTIAL_CONTENT_BUILDING_TYPE, type: .Failure)
                }
                else if self.tempMobileUserSetting?.mitigationsystemtypeid == 999 {
                    Helper.shared.showSnackBarAlert(message: INTIAL_CONTENT_MITIGATION_SYSTEM, type: .Failure)
                }
                else {
                    self.moveToInitialAccount()
                }
            }
            
        }else {
            
        }
    }

    
    @objc func btnBackSettingTapped(sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    
    func uatLBLTheme(lbl:UILabel)  {
        lbl.textColor = ThemeManager.currentTheme().titleTextColor
        lbl.font = UIFont.setAppFontBold(12)
        if AppSession.shared.getUserLiveState() == 2 {
            lbl.text = UAT_TEXT
        }else {
            lbl.text = ""
        }
        lbl.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    func loadArrayData() {
        self.arrAccountSetting.removeAll()
        self.arrThemeSetting.removeAll()
        self.hideActivityIndicator(self.view)
        if isFromInitialAddDevice == true {
            self.arrSectionTilte.removeAll()
            self.arrSectionTilte.append("GENERAL")
            self.arrAccountSetting.append(SettingData(title: "Units", subTitle: "", imageType: "Disclosure"))
            self.arrAccountSetting.append(SettingData(title: "Thresholds", subTitle: "", imageType: "Disclosure"))
            self.arrAccountSetting.append(SettingData(title: "Colors", subTitle: "", imageType: "Disclosure"))
            self.tblSetting?.reloadData()
            return
        }else {
            //Account
            self.arrAccountSetting.append(SettingData(title: "Name", subTitle: String(format: "%@ %@", AppSession.shared.getMobileUserMeData()?.firstName ?? "",AppSession.shared.getMobileUserMeData()?.lastName ?? ""), imageType: "Disclosure"))
//            if AppSession.shared.getMobileUserMeData()?.buildingtypeid == nil || AppSession.shared.getMobileUserMeData()?.buildingtypeid == -1{
//                self.arrAccountSetting.append(SettingData(title: "Building Type", subTitle: "Select", imageType: "Disclosure"))
//                self.tempMobileUserSetting?.buildingtypeid = 999
//            }else {
//                self.arrAccountSetting.append(SettingData(title: "Building Type", subTitle: self.readBuildingTypeData(idBuildType: AppSession.shared.getMobileUserMeData()?.buildingtypeid ?? 0), imageType: "Disclosure"))
//            }
//            if AppSession.shared.getMobileUserMeData()?.mitigationsystemtypeid == nil || AppSession.shared.getMobileUserMeData()?.mitigationsystemtypeid == -1{
//                self.arrAccountSetting.append(SettingData(title: "Mitigation System", subTitle: "Select", imageType: "Disclosure"))
//                self.tempMobileUserSetting?.mitigationsystemtypeid = 999
//            }else {
//                self.arrAccountSetting.append(SettingData(title: "Mitigation System", subTitle: self.readMitigationTypeData(idBuildType: AppSession.shared.getMobileUserMeData()?.mitigationsystemtypeid ?? 0), imageType: "Disclosure"))
//            }
            //App Layout
            self.arrThemeSetting.append(SettingData(title: "Light Mode", subTitle: "true", imageType: "Disclosure"))
            self.arrThemeSetting.append(SettingData(title: "Dark Mode", subTitle: "", imageType: "Disclosure"))
            if AppSession.shared.getMobileUserMeData()?.appTheme == 2{
                self.arrThemeSetting[0].subTitle = "false"
                self.arrThemeSetting[1].subTitle = "true"
                AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
            }else {
                self.arrThemeSetting[0].subTitle = "true"
                self.arrThemeSetting[1].subTitle = "false"
                AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
            }
        }
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        self.applyViewTheme()
    }
    
    func applyViewTheme()  {
        self.headerView.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.lblHeader.textColor = ThemeManager.currentTheme().headerTitleTextColor
        //UIApplication.shared.statusBarView?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.setLatestStatusBar()
        self.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.barTintColor = ThemeManager.currentTheme().viewBackgroundColor
        let tabHome = self.tabBarController?.tabBar.items![0]
        tabHome?.image = ThemeManager.currentTheme().luftDashBoardIconImage.withRenderingMode(.alwaysOriginal)
        let tabFoll = self.tabBarController?.tabBar.items![1]
        tabFoll?.image = ThemeManager.currentTheme().luftDashBoardChartIconImage.withRenderingMode(.alwaysOriginal)
        let tabMsg = self.tabBarController?.tabBar.items![2]
        tabMsg?.image = ThemeManager.currentTheme().luftDashBoardSettingIconImage.withRenderingMode(.alwaysOriginal)
        self.tabBarController?.tabBar.isHidden = true
        self.view.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.tblSetting.backgroundColor = UIColor.clear
        self.tabBarController?.tabBar.layer.addBorder(edge: .top, color: ThemeManager.currentTheme().ltCellHeaderTabbarBorderColor, thickness: 1.0)
        
        self.tblSetting?.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.isUpadteTempPassword = false
    }
    
}
// MARK: - Save API Data's
extension InitialSettingViewController: LTDropDownMitigationBuildingType{
    
    func selectedHomeBuildType(id:Int,idvalue:String){
        if self.selectedType == .SelectedBuildingType {
            self.arrAccountSetting[1].subTitle =  self.readBuildingTypeData(idBuildType: id)
            self.tempMobileUserSetting?.buildingtypeid = id
        }
        if self.selectedType == .SelectedMitigation {
            self.arrAccountSetting[2].subTitle =  self.readMitigationTypeData(idBuildType: id)
            self.tempMobileUserSetting?.mitigationsystemtypeid = id
        }
        self.callSaveUserMeApi()
    }
    
    func callSaveUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            
            if self.tempMobileUserSetting?.mitigationsystemtypeid == 999{
                self.tempMobileUserSetting?.mitigationsystemtypeid = nil
            }
            if self.tempMobileUserSetting?.buildingtypeid == 999{
                self.tempMobileUserSetting?.buildingtypeid = nil
            }
            self.showActivityIndicator(self.view)
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            AppUserAPI.apiAppUserUpdateMobileUserPost(user: self.tempMobileUserSetting, completion: { (error) in
                self.hideActivityIndicator(self.view)
                if error == nil {
                    let saveMobileUserSetting = AppUserMobileDetails.init(firstName: AppSession.shared.getMobileUserMeData()?.firstName ?? "", lastName: AppSession.shared.getMobileUserMeData()?.lastName ?? "", buildingtypeid: self.tempMobileUserSetting?.buildingtypeid, mitigationsystemtypeid: self.tempMobileUserSetting?.mitigationsystemtypeid, enableNotifications: self.tempMobileUserSetting?.enableNotifications, isTextNotificationEnabled: self.tempMobileUserSetting?.isTextNotificationEnabled, mobileNo: self.tempMobileUserSetting?.mobileNo, isEmailNotificationEnabled: self.tempMobileUserSetting?.isEmailNotificationEnabled, notificationEmail: self.tempMobileUserSetting?.notificationEmail, isMobileNotificationFrequencyEnabled: self.tempMobileUserSetting?.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: self.tempMobileUserSetting?.isSummaryEmailEnabled, isDailySummaryEmailEnabled: self.tempMobileUserSetting?.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: self.tempMobileUserSetting?.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: self.tempMobileUserSetting?.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: self.tempMobileUserSetting?.temperatureUnitTypeId, pressureUnitTypeId: self.tempMobileUserSetting?.pressureUnitTypeId, radonUnitTypeId: self.tempMobileUserSetting?.radonUnitTypeId, appLayout: self.tempMobileUserSetting?.appLayout, appTheme: self.tempMobileUserSetting?.appTheme, outageNotificationsDuration: self.tempMobileUserSetting?.outageNotificationsDuration, notificationFrequency: self.tempMobileUserSetting?.notificationFrequency, isMobileOutageNotificationsEnabled: self.tempMobileUserSetting?.isMobileOutageNotificationsEnabled)
                    AppSession.shared.setMobileUserMeData(mobileSettingData: saveMobileUserSetting)
                    AppSession.shared.setUserSelectedTheme(themeType: self.tempMobileUserSetting?.appTheme ?? 0)
                    AppSession.shared.setUserSelectedLayout(layOut: self.tempMobileUserSetting?.appLayout ?? 0)
                    
                    self.callUserMeApi()
                    Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
                }else {
                    self.loadArrayData()
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            })
        }else {
            self.loadArrayData()
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}

extension InitialSettingViewController  {
    
    func medataAPIData(meData: AppUserMobileDetails?) {
        
        if let meDatass = meData {
            self.tempMobileUserSetting = AppUserMobileDetails.init(firstName: meDatass.firstName, lastName: meDatass.lastName, buildingtypeid: meDatass.buildingtypeid, mitigationsystemtypeid: meDatass.mitigationsystemtypeid, enableNotifications: meDatass.enableNotifications, isTextNotificationEnabled: meDatass.isTextNotificationEnabled, mobileNo: meDatass.mobileNo, isEmailNotificationEnabled: meDatass.isEmailNotificationEnabled, notificationEmail: meDatass.notificationEmail, isMobileNotificationFrequencyEnabled: meDatass.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: meDatass.isSummaryEmailEnabled, isDailySummaryEmailEnabled: meDatass.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: meDatass.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: meDatass.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: meDatass.temperatureUnitTypeId, pressureUnitTypeId: meDatass.pressureUnitTypeId, radonUnitTypeId: meDatass.radonUnitTypeId, appLayout: meDatass.appLayout, appTheme: meDatass.appTheme, outageNotificationsDuration: meDatass.outageNotificationsDuration, notificationFrequency: meDatass.notificationFrequency, isMobileOutageNotificationsEnabled: meDatass.isMobileOutageNotificationsEnabled)
            
            AppSession.shared.setUserSelectedTheme(themeType: meDatass.appTheme ?? 0)
            AppSession.shared.setUserSelectedLayout(layOut: meDatass.appLayout ?? 0)
        }
        self.loadArrayData()
    }
}

// MARK: - Table View Data's
extension InitialSettingViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrSectionTilte.count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.settingHeaderCellIdentifier) as! LTSettingHeaderViewTableViewCell
        if isFromInitialAddDevice == true {
            switch section {
            case 0:
                cell.lblHeaderTilte.text = self.arrSectionTilte[section]
                cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
            default:
                cell.lblHeaderTilte.text = ""
                cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().clearColor
            }
        }else {
            switch section {
            case 0:
                cell.lblHeaderTilte.text = self.arrSectionTilte[section]
                cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
            case 1:
                cell.lblHeaderTilte.text = self.arrSectionTilte[section]
                cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
            default:
                cell.lblHeaderTilte.text = ""
                cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().clearColor
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if isFromInitialAddDevice == true {
            switch section {
            case 0:
                return self.arrAccountSetting.count
            default:
                return 0
            }
        }else {
            switch section {
            case 0:
                return self.arrAccountSetting.count
            case 1:
                return self.arrThemeSetting.count
            default:
                return 0
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFromInitialAddDevice == true {
            switch indexPath.section {
            case 0:
                let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
                return self.accountCellSetting(cellValue: cell, index: indexPath)
            default:
                return UITableViewCell()
            }
        }else {
            switch indexPath.section {
            case 0:
                let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
                return self.accountCellSetting(cellValue: cell, index: indexPath)
            case 1:
                let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
                return self.themeCellSetting(cellValue: cell, index: indexPath)
            default:
                return UITableViewCell()
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  isFromInitialAddDevice == true{
            switch indexPath.section {
            case 0:
                if indexPath.row == 0{
                    self.moveToUnits()
                }
                else if indexPath.row == 1{
                    self.moveToThersHolds()
                }
                else if indexPath.row == 2{
                    self.moveToColors()
                }
                
            default:
                print(indexPath.section)
            }
        }else {
            switch indexPath.section {
            case 0:
                if indexPath.row == 0 {
                    self.moveToChangeNameView()
                }
                else if indexPath.row == 1{
                    self.showDropDownView(appDropDownType: AppDropDownType.DropDownHomeBuildingType)
                    self.selectedType = .SelectedBuildingType
                }
                else if indexPath.row == 2{
                    self.showDropDownView(appDropDownType: AppDropDownType.DropDownMitigationType)
                    self.selectedType = .SelectedMitigation
                }
            case 1:
                if indexPath.row == 0 {
                    self.tempMobileUserSetting?.appTheme = 1
                    AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
                }else {
                    self.tempMobileUserSetting?.appTheme = 2
                    AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
                }
                self.callSaveUserMeApi()
                self.tblSetting?.scrollToRow(at: indexPath, at: .none, animated: false)
            default:
                print(indexPath.section)
            }
        }
    }
}

extension InitialSettingViewController {
    
    func accountCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        cellValue.lblTitleCell.text = self.arrAccountSetting[index.row].title
        cellValue.lblSubTitleCell.text = self.arrAccountSetting[index.row].subTitle
        
        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleView.isHidden = false
        cellValue.lblTitleCell.textAlignment = .left
        cellValue.lblSubTitleCell.textAlignment = .right
        cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellDisclousreIconImage
        cellValue.selectionStyle = .none
        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        return cellValue
    }
    
    func themeCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        
        cellValue.lblTitleCell.text = self.arrThemeSetting[index.row].title
        cellValue.lblSubTitleCell.text = self.arrThemeSetting[index.row].subTitle
        
        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleView.isHidden = true
        cellValue.lblTitleCell.textAlignment = .left
        cellValue.lblSubTitleCell.textAlignment = .right
        if self.arrThemeSetting[index.row].subTitle == "true" {
            cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }
        cellValue.selectionStyle = .none
        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        return cellValue
    }
}

extension InitialSettingViewController {
    
    func moveToInitialAccount() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerMenu = mainStoryboard.instantiateViewController(withIdentifier: "InitialAccountViewController") as! InitialAccountViewController
        viewControllerMenu.tempMobileUserSetting = self.tempMobileUserSetting
        self.tabBarController?.tabBar.isHidden = true
        viewControllerMenu.isFromInitialAddDevice = true
        self.navigationController?.pushViewController(viewControllerMenu, animated: false)
    }
   
    func moveToUnits() {
        let unitsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UnitsViewController") as! UnitsViewController
        unitsView.isFromInitialAddDevice = true
        self.navigationController?.pushViewController(unitsView, animated: true)
    }
    func moveToThersHolds() {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThersholdsViewController") as! ThersholdsViewController
        self.tabBarController?.tabBar.isHidden = true
        mainTabbar.isFromInitialAddDevice = true
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    func moveToColors() {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorsViewController") as! ColorsViewController
        self.tabBarController?.tabBar.isHidden = true
        mainTabbar.isFromInitialAddDevice = true
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    func showDropDownView(appDropDownType:AppDropDownType) {
        let dropDownVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LTDropDownViewController") as! LTDropDownViewController
        dropDownVC.dropDownType = appDropDownType
        dropDownVC.dropDownBuildingMititgationDelegate = self
        dropDownVC.modalPresentationStyle = .fullScreen
        self.present(dropDownVC, animated: false, completion: nil)
    }
}

extension InitialSettingViewController {
    
    func moveToChangeNameView() {
        let changeNameView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangeNameViewController") as! ChangeNameViewController
        changeNameView.changeNameMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.navigationController?.pushViewController(changeNameView, animated: true)
    }
    
    func callUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            AppUserAPI.apiAppUserMeGet { (response, error) in
                if error == nil {
                    if let responseValue = response {
                        self.appUserSettingData = response
                        self.saveMobileUserSetting = AppUserMobileDetails.init(firstName: self.appUserSettingData?.firstName, lastName: self.appUserSettingData?.lastName, buildingtypeid: self.appUserSettingData?.buildingtypeid, mitigationsystemtypeid: self.appUserSettingData?.mitigationsystemtypeid, enableNotifications: self.appUserSettingData?.enableNotifications, isTextNotificationEnabled: self.appUserSettingData?.isTextNotificationEnabled, mobileNo: self.appUserSettingData?.mobileNo, isEmailNotificationEnabled: self.appUserSettingData?.isEmailNotificationEnabled, notificationEmail: self.appUserSettingData?.notificationEmail, isMobileNotificationFrequencyEnabled: self.appUserSettingData?.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: self.appUserSettingData?.isSummaryEmailEnabled, isDailySummaryEmailEnabled: self.appUserSettingData?.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: self.appUserSettingData?.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: self.appUserSettingData?.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: self.appUserSettingData?.temperatureUnitTypeId, pressureUnitTypeId: self.appUserSettingData?.pressureUnitTypeId, radonUnitTypeId: self.appUserSettingData?.radonUnitTypeId, appLayout: self.appUserSettingData?.appLayout, appTheme: self.appUserSettingData?.appTheme, outageNotificationsDuration: self.appUserSettingData?.outageNotificationsDuration, notificationFrequency: self.appUserSettingData?.notificationFrequency, isMobileOutageNotificationsEnabled:self.appUserSettingData?.isMobileOutageNotificationsEnabled)
                        //Save User default data's
                        AppSession.shared.setMEAPIData(userSettingData: responseValue)
                        AppSession.shared.setMobileUserMeData(mobileSettingData: self.saveMobileUserSetting!)
                        self.medataAPIData(meData: self.saveMobileUserSetting!)
                        self.loadArrayData()
                    }
                }else {
                    self.hideActivityIndicator(self.view)
                    self.medataAPIData(meData: self.saveMobileUserSetting ?? nil)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    self.loadArrayData()
                }
            }
        }
        else{
            self.hideActivityIndicator(self.view)
            self.medataAPIData(meData: self.saveMobileUserSetting ?? nil)
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}


