//
//  SettingViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import Realm
import RealmSwift

class SettingViewController: LTViewController {
    
    @IBOutlet weak var tblSetting: UITableView!
    @IBOutlet weak var headerView: AppHeaderView!
    @IBOutlet weak var lblHeader: LTHeaderTitleLabel!
    @IBOutlet weak var lblUAT: UILabel!
    var luftSettingTabbar:Int = 0
    
    var arrSectionTilte: [String] = ["ACCOUNT","GENERAL","APP LAYOUT","APP THEME","ABOUT","LEGAL","","",""]
    var arrAccountSetting: [SettingData] = []
    var arrGeneralSetting: [SettingData] = []
    var arrLegalSetting: [SettingData] = []
    var arrLayoutSetting: [SettingData] = []
    var arrThemeSetting: [SettingData] = []
    var arrAboutSetting: [SettingData] = []
    var arrLogoutSetting: [SettingData] = []
    var arrDeleteSetting: [SettingData] = []
    
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
        self.luftSettingTabbar = 100
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadArrayData()
        if self.luftSettingTabbar == 100 {
            self.callMEIDATA()
            self.luftSettingTabbar = 0
        }
        DispatchQueue.main.async(execute: {
            self.tabBarController?.tabBar.isHidden = false
        })
        self.uatLBLTheme(lbl: self.lblUAT)
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
        // NotificationCenter.default.removeObserver(self, name: .postNotifiDeviceUpadte, object: nil)
    }
    
    func callMEIDATA()  {
        // self.showActivityIndicator(self.view)
        //APIManager.shared.meDelegate = self
        //APIManager.shared.callUserMeApi()
        self.callUserMeApi()
    }
    
    func loadArrayData() {
        self.arrAccountSetting.removeAll()
        self.arrGeneralSetting.removeAll()
        self.arrLegalSetting.removeAll()
        self.arrLayoutSetting.removeAll()
        self.arrThemeSetting.removeAll()
        self.arrAboutSetting.removeAll()
        self.arrLogoutSetting.removeAll()
        self.arrDeleteSetting.removeAll()
        //Account
        self.arrAccountSetting.append(SettingData(title: "Name", subTitle: String(format: "%@ %@", AppSession.shared.getMobileUserMeData()?.firstName ?? "",AppSession.shared.getMobileUserMeData()?.lastName ?? ""), imageType: "Disclosure"))
        self.arrAccountSetting.append(SettingData(title: "Email Address", subTitle:  String(format: "%@", AppSession.shared.getMEAPIData()?.email ?? ""), imageType: "Disclosure"))
        self.arrAccountSetting.append(SettingData(title: "Password", subTitle: "", imageType: "Disclosure"))
        if AppSession.shared.getMobileUserMeData()?.buildingtypeid == nil || AppSession.shared.getMobileUserMeData()?.buildingtypeid == -1{
            self.arrAccountSetting.append(SettingData(title: "Building Type", subTitle: "Select", imageType: "Disclosure"))
            self.tempMobileUserSetting?.buildingtypeid = 999
        }else {
            self.arrAccountSetting.append(SettingData(title: "Building Type", subTitle: self.readBuildingTypeData(idBuildType: AppSession.shared.getMobileUserMeData()?.buildingtypeid ?? 0), imageType: "Disclosure"))
        }
        if AppSession.shared.getMobileUserMeData()?.mitigationsystemtypeid == nil || AppSession.shared.getMobileUserMeData()?.mitigationsystemtypeid == -1{
            self.arrAccountSetting.append(SettingData(title: "Mitigation System", subTitle: "Select", imageType: "Disclosure"))
            self.tempMobileUserSetting?.mitigationsystemtypeid = 999
        }else if  AppSession.shared.getMobileUserMeData()?.mitigationsystemtypeid == 0{
            self.arrAccountSetting.append(SettingData(title: "Mitigation System", subTitle: "None", imageType: "Disclosure"))
            self.tempMobileUserSetting?.mitigationsystemtypeid = 0
        }else {
            self.arrAccountSetting.append(SettingData(title: "Mitigation System", subTitle: self.readMitigationTypeData(idBuildType: AppSession.shared.getMobileUserMeData()?.mitigationsystemtypeid ?? 0), imageType: "Disclosure"))
        }
        //General
        self.arrGeneralSetting.append(SettingData(title: "Notifications", subTitle: "", imageType: "Disclosure"))
        self.arrGeneralSetting.append(SettingData(title: "Check for Firmware Update", subTitle: "", imageType: "Disclosure"))
        self.arrGeneralSetting.append(SettingData(title: "Units", subTitle: "", imageType: "Disclosure"))
        self.arrGeneralSetting.append(SettingData(title: "Thresholds", subTitle: "", imageType: "Disclosure"))
        self.arrGeneralSetting.append(SettingData(title: "Colors", subTitle: "", imageType: "Disclosure"))
        //Legal
        self.arrLegalSetting.append(SettingData(title: "Privacy Policy", subTitle: "", imageType: "Disclosure"))
        self.arrLegalSetting.append(SettingData(title: "Terms & Conditions", subTitle: "", imageType: "Disclosure"))
        self.arrLegalSetting.append(SettingData(title: "Product Warranty", subTitle: "", imageType: "Disclosure"))
        //self.arrLegalSetting.append(SettingData(title: "Service Warranty ", subTitle: "", imageType: "Disclosure"))
        //App Layout
        self.arrLayoutSetting.append(SettingData(title: "Tile View", subTitle: "true", imageType: "Disclosure"))
        self.arrLayoutSetting.append(SettingData(title: "List View", subTitle: "", imageType: "Disclosure"))
        //App Layout
        self.arrThemeSetting.append(SettingData(title: "Light Mode", subTitle: "true", imageType: "Disclosure"))
        self.arrThemeSetting.append(SettingData(title: "Dark Mode", subTitle: "", imageType: "Disclosure"))
        //About
        self.arrAboutSetting.append(SettingData(title: "Version", subTitle: "", imageType: "Disclosure"))
        //LogOut
        self.arrLogoutSetting.append(SettingData(title: "Log out", subTitle: "", imageType: "Disclosure"))
        //Delete Account
        self.arrDeleteSetting.append(SettingData(title: "Delete account", subTitle: "", imageType: "Disclosure"))
        
        if AppSession.shared.getUserLiveState() == 2 {
            self.arrDeleteSetting.append(SettingData(title: "Export logs", subTitle: "", imageType: "Disclosure"))
        }
        
        if AppSession.shared.getMobileUserMeData()?.appTheme == 2{
            self.arrThemeSetting[0].subTitle = "false"
            self.arrThemeSetting[1].subTitle = "true"
            AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
        }else {
            self.arrThemeSetting[0].subTitle = "true"
            self.arrThemeSetting[1].subTitle = "false"
            AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
        }
        if AppSession.shared.getMobileUserMeData()?.appLayout == 2{
            self.arrLayoutSetting[0].subTitle = "false"
            self.arrLayoutSetting[1].subTitle = "true"
        }else {
            self.arrLayoutSetting[0].subTitle = "true"
            self.arrLayoutSetting[1].subTitle = "false"
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
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            self.tabBarController?.tabBar.standardAppearance = appearance;
            self.tabBarController?.tabBar.scrollEdgeAppearance = self.tabBarController?.tabBar.standardAppearance
        } else {
            // or use some work around
        }
        
        let tabHome = self.tabBarController?.tabBar.items![0]
        tabHome?.image = ThemeManager.currentTheme().luftDashBoardIconImage.withRenderingMode(.alwaysOriginal)
        let tabFoll = self.tabBarController?.tabBar.items![1]
        tabFoll?.image = ThemeManager.currentTheme().luftDashBoardChartIconImage.withRenderingMode(.alwaysOriginal)
        let tabMsg = self.tabBarController?.tabBar.items![2]
        tabMsg?.image = ThemeManager.currentTheme().luftDashBoardSettingIconImage.withRenderingMode(.alwaysOriginal)
        self.tabBarController?.tabBar.isHidden = false
        self.view.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.tblSetting.backgroundColor = UIColor.clear
        self.tabBarController?.tabBar.layer.addBorder(edge: .top, color: ThemeManager.currentTheme().ltCellHeaderTabbarBorderColor, thickness: 1.0)
        
        self.tblSetting?.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.isUpadteTempPassword = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarTextColor
    }
    
    
}
// MARK: - Save API Data's
extension SettingViewController: LTDropDownMitigationBuildingType{
    
