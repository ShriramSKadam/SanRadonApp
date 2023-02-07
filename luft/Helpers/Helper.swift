//
//  Helper.swift
//  StopGap
//
//  Created by Anand-iMac on 08/10/18.
//  Copyright © 2018 augusta. All rights reserved.
//

import UIKit
import UserNotifications
import TTGSnackbar
import SystemConfiguration.CaptiveNetwork
import MessageUI
import SwiftyJSON

public enum AppUserType : Int {
    case UserTypeOffice = 0
    case UserTypeIndividual = 1
}

public enum BlueToothFeatureType : Int {
    case BlueToothFeatureNone = -1
    case BlueToothFeatureWifiStatus = 1
    case BlueToothFeatureLogCurrentIndexWrite = 2
    case BlueToothFeatureLogCurrentGetValue = 3
    case BlueToothFeatureSSIDWrite = 4
    case BlueToothUpperBound = 5
    case BlueToothUpperBackGroundDataBound = 6
    case BlueToothFeatureRemoveSSIDWrite = 7
    case BlueToothBackWrite = 8
    case BlueToothLowerBound = 9
    case BlueToothFirmwareVersion = 10
    case BlueToothTimeStampWrite = 11
    case BluetoothReadSerial = 12
}


public enum AppDropDownType : Int {
    case DropDownNone = -1
    case DropDownHomeBuildingType = 0
    case DropDownMitigationType = 1
    case DropDownDeviceList = 2
    case DropDownRadonBQM = 3
    case DropDownRadonPCII = 4
    case DropDownVOC = 5
    case DropDownECO2 = 6
    case DropDownHUMIDITY = 7
    case DropDownAIRPRESSURE_INHG = 8
    case DropDownAIRPRESSURE_KPA = 9
    case DropDownTEMPERATURE_CELSIUS = 10
    case DropDownTEMPERATURE_FAHRENHEIT = 11
    case DropDownCOLOR_CODE = 12
    case DropDownAIRPRESSURE_MBAR = 13
    
}

public enum SelectedFieldType : Int {
    case SelectedNone = -1
    case SelectedWarning = 1
    case SelectedAlert = 2
    case SelectedLowWarning = 3
    case SelectedAlertsEnabledWarning = 4
    case SelectedLowAlert = 5
    case SelectedHighWarning = 6
    case SelectedHighAlert = 7
    case SelectedOffset = 8
    case SelectedStartTime = 9
    case SelectedEndTime = 10
    case SelectedBuildingType = 11
    case SelectedMitigation = 12
}

public enum PollutantType : String {
    case PollutantNone = "None"
    case PollutantRadon = "Radon"
    case PollutantVOC = "VOC"
    case PollutantECO2 = "ECO2"
    case PollutantTemperature = "Temperature"
    case PollutantAirPressure = "AirPressure"
    case PollutantHumidity = "Humidity"
}

public enum ColorType : String {
    case ColorNone = "None"
    case ColorOk = "Ok"
    case ColorWarning = "Warning"
    case ColorAlert = "Alert"
    case ColorNightLight = "Nightlight"
}


public enum WIFIDEVICESTATUS : String {
    case WIFI_CONNECTED = "37"
    case WIFI_INTERNET = "45"
    case WIFI_CONNECTING = "33"
    case WIFI_NOT_CONNECTED = "0"
    
    case ICD_WIFI_CONNECTED = "1"
    case ICD_WIFI_INTERNET = "3"
    case ICD_WIFI_CONNECTING = "2"
    case ICD_WIFI_CLOUD  = "4"
    case ICD_WIFI_FAULT = "5"
    case ICD_WIFI_AUTHENTICATED = "6"
}

enum WebSocketReceivedType: String {
    case pushlatestreadings = "PUSHLATESTREADINGS"
    case updatesettings = "UPDATESETTINGS"
    case startinspection = "STARTINSPECTION"
    case stopinspection = "STOPINSPECTION"
    case restartinspection = "RESTARTINSPECTION"
    case latestreadingsavailable = "LATESTREADINGSAVAILABLE"
    case updatefirmware = "UPDATEFIRMWARE"
    
}

public enum WIFIButtonFeatureType : Int {
    case WIFIButtonNone = -1
    case WIFIButtonConnectTOWIFI = 1
    case WIFIButtonConnectTOWIFILATER = 2
    case WIFIButtonConnectTOWIFISAME = 3
    case WIFIButtonConnectTOWIFIANOTHER = 4
}

public enum BLEFetchType : Int {
    case WIFIButtonNone = -1
    case BLEFetchRemoveWiFi = 1
    case BLEFetchGetLatestData = 2
}


enum SortFilterTypeEnum: Int {
    case SortNone = -1
    case SortDeviceNameAscending = 1
    case SortDeviceNameDescending = 2
    case SortUpdateByNameAscending = 3
    case SortUpdateByNameDescending = 4
    
}

protocol HelperActionSheetDelegate {
    func didSelectOnHelperActionSheet(_ selectedTitle:NSString)
}

enum SnackBarType {
    case Failure
    case Success
    case Warning
    case InfoOrNotes
    case Toast
}

struct Validation {
    static let EMAIL_MIN = 5
    static let EMAIL_MAX = 120
    static let PASSWORD_MIN = 8
    static let PASSWORD_MAX = 16
}

public enum SideMenuType : String {
    case SideMenuNone = ""
    case SideMenuRename = "Rename"
    case SideMenuNotification = "Notifications"
    case SideMenuFrimware = "Check for Firmware Update"
    case SideMenuConnectToWifi = "Connect to Wi-Fi"
    case SideMenuRemoveToWifi = "Remove from Wi-Fi"
    case SideMenuRemoveDevice = "Remove Device"
    case SideMenuShareData = "Share Data"
    case SideMenuTempOffset = "Temperature Offset"
    case SideMenuFAQ = "FAQ"
    case SideMenuContactSupport = "Contact Support"
}

public enum MoldRisk: String{
    case MoldRisk = "Mold Risk - Very Low"
    case MoldRiskLow = "Mold Risk: Low - Keep Humidity Low!"
    case MoldRiskMedium = "Mold Risk: Medium - Control the Humidity!"
    case MoldRiskHigh = "High Mold - Lower the Humidity!"
    case MoldRiskVeryHigh = "Very High Mold Risk - Reduce the Humidity!"
    case MoldRiskUnknown = ""
}

class Helper: NSObject {
    var isSupendedAlertShowing: Bool = false
    var snackBar : TTGSnackbar? = nil
    var actIndicator:UIActivityIndicatorView!
    
    class var shared: Helper {
        struct Static {
            static let instance: Helper = Helper()
        }
        return Static.instance
    }
    
    func getCurrentTimeZoneinIANAFormat()-> String{
          return TimeZone.current.identifier
      }
    
    func togglePasswordVisibility(textFiled: UITextField) {
        if let textRange = textFiled.textRange(from: textFiled.beginningOfDocument, to: textFiled.endOfDocument) {
            textFiled.replace(textRange, withText: textFiled.text!)
        }
    }
    
    func getDateStringFromDateTime(dateStr: String)-> String{
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")! //Your date format
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        if date == nil {
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let date1 = dateFormatter.date(from: dateStr)
            if date1 == nil{
                return ""
            }else {
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let newDateString = dateFormatter.string(from: date1!)
                
                return newDateString
            }
        }
        //Convert String to Date
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let newDateString = dateFormatter.string(from: date!)
        
        return newDateString
    }
    
    func convertDateToString(date: Date)-> String{
        let utc = TimeZone(identifier: "UTC")
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = utc ?? TimeZone.init(secondsFromGMT: 0)!
        return dateFormatter.string(from: date)
    }
    
