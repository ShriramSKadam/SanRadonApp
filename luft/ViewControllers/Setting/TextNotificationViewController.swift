//
//  TextNotificationViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class TextNotificationViewController:LTSettingBaseViewController {
    
    @IBOutlet weak var txtTXNotEmailAddress: LTSettingTextFiled!
    @IBOutlet weak var btnTXSave: UIButton!
    @IBOutlet weak var SwitchTXEnable: UISwitch!
    @IBOutlet weak var stackViewTXEnable: UIStackView!
    var txtNotifiMobileUserSetting: AppUserMobileDetails? = nil
    var previousSwitchTextNotificationEnable:Bool = false
    var previousMobileNo:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SwitchTXEnable.addTarget(self, action: #selector(switchTxtNotificationChanged), for: UIControl.Event.valueChanged)
        self.btnTXSave.addTarget(self, action:#selector(self.btnSaveTxtNotificationBtn(_sender:)), for: .touchUpInside)
        self.txtTXNotEmailAddress.keyboardType = .numberPad
        self.txtTXNotEmailAddress.text = AppSession.shared.getMobileUserMeData()?.mobileNo
        if AppSession.shared.getMobileUserMeData()?.isTextNotificationEnabled == true{
            self.stackViewTXEnable.isHidden = false
            self.SwitchTXEnable.isOn = true
            self.previousSwitchTextNotificationEnable = true
        }else {
            self.stackViewTXEnable.isHidden = true
            self.SwitchTXEnable.isOn = false
            self.previousSwitchTextNotificationEnable = false
        }
        self.previousMobileNo = self.txtTXNotEmailAddress?.text ?? ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.txtNotifiMobileUserSetting = nil
    }
    
    func loadTxtNotificationStatus()  {
        if self.txtNotifiMobileUserSetting?.isTextNotificationEnabled == true{
            self.stackViewTXEnable.isHidden = false
            self.SwitchTXEnable.isOn = true
        }else {
            self.stackViewTXEnable.isHidden = true
            self.SwitchTXEnable.isOn = false
        }
    }
    
}
extension TextNotificationViewController {
    
    @objc func switchTxtNotificationChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            self.txtNotifiMobileUserSetting?.isTextNotificationEnabled = true
        }else{
           self.txtNotifiMobileUserSetting?.isTextNotificationEnabled = false
        }
        self.loadTxtNotificationStatus()
    }
    
    @objc func btnSaveTxtNotificationBtn(_sender:UIButton){
        self.view.endEditing(true)
        if self.SwitchTXEnable.isOn == true {
            self.txtNotifiMobileUserSetting?.mobileNo = self.txtTXNotEmailAddress?.text ?? ""
        }else {
            self.txtNotifiMobileUserSetting?.mobileNo = ""
        }
        
        if self.SwitchTXEnable.isOn == true {
            if self.txtNotifiMobileUserSetting?.mobileNo?.count != 0 {
                self.callSaveUserMeApi()
            }else {
                Helper.shared.showSnackBarAlert(message: CONTENT_PHONE_NUMBER, type: .Failure)
            }
        }else {
            self.callSaveUserMeApi()
        }
        
    }
    
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    func callSaveUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            AppUserAPI.apiAppUserUpdateMobileUserPost(user: self.txtNotifiMobileUserSetting, completion: { (error) in
                self.hideActivityIndicator(self.view)
                if error == nil {
                    AppSession.shared.setMobileUserMeData(mobileSettingData: self.txtNotifiMobileUserSetting!)
                    Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
                    self.navigationController?.popViewController(animated: true)
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            })
            
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}
extension TextNotificationViewController {
    
    func backCompareValues() -> Bool{
        if self.previousSwitchTextNotificationEnable != self.SwitchTXEnable.isOn || self.previousMobileNo != self.txtTXNotEmailAddress?.text ?? ""{
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
            self.view.endEditing(true)
            self.btnSaveTxtNotificationBtn(_sender: self.btnTXSave)
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

