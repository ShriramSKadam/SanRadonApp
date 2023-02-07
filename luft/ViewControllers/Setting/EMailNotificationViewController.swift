//
//  EMailNotificationViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import TagListView

class EMailNotificationViewController:LTSettingBaseViewController {
    
    @IBOutlet weak var txtEMNotEmailAddress: LTSettingTextFiled!
    @IBOutlet weak var btnTXSave: UIButton!
    @IBOutlet weak var btnEMNotDaily: UIButton!
    @IBOutlet weak var btnEMNotWeekly: UIButton!
    @IBOutlet weak var btnEMNotMonthly: UIButton!
    @IBOutlet weak var imgViewEMNotWeekly: LTCellView!
    @IBOutlet weak var imgViewEMNotDaily: LTCellView!
    @IBOutlet weak var imgViewEMNotMonthly: LTCellView!
    
    @IBOutlet weak var SwitchEMNotEmail: UISwitch!
    @IBOutlet weak var SwitchEMNotWarning: UISwitch!
    @IBOutlet weak var SwitchEMNotSummary: UISwitch!
    
    @IBOutlet weak var viewEMNotWeekly: LTCellView!
    @IBOutlet weak var viewEMNotDaily: LTCellView!
    @IBOutlet weak var viewEMNotMonthly: LTCellView!
    
    @IBOutlet weak var summaryNotificationHeight: NSLayoutConstraint!
    @IBOutlet weak var outageNotificationHeight: NSLayoutConstraint!
    @IBOutlet weak var alertNotificationHeight: NSLayoutConstraint!

    //@IBOutlet weak var bottomConstraintHeight: NSLayoutConstraint!
    // @IBOutlet weak var emailEntryViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var warningStackView: UIStackView!
    @IBOutlet weak var summeryStackView: UIStackView!
    @IBOutlet weak var outageStackView: UIStackView!
    @IBOutlet weak var alertStackView: UIStackView!

    @IBOutlet weak var imgDataViewEMNotWeekly: UIImageView!
    @IBOutlet weak var imgDataViewEMNotDaily: UIImageView!
    @IBOutlet weak var imgDataViewEMNotMonthly: UIImageView!
    
    @IBOutlet weak var emailEntryView: UIView!
    
    @IBOutlet weak var taglistViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tagListView: TagListView!
    
    var emailNotifiMobileUserSetting: AppUserMobileDetails? = nil
    
    var prevEmailNotificationEnable:Bool = false
    var prevWarningNotificationEnable:Bool = false
    var prevSummaryNotificationEnable:Bool = false
    var prevOutageNotificationEnable:Bool = false

    var prevSummaryDaily:Bool = false
    var prevSummaryWeekly:Bool = false
    var prevSummaryMonthly:Bool = false
    
    var prevEmailID:String = ""
    var arrEmail:[String] = []
    var strEmail:String = ""
    
    //New Changes- Feb10,2022
    //Outage Notification
    @IBOutlet weak var SwitchOutageNot: UISwitch!

    @IBOutlet weak var btnEMNotTwoHour: UIButton!
    @IBOutlet weak var btnEMNotSixHour: UIButton!
    @IBOutlet weak var btnEMNotTwelveHour: UIButton!
    @IBOutlet weak var btnEMNotTwentyFourHour: UIButton!
    
    @IBOutlet weak var imgViewEMNotTwoHour: LTCellView!
    @IBOutlet weak var imgViewEMNotSixHour: LTCellView!
    @IBOutlet weak var imgViewEMNotTwelveHour: LTCellView!
    @IBOutlet weak var imgViewEMNotTwentyFourHour: LTCellView!
    
    @IBOutlet weak var viewEMNotTwoHour: LTCellView!
    @IBOutlet weak var viewEMNotSixHour: LTCellView!
    @IBOutlet weak var viewEMNotTwelveHour: LTCellView!
    @IBOutlet weak var viewEMNotTwentyFourHour: LTCellView!

    @IBOutlet weak var imgDataViewEMNotTwoHour: UIImageView!
    @IBOutlet weak var imgDataViewEMNotSixHour: UIImageView!
    @IBOutlet weak var imgDataViewEMNotTwelveHour: UIImageView!
    @IBOutlet weak var imgDataViewEMNotTwentyFourHour: UIImageView!