    func getDayBy2OfYear(date:Date)-> Int{
        var cal = Calendar.current
        let utc = TimeZone(identifier: "UTC")
        cal.timeZone = utc!
        let day = cal.ordinality(of: .day, in: .year, for: date)
        var isEven = false
        
        if (day ?? 0)%2 == 0{
            debugPrint("date :\(date) ---- Day number :\(((day ?? 0)/2))")
            return ((day ?? 0)/2)
        }
        else{
            debugPrint("date :\(date) ---- Day number :\(((day ?? 0)/2) + 1)")
             return ((day ?? 0)/2) + 1
        }
//        let halfDay = Double((day ?? 0)/2)
//        debugPrint("Day number :\(Int(ceil(halfDay)))")
//        return Int(ceil(Double(halfDay)))
//        if let day1 = cal.ordinality(of: .day, in: .year, for: Date()){
//                   if (day1)%2 == 0{
//                       isEven = true
//                   }
//                   else{
//                       isEven = false
//                   }
//               }
//
//        debugPrint("Day number :\(day!/2)")
//
//        if isEven{
//            if (day ?? 0)%2 == 0{
//                if ((day ?? 0)/2 - 1) < 0{
//                    return 182
//                }
//                else{
//                    return ((day ?? 0)/2 - 1)
//                }
//            }
//            else{
//                return (day ?? 0)/2
//            }
//
//
//        }
//        else{
//            let forcedDay = day ?? 0
//            return Int(ceil((forcedDay/2)))
//        }
        
    }
    
    func getWeekOfYear(date:Date)-> Int{
        var cal = Calendar.current
        let utc = TimeZone(identifier: "UTC")
        cal.timeZone = utc!
        let day = cal.ordinality(of: .weekOfYear, in: .year, for: date)
        debugPrint("Day number :\(day)")
        return day ?? 0
    }
    
    func getDateFromDateTime(dateStr: String)-> Date{
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!//Your date format
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        return date ?? Date()
    }
    
    func addDeviceTimeAndReturnUpdatedDate(date: Date, deviceId: Int)->Date{
        let deviceSettingsList = RealmDataManager.shared.getDeviceData(deviceID: deviceId)
        
        if deviceSettingsList.count > 0{
            let timeDifference = deviceSettingsList[0].timeDiffrence
            let existingDateMilliSeconds =  date.millisecondsSince1970
            
            let newDateMilliSeconds = existingDateMilliSeconds + ((timeDifference.toInt() ?? 0) * 1000)
            
            let newDate = Date(milliseconds: newDateMilliSeconds)
            return newDate
        }
        
        return Date()
        
    }
    
    func getUNIXDate(timeResult: Date) -> String {
        //let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.string(from: timeResult)
        return localDate
    }
    
    func getCSVDateTime(timeResult: Date) -> String {
        //let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.string(from: timeResult)
        return localDate
    }
    
    
    
    func getUNIXTime(timeResult: Date) -> String {
        // let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.string(from: timeResult)
        return localDate
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,61}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
    
