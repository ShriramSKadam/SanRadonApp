//
//  LTThemeManager.swift
//  luft
//
//  Created by iMac Augusta on 10/8/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import Foundation


enum Theme: Int {
    
    case theme1, theme2
    //App HeaderColor
    var headerViewBGColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#ffffff")
        case .theme2:
            //return UIColor().colorFromHexString("#202228")
            return UIColor().colorFromHexString("#000000")
        }
    }
    
    //ViewController
    var viewBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("ffffff")
        case .theme2:
            return UIColor().colorFromHexString("#000000")
        }
    }
    
    var viewInfoBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("ffffff")
        case .theme2:
            return UIColor().colorFromHexString("#18191A")
        }
    }
    
    var settingViewBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#F5F5FA")
        case .theme2:
            return UIColor().colorFromHexString("#000000")
        }
    }
    
    var settingVersionViewBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.white
        case .theme2:
            return UIColor().colorFromHexString("#000000")
        }
    }
    
    var filterSubViewBGColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.white
        case .theme2:
            //return UIColor().colorFromHexString("#202228")
            return UIColor.clear
        }
    }
    
    //ViewController
    var buttonBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#3E82F7")
        case .theme2:
            return UIColor().colorFromHexString("#3E82F7")
        }
    }
    
    //LT  Button TitleColor
    var buttonCommonTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#ffffff")
        case .theme2:
            return UIColor().colorFromHexString("#ffffff")
        }
    }
    
    //LT  Button Gray TitleColor
    var buttonGrayCommonTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.gray
        case .theme2:
            return UIColor.gray
        }
    }
    
    //LT Button TitleColor
    var buttonTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#ffffff")
        }
    }
    
    var chartButtonTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    var selectionButtonTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    //LT Image Button TitleColor
    var imgButtonTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#ffffff")
        case .theme2:
            return UIColor().colorFromHexString("#ffffff")
        }
    }
    
    var imgGoogleButtonBGColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    
    var imgGoogleButtonTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#ffffff")
        case .theme2:
            return UIColor().colorFromHexString("#000000")
        }
    }
    
    var searchBorderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.lightGray
        case .theme2:
            return UIColor.white
        }
    }
    
    //LT Button TitleColor
    var blueTextButtonTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#3E82F7")
        case .theme2:
            return UIColor().colorFromHexString("#3E82F7")
        }
    }
    //LT Button TitleColor
    var clearColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.clear
        case .theme2:
            return UIColor.clear
        }
    }
    
    //LT Header BorderColor
    var headerBorderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#00000059")
        case .theme2:
            return UIColor().colorFromHexString("#000000")
        }
    }
    
    //LT Button BorderColor
    var borderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#ffffff")
        }
    }
    
    //LT Button BorderColor
    var chartBorderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.gray
        case .theme2:
            return UIColor.white
        }
    }
   
    //Title Color
    var headerTitleTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#ffffff")
        }
    }
    
    //Title Color
    var titleTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#ffffff")
        }
    }
    
    //Sub-Title Color
    var subtitleTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#777777")
        case .theme2:
            return UIColor().colorFromHexString("#ffffff")
        }
    }
    
    
    //LT TextField TitleColor
    var textFieldTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#8E8E93")
        case .theme2:
            return UIColor().colorFromHexString("#8E8E93")
        }
    }
    
    //UITableViewCell - Header
    var ltCellHeaderViewBackgroudColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#F5F5FA")
        case .theme2:
            return UIColor().colorFromHexString("#24272d")
        }
    }
    
    var ltTempOffsetHeaderViewBackgroudColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#FFFFFF")
        case .theme2:
            return UIColor().colorFromHexString("#24272d")
        }
    }
    
    var ltCellHeaderBorderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#C7C7CC")
        case .theme2:
            return UIColor().colorFromHexString("#24272d") 
        }
    }
    
    var ltCellHeaderTabbarBorderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#C7C7CC")
        case .theme2:
            return UIColor().colorFromHexString("#24272d")
        }
    }
    
    var ltCellHeaderTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#6D6D72")
        case .theme2:
            return UIColor.white
        }
    }
    
    var ltFilterButtonTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    var ltLoaderViewBackgroudColor: UIColor {
        switch self {
        case .theme1:
            return UIColorFromHex(0x444444, alpha: 1.0)
        case .theme2:
            return UIColor.white
        }
    }
    
    var ltLoaderViewTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.white
        case .theme2:
            return UIColor.black
        }
    }
    
    public func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    //UITableViewcell
    var ltCellViewBackgroudColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#FFFFFF")
        case .theme2:
            return UIColor().colorFromHexString("#000000")
        }
    }
    
    var ltCellBorderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#C7C7CC")
        case .theme2:
            return UIColor().colorFromHexString("#24272d")
        }
    }
    
    var ltCellDashNBoardBorderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.lightGray
        case .theme2:
            return UIColor.white
        }
    }
    
    var chartNoDataTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    var scanAvailableNetworkView: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#24272d")
        case .theme2:
            return UIColor().colorFromHexString("#24272d")
        }
    }
    
    var ltCellTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#FFFFFF")
        }
    }
    
    var ltCellSubtitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#8E8E93")
        case .theme2:
            return UIColor().colorFromHexString("#C7C7CC")
        }
    }
    
    var ltFWCellTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#FFFFFF")
        }
    }
    
    var ltFWCellSubtitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#FFFFFF")
        }
    }
    
    var cellDisclousreIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:CELL_DISCLOUSRE)!
        case .theme2:
            return UIImage.init(named:CELL_DISCLOUSRE)!
        }
    }
    
    var cellNonSelectedCheckIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:CELL_BLANK_CHECKMARK)!
        case .theme2:
            return UIImage.init(named:CELL_BLANK_CHECKMARK)!
        }
    }
    
    var cellSelectedCheckIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:CELL_SELECTED_CHECKMARK)!
        case .theme2:
            return UIImage.init(named:CELL_SELECTED_CHECKMARK)!
        }
    }
    
    var cellCheckMarkIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:CELL_NEW_GOOD_CHECKMARK)!
        case .theme2:
            return UIImage.init(named:CELL_NEW_GOOD_CHECKMARK)!
        }
    }
    
    var cellNONCheckMarkIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:CELL_NON_CHECKMARK)!
        case .theme2:
            return UIImage.init(named:CELL_NON_CHECKMARK)!
        }
    }
    
    var ltCellRedTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#FF3B30")
        case .theme2:
            return UIColor().colorFromHexString("#FF3B30")
        }
    }
    
    //Sort and Fliter
    var sortOrderDeviceNameAsecendingIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:"BlackAescending")!
        case .theme2:
            return UIImage.init(named:"WhiteAescending")!
        }
    }
    
    var sortOrderDeviceNameDesecendingIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:"BlackDescending")!
        case .theme2:
            return UIImage.init(named:"WhiteDescending")!
        }
    }
    
    var sortByTimerAsecendingIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:"BlackTimerDescending")!
        case .theme2:
            return UIImage.init(named:"WhiteTimerDescending")!
        }
    }
    
    var sortByTimerDesecendingIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:"BlackTimerAscending")!
        case .theme2:
            return UIImage.init(named:"WhiteTimerAscending")!
        }
    }
    
    var ltCellOusideHeaderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    var labelTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    var ltCellOusideValueColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.lightGray
        case .theme2:
            return UIColor.lightGray
        }
    }
    
    //MARK:<******************Setting******************>
    var ltSettingHeaderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#F5F5F5")
        case .theme2:
            return UIColor().colorFromHexString("#202228")
        }
    }
    
    var ltSliderHeaderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.white
        case .theme2:
            return UIColor.clear
        }
    }
    
    var ltSettingHeaderTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#6D6D72")
        case .theme2:
            return UIColor().colorFromHexString("#C7C7CC")
        }
    }
    
    var ltInfoHeaderTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#FFFFFF")
        }
    }
    
    
    var ltSettingHeaderBorderColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#C7C7CC")
        case .theme2:
            return UIColor().colorFromHexString("#4F4F4F")
        }
    }
    
    var ltSettingTxtBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#FFFFFF")
        case .theme2:
            return UIColor().colorFromHexString("#171717")
        }
    }
    
    var ltSettingEmailTxtBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#FFFFFF")
        case .theme2:
            return UIColor.clear
        }
    }
    
    var ltSettingTxtColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#000000")
        case .theme2:
            return UIColor().colorFromHexString("#FFFFFF")
        }
    }
    
    var ltSettingPlaceHolderTxtColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#C7C7CC")
        case .theme2:
            return UIColor().colorFromHexString("#0000004D")
        }
    }
    
    var ltSyncBorderLabel: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#F5F5FA")
        case .theme2:
            return UIColor().colorFromHexString("#FFFFFF")
        }
    }
    
    var ltSearchViewBackGroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#F0F0F0")
        case .theme2:
            return UIColor().colorFromHexString("#333333")
        }
    }
    
    var ltSearchPlaceHolderTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#8E8E93")
        case .theme2:
            return UIColor().colorFromHexString("#8E8E93")
        }
    }
    
    
    
    //Drop Down
    var dropDownBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#202228")
        case .theme2:
            return UIColor().colorFromHexString("#FFFFFF")
        }
    }
    
    var dropDownCellBackgroundColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#202228")
        case .theme2:
            return UIColor().colorFromHexString("ffffff")
        }
    }
    
    var dropDownltCellTitleColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#FFFFFF")
        case .theme2:
            return UIColor().colorFromHexString("#000000")
        }
    }
    //DashBoard Color
    
    var collectionViewYellowCellBackColor: UIColor {
        return UIColor().colorFromHexString("#E0BF38")
    }
    var collectionViewRedCellBackColor: UIColor {
        return UIColor().colorFromHexString("#E34444")
    }
    var collectionViewGreenCellBackColor: UIColor {
        return UIColor().colorFromHexString("#32C772")
    }
    //MARK:<******************Images******************>
    
    var backIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:SINGUP_BACK_ARROW_IMAGE)!
        case .theme2:
            return UIImage.init(named:SINGUP_BACK_ARROW_IMAGE)!
        }
    }
    var backNewIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:SINGUP_BACK_ARROW_IMAGE)!
        case .theme2:
            return UIImage.init(named:SINGUP_BACK_ARROW_IMAGE)!
        }
    }
    
    
    
    var addIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:DASHBOARD_ADD_DEVICE_IMAGE)!
        case .theme2:
            return UIImage.init(named:DASHBOARD_ADD_DEVICE_IMAGE)!
        }
    }
    
    var menuIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:DASHBOARD_BLACK_IMAGE)!
        case .theme2:
            return UIImage.init(named:DASHBOARD_WHITE_IMAGE)!
        }
    }
    
    var menuRefreshIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:DASHBOARD_ADD_DEVICE_REFRESH_IMAGE)!
        case .theme2:
            return UIImage.init(named:DASHBOARD_ADD_DEVICE_REFRESH_IMAGE)!
        }
    }
    
    //UITableViewCell - Header
    var ltAddDeviceHeaderViewBackgroudColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#F5F5FA")
        case .theme2:
            return UIColor().colorFromHexString("#24272d")
        }
    }
    
    var luftImageIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:ADD_DEVICE_LUFT_IMAGE)!
        case .theme2:
            return UIImage.init(named:ADD_DEVICE_LUFT_IMAGE)!
        }
    }
    
    var luftDashBoardIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:DASHBOARD_IMAGE)!
        case .theme2:
            return UIImage.init(named:DASHBOARD_IMAGE_WHITE)!
        }
    }
    
    var luftDashBoardChartIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:DASHBOARD_CHART_IMAGE)!
        case .theme2:
            return UIImage.init(named:DASHBOARD_CHART_IMAGE_WHITE)!
        }
    }
    
    var luftDashBoardSettingIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:DASHBOARD_SETTING_IMAGE)!
        case .theme2:
            return UIImage.init(named:DASHBOARD_SETTING_IMAGE_WHITE)!
        }
    }
   
    
    var statusBarTextColor: UIStatusBarStyle {
        switch self {
        case .theme1:
            return .default
        case .theme2:
            return .lightContent
        }
    }
    
    var luftDashBoardSyncIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:LAST_SYNC_BLACK)!
        case .theme2:
            return UIImage.init(named:LAST_SYNC_WHITE)!
        }
    }
    
    var chartBGColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#ebf0f6")
        case .theme2:
            return UIColor().colorFromHexString("#464a55").withAlphaComponent(0.5)
        }
    }
    
    var chartButtonSelectionColor: UIColor {
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#eef3f6")
        case .theme2:
            return UIColor().colorFromHexString("#455c69")
        }
    }
    
    var chartTileBGViewColor: UIColor{
        switch self {
        case .theme1:
            return UIColor().colorFromHexString("#ffffff")
        case .theme2:
            return UIColor.clear
        }
    }
    
    var chartLabelTextColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    var ltChartGridColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.lightGray
        case .theme2:
            return UIColor.darkGray
        }
    }
    
    var pageCurrentControlColor: UIColor {
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
    
    var backUlogoImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:BACKULOGO1)!
        case .theme2:
            return UIImage.init(named:BACKULOGO2)!
        }
    }
    
    //MoldRiskIntegration
    var moldAlertIconImage: UIImage {
        switch self {
        case .theme1:
            return UIImage.init(named:"moldRisk")!
        case .theme2:
            return UIImage.init(named:"moldRiskWhite")!
        }
    }
    
    var moldAlertTextColor: UIColor{
        switch self {
        case .theme1:
            return UIColor.black
        case .theme2:
            return UIColor.white
        }
    }
}

// Enum declaration
let SelectedThemeKey = "SelectedTheme"
// This will let you use a theme in the app.
class ThemeManager {
    
    // ThemeManager
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .theme2
        }
    }
    
    static func applyTheme(theme: Theme) {
        // First persist the selected theme using NSUserDefaults.
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()

    }
}

extension UIColor {
    func colorFromHexString (_ hex:String) -> UIColor {
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
}
