//
//  ChangeNameViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class ChangeNameViewController: UIViewController {

    @IBOutlet weak var txtChangeFirstName: LTSettingTextFiled!
    @IBOutlet weak var txtChangeLastName: LTSettingTextFiled!
    @IBOutlet weak var btnSaveChangeName: UIButton!
    var changeNameMobileUserSetting: AppUserMobileDetails? = nil
    
    var prevFirstName:String = ""
    var prevLastName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtChangeFirstName?.keyboardType = .alphabet
        self.txtChangeLastName?.keyboardType = .alphabet
        self.txtChangeFirstName?.text = self.changeNameMobileUserSetting?.firstName
        self.txtChangeLastName?.text = self.changeNameMobileUserSetting?.lastName
        
        self.txtChangeFirstName?.placeholder = "First Name"
        self.txtChangeLastName?.placeholder = "Last Name"
        self.prevFirstName = self.changeNameMobileUserSetting?.firstName ?? ""
        self.prevLastName = self.changeNameMobileUserSetting?.lastName ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.btnSaveChangeName.addTarget(self, action:#selector(self.btnTapbtnSaveChangeName(_sender:)), for: .touchUpInside)
    }
}

extension ChangeNameViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
        self.backSetting()
    }
    
    @objc func btnTapbtnSaveChangeName(_sender:UIButton){
        self.view.endEditing(true)
        if self.txtChangeFirstName.text?.count != 0  && self.txtChangeLastName.text?.count != 0 { //New
            self.callSaveUserMeApi()
        }else {
            if self.txtChangeFirstName.text?.count == 0 {
                Helper.shared.showSnackBarAlert(message: CONTENT_FIRST_NAME, type: .Failure)
            }
            else if self.txtChangeLastName.text?.count == 0 {
                Helper.shared.showSnackBarAlert(message: CONTENT_LAST_NAME, type: .Failure)
            }
        }
    }
    
    func callSaveUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            self.changeNameMobileUserSetting?.firstName = self.txtChangeFirstName.text
            self.changeNameMobileUserSetting?.lastName = self.txtChangeLastName.text
            self.showActivityIndicator(self.view)
            AppUserAPI.apiAppUserUpdateMobileUserPost(user: self.changeNameMobileUserSetting, completion: { (error) in
                self.hideActivityIndicator(self.view)
                if error == nil {
                    AppSession.shared.setMobileUserMeData(mobileSettingData: self.changeNameMobileUserSetting!)
                    Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
                    self.navigationController?.popViewController(animated: true)
                    self.backSetting()
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            })
            
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
   
    func backSetting()  {
        if let vcs = self.navigationController?.viewControllers {
            for vc in vcs {
                if (vc.isKind(of: SettingViewController.self) == true) {
                    let vcSetting = vc as! SettingViewController
                    vcSetting.luftSettingTabbar = 100
                }
            }
        }
    }
}
extension ChangeNameViewController {
    
    func backCompareValues() -> Bool{
        if self.prevFirstName != self.txtChangeFirstName?.text ?? "" || self.prevLastName != self.txtChangeLastName?.text ?? "" {
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