    func canOpenURL(string: String?) -> Bool {
        guard let urlString = string else {return false}
        guard let url = NSURL(string: urlString) else {return false}
        if !UIApplication.shared.canOpenURL(url as URL) {return false}
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
    
    func isValidEmailAddress (strValue:String)-> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: [.caseInsensitive])
        return regex.firstMatch(in: strValue, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, strValue.count)) != nil
    }
    
    func isValidEmailAddressCount (strValue:String)-> Bool {
        
        let tempVal = strValue.components(separatedBy: "@") as NSArray
        if (tempVal[0] as! String).count > MAX_EMAIL_CHARACTER_COUNT_LEFT
        {
            return false
        }
        else if (tempVal[1] as! String).count > MAX_EMAIL_CHARACTER_COUNT_RIGHT
        {
            return false
        }
        else{
            return true
        }
    }
    
    func isCharValidPassword(password: String) -> Bool {
        //old match -> [_$@$!%*?&]
        //new match -> [!&^%$#@()/]
        let regularExpression = "^[A-Za-z0-9 !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~].{7,15}$"
        //let regularExpression = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!&^%$#@()/,])[A-Za-z\\d!&^%$#@()/,]{8,16}"
        let passwordValidation = NSPredicate.init(format: "SELF MATCHES %@", regularExpression)
        return passwordValidation.evaluate(with: password)
    }
    
    func isCheckForValidPassword(textString: String) -> Bool {
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
        let capitalresult = texttest.evaluate(with: textString)
        
        
        let lowerLetterRegEx  = ".*[a-z]+.*"
        let lowertest = NSPredicate(format:"SELF MATCHES %@", lowerLetterRegEx)
        let lowerResult = lowertest.evaluate(with: textString)
        
        let numberRegEx  = ".*[0-9]+.*"
        let numerictest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let numberresult = numerictest.evaluate(with: textString)
        
        let blankSpaceRegEx  = ".*[ ]+.*"
        let blanktest = NSPredicate(format:"SELF MATCHES %@", blankSpaceRegEx)
        let blankresult = blanktest.evaluate(with: textString)
        
        
        let specialCharacterRegEx  = ".*[!&^%$#@()?/]+.*"
        let specialChar = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
        let specialresult = specialChar.evaluate(with: textString)
        
        
        if(!(textString.count >= MIN_PASSWORD && textString.count <= MAX_PASSWORD)){
            return false
        }
        else if(!capitalresult)
        {
            return false
        }
        else if(!lowerResult)
        {
            return false
        }
        else if(!numberresult){
            return false
        }
        else if(!specialresult){
            return false
        }
        else if(blankresult){
            return false
        }
        else{
            return true
        }
        
    }
    
    func isValidPassword (strValue:String)-> Bool {
        if strValue.count < Validation.PASSWORD_MIN || strValue.count > Validation.PASSWORD_MAX {
            return false
        }
        return true
    }
    
    func isValidURL (urlString: String?) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    
    func doStringContainsNumber( _string : String) -> Bool{
        let numberRegEx  = ".*[0-9]+.*"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let containsNumber = testCase.evaluate(with: _string)
        return containsNumber
    }
    
    func getDateFromString(DateStr: String, seprator: String)-> Date {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let DateArray = DateStr.components(separatedBy: seprator)
        let components = NSDateComponents()
        components.year = Int(DateArray[2])!
        components.month = Int(DateArray[0])!
        components.day = Int(DateArray[1])!
        components.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let date = calendar?.date(from: components as DateComponents)
        
        return date!
    }
    
    // MARK: - FOR Time show
    func getConvertedDateToLocalZone (date: String, oldFormat: String) -> Date {
        debugPrint(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = oldFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        var utcDate:Date?
        utcDate = dateFormatter.date(from: date)
        if utcDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ss"
            utcDate = dateFormatter.date(from: date)
        }
        if utcDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            utcDate = dateFormatter.date(from: date)
        }
        if utcDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm.s"
            utcDate = dateFormatter.date(from: date)
        }
        if utcDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            utcDate = dateFormatter.date(from: date)
        }
        if utcDate == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            utcDate = dateFormatter.date(from: date)
        }
        if utcDate == nil {
            dateFormatter.dateFormat = "MM-dd-yyyy"
            utcDate = dateFormatter.date(from: date)
        }
        if utcDate == nil {
            dateFormatter.dateFormat = "mm/dd/yyyy"
            utcDate = dateFormatter.date(from: date)
        }
        if utcDate == nil {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            utcDate = dateFormatter.date(from: date)
        }
        dateFormatter.timeZone = NSTimeZone.local
        if  utcDate != nil {
            let timeStamp = dateFormatter.string(from: utcDate!)
            let localDate = dateFormatter.date(from: timeStamp)
            return localDate!
        }
        return NSDate() as Date
    }
    
    func numberOfLinesInLabel(yourString: String, labelWidth: CGFloat, labelHeight: CGFloat, font: UIFont) -> Int {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = labelHeight
        paragraphStyle.maximumLineHeight = labelHeight
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): font, NSAttributedString.Key(rawValue: NSAttributedString.Key.paragraphStyle.rawValue): paragraphStyle]
        
        let constrain = CGSize(width: labelWidth, height: CGFloat(Float.infinity))
        let size = yourString.size(withAttributes: attributes)
        
        let stringWidth = size.width
        
        let numberOfLines = ceil(Double(stringWidth/constrain.width))
        return Int(numberOfLines)
    }
    
    class RoundedImageView: UIImageView {
        override func layoutSubviews() {
            super.layoutSubviews()
            let radius: CGFloat = self.bounds.size.width / 2.0
            self.layer.cornerRadius = radius
            self.clipsToBounds = true
        }
    }
    
    func convertDateToString(inputDate: Date) -> String{
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        //let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "dd-MMM-yyyy"
        // again convert your date to string
        let myConvertedDateStr = formatter.string(from: inputDate)
        print(myConvertedDateStr)
        
        return myConvertedDateStr
    }
    
    func convertDateToTimerString(inputDate: Date) -> String{
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        //let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        //formatter.dateFormat = "dd-MMM-yyyy"
        // again convert your date to string
        let myConvertedDateStr = formatter.string(from: inputDate)
        print(myConvertedDateStr)
        
        return myConvertedDateStr
    }
    
    
    
    /// Using this method you can check the given experience is correct
    ///
    /// - Parameters:
    ///   - personDOBStr: Person DOB to compare and it should me in "mm/dd/yyyy"
    ///   - userGivenExperience: This is an string input, is give by the user and it should be in (0.00)
    /// - Returns: it will retun the given details true or false
    func checkYearOfExperienceWithDOB(personDOBStr: String, userGivenExperience: String) -> Bool {
        var isValidationSuccess = true
        
        let date = Helper.shared.getDateFromString(DateStr: personDOBStr, seprator: "/")
        let currentDate = NSDate() as Date// Current date
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
        let diffInDays = Calendar.current.dateComponents(components, from: date, to: currentDate)
        
        let sysYear = diffInDays.year ?? 0
        let sysMonth = diffInDays.month ?? 0
        var givenYear = 0
        var givenMonth = 0
        
        if userGivenExperience.contains(".") {
            if userGivenExperience.count > 1 {
                if let tempYear = Int((userGivenExperience.components(separatedBy: "."))[0]) {
                    givenYear = Int(tempYear)
                }
                if let tempMonth = Int((userGivenExperience.components(separatedBy: "."))[1]) {
                    givenMonth = Int(tempMonth)
                }
            } else {
                isValidationSuccess = false
            }
        } else {
            if Helper.shared.isStringAnInt(string: userGivenExperience) {
                givenYear = Int(userGivenExperience)!
            }
        }
        
        if (givenYear > sysYear) {
            isValidationSuccess = false
        }
        else if (givenYear == sysYear) && (givenMonth >= sysMonth) {
            isValidationSuccess = false
        }
        return isValidationSuccess
    }
    
    func isStringAnInt(string: String) -> Bool {
        return Int(string) != nil
    }
    
    func showAnimator(inputView:UIView, inputTbl: UITableView)  {
        self.actIndicator = UIActivityIndicatorView.init(style: .gray)
        self.actIndicator .startAnimating()
        self.actIndicator.color = UIColor.red
        self.actIndicator.frame = CGRect(x: 0, y: 0, width: inputView.frame.size.width, height: 44)
        inputTbl.tableFooterView = self.actIndicator
    }
    
    func stopAnimator(inputView:UIView, inputTbl: UITableView)  {
        //self.actIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        self.actIndicator .stopAnimating()
        UIView.animate(withDuration: 0.4, animations: {
            self.actIndicator.frame = CGRect(x: 0, y: 0, width: inputView.frame.size.width, height: 0)
            inputTbl.tableFooterView = self.actIndicator
        }, completion: nil)
        
    }
    
    
    func getLastFewYears(inputYear: Int, totalOutPutYear: Int, stopYear: Int) -> [String] {
        var formedYear: [String] = []
        var givenYear: Int = inputYear
        formedYear.append(String(format: "%d", givenYear))
        
        if givenYear == stopYear {
            
        } else {
            //            for _ in (0..<totalOutPutYear) {
            //                givenYear = givenYear - 1
            //                formedYear.append(String(format: "%d", givenYear))
            //                if givenYear == stopYear {
            //                    break
            //                }
            //            }
        }
        return formedYear
    }
    
    // for show the snack bar alert
    func showSnackBarAlert(message: String, type: SnackBarType) {
        
        if(self.snackBar != nil)
        {
            self.snackBar?.dismiss()
        }
        
        self.snackBar = TTGSnackbar(message: message, duration: .middle)
        snackBar?.messageTextColor = .white
        snackBar?.show()
        switch type {
        case .Success:
            snackBar?.backgroundColor = UIColor.init(hexString:"#1b5e20")
            break
        case .Failure:
            snackBar?.backgroundColor = UIColor.init(hexString:"#b71c1c")
            break
        case .Warning:
            snackBar?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            break
        case .InfoOrNotes:
            snackBar?.backgroundColor = ThemeManager.currentTheme().buttonBackgroundColor
            break
        case .Toast:
            snackBar?.backgroundColor = UIColor.init(white: 0.95, alpha: 0.95)
            snackBar?.messageTextColor = UIColor.white
            break
        }
        
        
    }
    
    func showSnackBarAlertWithButton(message: String, type: SnackBarType) {
        if(self.snackBar != nil)
        {
            self.snackBar?.dismiss()
        }
        self.snackBar = TTGSnackbar(message: message, duration: .forever, actionText: "Ok", actionBlock:
            {_ in
                self.snackBar?.dismiss()
        })
        snackBar?.animationType = .slideFromBottomBackToBottom
        snackBar?.messageTextColor = .white
        snackBar?.show()
        switch type {
        case .Success:
            snackBar?.backgroundColor = UIColor.init(hexString:"#1b5e20")
            break
        case .Failure:
            snackBar?.backgroundColor = UIColor.init(hexString:"#b71c1c")
            break
        case .Warning:
            snackBar?.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            break
        case .InfoOrNotes:
            snackBar?.backgroundColor = ThemeManager.currentTheme().buttonBackgroundColor
            break
        case .Toast:
            snackBar?.backgroundColor = UIColor.init(white: 0.95, alpha: 0.95)
            snackBar?.messageTextColor = UIColor.white
            break
        }
    }
    
    
    func showSnackBarAlertLong(message: String, type: SnackBarType) {
        let snackBar = TTGSnackbar(message: message, duration: .long)
        snackBar.messageTextColor = .blue
        snackBar.show()
        switch type {
        case .Success:
            snackBar.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            break
        case .Failure:
            snackBar.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            break
        case .Warning:
            snackBar.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            break
        case .InfoOrNotes:
            snackBar.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
            break
        case .Toast:
            snackBar.backgroundColor = UIColor.init(white: 0.95, alpha: 0.95)
            snackBar.messageTextColor = UIColor.blue
            break
        }
    }
    
    func removeBleutoothConnection()  {
        if  BluetoothManager.shared.centralManager != nil {
            BluetoothManager.shared.centralManager?.stopScan()
            BluetoothManager.shared.centralManager = nil
        }
        if  BackgroundBLEManager.shared.centralManager != nil {
            BackgroundBLEManager.shared.centralManager?.stopScan()
            BackgroundBLEManager.shared.centralManager = nil
        }
        if  SettingBLEManager.shared.centralManager != nil {
            SettingBLEManager.shared.centralManager?.stopScan()
            SettingBLEManager.shared.centralManager = nil
        }
    }
    
    func getAccurateValues(temperature: Int, humidity: Int)->(Int, Int){
        if temperature > 36 && humidity > 65 {
            return (temperature-36, humidity-65)
        }
        if temperature <= 36 && humidity <= 65 {
            return (0, 0)
        }
        if temperature > 36 && humidity < 65 {
            return (temperature-36, 0)
        }
        if temperature < 36 && humidity > 65 {
            return (0, humidity-65)
        }
        
        return (0,0)
    }
    
    func getMoldDataValue(temperature: Int, humidity: Int)->Double{
        let values = getAccurateValues(temperature: temperature, humidity: humidity)
        let array = [/*65*/
            [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*66*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.01,0.01,0.01,0.01,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.02,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*67*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.36,0.36,0.37,0.37,0.37,0.38,0.38,0.38,0.38,0.39,0.39,0.39,0.39,0.39,0.39,0.39,0.39,0.39,0.38,0.38,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*68*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.68,0.69,0.69,0.70,0.70,0.71,0.72,0.72,0.72,0.72,0.73,0.73,0.73,0.73,0.73,0.73,0.73,0.73,0.73,0.73,0.73,0.73,0.73,0.72,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*69*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.99,0.99,1.00,1.01,1.01,1.02,1.02,1.03,1.03,1.03,1.04,1.04,1.05,1.05,1.05,1.05,1.05,1.05,1.05,1.05,1.05,1.05,1.05,1.05,1.05,1.04,1.03,1.03,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*70*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.27,1.27,1.29,1.29,1.30,1.31,1.31,1.32,1.32,1.33,1.34,1.34,1.34,1.34,1.35,1.35,1.35,1.35,1.35,1.35,1.35,1.35,1.35,1.35,1.35,1.35,1.35,1.34,1.33,1.33,1.31,1.31,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*71*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.54,1.54,1.55,1.55,1.56,1.56,1.58,1.59,1.59,1.60,1.60,1.61,1.61,1.61,1.62,1.62,1.62,1.62,1.63,1.63,1.63,1.63,1.63,1.63,1.63,1.63,1.63,1.62,1.62,1.61,1.61,1.61,1.60,1.60,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*72*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,1.78,1.78,1.80,1.80,1.82,1.82,1.83,1.83,1.84,1.85,1.85,1.86,1.86,1.87,1.88,1.88,1.89,1.89,1.89,1.89,1.89,1.89,1.89,1.90,1.90,1.89,1.89,1.89,1.89,1.89,1.89,1.88,1.87,1.87,1.86,1.86,1.84,1.84,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*72*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,2.00,2.00,2.02,2.02,2.05,2.05,2.06,2.06,2.07,2.07,2.08,2.10,2.10,2.10,2.10,2.11,2.13,2.13,2.13,2.13,2.13,2.13,2.14,2.14,2.14,2.14,2.14,2.14,2.14,2.14,2.14,2.13,2.13,2.13,2.11,2.11,2.10,2.10,2.08,2.08,2.06,2.06,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*73*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,2.21,2.21,2.23,2.23,2.24,2.24,2.28,2.28,2.29,2.29,2.29,2.29,2.31,2.33,2.33,2.33,2.33,2.34,2.34,2.34,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.36,2.34,2.34,2.34,2.33,2.33,2.31,2.31,2.29,2.29,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*75*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,2.40,2.40,2.42,2.42,2.44,2.44,2.46,2.46,2.48,2.48,2.50,2.50,2.52,2.52,2.52,2.55,2.55,2.55,2.55,2.55,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.57,2.55,2.55,2.55,2.55,2.52,2.52,2.50,2.50,2.48,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*76*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,2.59,2.59,2.62,2.62,2.64,2.64,2.67,2.67,2.69,2.69,2.69,2.69,2.72,2.72,2.72,2.72,2.72,2.75,2.75,2.75,2.75,2.75,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.78,2.75,2.75,2.75,2.75,2.75,2.72,2.72,2.69,2.69,2.67,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*77*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,2.75,2.78,2.78,2.81,2.81,2.84,2.84,2.84,2.84,2.88,2.88,2.88,2.88,2.91,2.91,2.91,2.91,2.91,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.95,2.91,2.91,2.88,2.88,2.88,2.81,2.81,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*78*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,2.88,2.88,2.91,2.95,2.95,2.98,2.98,3.02,3.02,3.02,3.02,3.02,3.02,3.06,3.06,3.06,3.06,3.11,3.11,3.11,3.11,3.11,3.11,3.11,3.11,3.11,3.11,3.15,3.15,3.15,3.15,3.15,3.15,3.15,3.15,3.15,3.15,3.15,3.15,3.15,3.11,3.11,3.11,3.11,3.11,3.11,3.11,3.06,3.06,3.02,2.98,2.98,0.00,0.00,0.00,0.00,0.00,0.00 ],
            /*79*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3.02,3.02,3.06,3.06,3.06,3.11,3.11,3.15,3.15,3.15,3.15,3.20,3.20,3.20,3.20,3.20,3.20,3.25,3.25,3.25,3.25,3.25,3.25,3.25,3.25,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.31,3.25,3.25,3.25,3.25,3.25,3.25,3.25,3.25,3.20,3.15,3.15,3.11,3.11,0.00,0.00,0.00,0.00 ],
            /*80*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3.11,3.15,3.15,3.20,3.20,3.25,3.25,3.25,3.31,3.31,3.31,3.31,3.36,3.36,3.36,3.36,3.36,3.36,3.36,3.36,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.43,3.36,3.36,3.36,3.31,3.31,3.25,3.25,0.00,0.00,0.00,0.00 ],
            /*81*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3.25,3.31,3.31,3.36,3.36,3.36,3.43,3.43,3.43,3.43,3.49,3.49,3.49,3.49,3.49,3.49,3.49,3.49,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.57,3.49,3.49,3.49,3.43,3.43,3.36,3.36,0.00,0.00,0.00,0.00 ],
            /*82*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3.31,3.31,3.36,3.43,3.43,3.49,3.49,3.49,3.57,3.57,3.57,3.57,3.57,3.57,3.65,3.65,3.65,3.65,3.65,3.65,3.65,3.65,3.65,3.65,3.65,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.65,3.65,3.65,3.65,3.65,3.57,3.57,3.49,3.49,3.43,3.43,0.00,0.00 ],
            /*83*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3.36,3.36,3.43,3.43,3.49,3.57,3.57,3.57,3.57,3.65,3.65,3.65,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.73,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.73,3.73,3.73,3.73,3.73,3.65,3.65,3.57,3.57,0.00,0.00 ],
            /*84*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3.43,3.43,3.49,3.49,3.57,3.57,3.65,3.65,3.65,3.73,3.73,3.73,3.73,3.73,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.83,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.83,3.83,3.83,3.73,3.73,3.65,3.65,3.49,0.00 ],
            /*85*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,3.49,3.49,3.65,3.65,3.65,3.65,3.73,3.83,3.83,3.83,3.83,3.83,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,3.95,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,3.95,3.95,3.95,3.95,3.95,3.83,3.83,3.73,3.73,3.65,0.00 ],
            /*86*/    [ 0.00,0.00,0.00,0.00,0.00,0.00,3.49,3.49,3.65,3.65,3.73,3.73,3.73,3.73,3.83,3.83,3.83,3.95,3.95,3.95,3.95,3.95,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,3.95,3.95,3.83,3.83,3.73,0.00 ],
            /*87*/    [ 0.00,0.00,0.00,0.00,0.00,3.49,3.65,3.65,3.73,3.73,3.83,3.83,3.83,3.83,3.95,3.95,3.95,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.08,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.08,4.08,4.08,4.08,3.95,3.95,3.83,3.49 ],
            /*88*/    [ 0.00,0.00,0.00,3.43,3.43,3.57,3.73,3.73,3.83,3.83,3.95,3.95,3.95,3.95,4.08,4.08,4.08,4.08,4.08,4.08,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.08,4.08,3.95,3.65 ],
            /*89*/    [ 0.00,3.25,3.25,3.49,3.49,3.65,3.83,3.83,3.95,3.95,3.95,3.95,4.08,4.08,4.08,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.23,4.23,4.23,4.23,4.08,4.08,3.95,3.73 ],
            /*90*/    [ 2.95,3.31,3.31,3.57,3.57,3.73,3.83,3.83,3.95,3.95,4.08,4.08,4.08,4.08,4.23,4.23,4.23,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.23,4.23,4.23,4.23,4.08,3.73 ],
            /*91*/    [ 3.02,3.36,3.36,3.65,3.65,3.83,3.95,3.95,4.08,4.08,4.08,4.08,4.23,4.23,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.23,4.23,4.08,3.83 ],
            /*92*/    [ 3.11,3.43,3.43,3.73,3.73,3.83,3.95,3.95,4.08,4.08,4.23,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.42,4.42,4.42,4.42,4.42,4.42,4.23,3.95 ],
            /*93*/    [ 3.15,3.49,3.49,3.73,3.73,3.95,4.08,4.08,4.23,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.42,4.42,4.42,4.42,4.23,3.95 ],
            /*94*/    [ 3.20,3.57,3.57,3.83,3.83,3.95,4.08,4.08,4.23,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.42,4.42,4.42,4.08 ],
            /*95*/    [ 3.25,3.65,3.65,3.83,3.83,4.08,4.23,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.42,4.08 ],
            /*96*/    [ 3.31,3.65,3.65,3.95,3.95,4.08,4.23,4.23,4.42,4.42,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.42,4.08 ],
            /*97*/    [ 3.36,3.73,3.73,3.95,3.95,4.23,4.23,4.23,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,4.66,4.66,4.66,4.66,4.66,4.66,4.42,4.23 ],
            /*98*/    [ 3.43,3.73,3.73,4.08,4.08,4.23,4.42,4.42,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,4.66,4.66,4.66,4.66,4.66,4.23 ],
            /*99*/    [ 3.49,3.83,3.83,4.08,4.08,4.23,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,4.66,4.66,4.66,4.23 ],
            /*100*/   [ 3.49,3.83,3.83,4.08,4.08,4.23,4.42,4.42,4.42,4.42,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,4.66,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,5.00,4.66,4.66,4.66,4.42 ]]

        return array[values.1][values.0]
    }
    
    func getMoldDataText(moldValue: Double)->String{
        switch moldValue {
        case 0.0:
            return MoldRisk.MoldRisk.rawValue
        case 0.0...1.2:
            return MoldRisk.MoldRiskLow.rawValue
        case 1.2...2.7:
            return MoldRisk.MoldRiskMedium.rawValue
        case 2.7...4.6:
            return MoldRisk.MoldRiskHigh.rawValue
        case _ where moldValue > 4.6:
            return MoldRisk.MoldRiskVeryHigh.rawValue
        default:
            return MoldRisk.MoldRiskUnknown.rawValue
        }
    }
}

