//
//  ShareDataEmailViewController.swift
//  luft
//
//  Created by iMac Augusta on 11/2/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class ShareDataEmailViewController: LTViewController {
    
    @IBOutlet weak var lblChangeEmail: LTCellTitleLabel!
    @IBOutlet weak var btnShareEmailSave: UIButton!
    @IBOutlet weak var btnShareEmailRemove: UIButton!
    @IBOutlet weak var imgViewShareEmailRemove: UIImageView!
    
    var currentDeviceID:Int = 0
    var currentEmailID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnShareEmailSave.addTarget(self, action:#selector(self.btnShareEmailSaveTap(_sender:)), for: .touchUpInside)
        self.btnShareEmailRemove.addTarget(self, action:#selector(self.btnShareEmailRemoveTap(_sender:)), for: .touchUpInside)
        self.btnShareEmailSave.isHidden = true
        self.imgViewShareEmailRemove.image = UIImage.init(named: CELL_DISCLOUSRE)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.tabBarController?.tabBar.isHidden = true
        self.lblChangeEmail?.text = self.currentEmailID
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
}
extension ShareDataEmailViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnShareEmailSaveTap(_sender:UIButton) {
        self.view.endEditing(true)
    }
    
    @objc func btnShareEmailRemoveTap(_sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcRemoveMail = storyboard.instantiateViewController(withIdentifier: "RemoveMailViewController") as! RemoveMailViewController
        vcRemoveMail.currentDeviceID = self.currentDeviceID
        vcRemoveMail.currentEmailID = self.currentEmailID
        self.navigationController?.pushViewController(vcRemoveMail, animated: false)
    }

}
