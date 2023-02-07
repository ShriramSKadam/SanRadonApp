//
//  ForgotpPasswordViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: LTViewController {

    @IBOutlet weak var txtEmail: LTCommonTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtEmail.keyboardType = .emailAddress
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension  ForgotPasswordViewController {
    
    @IBAction func btnTapTempPassword(_ sender: Any) {
        self.view.endEditing(true)
        let userEmail = removeWhiteSpace(text: self.txtEmail.text ?? "")
        let password = removeWhiteSpace(text:"Admin@12")
        let isValidated = self.validate(emailId: userEmail, password: password)
        if isValidated.0 == true {
            if Reachability.isConnectedToNetwork() == true {
                self.showActivityIndicator(self.view)
                MobileApiAPI.apiMobileApiSendTemporaryPasswordGet(email: userEmail, completion: { (response, error) in
                    self.hideActivityIndicator(self.view)
                    if error == nil && (response?.success ?? false) == true {
                        let pushToVC: ResetPasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
                        pushToVC.userEmailID = userEmail
                        self.navigationController?.pushViewController(pushToVC, animated: true)
                    }else {
                        Helper().showSnackBarAlert(message: response?.message ?? "Something went wrong while retrieving information. Please try again later.", type: .Failure)
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
        return (isValidationSuccess, message)
    }
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