extension UISearchBar {
    var dtXcode: Int {
        if let dtXcodeString = Bundle.main.infoDictionary?["DTXcode"] as? String {
            if let dtXcodeInteger = Int(dtXcodeString) {
                return dtXcodeInteger
            }
        }
        return Int()
    }
    
    // Due to searchTextField property who available iOS 13 only, extend this property for iOS 13 previous version compatibility
    var compatibleSearchTextField: UITextField {
        
        guard let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField else {
            return legacySearchField }
        return textFieldInsideSearchBar
    }
    
    var legacySearchField: UITextField {
        guard let textField = self.subviews.first?.subviews.last as? UITextField else { return UITextField() }
        return textField
    }
}

extension NSDictionary {
    func isHaveBoolValue(_ key:NSString) -> (Bool) {
        if let value = self[key] as? Bool {
            return value
        }
        return false
    }
    
    func isHaveStringValue(_ key:NSString) -> (String) {
        if let value = self[key] as? NSString {
            if (value.length > 0  && (value != ("null"))) {
                return value as (String)
            } else {
                return ""
            }
        }
        return ""
    }
    
    func isHaveArrayValue(_ key:NSString) -> (NSArray) {
        if let value = self[key] as? NSArray {
            if(value.count > 0) {
                return value
            } else {
                return []
            }
        }
        return []
    }
    
