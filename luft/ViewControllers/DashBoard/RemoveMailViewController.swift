//
//  RemoveMailViewController.swift
//  luft
//
//  Created by iMac Augusta on 11/4/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class RemoveMailViewController: LTViewController {

    
    @IBOutlet weak var lblChangeEmail: LTHeaderTitleLabel!
    @IBOutlet weak var lblEmail: LTCellTitleLabel!
    @IBOutlet weak var btnShareEmailRemove: UIButton!
    
    var currentDeviceID:Int = 0
    var currentDeviceToken:String = ""
    var currentEmailID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblChangeEmail?.text = self.currentEmailID
        self.btnShareEmailRemove.addTarget(self, action:#selector(self.btnShareEmailRemoveTap(_sender:)), for: .touchUpInside)
        self.lblEmail?.textColor = ThemeManager.currentTheme().ltCellRedTitleColor
    }

}
extension RemoveMailViewController: DeviceMEAPIDelegate {
    
    func deviceDataAPIStatus(update: Bool) {
        self.hideActivityIndicator(self.view)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func btnShareEmailRemoveTap(_sender:UIButton) {
        self.showToRemoveUserEMAILDevice()
    }
    
    func showToRemoveUserEMAILDevice() {
        let titleString = NSAttributedString(string: "Remove", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let messageString = NSAttributedString(string: "Are you sure you would like to remove this user?", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : ThemeManager.currentTheme().ltCellTitleColor])
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.setValue(messageString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.removeDeviceAPIEMAIL()
        })
        alert.addAction(ok)
        let cancel = UIAlertAction(title: "No", style: .default, handler: { action in
            
        })
        alert.addAction(cancel)
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
    func removeDeviceAPIEMAIL()  {
        self.showActivityIndicator(self.view)
        SwaggerClientAPI.customHeaders = HttpManager.sharedInstance.getDefaultHeaderDetails()
        MobileApiAPI.apiMobileApiDeleteSharedHomeDevicePost(deviceId: Int64(self.currentDeviceID), email: self.currentEmailID, completion: { (responses, error) in
            self.hideActivityIndicator(self.view)
            AppSession.shared.setIsConnectedWifi(iswifi:true)
            if responses?.success ==  true {
                //self.callMyDeviceAPI()
                self.hideActivityIndicator(self.view)
                self.navigationController?.popToRootViewController(animated: true)
            }else {
                //Helper.shared.showSnackBarAlert(message: responses?.message ?? "", type: .Failure)
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    func callMyDeviceAPI()  {
        self.showActivityIndicator(self.view)
        APIManager.shared.myDeviceDelegate = self
        APIManager.shared.callDeviceDetailsTypeApi(isUpdateDummy: true)
    }
}
