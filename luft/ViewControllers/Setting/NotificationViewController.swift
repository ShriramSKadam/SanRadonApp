//
//  NotificationViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class NotificationViewController:LTSettingBaseViewController, LTIntialAGREEDelegate {
    func selectedIntialAGREE() {
        print("ios")
    }
    
    @IBOutlet weak var btnNotificationSave: UIButton!
    @IBOutlet weak var btnNotificationBack: UIButton!
    @IBOutlet weak var GetMoreHelp: UIButton!

    @IBOutlet weak var SwitchPUSHNOTEnable: UISwitch!
    @IBOutlet weak var txtNotification: UIView!
    @IBOutlet weak var emailNotification: UIView!
    @IBOutlet weak var outageNotification: UIView!
    @IBOutlet weak var alertNotification: UIView!
    @IBOutlet weak var notificationStackViewHeight: NSLayoutConstraint!
    var notificationMobileUserSetting: AppUserMobileDetails? = nil
    var isFromInitialAddDevice:Bool = false
    var previousSwitchPUSHNOTEnable:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadNotificationStatus()
        self.SwitchPUSHNOTEnable.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        self.btnNotificationSave.addTarget(self, action:#selector(self.btnSaveNotificationBtn(_sender:)), for: .touchUpInside)
        self.loadNotificationStatus()
        self.btnNotificationSave?.titleLabel?.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isFromInitialAddDevice == true {
            self.btnNotificationSave.isHidden = false
            self.btnNotificationSave?.titleLabel?.text = "Next"
            self.btnNotificationBack.isHidden = true
        }
    }
    
    @IBAction func GetMorehelp(_ sender: Any) {
        self.moveToWebView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
        webdataView.Urltodisplay = APPLICATION_Url
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = UNITS
        webdataView.strTitle = UNITS
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .pageSheet
        self.present(webdataView, animated: false, completion: nil)
    }
    
    func loadNotificationStatus()  {
        if AppSession.shared.getMobileUserMeData()?.enableNotifications == true{
            self.SwitchPUSHNOTEnable.isOn = true
        }else {
            self.SwitchPUSHNOTEnable.isOn = false
        }
        self.txtNotification.isHidden = true
        self.emailNotification.isHidden = false
        self.notificationStackViewHeight.constant = 80.0
        self.previousSwitchPUSHNOTEnable = self.SwitchPUSHNOTEnable.isOn
    }
    
}
extension NotificationViewController {
    
    @objc func switchChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
           self.notificationMobileUserSetting?.enableNotifications = true
        }else{
            self.notificationMobileUserSetting?.enableNotifications = false
        }
        self.callSaveUserMeApi()
    }
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
        if let vcs = self.navigationController?.viewControllers {
            for vc in vcs {
                if (vc.isKind(of: SettingViewController.self) == true) {
                    let vcSetting = vc as! SettingViewController
                    vcSetting.luftSettingTabbar = 100
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnSaveNotificationBtn(_sender:UIButton){
        if self.isFromInitialAddDevice == true {
            AppSession.shared.setIsAddedNewDevice(isAddedDevice:true)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnTapTxtNotification(_ sender: Any) {
        let txtNotification = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextNotificationViewController") as! TextNotificationViewController
        txtNotification.txtNotifiMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.navigationController?.pushViewController(txtNotification, animated: true)
    }
    
    @IBAction func btnTapEmailNotification(_ sender: Any) {
        let emailNotification = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EMailNotificationViewController") as! EMailNotificationViewController
        emailNotification.emailNotifiMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.navigationController?.pushViewController(emailNotification, animated: true)
    }
    
    func callSaveUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            AppUserAPI.apiAppUserUpdateMobileUserPost(user: self.notificationMobileUserSetting, completion: { (error) in
                self.hideActivityIndicator(self.view)
                if error == nil {
                    AppSession.shared.setMobileUserMeData(mobileSettingData: self.notificationMobileUserSetting!)
                    Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
                    //self.navigationController?.popViewController(animated: true)
                    //self.loadNotificationStatus()
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            })
            
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}
//
extension NotificationViewController {
    
    func backCompareValues() -> Bool{
        if self.previousSwitchPUSHNOTEnable != self.SwitchPUSHNOTEnable.isOn {
            return false
        }
        return true
    }
    
    
    func backValidationAlert()  {
        self.hideActivityIndicator(self.view)
        let titleString = NSAttributedString(string: "Confirmation", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string:"Do you want to save changes?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let cancel = UIAlertAction(title: "Yes", style: .cancel, handler: { action in
            self.callSaveUserMeApi()
        })
        alert.addAction(cancel)
        let save = UIAlertAction(title: "No", style: .default, handler: { action in
            
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(save)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}