    func isHaveMutableArrayValue(_ key:NSString) -> (NSMutableArray) {
        if let value = self[key] as? NSMutableArray {
            if(value.count > 0) {
                return value
            } else {
                return []
            }
        }
        return []
    }
    
    func isHaveDictionayValude(_ key:NSString) -> (NSDictionary) {
        if let value = self[key] as? NSDictionary {
            return value
        }
        return [String:AnyObject]() as (NSDictionary)
    }
    
    func isHaveMutableDictionayValude(_ key:NSString) -> (NSMutableDictionary) {
        if let value = self[key] as? NSMutableDictionary {
            return value
        }
        return ([String:AnyObject]() as? (NSMutableDictionary))!
    }
    
    func isHaveIntValue(_ key:NSString) -> Int {
        if let value = self[key] as? Int {
            return value
        }
        return 0
    }
    
    func isHaveImageValue(_ key:NSString) -> (UIImage) {
        if let value = self[key] as? UIImage {
            return value as (UIImage)
        }
        return UIImage()
    }
    
    func isHaveDoubleValue(_ key:NSString) -> Double {
        if let value = self[key] as? Double {
            return value
        }
        return 0
    }
    
    func isHaveFloatValue(_ key:NSString) -> Float {
        if let value = self[key] as? Float {
            return value
        }
        return 0
    }
}

extension String {
    
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }
    
    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var integer: Int {
        return Int(self) ?? 0
    }
    
    var secondFromString : Int{
        var components: Array = self.components(separatedBy: ":")
        let hours = components[0].integer
        let minutes = components[1].integer
        return Int((hours * 60 * 60) + (minutes * 60))
    }
    
    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    
    //Converts String to Double
    public func toDouble() -> Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Float
    public func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }
    
    //Converts String to Bool
    public func toBool() -> Bool? {
        return (self as NSString).boolValue
    }
    
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        if let text = String(data: messageData!, encoding: .utf8) {
            return text
        }
        return ""
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
    
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    
}

extension UIViewController {
    
    public func setLatestStatusBar() {
        let sharedApplication = UIApplication.shared
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager!.statusBarFrame ?? CGRect.init(x: 0, y: 0, width: 0, height: 0))
            statusBar.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
            sharedApplication.delegate?.window??.addSubview(statusBar)
        } else {
            sharedApplication.statusBarView?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        }
    }
    
    
    public func removeWhiteSpace(text:String) -> String
    {
        return text.trimmingCharacters(in: CharacterSet.whitespaces)
        
    }
    
    
    
    func getCurrentTimeZoneShortName() -> String{
        if let dictionaryTimeZones = NSTimeZone.abbreviationDictionary as? [String:String]{
            if let key = dictionaryTimeZones.someKey(forValue: NSTimeZone.local.identifier) {
                return key
            }
        }
        return ""
    }
    
    func getWiFiName() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    private func getUNIXDateTime(timeResult: Double) -> String {
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd YYYY hh:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let localDate = dateFormatter.string(from: date)
        return localDate
    }
    
    func getTodayString() -> String{
        let date = Date()
        var calender = Calendar.current
        calender.timeZone = TimeZone(abbreviation: "UTC")!
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        return today_string
    }
    
    
    
}

// Data Extensions:
protocol DataConvertible {
    init(data:Data)
    var data:Data { get }
}

extension DataConvertible {
    init(data:Data) {
        guard data.count == MemoryLayout<Self>.size else {
            fatalError("data size (\(data.count)) != type size (\(MemoryLayout<Self>.size))")
        }
        self = data.withUnsafeBytes { $0.pointee }
    }
    