    var prevSummarySixHour:Bool = false
    var prevSummaryTwoHour:Bool = false
    var prevSummaryTwelveHour:Bool = false
    var prevSummaryTwentyFourHour:Bool = false

    var prevSelectedOutageValue = "0"

    //Alert frequency
    @IBOutlet weak var btnAlertNotHourly: UIButton!
    @IBOutlet weak var btnAlertNotDaily: UIButton!
    @IBOutlet weak var btnAlertNotWeekly: UIButton!
    @IBOutlet weak var btnAlertNotMonthly: UIButton!
    
    @IBOutlet weak var imgViewAlertNotWeekly: LTCellView!
    @IBOutlet weak var imgViewAlertNotDaily: LTCellView!
    @IBOutlet weak var imgViewAlertNotHourly: LTCellView!
    @IBOutlet weak var imgViewAlertNotMonthly: LTCellView!

    @IBOutlet weak var viewAlertNotWeekly: LTCellView!
    @IBOutlet weak var viewAlertNotDaily: LTCellView!
    @IBOutlet weak var viewAlertNotHourly: LTCellView!
    @IBOutlet weak var viewAlertNotMonthly: LTCellView!

    @IBOutlet weak var imgDataViewAlertNotWeekly: UIImageView!
    @IBOutlet weak var imgDataViewAlertNotDaily: UIImageView!
    @IBOutlet weak var imgDataViewAlertNotHourly: UIImageView!
    @IBOutlet weak var imgDataViewAlertNotMonthly: UIImageView!

    var prevAlertHourly:Bool = false
    var prevAlertDaily:Bool = false
    var prevAlertWeekly:Bool = false
    var prevAlertMonthly:Bool = false

    var prevSelectedAlertValue = "0"
   //Enabled/Diabled added 34857- Gauri
    //LTCellTitleLabel
    @IBOutlet weak var lblEnbOutageNot: LTCellTitleLabel!
    @IBOutlet weak var lblEnbAlertNot: LTCellTitleLabel!
    @IBOutlet weak var lblEnbIAQNot: LTCellTitleLabel!

