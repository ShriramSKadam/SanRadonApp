//
//  TemperatureViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class TemperatureViewController:LTSettingBaseViewController {
    
    @IBOutlet weak var btnTMPEEFahrenhit: UIButton!
    @IBOutlet weak var imgViewTMPEEFahrenhit: LTCellView!
    @IBOutlet weak var btnTMPEECelsius: UIButton!
    @IBOutlet weak var imgViewTMPEETMPEECelsius: LTCellView!
    var tempunitsNotifiMobileUserSetting: AppUserMobileDetails? = nil
    
    @IBOutlet weak var imgDataViewTMPEEFahrenhit: UIImageView!
    @IBOutlet weak var imgDataViewTMPEETMPEECelsius: UIImageView!
    var tempType:Int64 = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnTMPEEFahrenhit.addTarget(self, action:#selector(self.btnTapFahrenhitBtn(_sender:)), for: .touchUpInside)
        self.btnTMPEECelsius.addTarget(self, action:#selector(self.btnTapCelsiusBtn(_sender:)), for: .touchUpInside)
        self.loadTemperatureStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tempunitsNotifiMobileUserSetting = nil
    }
    
    func loadTemperatureStatus()  {
        if AppSession.shared.getMobileUserMeData()?.temperatureUnitTypeId == 1{
           self.selectedTempUnitsPeriod(selected: 1)
        }else {
            self.selectedTempUnitsPeriod(selected: 2)
        }
        self.tempType = self.tempunitsNotifiMobileUserSetting?.temperatureUnitTypeId ?? 100
    }
}
extension TemperatureViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
        
    }
    
    @IBAction func btnTapTMPEESaveBtn(_sender:UIButton) {
        self.callSaveUserMeApi()
    }
    
    @objc func btnTapFahrenhitBtn(_sender:UIButton) {
        self.selectedTempUnitsPeriod(selected: 1)
    }
    
    @objc func btnTapCelsiusBtn(_sender:UIButton) {
        self.selectedTempUnitsPeriod(selected: 2)
    }
    
    func selectedTempUnitsPeriod(selected:Int)  {
        self.imgViewTMPEEFahrenhit.isHidden = false
        self.imgViewTMPEETMPEECelsius.isHidden = false
        switch selected {
        case 1:
            self.imgDataViewTMPEEFahrenhit.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.imgDataViewTMPEETMPEECelsius.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.tempunitsNotifiMobileUserSetting?.temperatureUnitTypeId = 1
        case 2:
            self.imgDataViewTMPEEFahrenhit.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.imgDataViewTMPEETMPEECelsius.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.tempunitsNotifiMobileUserSetting?.temperatureUnitTypeId = 2
        default:
            print("Fallback option")
        }
    }
    
    func callSaveUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            AppUserAPI.apiAppUserUpdateMobileUserPost(user: self.tempunitsNotifiMobileUserSetting, completion: { (error) in
                self.hideActivityIndicator(self.view)
                if error == nil {
                    AppSession.shared.setMobileUserMeData(mobileSettingData: self.tempunitsNotifiMobileUserSetting!)
                    Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
                    self.navigationController?.popViewController(animated: true)
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            })
            
        }else {
            Helper.shared.showSnackBarAlert(message: NETWORK_CONNECTION, type: .Failure)
        }
    }
}
extension TemperatureViewController {
   
    
    func backCompareValues() -> Bool{
        if self.tempType != self.tempunitsNotifiMobileUserSetting?.temperatureUnitTypeId {
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
