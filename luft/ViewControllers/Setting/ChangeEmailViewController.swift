//
//  ChangeEmailViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class ChangeEmailViewController: UIViewController {
    
    @IBOutlet weak var txtChangeEmail: LTSettingTextFiled!
    var prevEmailID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let appUserSettingChangeName:AppUser = AppSession.shared.getMEAPIData() {
            self.txtChangeEmail?.text = appUserSettingChangeName.email ?? ""
        }
        self.txtChangeEmail?.isUserInteractionEnabled = false
        self.txtChangeEmail?.clearButtonMode = UITextField.ViewMode.never
        self.prevEmailID = self.txtChangeEmail?.text ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
    }
    
}
extension ChangeEmailViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
//        if self.backCompareValues() {
//            
//        }else {
//            self.backValidationAlert()
//        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChangeEmailViewController {
    
    func backCompareValues() -> Bool{
        if self.prevEmailID != self.txtChangeEmail?.text ?? "" {
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
           // self.callSaveUserMeApi()
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

