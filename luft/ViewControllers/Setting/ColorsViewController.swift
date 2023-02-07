//
//  ColorsViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class ColorsViewController:UIViewController, LTIntialAGREEDelegate {
    func selectedIntialAGREE() {
        print("ios")
    }
    
    var isFromInitialAddDevice:Bool = false
    @IBOutlet weak var btnNextSkip: UIButton!
    @IBOutlet weak var btnColorsViewBack: UIButton!
    @IBOutlet weak var GetMoreHelp: UIButton!
    var isFromInitialSelectedDeviceID:Int = 0
    var isFromInitialSelectedDeviceTokenColor:String = ""
    var avilableDeviceSharedEMailIsfromAddDeviceColor:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnNextSkip.addTarget(self, action:#selector(self.btnNextSkipTapped(_sender:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tabBarController?.tabBar.isHidden = true
        }
        if self.isFromInitialAddDevice == true {
            self.btnColorsViewBack.isHidden = true
            self.btnNextSkip?.isHidden = false
        }
    }
    
    @IBAction func GetMoreHelp(_ sender: Any) {
        self.moveToWebView()
    }
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
        webdataView.Urltodisplay = Colours_Url
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = "colors"
        webdataView.strTitle = "colors"
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .pageSheet
        self.present(webdataView, animated: false, completion: nil)
    }
    
    @objc func btnNextSkipTapped(_sender:UIButton) {
        
        if self.avilableDeviceSharedEMailIsfromAddDeviceColor.count != 0 {
            self.btnNextSkip.titleLabel?.text = ""
            self.navigationController?.popToRootViewController(animated: false)
        }else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewControllerMenu = mainStoryboard.instantiateViewController(withIdentifier: "ShareEmailViewController") as! ShareEmailViewController
            viewControllerMenu.isFromInitialAddDevice = true
            viewControllerMenu.isFromInitialCurrentDeviceID = self.isFromInitialSelectedDeviceID
            viewControllerMenu.isFromInitialCurrentDeviceToken = self.isFromInitialSelectedDeviceTokenColor
            self.navigationController?.pushViewController(viewControllerMenu, animated: false)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //        self.btnNextSkip?.isHidden = true
        //        if self.isFromInitialAddDevice == true {
        //            self.btnNextSkip?.isHidden = false
        //        }
    }
    
}
extension ColorsViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
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
    
    @IBAction func btnTapOKBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorsOKViewController") as! ColorsOKViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    @IBAction func btnTapWarningBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorsWarningViewController") as! ColorsWarningViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    @IBAction func btnTapAlertBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorsAlertViewController") as! ColorsAlertViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
    
    @IBAction func btnTapNightLightBtn(_ sender: Any) {
        let mainTabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorsNightLightViewController") as! ColorsNightLightViewController
        mainTabbar.selectedDeviceID = self.isFromInitialSelectedDeviceID
        mainTabbar.isFromInitialAddDevice = self.isFromInitialAddDevice
        self.navigationController?.pushViewController(mainTabbar, animated: true)
    }
}
