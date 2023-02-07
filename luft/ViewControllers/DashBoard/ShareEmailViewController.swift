//
//  ShareEmailViewController.swift
//  Luft
//
//  Created by iMac Augusta on 2/13/20.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class ShareEmailViewController: UIViewController {
    
    @IBOutlet weak var txtChangeEmail: LTSettingTextFiled!
    @IBOutlet weak var btnSaveEmail: UIButton!
    @IBOutlet weak var btnSkipNext: LTBlueTextNormalButton!
    @IBOutlet weak var btnBack: UIButton!
    var isFromInitialAddDevice:Bool = false
    var isFromInitialCurrentDeviceID:Int = 0
    var isFromInitialCurrentDeviceToken:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnSaveEmail.addTarget(self, action:#selector(self.btnSaveEmailTapped(_sender:)), for: .touchUpInside)
        self.btnSkipNext.addTarget(self, action:#selector(self.btnSkipNextTapped(_sender:)), for: .touchUpInside)
        self.btnBack.isHidden = true
        self.txtChangeEmail?.keyboardType = .emailAddress
        self.txtChangeEmail?.setLeftPaddingPoints(10)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
    }
}

extension ShareEmailViewController {
    
    @objc func btnSaveEmailTapped(_sender:UIButton){
        self.view.endEditing(true)
        if self.txtChangeEmail?.text?.count == 0{
            Helper.shared.showSnackBarAlert(message: CONTENT_EMPTY_USERNAME, type: .Failure)
        } else if Helper.shared.isValidEmailAddress(strValue: self.txtChangeEmail?.text ?? "") == false {
            Helper.shared.showSnackBarAlert(message: CONTENT_INVALID_EMAIL, type: .Failure)
        } else {
            self.callShareEmailIDAPI()
        }
        
    }
    
    @objc func btnSkipNextTapped(_sender:UIButton){
        self.view.endEditing(true)
        self.moveToBackDashBoard()
    }
    
    func moveToBackDashBoard() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func callShareEmailIDAPI(){
        self.showActivityIndicator(self.view)
        if Reachability.isConnectedToNetwork() == true {
            AppSession.shared.setCurrentDeviceToken("")
            SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
            MobileApiAPI.apiMobileApiSharedHomeDevicePost(email: self.txtChangeEmail?.text ?? "", deviceId: Int64(self.isFromInitialCurrentDeviceID)) { (responses, error) in
                self.hideActivityIndicator(self.view)
                if responses?.success == true {
                    self.showShareDataAlert(message: responses?.message ?? "")
                    if self.isFromInitialAddDevice == true {
                        self.moveToBackDashBoard()
                    }
                }else {
                    self.showShareDataAlert(message: responses?.message ?? "")
                }
            }
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            UIApplication.shared.endIgnoringInteractionEvents()
            self.hideActivityIndicator(self.view)
        }
    }
    
    func showShareDataAlert(message:String) {
        let titleString = NSAttributedString(string: LUFT_APP_NAME, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            
        })
        alert.addAction(ok)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}