    func selectedHomeBuildType(id:Int,idvalue:String){
        if self.selectedType == .SelectedBuildingType {
            self.arrAccountSetting[3].subTitle =  self.readBuildingTypeData(idBuildType: id)
            self.tempMobileUserSetting?.buildingtypeid = id
        }
        if self.selectedType == .SelectedMitigation {
            self.arrAccountSetting[4].subTitle =  self.readMitigationTypeData(idBuildType: id)
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
                    let saveMobileUserSetting = AppUserMobileDetails.init(firstName: self.tempMobileUserSetting?.firstName, lastName: self.tempMobileUserSetting?.lastName, buildingtypeid: self.tempMobileUserSetting?.buildingtypeid, mitigationsystemtypeid: self.tempMobileUserSetting?.mitigationsystemtypeid, enableNotifications: self.tempMobileUserSetting?.enableNotifications, isTextNotificationEnabled: self.tempMobileUserSetting?.isTextNotificationEnabled, mobileNo: self.tempMobileUserSetting?.mobileNo, isEmailNotificationEnabled: self.tempMobileUserSetting?.isEmailNotificationEnabled, notificationEmail: self.tempMobileUserSetting?.notificationEmail, isMobileNotificationFrequencyEnabled: self.tempMobileUserSetting?.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: self.tempMobileUserSetting?.isSummaryEmailEnabled, isDailySummaryEmailEnabled: self.tempMobileUserSetting?.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: self.tempMobileUserSetting?.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: self.tempMobileUserSetting?.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: self.tempMobileUserSetting?.temperatureUnitTypeId, pressureUnitTypeId: self.tempMobileUserSetting?.pressureUnitTypeId, radonUnitTypeId: self.tempMobileUserSetting?.radonUnitTypeId, appLayout: self.tempMobileUserSetting?.appLayout, appTheme: self.tempMobileUserSetting?.appTheme, outageNotificationsDuration: self.tempMobileUserSetting?.outageNotificationsDuration, notificationFrequency: self.tempMobileUserSetting?.notificationFrequency, isMobileOutageNotificationsEnabled: self.tempMobileUserSetting?.isMobileOutageNotificationsEnabled)
                    
                    AppSession.shared.setMobileUserMeData(mobileSettingData: saveMobileUserSetting)
                    AppSession.shared.setUserSelectedTheme(themeType: self.tempMobileUserSetting?.appTheme ?? 0)
                    AppSession.shared.setUserSelectedLayout(layOut: self.tempMobileUserSetting?.appLayout ?? 0)
                    
                    self.loadArrayData()
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

extension SettingViewController  {
    
    func medataAPIData(meData: AppUserMobileDetails?) {
        
        if let meDatass = meData {
            self.tempMobileUserSetting = AppUserMobileDetails.init(firstName: meDatass.firstName, lastName: meDatass.lastName, buildingtypeid: meDatass.buildingtypeid, mitigationsystemtypeid: meDatass.mitigationsystemtypeid, enableNotifications: meDatass.enableNotifications, isTextNotificationEnabled: meDatass.isTextNotificationEnabled, mobileNo: meDatass.mobileNo, isEmailNotificationEnabled: meDatass.isEmailNotificationEnabled, notificationEmail: meDatass.notificationEmail, isMobileNotificationFrequencyEnabled: meDatass.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: meDatass.isSummaryEmailEnabled, isDailySummaryEmailEnabled: meDatass.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: meDatass.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: meDatass.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: meDatass.temperatureUnitTypeId, pressureUnitTypeId: meDatass.pressureUnitTypeId, radonUnitTypeId: meDatass.radonUnitTypeId, appLayout: meDatass.appLayout, appTheme: meDatass.appTheme, outageNotificationsDuration: meDatass.outageNotificationsDuration, notificationFrequency: meDatass.notificationFrequency, isMobileOutageNotificationsEnabled: meDatass.isMobileOutageNotificationsEnabled)
            
            AppSession.shared.setUserSelectedTheme(themeType: meDatass.appTheme ?? 0)
            AppSession.shared.setUserSelectedLayout(layOut: meDatass.appLayout ?? 0)
        }
        self.loadArrayData()
        self.callMyDeviceAPI()
    }
    
    func deviceDataAPIStatus(update:Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideActivityIndicator(self.view)
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func callMyDeviceAPI() {
        self.showActivityIndicator(self.view)
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.callDeviceDetailsTypeApi(isUpdateDummy: false)
    }
    
    
}

// MARK: - Table View Data's
extension SettingViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrSectionTilte.count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.settingHeaderCellIdentifier) as! LTSettingHeaderViewTableViewCell
        switch section {
        case 0:
            cell.lblHeaderTilte.text = self.arrSectionTilte[section]
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        case 1:
            cell.lblHeaderTilte.text = self.arrSectionTilte[section]
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        case 2:
            cell.lblHeaderTilte.text = self.arrSectionTilte[section]
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        case 3:
            cell.lblHeaderTilte.text = self.arrSectionTilte[section]
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        case 4:
            cell.lblHeaderTilte.text = self.arrSectionTilte[section]
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        case 5:
            cell.lblHeaderTilte.text = self.arrSectionTilte[section]
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        case 6:
            cell.lblHeaderTilte.text = self.arrSectionTilte[section]
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        case 7:
            cell.lblHeaderTilte.text = self.arrSectionTilte[section]
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        default:
            cell.lblHeaderTilte.text = ""
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().clearColor
        }
        cell.isUserInteractionEnabled = false
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
        
        switch section {
        case 0:
            return self.arrAccountSetting.count
        case 1:
            return self.arrGeneralSetting.count
        case 2:
            return self.arrLayoutSetting.count
        case 3:
            return self.arrThemeSetting.count
        case 4:
            return self.arrAboutSetting.count
        case 5:
            return self.arrLegalSetting.count
        case 6:
            return self.arrLogoutSetting.count
        case 7:
            return self.arrDeleteSetting.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            return self.accountCellSetting(cellValue: cell, index: indexPath)
        case 1:
            let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            return self.generalCellSetting(cellValue: cell, index: indexPath)
        case 2:
            let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            return self.layoutCellSetting(cellValue: cell, index: indexPath)
        case 3:
            let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            return self.themeCellSetting(cellValue: cell, index: indexPath)
        case 4:
            let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            return self.aboutCellSetting(cellValue: cell, index: indexPath)
        case 5:
            let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            return self.legalCellSetting(cellValue: cell, index: indexPath)
        case 6:
            let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            return self.logoutCellSetting(cellValue: cell, index: indexPath)
        case 7:
            let cell:LTSettingListTableViewCell = self.tblSetting.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
            return self.deleteCellSetting(cellValue: cell, index: indexPath)
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                self.moveToChangeNameView()
            }else if indexPath.row == 1{
                self.moveToEmailView()
            }
            else if indexPath.row == 2{
                self.moveToPassword()
            }
            else if indexPath.row == 3{
                self.showDropDownView(appDropDownType: AppDropDownType.DropDownHomeBuildingType)
                self.selectedType = .SelectedBuildingType
            }
            else if indexPath.row == 4{
                self.showDropDownView(appDropDownType: AppDropDownType.DropDownMitigationType)
                self.selectedType = .SelectedMitigation
            }
        case 1:
            if indexPath.row == 0 {
                self.moveToNotification()
            }else if indexPath.row == 1{
                self.moveToFirmWare()
            }
            else if indexPath.row == 2{
                self.moveToUnits()
            }
            else if indexPath.row == 3{
                self.moveToThersHolds()
            }
            else if indexPath.row == 4{
                self.moveToColors()
            }
        case 2:
            if indexPath.row == 0 {
                self.tempMobileUserSetting?.appLayout = 1
            }else {
                self.tempMobileUserSetting?.appLayout = 2
            }
            self.callSaveUserMeApi()
            self.tblSetting?.scrollToRow(at: indexPath, at: .none, animated: false)
        case 3:
            if indexPath.row == 0 {
                self.tempMobileUserSetting?.appTheme = 1
                AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
            }else {
                self.tempMobileUserSetting?.appTheme = 2
                AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
            }
            self.callSaveUserMeApi()
            self.tblSetting?.scrollToRow(at: indexPath, at: .none, animated: false)
        case 4:
            self.moveToVersion()
        case 5:
            if indexPath.row == 0 {
                self.moveToWebView(privacyTerms: true, type: 0)
            }else if indexPath.row == 1{
                self.moveToWebView(privacyTerms: false, type: 1)
            }
            else if indexPath.row == 2{
                self.moveToWebView(privacyTerms: false, type: 2)
            }
            else if indexPath.row == 3{
                self.moveToWebView(privacyTerms: false, type: 3)
            }
        case 6:
            self.moveToLogout()
        case 7:
            if indexPath.row == 0{
                self.moveToDeleteAccount()
            }
            else{
                textLog.sendEmail(viewController: self)
            }
            
        default:
            print(indexPath.section)
        }
    }
}

