//
//  SignUpViewController.swift
//  luft
//
//  Created by Augusta on 09/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

let ACCEPTABLE_CHARACTERS_PASSWORD = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$@$!%*?&"

class SignUpViewController: LTViewController {
    
    let ACCEPTABLE_CHARACTERS_PASSWORD = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$@$!%*?&"

    
    @IBOutlet weak var txtEmailSignUp: LTCommonTextField!
    @IBOutlet weak var txtSignUppassword: LTCommonTextField!
    @IBOutlet weak var txtSignUpConfirmPassword: LTCommonTextField!
    @IBOutlet weak var txtViewTermsPrivacy: UITextView!
    
    var isPasswordHide: Bool = true
    var isConfirmPasswordHide: Bool = true
    @IBOutlet weak var btnPasswordShow: UIButton!
    @IBOutlet weak var btnConfirmPasswordShow: UIButton!
    @IBOutlet weak var btnAlreadyHaveLogin: UIButton!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var imgViewDisclosureCell: LTCellDisclosureImageView!
    var pwdHelper: AUPasswordFieldHelper = AUPasswordFieldHelper.init(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnPasswordShow.addTarget(self, action: #selector(self.showPasswordHintAlertSignUp(sender:)), for: .touchUpInside)
        self.btnConfirmPasswordShow.addTarget(self, action: #selector(self.showConfirmPasswordHintAlertSignUp(sender:)), for: .touchUpInside)
        self.btnAlreadyHaveLogin.addTarget(self, action:#selector(self.btnAlreadyHaveLoginTap(_sender:)), for: .touchUpInside)
        self.btnCheckBox.addTarget(self, action:#selector(self.btnCheckBoxTap(_sender:)), for: .touchUpInside)
        
        self.txtSignUppassword.isSecureTextEntry = self.isPasswordHide
        self.txtSignUpConfirmPassword.isSecureTextEntry = self.isPasswordHide
        self.txtEmailSignUp.delegate = self
        self.txtEmailSignUp.keyboardType = .emailAddress
        self.btnCheckBox.isSelected = true
        
        txtSignUppassword.delegate = self
        txtSignUpConfirmPassword.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.btnCheckBox.isSelected = false
        self.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        if AppSession.shared.isKeyPresentInUserDefaults(key: "SortFilterTypeEnum") == false{
            AppSession.shared.setUserSortFilterType(sortfilterType:1)
        }
        super.viewWillAppear(animated)
        self.txtViewTermsPrivacy.delegate = self
        self.txtViewTermsPrivacy.hyperLink(originalText: "I have read and understand SunRADON's privacy policy", hyperLink1: "privacy policy", hyperLink2: "", urlString1: TERMS_AND_CONDTIONS,urlString2: PRIVACY_POLICY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pwdHelper = AUPasswordFieldHelper.init(frame: self.txtSignUppassword.frame)
        pwdHelper.minimumCharLimit = 8
        pwdHelper.maximumCharLimit = 16
        pwdHelper.configurePasswordHelper(textField: self.txtSignUppassword, position: .top, isAutoEnable: true, isInsideTableView: false, superView: self.view, cell: nil, itemsNeeded: [.lowerCaseNeeded,.upperCaseNeeded,.minMaxCharacterLimit, .numericNeeded, .noBlankSpace, .specialCharNeeded], tickImage: UIImage.init(named: "check_tick")!, unTickImage: UIImage.init(named: "check_round")!)
    }
    
}

extension  SignUpViewController:UITextViewDelegate,UITextFieldDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if (URL.absoluteString == TERMS_AND_CONDTIONS) {
            let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController") as! WebDataViewController
            webdataView.lblHeader?.text = TERMS_AND_CONDITIONS_TITLE
            webdataView.strTitle = PRIVACY_POLICY_TITLE
            self.navigationController?.pushViewController(webdataView, animated: false)
        }
        else if (URL.absoluteString == PRIVACY_POLICY) {
            let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController") as! WebDataViewController
            webdataView.lblHeader?.text = PRIVACY_POLICY_TITLE
            webdataView.strTitle = PRIVACY_POLICY_TITLE
            self.navigationController?.pushViewController(webdataView, animated: false)
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.placeHolderColor = UIColor.red
        return true
    }
    
}
extension  SignUpViewController: LTIntialAGREEDelegate {
    
    
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnTapSignUp(_ sender: Any) {
        self.callSignUpApi()
    }
    
    @objc func showPasswordHintAlertSignUp(sender: UIButton) {
        let eyeOpen = UIImage(named: "icon_eye_open")
        let eyeClose = UIImage(named: "icon_eye_hide")
        self.isPasswordHide = !self.isPasswordHide
        let image = self.isPasswordHide ? eyeClose : eyeOpen
        self.btnPasswordShow.setImage(image, for: .normal)
        self.txtSignUppassword.isSecureTextEntry = self.isPasswordHide
        self.btnPasswordShow.layoutIfNeeded()
        Helper.shared.togglePasswordVisibility(textFiled: self.txtSignUppassword)
    }
    
    @objc func btnAlreadyHaveLoginTap(_sender:UIButton) {
        let pushToVC: SignInViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        AppSession.shared.setIsShowBack(isShow: true)
        self.navigationController?.pushViewController(pushToVC, animated: true)
    }
    
    @objc func btnCheckBoxTap(_sender:UIButton) {
        
        if _sender.isSelected == true {
            _sender.isSelected = false
            self.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        }else {
            _sender.isSelected = true
            self.imgViewDisclosureCell.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }
    }
    
    @objc func showConfirmPasswordHintAlertSignUp(sender: UIButton) {
        let eyeOpen = UIImage(named: "icon_eye_open")
        let eyeClose = UIImage(named: "icon_eye_hide")
        self.isConfirmPasswordHide = !self.isConfirmPasswordHide
        let image = self.isConfirmPasswordHide ? eyeClose : eyeOpen
        self.btnConfirmPasswordShow.setImage(image, for: .normal)
        self.txtSignUpConfirmPassword.isSecureTextEntry = self.isConfirmPasswordHide
        self.btnConfirmPasswordShow.layoutIfNeeded()
        Helper.shared.togglePasswordVisibility(textFiled: self.txtSignUpConfirmPassword)
    }
    
    func callSignUpApi(){
        self.view.endEditing(true)
        let userEmail = removeWhiteSpace(text: self.txtEmailSignUp.text ?? "")
        let password = removeWhiteSpace(text: self.txtSignUppassword.text ?? "")
        let isValidated = self.validate(emailId: userEmail, password: password)
        
        if isValidated.0 == true {
            self.checkHomeUserExist()
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
        else if password != self.txtSignUpConfirmPassword.text {
            message = CONTENT_MISMATCH_PASSWORD
            isValidationSuccess = false
        }
        //        else if self.btnCheckBox.isSelected == false {
        //            message = CONTENT_INVALID_TERMS_PRIVACY
        //            isValidationSuccess = false
        //        }
        return (isValidationSuccess, message)
    }
    
    func moveToLoginBorad() {
        let signInView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        AppSession.shared.setIsShowBack(isShow: true)
        self.navigationController?.pushViewController(signInView, animated: true)
    }
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController") as! WebDataViewController
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = PRIVACY_POLICY_TITLE
        webdataView.strTitle = PRIVACY_POLICY_TITLE
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .overFullScreen
        self.present(webdataView, animated: false, completion: nil)
    }
    
    func selectedIntialAGREE() {
        if Reachability.isConnectedToNetwork() == true {
            showActivityIndicator(self.view)
            let userEmail = removeWhiteSpace(text: self.txtEmailSignUp.text ?? "")
            let password = removeWhiteSpace(text: self.txtSignUppassword.text ?? "")
            let registerModel = RegisterUserViewModel.init(name: "", email: userEmail, mobile: "", password: password)
            MobileApiAPI.apiMobileApiRegisterPost(model: registerModel, completion: { (response, error) in
                self.hideActivityIndicator(self.view)
                if response?.success == true {
                    let titleString = NSAttributedString(string: "Sign Up Success", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
                    let message = String(format: "Account validation link has been sent to your registered mail address. Please validate to access the application")
                    let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
                    let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                    alert.setValue(titleString, forKey: "attributedTitle")
                    alert.setValue(messageString, forKey: "attributedMessage")
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.moveToLoginBorad()
                    })
                    alert.addAction(ok)
                    alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
                    DispatchQueue.main.async(execute: {
                        self.present(alert, animated: true)
                    })
                }else if response?.success == false {
                    //Helper().showSnackBarAlert(message: response?.message ?? "", type: .Failure)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }else { // New Good
                    //Helper().showSnackBarAlert(message: response?.message ?? "", type: .Failure)
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)

                }
            })
        }
        else{
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
    
    func checkHomeUserExist() {
        if Reachability.isConnectedToNetwork() == true {
            showActivityIndicator(self.view)
            let userEmail = removeWhiteSpace(text: self.txtEmailSignUp.text ?? "")
            MobileApiAPI.apiMobileApiCheckHomeUserAlreadyExistGet(email: userEmail, completion: { (response, error) in
                
                self.hideActivityIndicator(self.view)
                if response?.success == true {
                    self.moveToWebView()
                }else if response?.success == false {
                    if response?.errorCode == EXISTSPROFESSONALUSER {
                        let titleString = NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
                        let message = String(format: response?.message ?? "")
                        let messageString = NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
                        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
                        alert.setValue(titleString, forKey: "attributedTitle")
                        alert.setValue(messageString, forKey: "attributedMessage")
                       
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: { action in
                            self.moveToWebView()
                        })
                        alert.addAction(ok)
                        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
                        DispatchQueue.main.async(execute: {
                            self.present(alert, animated: true)
                        })
                    }else {
                        Helper.shared.showSnackBarAlert(message: response?.message ?? "", type: .Failure)
                    }
                }else { // New Good
                    Helper().showSnackBarAlert(message: response?.message ?? "", type: .Failure)
                }
            })
        }
        else{
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}

extension UITextView {
    
    
    func hyperLink(originalText: String, hyperLink1: String, hyperLink2: String,urlString1: String,urlString2: String) {
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        
        let attributedOriginalText = NSMutableAttributedString(string: originalText)
        let linkRange1 = attributedOriginalText.mutableString.range(of: hyperLink1)
        let linkRange2 = attributedOriginalText.mutableString.range(of: hyperLink2)
        let fullRange = NSMakeRange(0, attributedOriginalText.length)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString1, range: linkRange1)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: urlString2, range: linkRange2)
        attributedOriginalText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: linkRange1)
        attributedOriginalText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: linkRange2)
        attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: ThemeManager.currentTheme().titleTextColor, range: fullRange)
        attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont.setAppFontRegular(14), range: fullRange)
        
        self.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor.rawValue  : UIColor.blue,
            NSAttributedString.Key.underlineStyle.rawValue  : NSUnderlineStyle.single.rawValue
            ] as? [NSAttributedString.Key:Any]
        
        self.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.attributedText = attributedOriginalText
    }
    
    
}


extension SignUpViewController{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                    
            let stringVal = NSString(string: textField.text!)
            let newText = stringVal.replacingCharacters(in: range, with: string)
            
            
            if textField == txtSignUppassword || textField == txtSignUpConfirmPassword{
                
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
