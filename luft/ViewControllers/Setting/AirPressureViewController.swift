//
//  AirPressureViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class AirPressureViewController:LTSettingBaseViewController {
    
    @IBOutlet weak var btnAIRPkPa: UIButton!
    @IBOutlet weak var imgViewAIRPkPa: LTCellView!
    @IBOutlet weak var btnAIRPinHg: UIButton!
    @IBOutlet weak var imgViewAIRPinHg: LTCellView!
    @IBOutlet weak var btnAirPressureSave: UIButton!
    var airpreunitsNotifiMobileUserSetting: AppUserMobileDetails? = nil
    
    @IBOutlet weak var imgDataViewAIRPkPa: UIImageView!
    @IBOutlet weak var imgDataViewAIRPinHg: UIImageView!
    var tempType:Int64 = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnAIRPkPa.addTarget(self, action:#selector(self.btnTapAIRPkPaBtn(_sender:)), for: .touchUpInside)
        self.btnAIRPinHg.addTarget(self, action:#selector(self.btnTapAIRPinHgBtn(_sender:)), for: .touchUpInside)
        self.btnAirPressureSave.addTarget(self, action:#selector(self.btnTapAirPressureSaveBtn(_sender:)), for: .touchUpInside)
        self.loadAirPressureStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.airpreunitsNotifiMobileUserSetting = nil
    }
    
    func loadAirPressureStatus()  {
        if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
            self.selectedAIRPREUnitsPeriod(selected: 2)
        }else {
            self.selectedAIRPREUnitsPeriod(selected: 1)
        }
        self.tempType = self.airpreunitsNotifiMobileUserSetting?.pressureUnitTypeId ?? 100
    }
}
extension AirPressureViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnTapAirPressureSaveBtn(_sender:UIButton) {
        self.callSaveUserMeApi()
    }
    
    @objc func btnTapAIRPkPaBtn(_sender:UIButton) {
        self.selectedAIRPREUnitsPeriod(selected: 1)
    }
    @objc func btnTapAIRPinHgBtn(_sender:UIButton) {
        self.selectedAIRPREUnitsPeriod(selected: 2)
    }
    
    func selectedAIRPREUnitsPeriod(selected:Int)  {
        
        self.imgViewAIRPkPa.isHidden = false
        self.imgViewAIRPinHg.isHidden = false
        
        switch selected {
        case 1:
            self.imgDataViewAIRPkPa.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.imgDataViewAIRPinHg.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.airpreunitsNotifiMobileUserSetting?.pressureUnitTypeId = 1
        case 2:
            self.imgDataViewAIRPkPa.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.imgDataViewAIRPinHg.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.airpreunitsNotifiMobileUserSetting?.pressureUnitTypeId = 2
        default:
            print("Fallback option")
        }
    }
    
    func callSaveUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            AppUserAPI.apiAppUserUpdateMobileUserPost(user: self.airpreunitsNotifiMobileUserSetting, completion: { (error) in
                self.hideActivityIndicator(self.view)
                if error == nil {
                    AppSession.shared.setMobileUserMeData(mobileSettingData: self.airpreunitsNotifiMobileUserSetting!)
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
extension AirPressureViewController {
    
    
    func backCompareValues() -> Bool{
        if self.tempType != self.airpreunitsNotifiMobileUserSetting?.pressureUnitTypeId {
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
