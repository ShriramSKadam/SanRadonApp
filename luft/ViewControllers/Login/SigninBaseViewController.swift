//
//  SigninBaseViewController.swift
//  luft
//
//  Created by Augusta on 09/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import FBSDKCoreKit
import FacebookCore
import GoogleSignIn
import SwiftyJSON
import CoreData
import Realm
import RealmSwift
import Alamofire
import AuthenticationServices

var isShowBackBtnSignin:Bool = false
var dataBasePathChange:Bool = false
var strFirmwareVesrion:String = ""
var isFromVersion:Bool = false // Version (UAT/LIVE) page when app got logout at that app need to redirect SigninBase page,So only we are using this variable

class SigninBaseViewController: LTViewController {
    
    @IBOutlet weak var btnLoginWithEmail: LTNormalButton!
    @IBOutlet weak var btnSignUpWithEMail: LTNormalButton!
    @IBOutlet weak var lblSignUpBorderLeft: LTBorderLabel!
    @IBOutlet weak var lblSignUpOR: LTORLabel!
    @IBOutlet weak var lblSignUpBorderRight: LTBorderLabel!
    @IBOutlet weak var btnLoginWithGoogle: LTGoogleImageButton!
    @IBOutlet weak var btnLoginWithFacebook: LTFacebookImageButton!
    //@IBOutlet weak var btnLoginWithApple: LTAppleImageButton!
    @IBOutlet weak var viewAlreadyHaveLogin: UIView!
    @IBOutlet weak var lblUAT: UILabel!
    @IBOutlet weak var btnUAT: UIButton!
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    var homeBuildingTypeData: [BuildingModelType?] = []
    var arrMitigationTypeData: [BuildingModelType?] = []
    
    var counter = 0
    var tapCount = 0
    var sType:String = ""
    var sToken:String = ""
    
    //API'S data
    var tempMobileUserSetting: AppUserMobileDetails? = nil
    var arrMYdeviceList: [RealmDeviceList] = []
    
    var strEmail: String! = ""
    var strAppleIdentifier: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadColorValue()
        //self.callBuildIngTypeApi()
        self.getFWVersionAPI()
        self.btnUAT.addTarget(self, action:#selector(self.btnTap(_sender:)), for: .touchUpInside)
    }
    
