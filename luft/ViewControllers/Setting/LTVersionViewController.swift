//
//  LTVersionViewController.swift
//  luft
//
//  Created by iMac Augusta on 11/1/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

protocol LTDismissVerisonDelegate:class {
    func moveLoginViewVerison(isUpdate:Bool)
}

class LTVersionViewController: UIViewController {
    
    @IBOutlet weak var txtChangeEmail: LTSettingTextFiled!
    @IBOutlet weak var btnTap: UIButton!
    @IBOutlet weak var viewBack: LTSettingTextBackView!
    
    var counter = 0
    var tapCount = 0
    var ltdismissVerisonDelegate: LTDismissVerisonDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.txtChangeEmail?.text = version
            if let buildNo = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                self.txtChangeEmail?.text = String(format: "Version: %@ (%@)",version,buildNo)
            }
        }
        self.txtChangeEmail?.isUserInteractionEnabled = false
        self.txtChangeEmail?.clearButtonMode = UITextField.ViewMode.never
        self.btnTap.addTarget(self, action:#selector(self.btnTap(_sender:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.viewBack.backgroundColor = ThemeManager.currentTheme().settingVersionViewBackgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
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
            self.logoutAPI()
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func logoutAPI()  {
//        self.showActivityIndicator(self.view)
//        let logoutModel = LoginUserViewModel.init(email: "", password: "", deviceToken: currentDeviceToken, deviceId: currentDeviceId, loginDevice: 2, isWeb: false, userAgentId: "2", ipAddress: "")
//        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
//        AdminAPI.apiAdminLogoutPost(model: logoutModel, completion: { (respones, error) in
//            self.hideActivityIndicator(self.view)
//            if respones == 1 {
//                if AppSession.shared.getUserLiveState() == 1 || AppSession.shared.getUserLiveState() == 0 {
//                    AppSession.shared.setLiveState(state:2)
//                }else {
//                    AppSession.shared.setLiveState(state:1)
//                }
//                self.navigationController?.popViewController(animated: false)
//                self.ltdismissVerisonDelegate?.moveLoginViewVerison(isUpdate: false)
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
                if AppSession.shared.getUserLiveState() == 1 || AppSession.shared.getUserLiveState() == 0 {
                    AppSession.shared.setLiveState(state:2)
                }else {
                    AppSession.shared.setLiveState(state:1)
                }
                self.navigationController?.popViewController(animated: false)
                self.ltdismissVerisonDelegate?.moveLoginViewVerison(isUpdate: false)
            }else if respones?.success == false {
                Helper().showSnackBarAlert(message: respones?.message ?? "", type: .Failure)
            }else {
                Helper.shared.showSnackBarAlert(message: "Log out Failure", type: .Failure)
            }
        }
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
}
extension LTVersionViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
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
