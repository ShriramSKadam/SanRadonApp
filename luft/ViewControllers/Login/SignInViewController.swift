//
//  SignInViewController.swift
//  luft
//
//  Created by Augusta on 09/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import SystemConfiguration.CaptiveNetwork


class SignInViewController: LTViewController {

    @IBOutlet weak var txtEmailSignIn: LTCommonTextField!
    @IBOutlet weak var txtPaswordSignIn: LTCommonTextField!
    @IBOutlet weak var headerSignIn: AppHeaderView!
    @IBOutlet weak var btnPasswordShow: UIButton!
    @IBOutlet weak var btnBackSign: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnDontHaveLogin: UIButton!
    @IBOutlet weak var lblUAT: UILabel!

    var isPasswordHide: Bool = true
    var arrMYdeviceList: [RealmDeviceList] = []

    //API'S data
    var tempMobileUserSetting: AppUserMobileDetails? = nil
    var pwdHelper: AUPasswordFieldHelper = AUPasswordFieldHelper.init(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnPasswordShow.addTarget(self, action: #selector(self.showPasswordHintAlert(sender:)), for: .touchUpInside)
        self.btnLogin.addTarget(self, action:#selector(self.btnLoginTap(_sender:)), for: .touchUpInside)
        self.btnDontHaveLogin.addTarget(self, action:#selector(self.btnDontHaveLoginTap(_sender:)), for: .touchUpInside)
        self.txtPaswordSignIn.isSecureTextEntry = self.isPasswordHide
        self.txtEmailSignIn.keyboardType = .emailAddress
        let ssid = self.getAllWiFiNameList()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppSession.shared.isKeyPresentInUserDefaults(key: "SortFilterTypeEnum") == false{
            AppSession.shared.setUserSortFilterType(sortfilterType:1)
        }
        self.txtEmailSignIn.commonSetup()
        self.txtPaswordSignIn.commonSetup()
        self.headerSignIn.commonSetup()
        self.btnBackSign.isHidden = true
        if AppSession.shared.getIsShowBack() == false {
            isShowBackBtnSignin = false
        }else {
            AppSession.shared.setIsShowBack(isShow: true)
            self.btnBackSign.isHidden = false
        }
        if isFromVersion == true {
            self.navigationController?.popToRootViewController(animated: true)
            isFromVersion = false
        }
        self.removeDeviceData()
        self.uatLBLTheme(lbl: self.lblUAT)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        pwdHelper = AUPasswordFieldHelper.init(frame: self.txtPaswordSignIn.frame)
//        pwdHelper.minimumCharLimit = 8
//        pwdHelper.maximumCharLimit = 16
//        pwdHelper.configurePasswordHelper(textField: self.txtPaswordSignIn, position: .top, isAutoEnable: true, isInsideTableView: false, superView: self.view, cell: nil, itemsNeeded: [.lowerCaseNeeded,.upperCaseNeeded,.minMaxCharacterLimit, .numericNeeded, .noBlankSpace, .specialCharNeeded], tickImage: UIImage.init(named: "check_tick")!, unTickImage: UIImage.init(named: "check_round")!)
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
       self.txtEmailSignIn?.text = ""
       self.txtPaswordSignIn?.text = ""
    }
    
    func removeDeviceData()  {
        RealmDataManager.shared.deleteDeviceRelamDataBase()
        RealmDataManager.shared.deleteDUMMYDeviceRelamDataBase()
        RealmDataManager.shared.deleteRelamSettingColorDataBase()
    }
}
extension  SignInViewController {
    
    @objc func btnLoginTap(_sender:UIButton) {
        self.callSignInApi()
    }
    
    @objc func btnDontHaveLoginTap(_sender:UIButton) {
        let pushToVC: SignUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(pushToVC, animated: true)
    }
    
    @IBAction func btnTapBForgotPasswordBtn(_ sender: Any) {
        let pushToVC: ForgotPasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(pushToVC, animated: true)
    }
    
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func callSignInApi(){ //newGood
        self.view.endEditing(true)
//        self.txtEmailSignIn.text = "newgood@yopmail.com"
//        self.txtPaswordSignIn.text = "Augusta@12"
//        self.txtEmailSignIn.text = "kaiwundke@gmail.com"
//        self.txtPaswordSignIn.text = "Welcome2!"
        self.showActivityIndicator(self.view)
        let userEmail = removeWhiteSpace(text: self.txtEmailSignIn.text ?? "")
        let password = removeWhiteSpace(text: self.txtPaswordSignIn.text ?? "")
        let isValidated = self.validate(emailId: userEmail, password: password)
        if isValidated.0 == true {
            var versionValue:String = ""
            var buildNoValue:String = ""
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                versionValue = version
                if let buildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    buildNoValue = buildNo
                }
            }
            if Reachability.isConnectedToNetwork() == true {
                let loginModel = LoginUserViewModel(email: userEmail, password: password, deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", ipAddress: "", osVersion:  UIDevice.current.systemVersion, osName: UIDevice.current.systemName, mobileDeviceModel: UIDevice.modelName, appversion: versionValue, buildVersion: buildNoValue)
                MobileApiAPI.apiMobileApiLoginPost(model: loginModel) { (respones, error) in
                
                    if respones?.success == true {
                        UserDefaults.standard.set(self.txtEmailSignIn.text!, forKey: "LoginUser")

                        AppSession.shared.setAccessToken(respones?.data ?? "")
                        AppSession.shared.setIsUserLogin(userLoginStatus: true)
                        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
                        RealmDataManager.shared.dispose()
                        self.callMeAPIService()
                    }else if respones?.success == false {
                        self.hideActivityIndicator(self.view)
                        Helper().showSnackBarAlert(message: respones?.message ?? "", type: .Failure)
                    }else { // New Good
                        self.hideActivityIndicator(self.view)
                        Helper().showSnackBarAlert(message:"Invalid e-mail or password", type: .Failure)
                    }
                }
            }else {
                self.hideActivityIndicator(self.view)
                Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            }
        }else {
            self.hideActivityIndicator(self.view)
            Helper.shared.showSnackBarAlert(message: isValidated.1, type: .Failure)
        }
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
    
    @objc func showPasswordHintAlert(sender: UIButton) {
        let eyeOpen = UIImage(named: "icon_eye_open")
        let eyeClose = UIImage(named: "icon_eye_hide")
        self.isPasswordHide = !self.isPasswordHide
        let image = self.isPasswordHide ? eyeClose : eyeOpen
        self.btnPasswordShow.setImage(image, for: .normal)
        self.txtPaswordSignIn.isSecureTextEntry = self.isPasswordHide
        self.btnPasswordShow.layoutIfNeeded()
        Helper.shared.togglePasswordVisibility(textFiled: self.txtPaswordSignIn)
    }
    
    func getAllWiFiNameList() -> String? {
        let interfaces = CNCopySupportedInterfaces()
        if interfaces == nil {
            return nil
        }
        
        let interfacesArray = interfaces as! [String]
        if interfacesArray.count <= 0 {
            return nil
        }
        
        let interfaceName = interfacesArray[0] as String
        let unsafeInterfaceData =     CNCopyCurrentNetworkInfo(interfaceName as CFString)
        if unsafeInterfaceData == nil {
            return nil
        }
        
        let interfaceData = unsafeInterfaceData as! Dictionary <String,AnyObject>
        
        return interfaceData["SSID"] as? String
    }
}

extension SignInViewController: MEDataAPIDelegate {
    
    func medataAPIData(meData: AppUserMobileDetails?) {
        //self.hideActivityIndicator(self.view)
        if let meDatass = meData {
            self.tempMobileUserSetting = AppUserMobileDetails.init(firstName: meDatass.firstName, lastName: meDatass.lastName, buildingtypeid: meDatass.buildingtypeid, mitigationsystemtypeid: meDatass.mitigationsystemtypeid, enableNotifications: meDatass.enableNotifications, isTextNotificationEnabled: meDatass.isTextNotificationEnabled, mobileNo: meDatass.mobileNo, isEmailNotificationEnabled: meDatass.isEmailNotificationEnabled, notificationEmail: meDatass.notificationEmail, isMobileNotificationFrequencyEnabled: meDatass.isMobileNotificationFrequencyEnabled, isSummaryEmailEnabled: meDatass.isSummaryEmailEnabled, isDailySummaryEmailEnabled: meDatass.isDailySummaryEmailEnabled, isWeeklySummaryEmailEnabled: meDatass.isWeeklySummaryEmailEnabled, isMonthlySummaryEmailEnabled: meDatass.isMonthlySummaryEmailEnabled, temperatureUnitTypeId: meDatass.temperatureUnitTypeId, pressureUnitTypeId: meDatass.pressureUnitTypeId, radonUnitTypeId: meDatass.radonUnitTypeId, appLayout: meDatass.appLayout, appTheme: meDatass.appTheme,outageNotificationsDuration: meDatass.outageNotificationsDuration,notificationFrequency: meDatass.notificationFrequency, isMobileOutageNotificationsEnabled: meDatass.isMobileOutageNotificationsEnabled)
            AppSession.shared.setUserSelectedTheme(themeType: meDatass.appTheme ?? 0)
            AppSession.shared.setUserSelectedLayout(layOut: meDatass.appLayout ?? 0)
            if  AppSession.shared.getUserSelectedTheme() == 2{
                AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
            }else {
                AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
            }
            ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        }
        self.callMyDeviceAPI()
    }
   
    func callMeAPIService() {
        self.showActivityIndicator(self.view)
        APIManager.shared.callUserMeApi()
        APIManager.shared.meDelegate = self
    }
}
extension SignInViewController: DeviceMEAPIDelegate,MAXINDEXDataAPIDelegate {
    
    func moveToDashBoard()  {
        self.hideActivityIndicator(self.view)
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
           self.moveToDashBoard()
        }
    }
    
    func callMyDeviceAPI() {
        self.showActivityIndicator(self.view)
        RealmDataManager.shared.dispose()
        APIManager.shared.callDeviceDetailsTypeApi(isUpdateDummy: true)
        APIManager.shared.myDeviceDelegate = self
    }
    
    func updateMaxIdex(updateStatus: Bool) {
        //self.hideActivityIndicator(self.view)
        self.callMaxIndexDeviceAPI()
    }
    
    func callMaxIndexDeviceAPI() {
        self.showActivityIndicator(self.view)
        if self.arrMYdeviceList.count != 0 {
            APIManager.shared.callMAXINDEXDeviceData(deviceToken: self.arrMYdeviceList[0].device_token, maxLogIndex: self.arrMYdeviceList[0].maxLogIndex.toInt() ?? 0, deviceSerialID: self.arrMYdeviceList[0].serial_id, isFromIntial: true)
            APIManager.shared.maxIndexDelegate = self
            self.arrMYdeviceList.remove(at: 0)
        }else {
            self.hideActivityIndicator(self.view)
            self.moveToDashBoard()
        }
    }
}
extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
}
