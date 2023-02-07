//
//  ResetPasswordViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

protocol LTDismissDelegate:class {
    func moveLoginView(isUpdate:Bool)
}



class ResetPasswordViewController: LTViewController {
    
    @IBOutlet weak var txtTempPassword: LTCommonTextField!
    @IBOutlet weak var txtPassword: LTCommonTextField!
    @IBOutlet weak var txtConfirmPassword: LTCommonTextField!
    @IBOutlet weak var btnBackSignin: UIButton!
    
    var isFromSetting:Bool = false
    var isPasswordHideReset: Bool = true
    var isConfirmPasswordHideReset: Bool = true
    var isTempPasswordHideReset: Bool = true
    
    var dismissDelegate: LTDismissDelegate? = nil
    var userEmailID: String = ""
    @IBOutlet weak var btnPasswordShowReset: UIButton!
    @IBOutlet weak var btnConfirmPasswordShowReset: UIButton!
    @IBOutlet weak var btnTempPasswordShowReset: UIButton!
    var pwdHelper: AUPasswordFieldHelper = AUPasswordFieldHelper.init(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnPasswordShowReset.addTarget(self, action: #selector(self.showPasswordHintAlertReset(sender:)), for: .touchUpInside)
        self.btnConfirmPasswordShowReset.addTarget(self, action: #selector(self.showConfirmPasswordHintAlertReset(sender:)), for: .touchUpInside)
        self.btnTempPasswordShowReset.addTarget(self, action: #selector(self.btnTempPasswordShowResetTap(sender:)), for: .touchUpInside)
        
        self.txtPassword.isSecureTextEntry = self.isPasswordHideReset
        self.txtConfirmPassword.isSecureTextEntry = self.isConfirmPasswordHideReset
        self.txtTempPassword.isSecureTextEntry = self.isTempPasswordHideReset
        
        self.btnBackSignin.isHidden = false
        
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self
        txtTempPassword.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pwdHelper = AUPasswordFieldHelper.init(frame: self.txtPassword.frame)
        pwdHelper.minimumCharLimit = 8
        pwdHelper.maximumCharLimit = 16
        pwdHelper.configurePasswordHelper(textField: self.txtPassword, position: .top, isAutoEnable: true, isInsideTableView: false, superView: self.view, cell: nil, itemsNeeded: [.lowerCaseNeeded,.upperCaseNeeded,.minMaxCharacterLimit, .numericNeeded, .noBlankSpace, .specialCharNeeded], tickImage: UIImage.init(named: "check_tick")!, unTickImage: UIImage.init(named: "check_round")!)
    }
}

extension  ResetPasswordViewController {
    
    
    @objc func showPasswordHintAlertReset(sender: UIButton) {
        let eyeOpen = UIImage(named: "icon_eye_open")
        let eyeClose = UIImage(named: "icon_eye_hide")
        self.isPasswordHideReset = !self.isPasswordHideReset
        let image = self.isPasswordHideReset ? eyeClose : eyeOpen
        self.btnPasswordShowReset.setImage(image, for: .normal)
        self.txtPassword.isSecureTextEntry = self.isPasswordHideReset
        self.btnPasswordShowReset.layoutIfNeeded()
        Helper.shared.togglePasswordVisibility(textFiled: self.txtPassword)
    }
    
    @objc func showConfirmPasswordHintAlertReset(sender: UIButton) {
        let eyeOpen = UIImage(named: "icon_eye_open")
        let eyeClose = UIImage(named: "icon_eye_hide")
        self.isConfirmPasswordHideReset = !self.isConfirmPasswordHideReset
        let image = self.isConfirmPasswordHideReset ? eyeClose : eyeOpen
        self.btnConfirmPasswordShowReset.setImage(image, for: .normal)
        self.txtConfirmPassword.isSecureTextEntry = self.isConfirmPasswordHideReset
        self.btnConfirmPasswordShowReset.layoutIfNeeded()
        Helper.shared.togglePasswordVisibility(textFiled: self.txtConfirmPassword)
    }
    
    @objc func btnTempPasswordShowResetTap(sender: UIButton) {
        let eyeOpen = UIImage(named: "icon_eye_open")
        let eyeClose = UIImage(named: "icon_eye_hide")
        self.isTempPasswordHideReset = !self.isTempPasswordHideReset
        let image = self.isTempPasswordHideReset ? eyeClose : eyeOpen
        self.btnTempPasswordShowReset.setImage(image, for: .normal)
        self.txtTempPassword.isSecureTextEntry = self.isTempPasswordHideReset
        self.btnTempPasswordShowReset.layoutIfNeeded()
        Helper.shared.togglePasswordVisibility(textFiled: self.txtTempPassword)
    }
    
    func btnResetSaveAPI() {
        self.view.endEditing(true)
        let userEmail = removeWhiteSpace(text:userEmailID)
        let password = removeWhiteSpace(text: self.txtPassword?.text ?? "")
        let tempPassword = removeWhiteSpace(text: self.txtTempPassword?.text ?? "")
        let isValidated = self.validate(emailId: userEmail, password: password)
        if isValidated.0 == true {
            if Reachability.isConnectedToNetwork() == true {
                self.showActivityIndicator(self.view)
                print(tempPassword)
                print(password)
                let changePassowrdModel = ChangePasswordWithTempPasswordViewModel.init(email: userEmailID, tempPassword: tempPassword, newPassword: password)
                MobileApiAPI.apiMobileApiChangePasswordUsingTempPasswordPost(model: changePassowrdModel,completion: { (response, error) in
                    self.hideActivityIndicator(self.view)
                    if response?.success == true {
                        self.moveToLoginBorad()
                    }else {
                        Helper().showSnackBarAlert(message: response?.message ?? "", type: .Failure)
                    }
                })
            }else {
                Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
            }
        }else {
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
        else if Helper.shared.isCheckForValidPassword(textString: password) == false {
            message = CONTENT_CHAR_PASSWORD
            isValidationSuccess = false
        }
        else if password != self.txtConfirmPassword.text {
            message = CONTENT_MISMATCH_PASSWORD
            isValidationSuccess = false
        }
        return (isValidationSuccess, message)
    }
    
    @IBAction func btnTapLogIn(_ sender: Any) {
        self.btnResetSaveAPI()
    }
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if isFromSetting == true  {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func moveToLoginBorad(){
        if isFromSetting == true  {
            self.navigationController?.popViewController(animated: false)
            self.dismissDelegate?.moveLoginView(isUpdate: false)
            isShowBackBtnSignin = true
        }else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
}

extension ResetPasswordViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                    
            let stringVal = NSString(string: textField.text!)
            let newText = stringVal.replacingCharacters(in: range, with: string)
            
            
            if textField == txtConfirmPassword || textField == txtPassword{
                
               let cs = NSCharacterSet(charactersIn: ACCEPTABLE_CHARACTERS_PASSWORD).inverted
                let filtered = string.components(separatedBy: cs).joined(separator: "")
                if (string == filtered){
                     if newText.containsEmoji{
                                   return false
                               }
                     else{
                        return true
                    }
                }else{
                    return false
                }
            }
            
           
            
            return true
            
        }
}