extension SettingViewController {
    
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
        
        //        if index.row == 3{
        //            cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
        //        }
        //        else if index.row == 4{
        //            cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
        //        }
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        
        if index.row == arrAccountSetting.count-1 {
            cellValue.lblCellBorder.isHidden = true
        } else {
            cellValue.lblCellBorder.isHidden = false
        }
        return cellValue
    }
    
    func generalCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        cellValue.lblTitleCell.text = self.arrGeneralSetting[index.row].title
        cellValue.lblSubTitleCell.text = self.arrGeneralSetting[index.row].subTitle
        
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
        if index.row == arrGeneralSetting.count-1 {
            cellValue.lblCellBorder.isHidden = true
        } else {
            cellValue.lblCellBorder.isHidden = false
        }
        return cellValue
    }
    
    func legalCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        cellValue.lblTitleCell.text = self.arrLegalSetting[index.row].title
        cellValue.lblSubTitleCell.text = self.arrLegalSetting[index.row].subTitle
        
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
        if index.row == arrLegalSetting.count-1 {
            cellValue.lblCellBorder.isHidden = true
        } else {
            cellValue.lblCellBorder.isHidden = false
        }
        return cellValue
    }
    
    func layoutCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        cellValue.lblTitleCell.text = self.arrLayoutSetting[index.row].title
        cellValue.lblSubTitleCell.text = self.arrLayoutSetting[index.row].subTitle
        
        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleView.isHidden = true
        cellValue.lblTitleCell.textAlignment = .left
        cellValue.lblSubTitleCell.textAlignment = .right
        cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        cellValue.selectionStyle = .none
        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
        if self.arrLayoutSetting[index.row].subTitle == "true" {
            cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
            cellValue.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        if index.row == arrLayoutSetting.count-1 {
            cellValue.lblCellBorder.isHidden = true
        } else {
            cellValue.lblCellBorder.isHidden = false
        }
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
        if index.row == arrThemeSetting.count-1 {
            cellValue.lblCellBorder.isHidden = true
        } else {
            cellValue.lblCellBorder.isHidden = false
        }
        return cellValue
    }
    
    func aboutCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        cellValue.lblTitleCell.text = self.arrAboutSetting[index.row].title
        cellValue.lblSubTitleCell.text = self.arrAboutSetting[index.row].subTitle
        
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
        if index.row == arrAboutSetting.count-1 {
            cellValue.lblCellBorder.isHidden = true
        } else {
            cellValue.lblCellBorder.isHidden = false
        }
        return cellValue
    }
    
    func logoutCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        cellValue.lblTitleCell.text = self.arrLogoutSetting[index.row].title
        cellValue.lblSubTitleCell.text = self.arrLogoutSetting[index.row].subTitle
        
        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellRedTitleColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellRedTitleColor
        
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleView.isHidden = true
        cellValue.lblTitleCell.textAlignment = .center
        cellValue.lblSubTitleCell.textAlignment = .right
        cellValue.imgViewDisclosureCell.image = nil
        cellValue.selectionStyle = .none
        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        if index.row == arrLogoutSetting.count-1 {
            cellValue.lblCellBorder.isHidden = true
        } else {
            cellValue.lblCellBorder.isHidden = false
        }
        return cellValue
    }
    
    func deleteCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        cellValue.lblTitleCell.text = self.arrDeleteSetting[index.row].title
        cellValue.lblSubTitleCell.text = self.arrDeleteSetting[index.row].subTitle
        
        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellRedTitleColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellRedTitleColor
        
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleView.isHidden = true
        cellValue.lblTitleCell.textAlignment = .center
        cellValue.lblSubTitleCell.textAlignment = .right
        cellValue.imgViewDisclosureCell.image = nil
        cellValue.selectionStyle = .none
        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        if index.row == arrDeleteSetting.count-1 {
            cellValue.lblCellBorder.isHidden = true
        } else {
            cellValue.lblCellBorder.isHidden = false
        }
        return cellValue
    }
    
}
extension SettingViewController:LTDismissDelegate,LTDismissVerisonDelegate {
    
