//
//  UnitsViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class UnitsViewController:UIViewController, LTIntialAGREEDelegate {
    func selectedIntialAGREE() {
        print("mani")
    }
    
    @IBOutlet weak var btnUnitsSkip: UIButton!
    @IBOutlet weak var btnUnitsBack: UIButton!
    
    var unitsNotifiMobileUserSetting: AppUserMobileDetails? = nil
    var isFromInitialAddDevice:Bool = false
    @IBOutlet weak var Getmorehelpbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnUnitsSkip.addTarget(self, action:#selector(self.btnUnitsSkipTapped(_sender:)), for: .touchUpInside)
        self.btnUnitsSkip?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        if self.isFromInitialAddDevice == true {
            self.btnUnitsBack.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isFromInitialAddDevice == true {
            self.btnUnitsSkip?.isHidden = false
            self.btnUnitsSkip?.titleLabel?.text = "Next"
        }
    }
    
    @objc func btnUnitsSkipTapped(_sender:UIButton) {
        self.moveToNotification()
    }
    
    @IBAction func getmorehelpbtn(_ sender: Any) {
        
        self.moveToWebView()
    }
    
    func moveToWebView() {
        let webdataView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebDataViewController2") as! webdata2ViewController
        webdataView.Urltodisplay = UNITS_URL
        webdataView.isFromIntial = true
        webdataView.lblHeader?.text = UNITS
        webdataView.strTitle = UNITS
        webdataView.delegateIntailAgree = self
        webdataView.modalPresentationStyle = .pageSheet
        self.present(webdataView, animated: false, completion: nil)
    }
    func moveToNotification() {
        let notificationView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        notificationView.isFromInitialAddDevice = true
        notificationView.notificationMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.navigationController?.pushViewController(notificationView, animated: true)
    }
    
}
extension UnitsViewController {
    
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
    
    @IBAction func btnTapTemperature(_ sender: Any) {
        let tempunitsNotifi = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TemperatureViewController") as! TemperatureViewController
        tempunitsNotifi.tempunitsNotifiMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.navigationController?.pushViewController(tempunitsNotifi, animated: true)
    }
    
    @IBAction func btnTapAirPressure(_ sender: Any) {
        let airPressureView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AirPressureViewController") as! AirPressureViewController
        airPressureView.airpreunitsNotifiMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.navigationController?.pushViewController(airPressureView, animated: true)
    }
    
    @IBAction func btnTapRadon(_ sender: Any) {
        let radonView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RadonViewController") as! RadonViewController
        radonView.radonUnitsNotifiMobileUserSetting = AppSession.shared.getMobileUserMeData()?.copy() as? AppUserMobileDetails
        self.navigationController?.pushViewController(radonView, animated: true)
    }
    
}