    var data:Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension UInt8:DataConvertible {}
extension UInt16:DataConvertible {}
extension UInt32:DataConvertible {}
extension Int32:DataConvertible {}
extension Int64:DataConvertible {}
extension Double:DataConvertible {}
extension Float:DataConvertible {}




extension FloatingPoint {
    func rounded(to n: Int) -> Self {
        let n = Self(n)
        return (self / n).rounded() * n
    }
}




extension Date {
    
    // you can create a read-only computed property to return just the nanoseconds from your date time
    var nanoSecondsValues: Int { return Calendar.current.component(.nanosecond,  from: self)   }
    // you can create a read-only computed property to return just the nanoseconds from your date time
    var secondValues: Int { return Calendar.current.component(.second,  from: self)   }
    // the same for your local time
    var preciseLocalTime: String {
        return Formatter.preciseLocalTime.string(for: self) ?? ""
    }
    // or GMT time
    var preciseGMTTime: String {
        return Formatter.preciseGMTTime.string(for: self) ?? ""
    }
}

extension Formatter {
    // create static date formatters for your date representations
    static let preciseLocalTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    static let preciseGMTTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}


extension Notification.Name {
    static let postNotifiDevivceWifiStatus = Notification.Name("postNotifiDevivceWifiStatus")
    static let postNotifiDeviceUpadte = Notification.Name("postNotifiDeviceUpadte")
    static let postNotifiWholeDataSync = Notification.Name("postNotifiWholeDataSync")
    static let postNotifiResetDevice = Notification.Name("postNotifiResetDevice")
}


extension Helper {
    
    
    
    func convertRadonBQM3ToPCIL(value : Float) -> Float{
        return value/37
    }
    
    func convertRadonPCILToBQM3(value : Float) -> Float{
        return value*37
    }
    
    func convertTemperatureCelsiusToFahrenheit(value: Float) -> Float{
        return ((value * 9) / 5) + 32
    }
    
    func convertTemperatureFahrenheitToCelsius(value: Float) -> Float{
        return ((value - 32) * 5 / 9)
    }
    
    func convertAirPressureINHGToMBAR(value: Float) -> Double{
        return Double(value*33.864)
    }
    
    func convertAirPressureMBARToINHG(value: Float) -> Double{
        return Double(value/33.864)
    }
    
    
    func getRadonColor(myValue: Float, deviceId:Int)-> (color: UIColor,type: ColorType){
        
        guard !(myValue.isNaN || myValue.isInfinite) else {
            let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
            return (color: color, type: ColorType.ColorOk)
        }
        
        var arrPollutantvalue:[RealmThresHoldSetting] = []
        arrPollutantvalue .removeAll()
        arrPollutantvalue = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceId, pollutantType: PollutantType.PollutantRadon.rawValue)
        if arrPollutantvalue.count != 0 {
            if AppSession.shared.getMobileUserMeData()?.radonUnitTypeId == 2{
                var myRadonValuePCI:Float = 0.0
                myRadonValuePCI = Float(String(format: "%.1f", myValue)) ?? 0.0
                var myLowWarningValuePCI:Float = 0.0
                myLowWarningValuePCI = String(format: "%.1f", arrPollutantvalue[0].low_waring_value.toFloat() ?? 0.0).toFloat() ?? 0.0
                var myLowAlertValuePCI:Float = 0.0
                myLowAlertValuePCI = String(format: "%.1f", arrPollutantvalue[0].low_alert_value.toFloat() ?? 0.0).toFloat() ?? 0.0
                //Compare
                if myRadonValuePCI >= myLowAlertValuePCI{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                    return (color: color, type: ColorType.ColorAlert)
                }
                else if myRadonValuePCI >= myLowWarningValuePCI{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                    return (color: color, type: ColorType.ColorWarning)
                }else {
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                    return (color: color, type: ColorType.ColorOk)
                }
            }else {
                var myRadonValueBBm:Int = 0
                myRadonValueBBm = String(format: "%f", self.convertRadonPCILToBQM3(value: myValue).rounded()).toInt() ?? 0
                var myLowWarningValueBBm:Int = 0
                myLowWarningValueBBm = String(format: "%f", self.convertRadonPCILToBQM3(value: arrPollutantvalue[0].low_waring_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                var myLowAlertValueBBm:Int = 0
                myLowAlertValueBBm = String(format: "%f", self.convertRadonPCILToBQM3(value: arrPollutantvalue[0].low_alert_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                //Compare
                if myRadonValueBBm >= myLowAlertValueBBm{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                    return (color: color, type: ColorType.ColorAlert)
                }else if myRadonValueBBm >= myLowWarningValueBBm{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                    return (color: color, type: ColorType.ColorWarning)
                }else {
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                    return (color: color, type: ColorType.ColorOk)
                }
            }
        }
        let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
        return (color: color, type: ColorType.ColorOk)
    }
    
    func getVOCColor(myValue: Float = 0.0, deviceId:Int)-> (color: UIColor,type: ColorType) {
        
        guard !(myValue.isNaN || myValue.isInfinite) else {
            let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
            return (color: color, type: ColorType.ColorOk)
        }
        
        var arrPollutantvalue:[RealmThresHoldSetting] = []
        arrPollutantvalue .removeAll()
        arrPollutantvalue = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceId, pollutantType: PollutantType.PollutantVOC.rawValue)
        if arrPollutantvalue.count != 0 {
            var myVOCValue:Int = 0
            
            myVOCValue = Int(myValue.rounded())
            var myLowWarningValueVOC:Int = 0
            myLowWarningValueVOC = arrPollutantvalue[0].low_waring_value.toInt() ?? 0
            var myLowAlertValueVOC:Int = 0
            myLowAlertValueVOC = arrPollutantvalue[0].low_alert_value.toInt() ?? 0
            //Compare
            if  myVOCValue >= myLowAlertValueVOC{
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                return (color: color, type: ColorType.ColorAlert)
            }else if myVOCValue >= myLowWarningValueVOC{
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                return (color: color, type: ColorType.ColorWarning)
            }
            else {
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                return (color: color, type: ColorType.ColorOk)
            }
        }
        let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
        return (color: color, type: ColorType.ColorOk)
    }
    
    func getECO2Color(myValue: Float = 0.0, deviceId:Int)-> (color: UIColor,type: ColorType) {
        
        guard !(myValue.isNaN || myValue.isInfinite) else {
            let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
            return (color: color, type: ColorType.ColorOk)
        }
        
        var arrPollutantvalue:[RealmThresHoldSetting] = []
        arrPollutantvalue .removeAll()
        arrPollutantvalue = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceId, pollutantType: PollutantType.PollutantECO2.rawValue)
        if arrPollutantvalue.count != 0 {
            var myVOCValue:Int = 0
            myVOCValue = Int(myValue.rounded())
            var myLowWarningValueVOC:Int = 0
            myLowWarningValueVOC = arrPollutantvalue[0].low_waring_value.toInt() ?? 0
            var myLowAlertValueVOC:Int = 0
            myLowAlertValueVOC = arrPollutantvalue[0].low_alert_value.toInt() ?? 0
            //Compare
            if  myVOCValue >= myLowAlertValueVOC{
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                return (color: color, type: ColorType.ColorAlert)
            }else if myVOCValue >= myLowWarningValueVOC{
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                return (color: color, type: ColorType.ColorWarning)
            }
            else {
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                return (color: color, type: ColorType.ColorOk)
            }
        }
        let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
        return (color: color, type: ColorType.ColorOk)
    }
    
    func getHumidityColor(myValue: Float = 0.0, deviceId:Int)-> (color: UIColor,type: ColorType) {
        
        guard !(myValue.isNaN || myValue.isInfinite) else {
            let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
            return (color: color, type: ColorType.ColorOk)
        }
        
        var arrPollutantvalue:[RealmThresHoldSetting] = []
        arrPollutantvalue .removeAll()
        arrPollutantvalue = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceId, pollutantType: PollutantType.PollutantHumidity.rawValue)
        if arrPollutantvalue.count != 0 {
            var myTempValue:Int = 0
            myTempValue = Int(myValue.rounded())
            var myHumidityLowWarning:Int = 0
            myHumidityLowWarning = arrPollutantvalue[0].low_waring_value.toInt() ?? 0
            var myHumidityLowAlert:Int = 0
            myHumidityLowAlert = arrPollutantvalue[0].low_alert_value.toInt() ?? 0
            var myHumidityHighWarning:Int = 0
            myHumidityHighWarning = arrPollutantvalue[0].high_waring_value.toInt() ?? 0
            var myHumidityHighAlert:Int = 0
            myHumidityHighAlert = arrPollutantvalue[0].high_alert_value.toInt() ?? 0
            //Compare
            if myTempValue >= myHumidityHighAlert || myTempValue <= myHumidityLowAlert{
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                return (color: color, type: ColorType.ColorAlert)
            }
            else if myTempValue >= myHumidityHighWarning || myTempValue <= myHumidityLowWarning{
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                return (color: color, type: ColorType.ColorWarning)
            }else {
                let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                return (color: color, type: ColorType.ColorOk)
            }
        }
        let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
        return (color: color, type: ColorType.ColorOk)
    }
    