    func defaultsSets()  {
        if AppSession.shared.isKeyPresentInUserDefaults(key: "SortFilterTypeEnum") == false{
            AppSession.shared.setUserSortFilterType(sortfilterType:1)
        }
        AppSession.shared.setIsAddedNewDevice(isAddedDevice:false)
        AppSession.shared.setIsConnectedWifi(iswifi:false)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.defaultsSets()
        super.viewWillAppear(animated)
       
        self.showActivityIndicator(self.view)
        if  AppSession.shared.getIsInfo() == false {
            self.moveToInfo()
            return
        }
        self.applySignUpTheme()
        if isShowBackBtnSignin == true {
            let pushToVC: SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            AppSession.shared.setIsShowBack(isShow: false)
            self.navigationController?.pushViewController(pushToVC, animated: false)
        }
        self.viewAlreadyHaveLogin.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        if  AppSession.shared.getIsUserLogin() == true {
            self.viewAlreadyHaveLogin.isHidden = false
        }else {
            self.hideActivityIndicator(self.view)
            self.viewAlreadyHaveLogin.isHidden = true
        }
        self.switchAccount()
        self.setupProviderLoginView()
    }
    
    
    func moveToInfo()  {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerMenu = mainStoryboard.instantiateViewController(withIdentifier: "LTInfoViewController") as! LTInfoViewController
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(viewControllerMenu, animated: false)
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
    
    func configureMigration() {
        let currentSchemaVersion: UInt64 = 2
        var config = Realm.Configuration()
        
        config = Realm.Configuration(
            schemaVersion: currentSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    self.migrateFrom0To1(with: migration)
                    print("Newgood realm1")
                }
                if oldSchemaVersion < 2 {
                    self.migrateFrom1To2(with: migration)
                    print("Newgood realm2")
                }
                if oldSchemaVersion < 3 {
                    //migrateFrom2To3(with: migration)
                    print("Newgood realm3")
                }
        })
        if AppSession.shared.getUserLiveState() == 2 {
            config.fileURL = config.fileURL!.deletingLastPathComponent()
                .appendingPathComponent("UAT.realm")
        }else {
            config.fileURL = config.fileURL!.deletingLastPathComponent()
                .appendingPathComponent("LIVE.realm")
        }
        Realm.Configuration.defaultConfiguration = config
        
    }
    
    // MARK: - Migrations
    func migrateFrom0To1(with migration: Migration) {
        // Add an email property
        migration.enumerateObjects(ofType: RealmColorSetting.className()) { (_, newPerson) in
            newPerson?["color_led_brightness"] = ""
        }
        migration.enumerateObjects(ofType: RealmDeviceList.className()) { (_, newPerson) in
            newPerson?["pressure_altitude_correction_status"] = false
            newPerson?["pressure_elevation"] = ""
            newPerson?["pressure_elevation_deviation_mbr"] = ""
            newPerson?["pressure_elevation_deviation_ihg"] = ""
        }
        migration.enumerateObjects(ofType: RealmDummyDeviceList.className()) { (_, newPerson) in
            newPerson?["pressure_altitude_correction_status"] = false
            newPerson?["pressure_elevation"] = ""
            newPerson?["pressure_elevation_deviation_mbr"] = ""
            newPerson?["pressure_elevation_deviation_ihg"] = ""
        }
    }
    
    func migrateFrom1To2(with migration: Migration) {
        // Add an email property
        migration.enumerateObjects(ofType: RealmDeviceList.className()) { (_, newPerson) in
            newPerson?["isBluetoothSync"] = false
        }
        migration.enumerateObjects(ofType: RealmDummyDeviceList.className()) { (_, newPerson) in
            newPerson?["isBluetoothSync"] = false
        }
    }
    
    func realmConfiguration() {
        self.configureMigration()
        RealmDataManager.shared.dispose()
        
        dataBasePathChange = true
        isFromVersion = false
    }
    
    
    
    
    func applySignUpTheme()  {
        self.btnLoginWithEmail.commonSetup()
        self.btnSignUpWithEMail.commonSetup()
        self.lblSignUpBorderLeft.commonSetup()
        self.lblSignUpOR.commonSetup()
        self.lblSignUpBorderRight.commonSetup()
        self.btnLoginWithGoogle.commonSetup()
        self.btnLoginWithFacebook.commonSetup()
        //self.btnLoginWithApple.commonSetup()
    }
    
    func removeDeviceData()  {
        RealmDataManager.shared.deleteDeviceRelamDataBase()
        RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
        RealmDataManager.shared.deleteRelamSettingColorDataBase()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideActivityIndicator(self.view)
    }
}

extension  SigninBaseViewController:  GIDSignInDelegate {
    
    @IBAction func btnTapSignInEmail(_ sender: Any) {
        self.ressetTimer()
        let pushToVC: SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        AppSession.shared.setIsShowBack(isShow: true)
        self.navigationController?.pushViewController(pushToVC, animated: true)
        
    }
    
    @IBAction func btnTapSignUp(_ sender: Any) {
        self.ressetTimer()
        let pushToVC: SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(pushToVC, animated: true)
    }
    
