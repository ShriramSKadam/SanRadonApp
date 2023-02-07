//
//  RadonViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class RadonViewController:LTSettingBaseViewController {
    
    @IBOutlet weak var btnRadonpCiI: UIButton!
    @IBOutlet weak var btnRadonBqm3: UIButton!
    @IBOutlet weak var imgViewRadonpCiI: LTCellView!
    @IBOutlet weak var imgViewRadonBqm3: LTCellView!
    @IBOutlet weak var btnRadonSave: UIButton!
    @IBOutlet weak var lblBqm3: LTCellTitleLabel!
    @IBOutlet weak var lblTipRadon: LTSettingHintLabel!

    var radonUnitsNotifiMobileUserSetting: AppUserMobileDetails? = nil
    
    @IBOutlet weak var imgDataViewRadonpCi: UIImageView!
    @IBOutlet weak var imgDataViewRadonBqm3: UIImageView!
    var tempType:Int64 = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnRadonpCiI.addTarget(self, action:#selector(self.btnTapRadonpCiI(_sender:)), for: .touchUpInside)
        self.btnRadonBqm3.addTarget(self, action:#selector(self.btnTapRadonBqm3Btn(_sender:)), for: .touchUpInside)
        self.btnRadonSave.addTarget(self, action:#selector(self.btnTapRadonSaveBtn(_sender:)), for: .touchUpInside)
        self.loadRadonStatus()
        
        
        let numberString1 = NSMutableAttributedString(string: "US EPA standard unit of measure for Radon exposure is pCi/l. International, including Canada and Europe use Bq/m", attributes: [.font: UIFont.setSystemFontRegular(14)])
        numberString1.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 4]))
        numberString1.append(NSAttributedString(string: " as standard.", attributes:[.font: UIFont.setSystemFontRegular(14)]))
        self.lblTipRadon.attributedText = numberString1
       self.lblTipRadon.backgroundColor = ThemeManager.currentTheme().clearColor
       self.lblTipRadon.textColor = ThemeManager.currentTheme().subtitleTextColor
        
        let numberString = NSMutableAttributedString(string: "Bq/m", attributes: [.font: UIFont.setSystemFontRegular(17)])
        numberString.append(NSAttributedString(string: "3", attributes: [.font: UIFont.setSystemFontRegular(14), .baselineOffset: 8]))
        self.lblBqm3.attributedText = numberString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.radonUnitsNotifiMobileUserSetting = nil
    }
    
    func loadRadonStatus()  {
        if AppSession.shared.getMobileUserMeData()?.radonUnitTypeId == 1{
            self.selectedRadonUnitsPeriod(selected: 1)
        }else {
            self.selectedRadonUnitsPeriod(selected: 2)
        }
        self.tempType = self.radonUnitsNotifiMobileUserSetting?.radonUnitTypeId ?? 100
    }
    
}
extension RadonViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @objc func btnTapRadonSaveBtn(_sender:UIButton) {
        self.callSaveUserMeApi()
    }
    
    @objc func btnTapRadonpCiI(_sender:UIButton) {
        self.selectedRadonUnitsPeriod(selected: 2)
    }
    
    @objc func btnTapRadonBqm3Btn(_sender:UIButton) {
        self.selectedRadonUnitsPeriod(selected: 1)
    }
    
    func selectedRadonUnitsPeriod(selected:Int)  {
        
        self.imgViewRadonpCiI.isHidden = false
        self.imgViewRadonBqm3.isHidden = false
        
        switch selected {
        case 1:
            self.imgDataViewRadonpCi.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.imgDataViewRadonBqm3.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.radonUnitsNotifiMobileUserSetting?.radonUnitTypeId = 1
        case 2:
            self.imgDataViewRadonpCi.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.imgDataViewRadonBqm3.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.radonUnitsNotifiMobileUserSetting?.radonUnitTypeId = 2
        default:
            print("Fallback option")
        }
    }
    
    func callSaveUserMeApi(){
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            AppUserAPI.apiAppUserUpdateMobileUserPost(user: self.radonUnitsNotifiMobileUserSetting, completion: { (error) in
                self.hideActivityIndicator(self.view)
                if error == nil {
                    AppSession.shared.setMobileUserMeData(mobileSettingData: self.radonUnitsNotifiMobileUserSetting!)
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

extension RadonViewController {
    
    
    func backCompareValues() -> Bool{
        if self.tempType != self.radonUnitsNotifiMobileUserSetting?.radonUnitTypeId {
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