    func getAirPressueColor(myValue: Float = 0.0, deviceId:Int)-> (color: UIColor,type: ColorType) {
        
        guard !(myValue.isNaN || myValue.isInfinite) else {
            let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
            return (color: color, type: ColorType.ColorOk)
        }
        
        var airPressureValue:Float = myValue
        var isLocalAltitudeINHG: Float = 0.0
        if Helper.shared.getDeviceDataAltitude(deviceID: deviceId).isAltitude == true {
            isLocalAltitudeINHG = Helper.shared.getDeviceDataAltitude(deviceID: deviceId).isLocalAltitudeINHG
            //isLocalAltitudeINHG = 0
            airPressureValue = myValue + isLocalAltitudeINHG
        }
        
        var arrPollutantvalue:[RealmThresHoldSetting] = []
        arrPollutantvalue .removeAll()
        arrPollutantvalue = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceId, pollutantType: PollutantType.PollutantAirPressure.rawValue)
        if arrPollutantvalue.count != 0 {
            if AppSession.shared.getMobileUserMeData()?.pressureUnitTypeId == 2{
                var myAirPressureINHGValue:Float = 0.0
                myAirPressureINHGValue = Float(String(format: "%.2f",airPressureValue)) ?? 0.0
                
                var myAirPressureINHGLowWarning:Float = 0.0
                myAirPressureINHGLowWarning = String(format: "%.2f", arrPollutantvalue[0].low_waring_value.toFloat() ?? 0.0).toFloat() ?? 0.0
                var myAirPressureINHGLowAlert:Float = 0.0
                myAirPressureINHGLowAlert = String(format: "%.2f", arrPollutantvalue[0].low_alert_value.toFloat() ?? 0.0).toFloat() ?? 0.0
                var myAirPressureINHGHighWarning:Float = 0.0
                myAirPressureINHGHighWarning = String(format: "%.2f", arrPollutantvalue[0].high_waring_value.toFloat() ?? 0.0).toFloat() ?? 0.0
                var myAirPressureINHGHighAlert:Float = 0.0
                myAirPressureINHGHighAlert = String(format: "%.2f", arrPollutantvalue[0].high_alert_value.toFloat() ?? 0.0).toFloat() ?? 0.0
                //Compare
                if myAirPressureINHGValue >= myAirPressureINHGHighAlert || myAirPressureINHGValue <= myAirPressureINHGLowAlert{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                    return (color: color, type: ColorType.ColorAlert)
                }
                else if myAirPressureINHGValue >= myAirPressureINHGHighWarning || myAirPressureINHGValue <= myAirPressureINHGLowWarning{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                    return (color: color, type: ColorType.ColorWarning)
                    
                }else {
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                    return (color: color, type: ColorType.ColorOk)
                }
            }else {
                var myAirPressureMBARValue:Int = 0
                myAirPressureMBARValue = String(format: "%f", self.convertAirPressureINHGToMBAR(value: airPressureValue ).rounded()).toInt() ?? 0
                var myAirPressureMBARLowWarning:Int = 0
                myAirPressureMBARLowWarning = String(format: "%f", self.convertAirPressureINHGToMBAR(value: arrPollutantvalue[0].low_waring_value.toFloat() ?? 0.0).rounded() ).toInt() ?? 0
                var myAirPressureMBARHighWarning:Int = 0
                myAirPressureMBARHighWarning = String(format: "%f", self.convertAirPressureINHGToMBAR(value: arrPollutantvalue[0].high_waring_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                var myAirPressureMBARLowAlert:Int = 0
                myAirPressureMBARLowAlert = String(format: "%f", self.convertAirPressureINHGToMBAR(value: arrPollutantvalue[0].low_alert_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                var myAirPressureMBARHighAlert:Int = 0
                myAirPressureMBARHighAlert = String(format: "%f", self.convertAirPressureINHGToMBAR(value: arrPollutantvalue[0].high_alert_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                if myAirPressureMBARValue >= myAirPressureMBARHighAlert || myAirPressureMBARValue <= myAirPressureMBARLowAlert{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                    return (color: color, type: ColorType.ColorAlert)
                }
                else if myAirPressureMBARValue >= myAirPressureMBARHighWarning || myAirPressureMBARValue <= myAirPressureMBARLowWarning{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                    return (color: color, type: ColorType.ColorWarning)
                }
                else {
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                    return (color: color, type: ColorType.ColorOk)
                }
            }
        }
        let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
        return (color: color, type: ColorType.ColorOk)
    }
    
    
    func getTempeatureColor(myValue: Float = 0.0, deviceId:Int)-> (color: UIColor,type: ColorType) {
        
        guard !(myValue.isNaN || myValue.isInfinite) else {
            let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
            return (color: color, type: ColorType.ColorOk)
        }
        
        var arrPollutantvalue:[RealmThresHoldSetting] = []
        arrPollutantvalue .removeAll()
        arrPollutantvalue = RealmDataManager.shared.readPollutantDataValues(deviceID: deviceId, pollutantType: PollutantType.PollutantTemperature.rawValue)
        if arrPollutantvalue.count != 0 {
            if AppSession.shared.getMobileUserMeData()?.temperatureUnitTypeId == 1{
                var myFAHRENHEITvalue:Int = 0
                myFAHRENHEITvalue = String(format: "%f",myValue.rounded()).toInt() ?? 0
                var myFAHRENHEITLowWarning:Int = 0
                myFAHRENHEITLowWarning = String(format: "%f", arrPollutantvalue[0].low_waring_value.toFloat()?.rounded() ?? 0.0).toInt() ?? 0
                var myFAHRENHEITLowAlert:Int = 0
                myFAHRENHEITLowAlert = String(format: "%f", arrPollutantvalue[0].low_alert_value.toFloat()?.rounded() ?? 0.0).toInt() ?? 0
                var myFAHRENHEITHighWarning:Int = 0
                myFAHRENHEITHighWarning = String(format: "%f", arrPollutantvalue[0].high_waring_value.toFloat()?.rounded() ?? 0.0).toInt() ?? 0
                var myFAHRENHEITHighAlert:Int = 0
                myFAHRENHEITHighAlert = String(format: "%f", arrPollutantvalue[0].high_alert_value.toFloat()?.rounded() ?? 0.0).toInt() ?? 0
                //Compare
                if myFAHRENHEITvalue >= myFAHRENHEITHighAlert || myFAHRENHEITvalue <= myFAHRENHEITLowAlert{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                    return (color: color, type: ColorType.ColorAlert)
                }
                else if myFAHRENHEITvalue >= myFAHRENHEITHighWarning || myFAHRENHEITvalue <= myFAHRENHEITLowWarning{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                    return (color: color, type: ColorType.ColorWarning)
                }else {
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                    return (color: color, type: ColorType.ColorOk)
                }
            }else {
                
                var myTempCelisusValue:Int = 0
                myTempCelisusValue = String(format: "%f", self.convertTemperatureFahrenheitToCelsius(value: myValue).rounded()).toInt() ?? 0
                var tempCelisusLowWarning:Int = 0
                tempCelisusLowWarning = String(format: "%f", self.convertTemperatureFahrenheitToCelsius(value: arrPollutantvalue[0].low_waring_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                var tempCelisusHighWarning:Int = 0
                tempCelisusHighWarning = String(format: "%f", self.convertTemperatureFahrenheitToCelsius(value: arrPollutantvalue[0].high_waring_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                var tempCelisusLowAlert:Int = 0
                tempCelisusLowAlert = String(format: "%f", self.convertTemperatureFahrenheitToCelsius(value: arrPollutantvalue[0].low_alert_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                var tempCelisusHighAlert:Int = 0
                tempCelisusHighAlert = String(format: "%f", self.convertTemperatureFahrenheitToCelsius(value: arrPollutantvalue[0].high_alert_value.toFloat() ?? 0.0).rounded()).toInt() ?? 0
                
                if myTempCelisusValue >= tempCelisusHighAlert || myTempCelisusValue <= tempCelisusLowAlert{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorAlert))
                    return (color: color, type: ColorType.ColorAlert)
                }
                    
                else if myTempCelisusValue >= tempCelisusHighWarning || myTempCelisusValue <= tempCelisusLowWarning{
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorWarning))
                    return (color: color, type: ColorType.ColorWarning)
                }
                else {
                    let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
                    return (color: color, type: ColorType.ColorOk)
                }
            }
        }
        let color = UIColor.init(hexString: self.getDeviceDataAlertColor(deviceID: deviceId, colorType: .ColorOk))
        return (color: color, type: ColorType.ColorOk)
    }
    
    func getDeviceDataAlertColor(deviceID:Int,colorType:ColorType) -> String{
        
        var data = RealmDataManager.shared.readColorDataValues(deviceID: deviceID, colorType: colorType.rawValue)
        if data.count > 0 {
            return data[0].color_code
        }
        return "#F7F9F9"
    }
    
    func getDeviceDataAltitude(deviceID:Int) -> (isAltitude: Bool,isLocalAltitudeINHG:Float,isLocalAltitudeMBAR:Float) {
        var isLocalAltitudeINHG: Float = 0.0
        var isLocalAltitudeMBAR: Float = 0.0
        let data = RealmDataManager.shared.getDeviceData(deviceID: deviceID)
        if data.count > 0 {
            guard !data[0].isInvalidated else {
                return (isAltitude: false,isLocalAltitudeINHG:isLocalAltitudeINHG,isLocalAltitudeMBAR:isLocalAltitudeMBAR)
            }
            if data[0].pressure_altitude_correction_status == false {
                return (isAltitude: false,isLocalAltitudeINHG:isLocalAltitudeINHG,isLocalAltitudeMBAR:isLocalAltitudeMBAR)
                
            }else {
                var isLocalINHG: Float = 0.0
                isLocalINHG = String(format: "%@", data[0].pressure_elevation_deviation_ihg).toFloat() ?? 0.0
//                print(isLocalINHG)
                isLocalAltitudeINHG = Float(String(format: "%.2f", isLocalINHG)) ?? 0.0
                
                isLocalAltitudeMBAR = String(format: "%@", data[0].pressure_elevation_deviation_mbr).toFloat() ?? 0.0
//                print(isLocalAltitudeMBAR)
            }
        }
        return (isAltitude: true,isLocalAltitudeINHG:isLocalAltitudeINHG,isLocalAltitudeMBAR:isLocalAltitudeMBAR)
    }
    
    func getTimeDiffBetweenTimeZone() -> String{
        let utcDate = Date().toGlobalTime()
        let localDate = utcDate.toCurrentLocalTime()
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second]
        formatter.unitsStyle = .full
        let difference = formatter.string(from: utcDate, to: localDate)!
        
        var selectedTimeZoneDiff = String(format: "%@", difference)
        selectedTimeZoneDiff = selectedTimeZoneDiff.replacingOccurrences(of: "seconds", with: "")
        selectedTimeZoneDiff = selectedTimeZoneDiff.replacingOccurrences(of: ",", with: "")
        selectedTimeZoneDiff = self.removeWhiteSpace(text: selectedTimeZoneDiff)
        return String(format: "%@", selectedTimeZoneDiff)
    }
    
    func removeWhiteSpace(text:String) -> String
    {
        return text.trimmingCharacters(in: CharacterSet.whitespaces)
        
    }
    
    func getOptionalJson(response : Any?)-> JSON?{
        return JSON(response as AnyObject)
    }
}


extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        border.backgroundColor = color.cgColor
        addSublayer(border)
    }
}



class TextLog: NSObject, MFMailComposeViewControllerDelegate {
    
    static var sharedInstance: TextLog = TextLog()
    
    var vcToPresent: UIViewController?
    
    let LOG_FILE = "log.txt"
    let API_LOG_FILE = "apilog.txt"

    //MARK:- Write API Logs
    func writeAPI(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent(API_LOG_FILE)
        
        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            
            let timezone = TimeZone.current
            let seconds = TimeInterval(timezone.secondsFromGMT(for: Date()))
            let newString = String.init(format: "\n%@    %@", Helper.shared.convertDateToString(date: Date(timeInterval: seconds, since: Date())) , string)
            handle.write(newString.data(using: .utf8)!)
            handle.closeFile()
            
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func clearLogsAPI(){
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory.appending("/\(API_LOG_FILE)")
        
        let text = ""
        do {
            try text.write(toFile: pathForLog, atomically: false, encoding: .utf8)
        } catch {
            
        }
        
    }
   
    //MARK:- Write Logs
    func write(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent(LOG_FILE)
        
        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            
            let timezone = TimeZone.current
            let seconds = TimeInterval(timezone.secondsFromGMT(for: Date()))
            let newString = String.init(format: "\n%@    %@", Helper.shared.convertDateToString(date: Date(timeInterval: seconds, since: Date())) , string)
            handle.write(newString.data(using: .utf8)!)
            handle.closeFile()
            
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func clearLogs(){
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory.appending("/\(LOG_FILE)")
        
        let text = ""
        do {
            try text.write(toFile: pathForLog, atomically: false, encoding: .utf8)
        } catch {
            
        }
        
    }
    
    func sendEmail(viewController: UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            
            let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = allPaths.first!
            let pathForLog = documentsDirectory.appending("/\(LOG_FILE)")
            let pathForLogAPI = documentsDirectory.appending("/\(API_LOG_FILE)")
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setBccRecipients(["sunradon@augustahitech.com"])
            mail.setToRecipients(["radonlogs@sunradon.com"])
            mail.setMessageBody("<p>Please see the attched logs</p>", isHTML: true)
            mail.setSubject("Logs from AirQuality app")
            if let fileData = NSData(contentsOfFile: pathForLog) {
                mail.addAttachmentData(fileData as Data, mimeType: "text/txt", fileName: "log.txt")
            }
            if let fileDataAPI = NSData(contentsOfFile: pathForLogAPI) {
                mail.addAttachmentData(fileDataAPI as Data, mimeType: "text/txt", fileName: "apilog.txt")
            }
            vcToPresent = viewController
            vcToPresent?.present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        vcToPresent?.dismiss(animated: true)
    }
    
}
extension String {
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x1F1E6...0x1F1FF, // Regional country flags
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
            127000...127600, // Various asian characters
            65024...65039, // Variation selector
            9100...9300, // Misc items
            8400...8447:
                return true
            default:
                continue
            }
        }
        return false
    }
    
}