    func moveLoginView(isUpdate: Bool) {
        self.isUpadteTempPassword = true
        self.removeDeviceData()
        self.dismiss(animated: false, completion: nil)
    }
    
    func moveLoginViewVerison(isUpdate: Bool) {
        self.removeDeviceData()
        self.dismiss(animated: false, completion: nil)
        isFromVersion = true
    }
    
    func moveToChangeNameView() {
        let changeNameView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangeNameViewController") as! ChangeNameViewController
        changeNameView.changeNameMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(changeNameView, animated: true)
    }
    func moveToEmailView() {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangeEmailViewController") as! ChangeEmailViewController
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    func moveToResetView() {
        let resetView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        resetView.isFromSetting = true
        resetView.dismissDelegate = self
        resetView.userEmailID = AppSession.shared.appUserSettingData?.email ?? ""
        self.tabBarController?.tabBar.isHidden = true
        isShowBackBtnSignin = false
        self.luftSettingTabbar = 100
        self.navigationController?.pushViewController(resetView, animated: true)
    }
    
    func tempAPINEWGOODPassword (){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            MobileApiAPI.apiMobileApiSendTemporaryPasswordGet(email: AppSession.shared.appUserSettingData?.email ?? "", completion: { (response, error) in
                self.hideActivityIndicator(self.view)
                if error == nil && (response?.success ?? false) == true {
                    self.moveToResetPasswordAlert()
                }else {
                    Helper().showSnackBarAlert(message: response?.message ?? "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            })
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    func moveToNotification() {
        let notificationView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        self.tabBarController?.tabBar.isHidden = true
        notificationView.notificationMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.navigationController?.pushViewController(notificationView, animated: true)
    }
    func moveToUnits() {
        let unitsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UnitsViewController") as! UnitsViewController
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(unitsView, animated: true)
    }
    func moveToThersHolds() {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThersholdsViewController") as! ThersholdsViewController
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(mainTabbar, animated: true)
        
    }
    func moveToColors() {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorsViewController") as! ColorsViewController
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    func showDropDownView(appDropDownType:AppDropDownType) {
        let dropDownVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LTDropDownViewController") as! LTDropDownViewController
        dropDownVC.dropDownType = appDropDownType
        dropDownVC.dropDownBuildingMititgationDelegate = self
        dropDownVC.modalPresentationStyle = .overFullScreen
        self.present(dropDownVC, animated: false, completion: nil)
    }
    
    
    
    func moveToPassword() {
        
        if self.appUserSettingData?.oauthProvider != nil && self.appUserSettingData?.oauthProvider ?? "" != ""{
            let titleString = NSAttributedString(string: "Information", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            
            let nameString = (self.appUserSettingData?.oauthProvider ?? "").capitalizingFirstLetter()
            
            let messageString = NSAttributedString(string: "Your Password is managed by your \(nameString) Account", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.setValue(titleString, forKey: "attributedTitle")
            alert.setValue(messageString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Close", style: .default, handler: { action in
            })
            alert.addAction(ok)
            alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }
        else{
            let titleString = NSAttributedString(string: "Reset Password", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let messageString = NSAttributedString(string: "We will send you a link to reset your password", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.setValue(titleString, forKey: "attributedTitle")
            alert.setValue(messageString, forKey: "attributedMessage")
            let ok = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            })
            alert.addAction(ok)
            let cancel = UIAlertAction(title: "Send", style: .default, handler: { action in
                self.tempAPINEWGOODPassword()
            })
            alert.addAction(cancel)
            alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
            })
        }
        
        
    }
    
    func removeDeviceData()  {
        AppSession.shared.setIsUserLogin(userLoginStatus: false)
        AppSession.shared.setAccessToken("")
        AppSession.shared.setCurrentDeviceToken("")
        AppSession.shared.removeAllInstance()
        RealmDataManager.shared.deleteDeviceRelamDataBase()
        RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
        RealmDataManager.shared.deleteRelamSettingColorDataBase()
    }
    
    func moveToLogout() {
        
        let titleString = NSAttributedString(string: "Log out", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: "Are you sure you want to logout your account?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.logoutAPI()
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.present(alert, animated: true)
    }
    
    func moveToDeleteAccount() {
        
        let titleString = NSAttributedString(string: "Delete Account", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: "Are you sure you want to delete your account?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.showActivityIndicator(self.view)
            MobileApiAPI.apiMobileApiDeleteAccountDelete(completion: { (response, error) in
                self.hideActivityIndicator(self.view)
                if response?.success == true {
                    self.removeDeviceData()
                    self.dismiss(animated: true, completion: nil)
                }else {
                    Helper().showSnackBarAlert(message: response?.message ?? "", type: .Failure)
                }
            })
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
    
    func moveToFirmWare() {
        //        let titleString = NSAttributedString(string: "Update", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        //        let messageString = NSAttributedString(string: "No new firmware has been found,please check again later.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        //        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        //        alert.setValue(titleString, forKey: "attributedTitle")
        //        alert.setValue(messageString, forKey: "attributedMessage")
        //        let cancel = UIAlertAction(title: "Ok", style: .default, handler: { action in
        //
        //        })
        //        alert.addAction(cancel)
        //        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        //        DispatchQueue.main.async(execute: {
        //            self.present(alert, animated: true)
        //        })
        self.moveToFirmWareVW()
    }
    
    func moveToFirmWareVW()  {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirmwareUpdateViewController") as! FirmwareUpdateViewController
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    func moveToResetPasswordAlert() {
        let titleString = NSAttributedString(string: "Alert", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: "We have sent you the temporary password to your mail.", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.moveToResetView()
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func moveToWebView(privacyTerms:Bool,type:Int) {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController") as! WebDataViewController
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webdataView, animated: true)
        if type == 0 {
            webdataView.strTitle = PRIVACY_POLICY_TITLE
        }
        else if type == 1 {
            webdataView.strTitle = TERMS_AND_CONDITIONS_TITLE
        }
        else if type == 2 {
            webdataView.strTitle = PRODUCT_WARRANTY
        }
        else if type == 3 {
            webdataView.strTitle = SERVICE_WARRANTY
        }
    }
    
    func moveToVersion() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LTVersionViewController") as! LTVersionViewController
        webdataView.ltdismissVerisonDelegate = self
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(webdataView, animated: true)
    }
}

extension SettingViewController {
    
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
                        self.appUserSettingData = response
                        self.saveMobileUserSetting = AppUserMobileDetails.init(firstName: self.appUserSettingData?.firstName, lastName: self.appUserSettingData?.lastName, buildingtypeid: self.appUserSettingData?.buildingtypeid, mitigationsystemtypeid: self.appUserSettingData?.mitigationsystemtypeid, enableNotifications: self.appUserSettingData?.enableNotifications, isTextNotificationEnabled: self.appUserSettingData?.isTextNotificationEnabled, mobileNo: self.appUserSettingData?.mobileNo, isEmailNotificationEnabled: self.appUserSettingData?.isEmailNotificationEnabled, notificationEmail: self.appUserSettingData?.notificationEmail, isMobileNotificationFrequencyEnabled: self.appUserSettingData?.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: self.appUserSettingData?.isSummaryEmailEnabled, isDailySummaryEmailEnabled: self.appUserSettingData?.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: self.appUserSettingData?.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: self.appUserSettingData?.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: self.appUserSettingData?.temperatureUnitTypeId, pressureUnitTypeId: self.appUserSettingData?.pressureUnitTypeId, radonUnitTypeId: self.appUserSettingData?.radonUnitTypeId, appLayout: self.appUserSettingData?.appLayout, appTheme: self.appUserSettingData?.appTheme, outageNotificationsDuration: self.appUserSettingData?.outageNotificationsDuration, notificationFrequency: self.appUserSettingData?.notificationFrequency, isMobileOutageNotificationsEnabled: self.appUserSettingData?.isMobileOutageNotificationsEnabled)
                       
                        //Save User default data's
                        AppSession.shared.setMEAPIData(userSettingData: responseValue)
                        AppSession.shared.setMobileUserMeData(mobileSettingData: self.saveMobileUserSetting!)
                        self.medataAPIData(meData: self.saveMobileUserSetting!)
                    }
                }else {
                    self.hideActivityIndicator(self.view)
                    self.medataAPIData(meData: self.saveMobileUserSetting ?? nil)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
        else{
            self.hideActivityIndicator(self.view)
            self.medataAPIData(meData: self.saveMobileUserSetting ?? nil)
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    func callDeviceDetailsTypeApi(isUpdateDummy:Bool){
        if Reachability.isConnectedToNetwork() == true {
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            AppUserAPI.apiAppUserGetMyDevicesGet { (response, error) in
                if error == nil {
                    if let responseValue = response,responseValue.count > 0 {
                        self.arrMyDeviceList?.removeAll()
                        self.arrMyDeviceList = responseValue
                        RealmDataManager.shared.deleteDeviceRelamDataBase()
                        RealmDataManager.shared.deleteRelamSettingColorDataBase()
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
                        RealmDataManager.shared.deleteDeviceRelamDataBase()
                        RealmDataManager.shared.deleteRelamSettingColorDataBase()
                        RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
                    }
                    self.deviceDataAPIStatus(update: true)
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    self.deviceDataAPIStatus(update: false)
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
        else{
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            self.deviceDataAPIStatus(update: false)
        }
    }
    
    func logoutAPI()  {
//        self.showActivityIndicator(self.view)
//        let logoutModel = LoginUserViewModel.init(email: "", password: "", deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", ipAddress: "")
//        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
//        AdminAPI.apiAdminLogoutPost(model: logoutModel, completion: { (respones, error) in
//            self.hideActivityIndicator(self.view)
//            if respones == 1 {
//                self.removeDeviceData()
//                isFromVersion = true
//                self.dismiss(animated: true, completion: nil)
//            }else {
//                Helper.shared.showSnackBarAlert(message: "Log out Failure", type: .Failure)
//            }
//        })
        self.logoutNewAPI()
    }
    func logoutNewAPI()  {
        self.showActivityIndicator(self.view)
        let logoutModel = LoginUserViewModel.init(email: "", password: "", deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", ipAddress: "", osVersion: UIDevice.current.systemVersion, osName: UIDevice.current.systemName, mobileDeviceModel: UIDevice.modelName, appversion: "", buildVersion: "")
        textLog.write("Input Params")
        textLog.write(String(format:"currentDeviceToken %@",currentDeviceToken))
        textLog.write(String(format:"currentDeviceId %@",currentDeviceId))
        textLog.write(String(format:"loginDevice 2"))
        textLog.write(String(format:"isWeb false"))
        textLog.write(String(format:"userAgentId 2"))
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        MobileApiAPI.apiMobileApiMobileLogoutPost(model: logoutModel) { (respones, error) in
            textLog.write("OutPut Params")
            textLog.write(String(format:"Log out success - %d",respones?.success ?? "no success"))
            textLog.write(String(format:"Log out data - %@",respones?.data ?? "no data"))
            textLog.write(String(format:"Log out message - %@",respones?.message ?? "no message"))
            textLog.write(String(format:"Log out errorCode -   %@",respones?.errorCode ?? "no errorCode"))
            self.hideActivityIndicator(self.view)
            if respones?.success == true {
                self.removeDeviceData()
                isFromVersion = true
                self.dismiss(animated: true, completion: nil)
            }else if respones?.success == false {
                Helper().showSnackBarAlert(message: respones?.message ?? "", type: .Failure)
            }else {
                Helper.shared.showSnackBarAlert(message: "Log out Failure", type: .Failure)
            }
        }
    }
}


extension AppUserMobileDetails{
    func copy(with zone: NSZone? = nil) -> Any {
        
        let copy = AppUserMobileDetails(firstName: firstName, lastName: lastName, buildingtypeid: buildingtypeid, mitigationsystemtypeid: mitigationsystemtypeid, enableNotifications: enableNotifications, isTextNotificationEnabled: isTextNotificationEnabled, mobileNo: mobileNo, isEmailNotificationEnabled: isEmailNotificationEnabled, notificationEmail: notificationEmail, isMobileNotificationFrequencyEnabled: isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: isSummaryEmailEnabled, isDailySummaryEmailEnabled: isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: isMonthlySummaryEmailEnabled, temperatureUnitTypeId: temperatureUnitTypeId, pressureUnitTypeId: pressureUnitTypeId, radonUnitTypeId: radonUnitTypeId, appLayout: appLayout, appTheme: appTheme, outageNotificationsDuration: outageNotificationsDuration, notificationFrequency: notificationFrequency, isMobileOutageNotificationsEnabled: isMobileOutageNotificationsEnabled)
        return copy
    }
}