    var arrBackStatus:[String] = []

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.switchControls()
        self.imgViewEMNotDaily.isHidden = false
        self.imgViewEMNotWeekly.isHidden = false
        self.imgViewEMNotMonthly.isHidden = false
        self.txtEMNotEmailAddress?.delegate = self
        self.txtEMNotEmailAddress?.keyboardType = .emailAddress
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Summary
        self.btnEMNotDaily.addTarget(self, action:#selector(self.btnTapDailyBtn(_sender:)), for: .touchUpInside)
        self.btnEMNotWeekly.addTarget(self, action:#selector(self.btnTapWeeklyBtn(_sender:)), for: .touchUpInside)
        self.btnEMNotMonthly.addTarget(self, action:#selector(self.btnTapMonthlyBtn(_sender:)), for: .touchUpInside)
        
        self.prevSummaryDaily = self.emailNotifiMobileUserSetting?.isDailySummaryEmailEnabled ?? false
        self.prevSummaryWeekly = self.emailNotifiMobileUserSetting?.isWeeklySummaryEmailEnabled ?? false
        self.prevSummaryMonthly = self.emailNotifiMobileUserSetting?.isMonthlySummaryEmailEnabled ?? false
        self.prevEmailID = self.strEmail
        
        self.prevEmailNotificationEnable = self.emailNotifiMobileUserSetting?.isEmailNotificationEnabled ?? false //self.SwitchEMNotEmail.isOn
        self.prevSummaryNotificationEnable = self.emailNotifiMobileUserSetting?.isSummaryEmailEnabled ?? false//self.SwitchEMNotSummary.isOn
       
        self.loadEmailNotificationStatus()
        self.loadEmailWarningNotificationStatus()
        self.loadEmailSummaryNotificationStatus()
       
        //Outage
        self.btnEMNotSixHour.addTarget(self, action:#selector(self.btnTapSixHourBtn(_sender:)), for: .touchUpInside)
        self.btnEMNotTwoHour.addTarget(self, action:#selector(self.btnTapTwoHourBtn(_sender:)), for: .touchUpInside)
        self.btnEMNotTwelveHour.addTarget(self, action:#selector(self.btnTapTwelveHourBtn(_sender:)), for: .touchUpInside)
        self.btnEMNotTwentyFourHour.addTarget(self, action:#selector(self.btnTapTwentyFourHourBtn(_sender:)), for: .touchUpInside)
        
        //self.prevOutageNotificationEnable = self.SwitchOutageNot.isOn
        self.prevSelectedOutageValue = self.emailNotifiMobileUserSetting?.outageNotificationsDuration ?? "0"
        self.prevOutageNotificationEnable = self.emailNotifiMobileUserSetting?.isMobileOutageNotificationsEnabled ?? false
        self.loadOutageSummaryNotificationStatus()
        
        //Alert
        self.btnAlertNotHourly.addTarget(self, action:#selector(self.btnTapHourlyAlertBtn(_sender:)), for: .touchUpInside)
        self.btnAlertNotDaily.addTarget(self, action:#selector(self.btnTapDailyAlertBtn(_sender:)), for: .touchUpInside)
        self.btnAlertNotWeekly.addTarget(self, action:#selector(self.btnTapWeeklyAlertBtn(_sender:)), for: .touchUpInside)
        self.btnAlertNotMonthly.addTarget(self, action:#selector(self.btnTapMonthlyAlertBtn(_sender:)), for: .touchUpInside)

        //self.prevWarningNotificationEnable = self.SwitchEMNotWarning.isOn
        self.prevWarningNotificationEnable = self.emailNotifiMobileUserSetting?.isMobileNotificationFrequencyEnabled ?? false
        self.prevSelectedAlertValue = self.emailNotifiMobileUserSetting?.notificationFrequency ?? "0"
        self.loadAlertSummaryNotificationStatus()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.emailNotifiMobileUserSetting = nil
    }
    
    func switchControls()  {
        // Switch Controls
        self.SwitchEMNotEmail.addTarget(self, action: #selector(switchEmailNotificationChanged), for: UIControl.Event.valueChanged)
        self.SwitchEMNotWarning.addTarget(self, action: #selector(switchWarningNotificationChanged), for: UIControl.Event.valueChanged)
        self.SwitchEMNotSummary.addTarget(self, action: #selector(switchSummaryNotificationChanged), for: UIControl.Event.valueChanged)
        //New changes
        self.SwitchOutageNot.addTarget(self, action: #selector(switchOutageNotificationChanged), for: UIControl.Event.valueChanged)
    }
    
    
    func loadEmailNotificationStatus()  {
        
        self.txtEMNotEmailAddress?.placeholder = "Enter email address(s)"
        
        if self.emailNotifiMobileUserSetting?.isEmailNotificationEnabled == true{
            //self.emailEntryViewHeight.constant = 105
            self.emailEntryView.isHidden = false
            self.SwitchEMNotEmail.isOn = true
            self.warningStackView.isHidden = false
            self.summeryStackView.isHidden = false
            self.outageStackView.isHidden = false
            self.alertStackView.isHidden = false
        }else {
            //self.emailEntryViewHeight.constant = 0
            self.emailEntryView.isHidden = true
            self.SwitchEMNotEmail.isOn = false
            self.warningStackView.isHidden = true
            self.summeryStackView.isHidden = true
            self.txtEMNotEmailAddress?.text = ""
            self.outageStackView.isHidden = true
            self.alertStackView.isHidden = true
        }
        self.strEmail = self.emailNotifiMobileUserSetting?.notificationEmail ?? ""
        self.intialTagList()
    }
    
    func loadEmailWarningNotificationStatus()  {
        if self.emailNotifiMobileUserSetting?.isMobileNotificationFrequencyEnabled == true{
            self.SwitchEMNotWarning.isOn = true
            self.prevWarningNotificationEnable = true
        }else {
            self.prevWarningNotificationEnable = false
            self.SwitchEMNotWarning.isOn = false
        }
        self.loadAlertSummaryNotificationStatus()
    }
    
    func loadEmailSummaryNotificationStatus()  {
        if  self.emailNotifiMobileUserSetting?.isSummaryEmailEnabled == true{
            lblEnbIAQNot.text = "Enabled"
            self.summaryNotificationHeight.constant = 217
            self.SwitchEMNotSummary.isOn = true
            self.viewEMNotWeekly.isHidden = false
            self.viewEMNotDaily.isHidden = false
            self.viewEMNotMonthly.isHidden = false
        }else {
            lblEnbIAQNot.text = "Disabled"
            self.summaryNotificationHeight.constant = 80
            self.SwitchEMNotSummary.isOn = false
            self.viewEMNotWeekly.isHidden = true
            self.viewEMNotDaily.isHidden = true
            self.viewEMNotMonthly.isHidden = true
        }
        
        self.imgDataViewEMNotWeekly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotDaily.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotMonthly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        
        if self.emailNotifiMobileUserSetting?.isDailySummaryEmailEnabled == true {
            self.imgDataViewEMNotDaily.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else if self.emailNotifiMobileUserSetting?.isWeeklySummaryEmailEnabled == true {
            self.imgDataViewEMNotWeekly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }
        else if self.emailNotifiMobileUserSetting?.isMonthlySummaryEmailEnabled == true {
            self.imgDataViewEMNotMonthly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }else {
        }
    }
    
    func loadAlertSummaryNotificationStatus()  {
        
        if self.prevWarningNotificationEnable {
            self.lblEnbAlertNot.text = "Enabled"
            self.alertNotificationHeight.constant = 161
            self.viewAlertNotWeekly.isHidden = false
            self.viewAlertNotDaily.isHidden = false
            self.viewAlertNotHourly.isHidden = false
            self.viewAlertNotMonthly.isHidden = false
        } else {
            self.lblEnbAlertNot.text = "Disabled"
            self.alertNotificationHeight.constant = 0
            self.viewAlertNotWeekly.isHidden = true
            self.viewAlertNotDaily.isHidden = true
            self.viewAlertNotHourly.isHidden = true
            self.viewAlertNotMonthly.isHidden = true
        }
        
        self.prevSelectedAlertValue = self.emailNotifiMobileUserSetting?.notificationFrequency ?? "0"
    
            self.imgDataViewAlertNotHourly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.imgDataViewAlertNotWeekly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.imgDataViewAlertNotDaily.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
            self.imgDataViewAlertNotMonthly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        
        if prevSelectedAlertValue == "1"{
            self.imgDataViewAlertNotHourly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        } else if prevSelectedAlertValue == "2"{
            self.imgDataViewAlertNotDaily.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        } else if prevSelectedAlertValue == "3"{
            self.imgDataViewAlertNotWeekly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        } else if prevSelectedAlertValue == "4"{
            self.imgDataViewAlertNotMonthly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        } else {
            //No mark displayed
        }
       
    }
   
    func loadOutageSummaryNotificationStatus()  {
        
        if self.prevOutageNotificationEnable {
            self.lblEnbOutageNot.text = "Enabled"
            self.outageNotificationHeight.constant = 250
            self.SwitchOutageNot.isOn = true
            self.viewEMNotTwoHour.isHidden = false
            self.viewEMNotSixHour.isHidden = false
            self.viewEMNotTwelveHour.isHidden = false
            self.viewEMNotTwentyFourHour.isHidden = false
        } else {
            self.lblEnbOutageNot.text = "Disabled"
            self.outageNotificationHeight.constant = 80
            self.SwitchOutageNot.isOn = false
            self.viewEMNotTwoHour.isHidden = true
            self.viewEMNotSixHour.isHidden = true
            self.viewEMNotTwelveHour.isHidden = true
            self.viewEMNotTwentyFourHour.isHidden = true
        }
        
        self.prevSelectedOutageValue = self.emailNotifiMobileUserSetting?.outageNotificationsDuration ?? "0"

        self.imgDataViewEMNotTwoHour.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotSixHour.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotTwelveHour.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotTwentyFourHour.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        
        if prevSelectedOutageValue == "1"{
            self.imgDataViewEMNotTwoHour.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        } else if prevSelectedOutageValue == "2"{
            self.imgDataViewEMNotSixHour.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }  else if prevSelectedOutageValue == "3"{
            self.imgDataViewEMNotTwelveHour.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        }  else if prevSelectedOutageValue == "4"{
            self.imgDataViewEMNotTwentyFourHour.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        } else {
            //no selection required
        }
    }
   
    func intialTagList()  {
        self.tagListView.textFont = UIFont.setAppFontMedium(14)
        self.tagListView?.delegate = self
        self.tagListView.removeButtonIconSize = 10
        self.tagListView.removeIconLineColor = UIColor.white
        self.tagListView?.removeIconLineColor = UIColor.clear
        self.loadTagDatas()
    }
    
}

extension EMailNotificationViewController {
    //Outage Switch update
    @objc func switchOutageNotificationChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            lblEnbOutageNot.text = "Enabled"
            self.prevOutageNotificationEnable = true
            self.emailNotifiMobileUserSetting?.isMobileOutageNotificationsEnabled = true
        }else{
            lblEnbOutageNot.text = "Disabled"
            self.prevOutageNotificationEnable = false
            self.emailNotifiMobileUserSetting?.isMobileOutageNotificationsEnabled = false
        }
        self.loadOutageSummaryNotificationStatus()
    }
    
    @objc func switchEmailNotificationChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            self.emailNotifiMobileUserSetting?.isEmailNotificationEnabled = true
        }else{
            self.emailNotifiMobileUserSetting?.isEmailNotificationEnabled = false
        }
        self.loadEmailNotificationStatus()
        self.loadOutageSummaryNotificationStatus()
    }
    
    //Warning & Alert Notif
    @objc func switchWarningNotificationChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            lblEnbAlertNot.text = "Enabled"
            self.emailNotifiMobileUserSetting?.isMobileNotificationFrequencyEnabled = true
        }else{
            lblEnbAlertNot.text = "Disabled"
            self.emailNotifiMobileUserSetting?.isMobileNotificationFrequencyEnabled = false
        }
        self.loadEmailWarningNotificationStatus()
    }
    
    //IAQ summary Notif
    @objc func switchSummaryNotificationChanged(mySwitch: UISwitch) {
        if  mySwitch.isOn {
            lblEnbIAQNot.text = "Enabled"
            self.emailNotifiMobileUserSetting?.isSummaryEmailEnabled = true
        }else{
            lblEnbIAQNot.text = "Disabled"
            self.emailNotifiMobileUserSetting?.isSummaryEmailEnabled = false
        }
        self.loadEmailSummaryNotificationStatus()
    }
    
}

extension EMailNotificationViewController {
    
    @IBAction func btnTapBackBtn(_ sender: Any) {
        if self.backCompareValues() {
            self.navigationController?.popViewController(animated: true)
        }else {
            self.backValidationAlert()
        }
    }
    
    @IBAction func btnSaveEMailNotifikBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.txtEMNotEmailAddress?.text?.count != 0 {
            if Helper.shared.isValidEmailAddress(strValue: self.removeWhiteSpace(text: self.txtEMNotEmailAddress.text ?? "")) {
                    if self.arrEmail.count < 5 {
                        if self.arrEmail.contains(self.removeWhiteSpace(text: self.txtEMNotEmailAddress.text ?? "")) {
                            self.view.endEditing(true)
                            Helper.shared.showSnackBarAlert(message: CONTENT_ALREADY_INVALID_EMAIL, type: .Failure)
                        }else {
                           self.callSaveUserMeApi()
                        }
                    }else {
                        self.view.endEditing(true)
                        Helper.shared.showSnackBarAlert(message: "You have reached a limit for sending mail", type: .Failure)
                    }
            }
            else {
                Helper.shared.showSnackBarAlert(message: CONTENT_INVALID_EMAIL, type: .Failure)
            }
        }else {
            self.callSaveUserMeApi()
        }
    }
    
    @objc func btnTapDailyBtn(_sender:UIButton) {
        self.selectedTimePeriod(selected: 1)
    }
    @objc func btnTapWeeklyBtn(_sender:UIButton) {
        self.selectedTimePeriod(selected: 2)
    }
    @objc func btnTapMonthlyBtn(_sender:UIButton) {
        self.selectedTimePeriod(selected: 3)
    }
    
    func selectedTimePeriod(selected:Int)  {
        
        self.imgDataViewEMNotWeekly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotDaily.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotMonthly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        
        self.emailNotifiMobileUserSetting?.isDailySummaryEmailEnabled = false
        self.emailNotifiMobileUserSetting?.isWeeklySummaryEmailEnabled = false
        self.emailNotifiMobileUserSetting?.isMonthlySummaryEmailEnabled = false
        switch selected {
        case 1:
            self.imgDataViewEMNotDaily.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.isDailySummaryEmailEnabled = true
        case 2:
            self.imgDataViewEMNotWeekly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.isWeeklySummaryEmailEnabled = true
        case 3:
            self.imgDataViewEMNotMonthly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.isMonthlySummaryEmailEnabled = true
        default:
            print("Fallback option")
        }
    }
   
    //Alert action
    @objc func btnTapHourlyAlertBtn(_sender:UIButton) {
        self.selectedTimePeriodAlert(selected: 1)
    }
    @objc func btnTapDailyAlertBtn(_sender:UIButton) {
        self.selectedTimePeriodAlert(selected: 2)
    }
    @objc func btnTapWeeklyAlertBtn(_sender:UIButton) {
        self.selectedTimePeriodAlert(selected: 3)
    }
    @objc func btnTapMonthlyAlertBtn(_sender:UIButton) {
        self.selectedTimePeriodAlert(selected: 4)
    }
    
    func selectedTimePeriodAlert(selected:Int)  {
        
        self.imgDataViewAlertNotHourly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewAlertNotDaily.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewAlertNotWeekly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewAlertNotMonthly.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage

        switch selected {
        case 1:
            self.imgDataViewAlertNotHourly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.notificationFrequency = "1"
        case 2:
            self.imgDataViewAlertNotDaily.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.notificationFrequency = "2"
        case 3:
            self.imgDataViewAlertNotWeekly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.notificationFrequency = "3"
        case 4:
            self.imgDataViewAlertNotMonthly.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.notificationFrequency = "4"

        default:
            print("Fallback option")
        }
    }
  
    //Outage action
    @objc func btnTapTwoHourBtn(_sender:UIButton) {
        self.selectedTimePeriodOutage(selected: 1)
    }
    @objc func btnTapSixHourBtn(_sender:UIButton) {
        self.selectedTimePeriodOutage(selected: 2)
    }
    @objc func btnTapTwelveHourBtn(_sender:UIButton) {
        self.selectedTimePeriodOutage(selected: 3)
    }
    @objc func btnTapTwentyFourHourBtn(_sender:UIButton) {
        self.selectedTimePeriodOutage(selected: 4)
    }
    
    func selectedTimePeriodOutage(selected:Int)  {
        
        self.imgDataViewEMNotTwoHour.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotSixHour.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotTwelveHour.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        self.imgDataViewEMNotTwentyFourHour.image = ThemeManager.currentTheme().cellNONCheckMarkIconImage
        
        switch selected {
        case 1:
            self.imgDataViewEMNotTwoHour.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.outageNotificationsDuration = "1"

        case 2:
            self.imgDataViewEMNotSixHour.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.outageNotificationsDuration = "2"
        case 3:
            self.imgDataViewEMNotTwelveHour.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.outageNotificationsDuration = "3"

        case 4:
            self.imgDataViewEMNotTwentyFourHour.image = ThemeManager.currentTheme().cellCheckMarkIconImage
            self.emailNotifiMobileUserSetting?.outageNotificationsDuration = "4"

        default:
            print("Fallback option")
        }
    }
    
    func callSaveUserMeApi(){
        
        if self.emailNotifiMobileUserSetting?.isEmailNotificationEnabled == true {
            let password = removeWhiteSpace(text:"Augusta@123")
            var emailStr = "luft@yop.com"
            if self.arrEmail.count <= 4 {
                if self.txtEMNotEmailAddress?.text?.count != 0 {
                    emailStr = self.removeWhiteSpace(text: self.txtEMNotEmailAddress?.text ?? "")
                    self.arrEmail.append(emailStr)
                    self.txtEMNotEmailAddress?.text = ""
                }
            }
            let isValidated = self.validate(emailId: emailStr, password: password)
            if isValidated.0 == true  {
                self.strEmail = ""
                self.strEmail = self.arrEmail.joined(separator: ",")
                self.loadTagDatas()
                self.saveEmailValue()
            }else {
                Helper.shared.showSnackBarAlert(message: isValidated.1, type: .Failure)
            }
        }else {
            //remove all email if email notification switch off
            self.emailNotifiMobileUserSetting?.notificationEmail = ""
            self.prevSelectedOutageValue = "0"
            self.prevSelectedAlertValue = "0"
            self.emailNotifiMobileUserSetting?.outageNotificationsDuration = "0"
            self.emailNotifiMobileUserSetting?.notificationFrequency = "0"
            self.emailNotifiMobileUserSetting?.isMobileOutageNotificationsEnabled = false
            self.emailNotifiMobileUserSetting?.isMobileNotificationFrequencyEnabled = false

            self.callSaveAPI()
        }
    }
    
    func saveEmailValue()  {
        if self.emailNotifiMobileUserSetting?.isSummaryEmailEnabled == true {
            if !(self.emailNotifiMobileUserSetting?.isDailySummaryEmailEnabled == true || self.emailNotifiMobileUserSetting?.isWeeklySummaryEmailEnabled == true || self.emailNotifiMobileUserSetting?.isMonthlySummaryEmailEnabled == true)
            {
                Helper.shared.showSnackBarAlert(message: CONTENT_INVALID_SUMMARY, type: .Failure)
                return
            }else {
                self.emailNotifiMobileUserSetting?.notificationEmail = self.strEmail
                self.callSaveAPI()
            }
        }else {
            
            self.emailNotifiMobileUserSetting?.notificationEmail = self.strEmail
            self.callSaveAPI()
        }
    }
    
    func validate(emailId: String, password: String) -> (Bool, String) {
        var isValidationSuccess = true
        var message:String = ""
        if self.arrEmail.count == 0 {
            self.strEmail = ""
            message = CONTENT_INVALID_EMAIL
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
        return (isValidationSuccess, message)
    }
    
    func callSaveAPI()  {
        if Reachability.isConnectedToNetwork() == true {
            self.showActivityIndicator(self.view)
            AppUserAPI.apiAppUserUpdateMobileUserPost(user: self.emailNotifiMobileUserSetting, completion: { (error) in
                self.hideActivityIndicator(self.view)
                if error == nil {
                    AppSession.shared.setMobileUserMeData(mobileSettingData: self.emailNotifiMobileUserSetting!)
                    Helper().showSnackBarAlert(message:"Details Updated Successfully", type: .Success)
                    self.navigationController?.popViewController(animated: true)
                }else {
                    Helper().showSnackBarAlert(message: "Something went wrong while retrieving information. Please try again later.", type: .Failure)
                }
            })
        }else {
            Helper.shared.showSnackBarAlert(message: CONTENT_INVALID_EMAIL, type: .Failure)
        }
    }
}
extension EMailNotificationViewController:TagListViewDelegate,UITextFieldDelegate {
    
    func backCompareValues() -> Bool{
        if self.prevEmailNotificationEnable != self.SwitchEMNotEmail.isOn {
            return false
        }else if self.SwitchEMNotEmail.isOn == true {
            if self.prevEmailID != self.strEmail {
                return false
            }
        }
        if self.prevWarningNotificationEnable != self.SwitchEMNotWarning.isOn {
            return false
        }
        else if self.prevSummaryNotificationEnable != self.SwitchEMNotSummary.isOn {
            return false
        }
        else if self.prevOutageNotificationEnable != self.SwitchOutageNot.isOn {
            return false
        }
        else if self.prevWarningNotificationEnable != self.SwitchEMNotWarning.isOn {
            return false
        }
        else if self.prevSummaryDaily != self.emailNotifiMobileUserSetting?.isDailySummaryEmailEnabled || self.prevSummaryWeekly != self.emailNotifiMobileUserSetting?.isWeeklySummaryEmailEnabled || self.prevSummaryMonthly != self.emailNotifiMobileUserSetting?.isMonthlySummaryEmailEnabled  {
            return false
        }
        
        else if self.txtEMNotEmailAddress?.text?.count != 0 {
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
            self.view.endEditing(true)
            self.btnSaveEMailNotifikBtn(self.btnTXSave)
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
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTag(title)
        //guard let item = self.arrEmail.firstIndex(where: { $0 == title }) else { return }
        var ind:Int = 0
        for val in self.arrEmail {
            if title == val{
                self.arrEmail.remove(at: ind)
                break
            }
            ind = ind + 1
        }
        self.strEmail = ""
        self.strEmail = self.arrEmail.joined(separator: ",")
        self.loadTagDatas()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        let stringVal = NSString(string: textField.text!)
        let newText = stringVal.replacingCharacters(in: range, with: string)
        if newText.containsEmoji{
            return false
        }
        if newText.count >= Validation.EMAIL_MAX {
            return false
        }
        
        if (isBackSpace == -60) {
            if self.txtEMNotEmailAddress?.text?.count != 0 {
                if Helper.shared.isValidEmailAddress(strValue: self.removeWhiteSpace(text: self.txtEMNotEmailAddress.text ?? "")) {
                    if self.arrEmail.contains(self.removeWhiteSpace(text: self.txtEMNotEmailAddress.text ?? "")) {
                        self.view.endEditing(true)
                        Helper.shared.showSnackBarAlert(message: CONTENT_ALREADY_INVALID_EMAIL, type: .Failure)
                    }else {
                        if self.arrEmail.count < 5 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                textField.resignFirstResponder()
                                textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
                                textField.becomeFirstResponder()
                            }
                            self.arrEmail.append(self.removeWhiteSpace(text: self.txtEMNotEmailAddress.text ?? ""))
                            self.txtEMNotEmailAddress.text = ""
                            self.strEmail = ""
                            self.strEmail = self.arrEmail.joined(separator: ",")
                            self.loadTagDatas()
                            self.txtEMNotEmailAddress?.placeholder = "Enter email address(s)"
                        }else {
                            self.view.endEditing(true)
                            Helper.shared.showSnackBarAlert(message: "You have reached a limit for sending mail", type: .Failure)
                        }
                    }
                }else {
                    self.view.endEditing(true)
                    Helper.shared.showSnackBarAlert(message: CONTENT_INVALID_EMAIL, type: .Failure)
                }
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
        }
        self.txtEMNotEmailAddress?.placeholder = "Enter email address(s)"
    }
    
    override func viewDidLayoutSubviews()
    {
        self.tagListView.autoresizingMask = .flexibleHeight
        //Total tags count
        let TagsCount = CGFloat(tagListView.tagViews.count * 40)
        //Change height of view.
        self.taglistViewHeight.constant  = TagsCount
        //self.bottomConstraintHeight.constant =  10
        self.tagListView.needsUpdateConstraints()
    }
    
    func loadTagListRemoveButton()  {
        if self.tagListView.tagViews.count != 0 {
            for tagview in tagListView.tagViews {
                let button = UIButton(type: .custom)
                button.frame = CGRect(x:tagview.frame.width - 30, y: 0, width: 30, height: tagview.frame.height)
                button.setImage(UIImage.init(named: "closeicon"), for: .normal)
                button.isUserInteractionEnabled = false
                button.backgroundColor = UIColor.clear
                tagview.addSubview(button)
            }
        }
    }
    
    func loadTagDatas()  {
        if self.strEmail.count != 0 {
            self.tagListView.removeAllTags()
            self.arrEmail.removeAll()
            let arr = self.strEmail.components(separatedBy: ",")
            for tagValue in arr {
                self.arrEmail.append(self.removeWhiteSpace(text: tagValue))
            }
            for val in self.arrEmail {
                self.tagListView.addTag(val)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                self.loadTagListRemoveButton()
            }
        }
    }
}