    @IBAction func btnTapGoogle(_ sender: Any) {
        //self.showActivityIndicator(self.view)
        self.ressetTimer()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        //        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func btnTapFB(_ sender: Any) {
        self.showActivityIndicator(self.view)
        self.ressetTimer()
        let loginManager = LoginManager()
        //Here in this line you need to mention permissions like .email, .userFriends, .userBirthday etc..
        loginManager.logIn(permissions: [Permission.email], viewController : self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.hideActivityIndicator(self.view)
                print(error)
            case .cancelled:
                self.hideActivityIndicator(self.view)
                print("User cancelled login")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in : \(grantedPermissions), \(declinedPermissions), \(accessToken)")
                self.getFbId()
            }
        }
    }
    
    
    
    func getFbId(){
        if(AccessToken.current != nil){
            
            GraphRequest(graphPath: "me", parameters: ["fields": "email"]).start(completionHandler: { (connection, result, error) in
                guard (result as? [String: Any]) != nil else { return }
                self.sToken = AccessToken.current?.tokenString ?? ""
                self.checkExstingUser(sType: "facebook", sToken: self.sToken)
                if(error == nil){
                    //self.hideActivityIndicator(self.view)
                    print("result")
                }else {
                    self.hideActivityIndicator(self.view)
                }
            })
        }
    }
    
    func loginWithFacebookAPI() {
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            
            let model: RegisterSocialUserViewModel = RegisterSocialUserViewModel.init(accessToken: self.sToken, phoneNumber: "24537", provider: "facebook", deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", name: "", email: "",osVersion:  UIDevice.current.systemVersion, osName: UIDevice.current.systemName, mobileDeviceModel: UIDevice.modelName, appversion: self.getVersionNo(), buildVersion: self.getVersionBuildNo())
            MobileApiAPI.apiMobileApiRegisterSocialUserPost(model: model) { (response, error) in
                if response?.success == true {
                    AppSession.shared.setAccessToken(response?.data ?? "")
                    textLog.write("Existing user facebook moveToLogged - 5")
                    self.moveToLogged()
                }else {
                    self.hideActivityIndicator(self.view)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            }
        }
    }
    
    func loginWithGoogleAPI() {
        if Reachability.isConnectedToNetwork() == true {
            
            
            let model: RegisterSocialUserViewModel = RegisterSocialUserViewModel.init(accessToken: self.sToken, phoneNumber: "46234", provider: "google", deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", name: "", email: "",osVersion:  UIDevice.current.systemVersion, osName: UIDevice.current.systemName, mobileDeviceModel: UIDevice.modelName, appversion: self.getVersionNo(), buildVersion: self.getVersionBuildNo())
            
            MobileApiAPI.apiMobileApiRegisterSocialUserPost(model: model) { (response, error) in
                if response?.success == true {
                    AppSession.shared.setAccessToken(response?.data ?? "")
                    if response?.success == true {
                        AppSession.shared.setAccessToken(response?.data ?? "")
                        textLog.write("Existing user Google moveToLogged - 5")
                        self.moveToLogged()
                    }else {
                        self.hideActivityIndicator(self.view)
                        Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                    }
                }else {
                    self.hideActivityIndicator(self.view)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            }
        }
    }
    
    func checkExstingUser(sType:String,sToken:String)  {
        self.showActivityIndicator(self.view)
        if Reachability.isConnectedToNetwork() == true {
            var versionValue:String = ""
            var buildNoValue:String = ""
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                versionValue = version
                if let buildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    buildNoValue = buildNo
                }
            }
            var model: SNAirQualityWebViewModelsRegisterSocialUserViewModel? = nil
            if sType == "google" {
                model = SNAirQualityWebViewModelsRegisterSocialUserViewModel.init(accessToken: sToken, phoneNumber: "24537", provider: sType, deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", osVersion:  UIDevice.current.systemVersion, osName: UIDevice.current.systemName, mobileDeviceModel: UIDevice.modelName, appversion: self.getVersionNo(), buildVersion: self.getVersionBuildNo())
                
            }else {
                model = SNAirQualityWebViewModelsRegisterSocialUserViewModel.init(accessToken: sToken, phoneNumber: "24537", provider: sType, deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", osVersion:  UIDevice.current.systemVersion, osName: UIDevice.current.systemName, mobileDeviceModel: UIDevice.modelName, appversion: self.getVersionNo(), buildVersion: self.getVersionBuildNo())
                
            }
            
            MobileApiAPI.apiMobileApiCheckSocialUserPost(model: model) { (response, error) in
                if response?.success == true {
                    self.sType = sType
                    if response?.data == false {
                        textLog.write("New Facebook or Google Login Try IT - 2 ")
                        self.moveToWebView()
                    }else {
                        if sType == "google" {
                            self.loginWithGoogleAPI()
                            textLog.write("Existing user Google Login - 5")
                        }else if sType == "facebook" {
                            self.loginWithFacebookAPI()
                            textLog.write("Existing user facebook Login - 5")
                        }
                    }
                }else {
                    self.hideActivityIndicator(self.view)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        textLog.write("Google Login Try IT - 1 ")
        self.sToken = user.authentication.idToken
        self.checkExstingUser(sType: "google", sToken: self.sToken)
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        
    }
    
    func moveToMEAPI() {
        //self.hideActivityIndicator(self.view)
        //self.showActivityIndicator(self.view)
        APIManager.shared.callUserMeApi()
        APIManager.shared.meDelegate = self
    }
    
    func moveToLogged() {
        AppSession.shared.setIsUserLogin(userLoginStatus: true)
        self.moveToMEAPI()
    }
}

extension SigninBaseViewController: DeviceMEAPIDelegate,MAXINDEXDataAPIDelegate {
    
    func moveToDashBoard()  {
        //self.hideActivityIndicator(self.view)
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LuftTabbarViewController") as! LuftTabbarViewController
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        mainTabbar.modalPresentationStyle = .fullScreen
        self.present(mainTabbar, animated: false, completion: nil)
    }
    
    
    func deviceDataAPIStatus(update: Bool) {
        // self.hideActivityIndicator(self.view)
        self.arrMYdeviceList.removeAll()
        self.arrMYdeviceList = RealmDataManager.shared.readDeviceListDataValues()
        if arrMYdeviceList.count != 0 {
            self.callMaxIndexDeviceAPI()
        }else {
            self.showActivityIndicator(self.view)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.moveToDashBoard()
            }
        }
    }
    
    func callMyDeviceAPI() {
        //self.showActivityIndicator(self.view)
        APIManager.shared.callDeviceDetailsTypeApi(isUpdateDummy: true)
        APIManager.shared.myDeviceDelegate = self
    }
    
    func updateMaxIdex(updateStatus: Bool) {
        // self.hideActivityIndicator(self.view)
        self.callMaxIndexDeviceAPI()
    }
    
    func callMaxIndexDeviceAPI() {
        // self.showActivityIndicator(self.view)
        if self.arrMYdeviceList.count != 0 {
            APIManager.shared.callMAXINDEXDeviceData(deviceToken: self.arrMYdeviceList[0].device_token, maxLogIndex: self.arrMYdeviceList[0].maxLogIndex.toInt() ?? 0, deviceSerialID: self.arrMYdeviceList[0].serial_id, isFromIntial: true)
            APIManager.shared.maxIndexDelegate = self
            self.arrMYdeviceList.remove(at: 0)
        }else {
            self.showActivityIndicator(self.view)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.moveToDashBoard()
            }
        }
    }
}
// MARK: - Core Data
//Building Type
extension SigninBaseViewController: MEDataAPIDelegate {
    
    func medataAPIData(meData: AppUserMobileDetails?) {
        //self.hideActivityIndicator(self.view)
        if let meDatass = meData {
            self.tempMobileUserSetting = AppUserMobileDetails.init(firstName: meDatass.firstName, lastName: meDatass.lastName, buildingtypeid: meDatass.buildingtypeid, mitigationsystemtypeid: meDatass.mitigationsystemtypeid, enableNotifications: meDatass.enableNotifications, isTextNotificationEnabled: meDatass.isTextNotificationEnabled, mobileNo: meDatass.mobileNo, isEmailNotificationEnabled: meDatass.isEmailNotificationEnabled, notificationEmail: meDatass.notificationEmail, isMobileNotificationFrequencyEnabled: meDatass.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: meDatass.isSummaryEmailEnabled, isDailySummaryEmailEnabled: meDatass.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: meDatass.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: meDatass.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: meDatass.temperatureUnitTypeId, pressureUnitTypeId: meDatass.pressureUnitTypeId, radonUnitTypeId: meDatass.radonUnitTypeId, appLayout: meDatass.appLayout, appTheme: meDatass.appTheme, outageNotificationsDuration: meDatass.outageNotificationsDuration, notificationFrequency: meDatass.notificationFrequency, isMobileOutageNotificationsEnabled: meDatass.isMobileOutageNotificationsEnabled)
            AppSession.shared.setUserSelectedTheme(themeType: meDatass.appTheme ?? 0)
            AppSession.shared.setUserSelectedLayout(layOut: meDatass.appLayout ?? 0)
            if  AppSession.shared.getUserSelectedTheme() == 2{
                AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
            }else {
                AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
            }
            ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        }
       // self.hideActivityIndicator(self.view)
        self.callMyDeviceAPI()
        
    }
    func callBuildIngTypeApi(){
        
        if Reachability.isConnectedToNetwork() == true {
            showActivityIndicator(self.view)
            HttpManager.sharedInstance.getHomeBuildTypeMe(userData: "" , successBlock: {[unowned self] (success, message, responseObject) in
                self.hideActivityIndicator(self.view)
                if success {
                    if let dataValue:JSON = Helper.shared.getOptionalJson(response: responseObject as AnyObject) {
                        let jsonString = dataValue.rawString()
                        if let jsonData = jsonString?.data(using: .utf8)! {
                            do {
                                let jsonDecoder = JSONDecoder()
                                self.homeBuildingTypeData = try jsonDecoder.decode([BuildingModelType].self, from: jsonData)
                                
                                self.writeHomeBuildingType()
                                self.callMitigationTypeApi()
                            }
                            catch {
                            }
                        }
                    }else {
                        Helper().showSnackBarAlert(message: message, type: .Failure)
                    }
                }
                }, failureBlock: {[unowned self] (errorMesssage) in
                    self.hideActivityIndicator(self.view)
                    Helper.shared.showSnackBarAlert(message: errorMesssage.description, type: .Failure)
            });
        }
        else{
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    func callMitigationTypeApi(){
        
        if Reachability.isConnectedToNetwork() == true {
            showActivityIndicator(self.view)
            HttpManager.sharedInstance.getMitigationTypeMe(userData: "" , successBlock: {[unowned self] (success, message, responseObject) in
                self.hideActivityIndicator(self.view)
                if success {
                    if let dataValue:JSON = Helper.shared.getOptionalJson(response: responseObject as AnyObject) {
                        let jsonString = dataValue.rawString()
                        if let jsonData = jsonString?.data(using: .utf8)! {
                            do {
                                let jsonDecoder = JSONDecoder()
                                self.arrMitigationTypeData = try jsonDecoder.decode([BuildingModelType].self, from: jsonData)
                                self.writeMitigationType()
                            }
                            catch {
                            }
                        }
                    }else {
                        Helper().showSnackBarAlert(message: message, type: .Failure)
                    }
                }
                }, failureBlock: {[unowned self] (errorMesssage) in
                    self.hideActivityIndicator(self.view)
                    Helper.shared.showSnackBarAlert(message: errorMesssage.description, type: .Failure)
            });
        }
        else{
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    func writeHomeBuildingType()  {
        self.homeBuildingTypeData.removeAll()
        self.homeBuildingTypeData.append(BuildingModelType.init(description: "", name: "Residential Single Family", datecreated: "", datemodified: "", createdBy: nil, id: 0, updatedBy: nil))
        self.homeBuildingTypeData.append(BuildingModelType.init(description: "", name: "Residential Multi Family", datecreated: "", datemodified: "", createdBy: nil, id: 1, updatedBy: nil))
        self.homeBuildingTypeData.append(BuildingModelType.init(description: "", name: "Educational", datecreated: "", datemodified: "", createdBy: nil, id: 2, updatedBy: nil))
        self.homeBuildingTypeData.append(BuildingModelType.init(description: "", name: "Nursing", datecreated: "", datemodified: "", createdBy: nil, id: 3, updatedBy: nil))
        self.homeBuildingTypeData.append(BuildingModelType.init(description: "", name: "Commercial", datecreated: "", datemodified: "", createdBy: nil, id: 4, updatedBy: nil))
        self.homeBuildingTypeData.append(BuildingModelType.init(description: "", name: "Office", datecreated: "", datemodified: "", createdBy: nil, id: 5, updatedBy: nil))
        self.homeBuildingTypeData.append(BuildingModelType.init(description: "", name: "Other - Not Specified", datecreated: "", datemodified: "", createdBy: nil, id: 6, updatedBy: nil))
        
        let context = appDelegate.persistentContainer.viewContext
        for buildType in self.homeBuildingTypeData {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_BUILDING_TYPE, into: context)
            newSetting.setValue(String(format: "%@", buildType?.description ?? ""), forKey: "descriptionValue")
            newSetting.setValue(String(format: "%@", buildType?.name ?? ""), forKey: "name")
            newSetting.setValue(String(format: "%d", buildType?.createdBy ?? 0), forKey: "createdBy")
            newSetting.setValue(String(format: "%d", buildType?.id ?? 0), forKey: "id")
            newSetting.setValue(String(format: "%d", buildType?.updatedBy ?? 0), forKey: "updatedBy")
            newSetting.setValue(String(format: "%@", buildType?.datecreated ?? ""), forKey: "datecreated")
            newSetting.setValue(String(format: "%@", buildType?.datemodified ?? ""), forKey: "datemodified")
        }
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func writeMitigationType()  {
        self.arrMitigationTypeData.removeAll()
        
        self.arrMitigationTypeData.append(BuildingModelType.init(description: "", name: "None", datecreated: "", datemodified: "", createdBy: nil, id: 0, updatedBy: nil))
        self.arrMitigationTypeData.append(BuildingModelType.init(description: "", name: "Active (with Fan)", datecreated: "", datemodified: "", createdBy: nil, id: 1, updatedBy: nil))
        self.arrMitigationTypeData.append(BuildingModelType.init(description: "", name: "Passive (insulations)", datecreated: "", datemodified: "", createdBy: nil, id: 2, updatedBy: nil))
        self.arrMitigationTypeData.append(BuildingModelType.init(description: "", name: "I don’t know", datecreated: "", datemodified: "", createdBy: nil, id: 3, updatedBy: nil))
        let context = appDelegate.persistentContainer.viewContext
        for buildType in self.arrMitigationTypeData {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_MITIGATION_TYPE, into: context)
            newSetting.setValue(String(format: "%@", buildType?.description ?? ""), forKey: "descriptionValue")
            newSetting.setValue(String(format: "%@", buildType?.name ?? ""), forKey: "name")
            newSetting.setValue(String(format: "%d", buildType?.createdBy ?? 0), forKey: "createdBy")
            newSetting.setValue(String(format: "%d", buildType?.id ?? 0), forKey: "id")
            newSetting.setValue(String(format: "%d", buildType?.updatedBy ?? 0), forKey: "updatedBy")
            newSetting.setValue(String(format: "%@", buildType?.datecreated ?? ""), forKey: "datecreated")
            newSetting.setValue(String(format: "%@", buildType?.datemodified ?? ""), forKey: "datemodified")
        }
        do {
            if  AppSession.shared.getIsUserLogin() == true {
                //self.moveToMEAPI()
                if Reachability.isConnectedToNetwork() == true {
                    self.removeDeviceData()
                    self.callMyDeviceAPI()
                }else {
                    self.showActivityIndicator(self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.moveToDashBoard()
                    }
                }
                self.viewAlreadyHaveLogin.isHidden = false
            }else {
                self.viewAlreadyHaveLogin.isHidden = true
            }
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func deleteSettingData()  {
        let context = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: TBL_BUILDING_TYPE))
        do {
            try context.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
        let DelAllReqVar1 = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: TBL_MITIGATION_TYPE))
        do {
            try context.execute(DelAllReqVar1)
        }
        catch {
            print(error)
        }
    }
    
    func loadColorValue()  {
        
        let context = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: TBL_COLORS))
        do {
            try context.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
        let arrColorCode:[String] = ["#F7F9F9", "#3E82F7", "#800080", "#E15D5B", "#FFA500", "#DEBF54", "#32C772", "#FFC0CB"]
        let arrColorName:[String] = ["White", "Blue", "Purple", "Red", "Orange", "Yellow", "Green", "Pink"]
        var count = arrColorCode.count
        for _ in arrColorName {
            let newSetting = NSEntityDescription.insertNewObject(forEntityName: TBL_COLORS, into: context)
            newSetting.setValue(String(format: "%@", arrColorCode[count - 1]), forKey: "colorcode")
            newSetting.setValue(String(format: "%@", arrColorName[count - 1]), forKey: "colorname")
            count = count - 1
        }
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        
    }
}
extension SigninBaseViewController {
    
    @objc func btnTap(_sender:UIButton) {
        self.tapCount = self.tapCount + 1
        if counter == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.counter = 60
                if self.tapCount >= 5 &&  self.counter == 60 {
                    self.passwordCheckAlert()
                }
                self.ressetTimer()
            }
        }
        if self.tapCount == 5  {
            self.passwordCheckAlert()
            self.ressetTimer()
        }
    }
    
    func moveToUATLIVEAlert() {
        var message:String = ""
        if AppSession.shared.getUserLiveState() == 2 {
            message = UAT_LIVE_ALERT_MSG
        }else {
            message = LIVE_UAT_ALERT_MSG
        }
        
        let titleString = NSAttributedString(string: "Alert", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel1 = UIAlertAction(title: "No", style: .default, handler: { action in
        })
        alert.addAction(cancel1)
        let cancel = UIAlertAction(title: "Yes", style: .default, handler: { action in
            if AppSession.shared.getUserLiveState() == 1 || AppSession.shared.getUserLiveState() == 0 {
                AppSession.shared.setLiveState(state:2)
            }else {
                AppSession.shared.setLiveState(state:1)
            }
            self.switchAccount()
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func ressetTimer() {
        counter = 0
        tapCount = 0
    }
    
    func passwordCheckAlert() {
        
        let titleString = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let message = String(format: DEVELOPER_ACCESS_ALERT_MSG)
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Password"
            textField.autocorrectionType = .default
        }
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Submit", style: .default, handler: { action in
            let firstTextField = alert.textFields![0] as UITextField
            //firstTextField.text = "Pa@5word"
            if firstTextField.text?.count == 0 {
                Helper.shared.showSnackBarAlert(message: "Enter Password", type: .Failure)
            }else {
                if firstTextField.text == "Pa@5word"{
                    self.showFunctionAlert()
                }else {
                    Helper.shared.showSnackBarAlert(message: "Invalid Password", type: .Failure)
                }
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.present(alert, animated: true, completion: nil)
    }
    
    func switchAccount()  {
        self.realmConfiguration()
        self.deleteSettingData()
        self.writeHomeBuildingType()
        self.writeMitigationType()
        self.uatLBLTheme(lbl: self.lblUAT)
        self.ressetTimer()
        SwaggerClientAPI.basePath =  getAPIBaseUrl()
    }
    
    func getFWVersionAPI() {
        if Reachability.isConnectedToNetwork() == true {
            //self.showActivityIndicator(self.view)
            var getFWVersionStr:String = ""
            if AppSession.shared.getUserLiveState() == 2 {
                getFWVersionStr = FW_VERSION_UAT_URL
            }else {
                getFWVersionStr = FW_VERSION_LIVE_URL
            }
            Alamofire.request(getFWVersionStr,method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                //self.hideActivityIndicator(self.view)
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let data : JSON = Helper.shared.getOptionalJson(response: response.result.value as AnyObject)  {
                            //self.hideActivityIndicator(self.view)
                            strFirmwareVesrion =  data["LuftFWVersion"].stringValue
                        }
                    }
                    break
                case .failure(let error):
                    self.hideActivityIndicator(self.view)
                    Helper.shared.showSnackBarAlert(message: error.localizedDescription, type: .Failure)
                    break
                }
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}

extension SigninBaseViewController : LTIntialAGREEDelegate {
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController") as! WebDataViewController
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = PRIVACY_POLICY_TITLE
        webdataView.strTitle = PRIVACY_POLICY_TITLE
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .overFullScreen
        textLog.write("New Facebook or Google Login Web View - 3 ")
        self.present(webdataView, animated: false, completion: nil)
    }
    
    func selectedIntialAGREE() {
        self.showActivityIndicator(self.view)
        if Reachability.isConnectedToNetwork() == true {
            if self.sType == "google" {
                self.loginWithGoogleAPI()
            }else if self.sType == "facebook" {
                self.loginWithFacebookAPI()
            }else {
                self.hideActivityIndicator(self.view)
            }
        }
        else{
            self.hideActivityIndicator(self.view)
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}
extension SigninBaseViewController {
    
    func showFunctionAlert()  {
        let actionSheetController = UIAlertController(title: "Please select", message: "", preferredStyle: .actionSheet)
        let environmentButton = UIAlertAction(title: "Change Environment", style: .default) { action -> Void in
            self.moveToUATLIVEAlert()
        }
        actionSheetController.addAction(environmentButton)
        
        let exportButton = UIAlertAction(title: "Export Log", style: .default) { action -> Void in
            textLog.sendEmail(viewController: self)
        }
        actionSheetController.addAction(exportButton)
        let clearActionButton = UIAlertAction(title: "Clear Log", style: .destructive) { action -> Void in
            textLog.clearLogs()
        }
        actionSheetController.addAction(clearActionButton)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelActionButton)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
}
extension SigninBaseViewController {
    
    /// - Tag: add_appleid_button
    func setupProviderLoginView() {
        if #available(iOS 13.0, *) {
            self.loginProviderStackView.safelyRemoveArrangedSubviews()
            if AppSession.shared.getUserSelectedTheme() == 2 {
                let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .white)
                authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
                self.loginProviderStackView.addArrangedSubview(authorizationButton)
            }else {
                let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
                authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
                self.loginProviderStackView.addArrangedSubview(authorizationButton)
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        if #available(iOS 13.0, *) {
            let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                            ASAuthorizationPasswordProvider().createRequest()]
            let authorizationController = ASAuthorizationController(authorizationRequests: requests)
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    /// - Tag: perform_appleid_request
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
        
        
        
    }
}

extension SigninBaseViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
        default:
            break
        }
    }
    
    
    
    private func showResultViewController(userIdentifier: String, fullName: PersonNameComponents?, email: String?) {
        DispatchQueue.main.async {
            print(userIdentifier)
            self.strAppleIdentifier = ""
            self.strEmail = String(format: "%@@luftsunradon.com", self.randomString(6))
            self.strAppleIdentifier = userIdentifier
            if let emailValue = email {
                self.strEmail = emailValue
//                if emailValue.contains("privaterelay.appleid.com") {
//                    self.strEmail = ""
//                }
            }
            self.loginWithAppleIdentifierAPI()
        }
    }
    
    
    
    /// - Tag: did_complete_error
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension SigninBaseViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func loginWithAppleIdentifierAPI() {
        self.showActivityIndicator(self.view)
        if Reachability.isConnectedToNetwork() == true {
            let model: SNAirQualityWebViewModelsAppleLogin = SNAirQualityWebViewModelsAppleLogin.init(appleKey: self.strAppleIdentifier, deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2")
            MobileApiAPI.apiMobileApiLoginAppleUserPost(model: model) { (response, error) in
                if response?.success == true {
                    if response?.data != nil {
                        AppSession.shared.setShowAppleIsInfo(isAppleLogin:3)
                        AppSession.shared.setAccessToken(response?.data ?? "")
                        self.moveToLogged()
                    }else {
                        if self.strEmail != "" && self.strEmail.count != 0 && self.strEmail != nil {
                           
                           let modelApple = RegisterSocialUserViewModel.init(accessToken: self.strAppleIdentifier, phoneNumber: "1234", provider: "apple", deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", name: "", email: self.strEmail,osVersion:  UIDevice.current.systemVersion, osName: UIDevice.current.systemName, mobileDeviceModel: UIDevice.modelName, appversion: self.getVersionNo(), buildVersion: self.getVersionBuildNo())
                            self.registerWithAppleAPI(appleEmail: self.strEmail, model: modelApple)
                        }else {
                            //self.moveToAppleEmailAlert()
                        }
                    }
                }else {
                    self.hideActivityIndicator(self.view)
                    Helper.shared.showSnackBarAlert(message: response?.message ?? "", type: .Failure)
                }
            }
        }
    }
    
    func registerWithAppleAPI(appleEmail:String,model:RegisterSocialUserViewModel) {
        self.showActivityIndicator(self.view)
        if Reachability.isConnectedToNetwork() == true {
            MobileApiAPI.apiMobileApiRegisterSocialUserPost(model: model) { (response, error) in
                if response?.success == true {
                    //self.hideActivityIndicator(self.view)
                    AppSession.shared.setAccessToken(response?.data ?? "")
                    AppSession.shared.setShowAppleIsInfo(isAppleLogin:1)
                    self.moveToLogged()
                }else {
                    self.hideActivityIndicator(self.view)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            }
        }
    }
    
    func moveToAppleEmailAlert() {
        self.hideActivityIndicator(self.view)
        let titleString = NSAttributedString(string: "Alert", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: APPLE_ALERT_MSG, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        alert.addTextField { (textField) in
            textField.placeholder = "Email-ID"
        }
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.strEmail = textField?.text
            self.vaildAlertMessage()
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            self.hideActivityIndicator(self.view)
           // Helper.shared.showSnackBarAlert(message: MANDATORY_APPLE_ALERT_MSG, type: .Failure)
          //  self.dismiss(animated: true, completion: nil)
            //self.moveToAppleEmailAlert()
        }))
     alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func vaildAlertMessage()  {
        if self.strEmail?.count == 0 {
            Helper.shared.showSnackBarAlert(message: CONTENT_EMPTY_USERNAME, type: .Failure)
            self.moveToAppleEmailAlert()
        } else if Helper.shared.isValidEmailAddress(strValue: self.strEmail ?? "") == false {
            Helper.shared.showSnackBarAlert(message: CONTENT_INVALID_EMAIL, type: .Failure)
            self.moveToAppleEmailAlert()
        }
       else {
            var modelApple:RegisterSocialUserViewModel? = nil
           
            modelApple = RegisterSocialUserViewModel.init(accessToken: self.strAppleIdentifier, phoneNumber: "1234", provider: "apple", deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", name: " ", email: self.strEmail,osVersion:  UIDevice.current.systemVersion, osName: UIDevice.current.systemName, mobileDeviceModel: UIDevice.modelName, appversion: self.getVersionNo(), buildVersion: self.getVersionBuildNo())
            self.registerWithAppleAPI(appleEmail: self.strEmail, model: modelApple!)
        }
    }
}

extension UIStackView {

    func safelyRemoveArrangedSubviews() {

        // Remove all the arranged subviews and save them to an array
        let removedSubviews = arrangedSubviews.reduce([]) { (sum, next) -> [UIView] in
            self.removeArrangedSubview(next)
            return sum + [next]
        }

        // Deactive all constraints at once
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))

        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
extension SigninBaseViewController {
    
    func randomString(_ length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}
extension SigninBaseViewController {
    
    func getVersionBuildNo() -> String{
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print(version)
            if let buildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                return buildNo
            }else {
                return ""
            }
        }
        return ""
    }
    
    func getVersionNo() -> String{
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return  version
        }else {
            return ""
        }
    }
}
