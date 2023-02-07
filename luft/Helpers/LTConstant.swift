//
//  LTConstant.swift
//  luft
//
//  Created by Augusta on 09/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation

let chartMinValMultiplier = 0.5
let chartMaxValMultiplier = 1.5
//Logo Image
let LOGO_IMAGE = "LuftLogo"

//API's
public func getAPIBaseUrl() -> String {
    
    //return QA_APIBASE_URL
    if AppSession.shared.getUserLiveState() == 2 {
//        return UAT_APIBASE_URL
        return UAT_DEVICE_APIBASE_URL
    }else {
        return LIVE_APIBASE_URL
    }
}

public func getDeviceGetAPIBaseUrl() -> String {
    
    //return QA_APIBASE_URL
    if AppSession.shared.getUserLiveState() == 2 {
//        return UAT_APIBASE_URL
        return UAT_DEVICE_APIBASE_URL
    }else {
        return LIVE_APIBASE_URL
    }
}

public func getSocketBaseUrl() -> String {
    if AppSession.shared.getUserLiveState() == 2 {
        return DEVICE_UAT_SOCKETS_URL
    }else {
        return LIVE_SOCKETS_URL
    }
}

public func getBLEWriteBaseUrl() -> String {
    if AppSession.shared.getUserLiveState() == 2 {
        return DEVICE_UAT_BLE_DEVICE_WEB_SOCKET_URL
    }else {
        return LIVE_BLE_DEVICE_WEB_SOCKET_URL
    }
}

//BASE API URL
let QA_APIBASE_URL = "https://sunnuclear-qa.augustasoftsol.com:5001"
let LIVE_APIBASE_URL = "https://radonapi.oneradon.com"
let UAT_DEVICE_APIBASE_URL = "https://apiuat.oneradon.com"
let UAT_APIBASE_URL = "https://webapiuat.oneradon.com"

//SOCKET CONNECTION URL
let LIVE_SOCKETS_URL = "wss://radonapi.oneradon.com/ws?token"
let UAT_SOCKETS_URL = "wss://webapiuat.oneradon.com/ws?token"
let DEVICE_UAT_SOCKETS_URL = "wss://apiuat.oneradon.com/ws?token"
//BLE WRITE
let LIVE_BLE_DEVICE_WEB_SOCKET_URL = "wss://radonapi.oneradon.com:443"
let UAT_BLE_DEVICE_WEB_SOCKET_URL = "wss://webapiuat.oneradon.com:443"
let DEVICE_UAT_BLE_DEVICE_WEB_SOCKET_URL = "wss://apiuat.oneradon.com:443"


//Terms and Conditions & Privacy Policy
let TERMS_AND_CONDTIONS = "https://sunradon.com/pages/terms-and-conditions"
let CONTACT_SUPPORT = "https://www.sunradon.com/helpdesk/product-support-1"
let PRIVACY_POLICY = "https://sunradon.com/pages/privacy-policy"
let PRODUCT_WARRANTY_URL = "https://sunradon.com/pages/product-warranty"
let SERVICE_WARRANTY_URL = "https://sunradon.com/pages/services-warranty"
let FW_VERSION_LIVE_URL = "https://storage.googleapis.com/sunradon/luft-img-version.json"
let FW_VERSION_UAT_URL = "https://storage.googleapis.com/sunradon/luft-img-version-uat.json"

// Get More Help!
let UNITS_URL = "https://www.sunradon.com/faq-units"
let APPLICATION_Url = "https://www.sunradon.com/faq-notify"
let Thresholds_url = "https://www.sunradon.com/faq-alarms"
let Colours_Url = "https://www.sunradon.com/faq-colors"
let Adddevice_Url = "https://www.sunradon.com/faq-add"
let Addwifi_Url = "https://www.sunradon.com/faq-wifi"
let ACCOUNT_URL = "https://www.sunradon.com/faq-acct"
let AddDeviceScreen_URL = "https://www.sunradon.com/faq-add"

let buttonRadion_URL = "https://www.sunradon.com/faq-radon"
let buttonTVoc_URL = "https://www.sunradon.com/faq-voc"
let buttonEco2_URL = "https://www.sunradon.com/faq-eco2"
let buttonTemperature_URL = "https://www.sunradon.com/faq-temp"
let buttonHumidity_URL = "https://www.sunradon.com/faq-hum"
let buttonAirPressure_URL = "https://www.sunradon.com/faq-pres"



let LIVE_OPEN_WEATHER_MAP_URL = "http://api.openweathermap.org/data/2.5/weather"
let LIVE_OPEN_AIR_QUALITY_URL = "http://api.openweathermap.org/data/2.5/air_pollution"
let LIVE_OPEN_WEATHER_MAP_IMAGE_URL = "https://radonapi.oneradon.com/weathericon/"
let UAT_OPEN_WEATHER_MAP_IMAGE_URL = "https://webapiuat.oneradon.com/weathericon/"
let LIVE_SUN_RADON_URL = "https://sunradon.com/"
let LIVE_SUN_RADON_FAQ_URL = "https://sunradon.com/resources-support#faq"

let OUTSIDE_DATA_API_KEY = "b72301282664be77ec4171dce053d70c" //LIVE

/// Base Url
let API_MANAGER_GET_BASE_URL = "https://sunnuclear-qa.augustasoftsol.com:5003" //QA

//SignUp and SignIn Images
let SINGUP_GMAIL_IMAGE = "Googlelogo"
let SINGUP_FACEBOOK_IMAGE = "FacebookLogo"
let SINGUP_BACK_ARROW_IMAGE = "back"
let SINGUP_NEW_BACK_ARROW_IMAGE = "back"


//DashBoard
let DASHBOARD_BLACK_IMAGE = "menuDot"
let DASHBOARD_WHITE_IMAGE = "menuDotWhite"

let DASHBOARD_ADD_DEVICE_IMAGE = "addDevice"
let DASHBOARD_ADD_DEVICE_REFRESH_IMAGE = "refresh"

let DASHBOARD_IMAGE = "devicesDashboard"
let DASHBOARD_CHART_IMAGE = "chart"
let DASHBOARD_SETTING_IMAGE = "settings"

let DASHBOARD_IMAGE_WHITE = "dashBoardWhite"
let DASHBOARD_CHART_IMAGE_WHITE = "chartWhite"
let DASHBOARD_SETTING_IMAGE_WHITE = "settingWhite"

let LAST_SYNC_WHITE = "syncButton"
let LAST_SYNC_BLACK = "syncblack"

//Add Device
let ADD_DEVICE_LUFT_IMAGE = "Airfilter"

//CELL DISCLOUSRE
let CELL_DISCLOUSRE = "cellDisclosureIndicatorWhite"
let CELL_CHECKMARK = "Checkmark"

let CELL_SELECTED_CHECKMARK = "checkMarkSelected"
//let CELL_NON_CHECKMARK = "checkMarkNON"
let CELL_NEW_GOOD_CHECKMARK = "Checkmark"
let CELL_NON_CHECKMARK = "NoImage"
let CELL_BLANK_CHECKMARK = "checkMarkNON"

let INFO_IMAGE1 = "info1"
let INFO_IMAGE2 = "info2"
let INFO_IMAGE3 = "info3"

let BACKULOGO1 = "backLuftLogo"
let BACKULOGO2 = "blackUlogo"

//Color Code
let GOOGLE_COLOR_CODE = "#000000"
let FACEBOOK_COLOR_CODE = "#3B5998"
let UAT_TEXT = "(UAT)"




struct cellIdentity {
    static var blinkingCellIndentifier = "BlinkingViewTableViewCell"
    static var addDeviceCellIdentifier = "AddDeviceTableViewCell"
    
    static var settingCellIdentifier = "LTSettingListTableViewCell"
    static var settingHeaderCellIdentifier = "LTSettingHeaderViewTableViewCell"
    static var settingHeaderCellIdentifierNew = "LTSettingHeaderViewNewTableViewCell"
    static var luftDeviceTableViewCell = "LuftDeviceTableViewCell"
    static var deviceCollectionViewCell = "DeviceCollectionViewCell"
    static var deviceDataTableViewCell = "DeviceDataTableViewCell"
    static var deviceStatusTableViewCell = "DeviceStatusTableViewCell"
    static var headerViewCollectionViewCell = "HeaderViewCollectionViewCell"
    static var luftLogoTableViewCell = "LuftLogoTableViewCell"
    static var outsideDataTableViewCell = "OutsideDataTableViewCell"
    static var firmwareTableViewCell = "FirmwareTableViewCell"
    static var infoCollectionViewCell = "InfoCollectionViewCell"
}


//Messages
//Reset Password
let CONSTANT_SIGN_UP = "Sign Up"
let CONTENT_EMPTY_USERNAME = "Enter Email ID to continue"
let CONTENT_INVALID_EMAIL = "Invalid Email Address" //Enter valid email ID
let CONTENT_RESET_LINK_SENT = "Reset Link has been sent to your email"
let CONTENT_EMPTY_PASSWPRD = "Enter Password to continue"
let CONTENT_TEMP_NEW_GOOD_EMPTY_PASSWPRD = "Enter Temporary Password to continue"
let CONTENT_ALREADY_INVALID_EMAIL = "You have already entered this email id"
let CONTENT_CHAR_PASSWORD = "Password did not meet the requirements."
let CONTENT_MISMATCH_PASSWORD = "Password and Confirm Password not match"
let CONTENT_INVALID_SUMMARY = "Please check any one summary report"
let CONTENT_INVALID_TERMS_PRIVACY = "Please read the privacy policy"
//Setting
let CONTENT_VALID_DATA = "Enter valid data"
let CONTENT_NAME = "Invalid Name"
let CONTENT_FIRST_NAME = "Invalid First Name"
let CONTENT_LAST_NAME = "Invalid Last Name"
let CONTENT_PHONE_NUMBER = "Invalid Phone Number"

//Initial Setting
let INTIAL_CONTENT_FIRST_NAME = "Invalid First Name"
let INTIAL_CONTENT_LAST_NAME = "Invalid Last Name"
let INTIAL_CONTENT_BUILDING_TYPE = "Select Building Type"
let INTIAL_CONTENT_MITIGATION_SYSTEM = "Select Mitigation System"

//Radon
let RADONBQME_LOW_WARNING = "50"
let RADONBQME_HIGH_WARNING = "125"
let RADONPCII_LOW_WARNING = "2.0 pCi/l"
let RADONPCII_HIGH_WARNING = "4.0 pCi/l"

//Temperature
let TEMP_CELSIUS_LOW_WARNING = "15 Celsius"
let TEMP_CELSIUS_HIGH_WARNING = "24 Celsius"
let TEMP_CELSIUS_LOW_ALERT = "12 Celsius"
let TEMP_CELSIUS_HIGH_ALERT = "30 Celsius"

let TEMP_FAHRENHEIT_LOW_WARNING = "60 Fahrenheit"
let TEMP_FAHRENHEIT_HIGH_WARNING = "76 Fahrenheit"
let TEMP_FAHRENHEIT_LOW_ALERT = "54 Fahrenheit"
let TEMP_FAHRENHEIT_HIGH_ALERT = "86 Fahrenheit"

//Humidity
let HUMIDITY_PRECENTAGE_LOW_WARNING = "40 %"
let HUMIDITY_PRECENTAGE_HIGH_WARNING = "70 %"
let HUMIDITY_PRECENTAGE_LOW_ALERT = "30 %"
let HUMIDITY_PRECENTAGE_HIGH_ALERT = "80 %"

//Air Pressure
let AIRPRESSURE_INHG_LOW_WARNING = "29.70 inHg"
let AIRPRESSURE_INHG_HIGH_WARNING = "30.30 inHg"
let AIRPRESSURE_INHG_LOW_ALERT = "29.50 inHg"
let AIRPRESSURE_INHG_HIGH_ALERT = "30.50 inHg"

//Air Pressure
let AIRPRESSURE_KPA_LOW_WARNING = "100.6 kPa"
let AIRPRESSURE_KPA_HIGH_WARNING = "102.6 kPa"
let AIRPRESSURE_KPA_LOW_ALERT = "99.8 kPa"
let AIRPRESSURE_KPA_HIGH_ALERT = "103.2 kPa"

//Air Pressure
let AIRPRESSURE_MBAR_LOW_WARNING = "1006 mbar"
let AIRPRESSURE_MBAR_HIGH_WARNING = "1026 mbar"
let AIRPRESSURE_MBAR_LOW_ALERT = "999 mbar"
let AIRPRESSURE_MBAR_HIGH_ALERT = "1033 mbar"


//Eco2
let ECO2_LOW_WARNING = "1000 ppm"
let ECO2_HIGH_WARNING = "2000 ppm"


//Voc
let VOC_LOW_WARNING = "200 ppb"
let VOC_HIGH_WARNING = "450 ppb"


//Terms conditions and Privacy Policy
let TERMS_AND_CONDITIONS_TITLE = "Terms & Conditions"
let PRIVACY_POLICY_TITLE = "Privacy Policy"
let PRODUCT_WARRANTY = "Product Warranty"
let SERVICE_WARRANTY = "Service Warranty"
let TERMS_AND_CONDITIONS_URL = "Terms & Conditions"
let PRIVACY_POLICY_URL = "Privacy Policy"
let ACCOUNT = "Account"
let UNITS = "Units"


//ADD MY DEVICE
let WIFI_CONNECTED_TITLE_MESSAGE = "This device is already connected to Wi-Fi network"
let WIFI_CONNECTED_SAME_WIFI = "Continue using existing Wi-Fi"
let WIFI_CONNECTED_DIFFERENT_WIFI = "Connect to another Wi-Fi?"

let WIFI_CONNECTED_LATER = "Connect to Wi-Fi later?"

// Firmware update view title

let FW_WILL_UPDATE = "Select devices to be updated."
let FW_BLE_DEVICE = "Please, connect following devices to Wi-Fi first to enable Firmware Update."
let FW_COMPLETED_UPDATE = "Firmware is Up to Date"
let FW_COMPLETED_UPDATE_INITIATED = "The firmware update has been initiated. You will receive a notification once the firmware is updated."

let FW_UPDATE_ALERT = "Latest Firmware is available. Do you want to update the device?"
let LIVE_UAT_ALERT_MSG = "Application is in Live environment. Do you want to change it to UAT environment?"
let UAT_LIVE_ALERT_MSG = "Application is in UAT environment. Do you want to change it to Live environment?"
let UAT_LIVE_PASWORD_ALERT_MSG = "Enter the password to change the environment changes"

let DEVELOPER_ACCESS_ALERT_MSG = "Enter the password to access the developer option"

let DEVICE_TIME_UPDATE_ALERT = "We detected your luft monitor time may be off! Would you like to synchronize now?"

let APPLE_ALERT_MSG = "Please enter your email-id"
let MANDATORY_APPLE_ALERT_MSG = "Mandatory email-id"

let LUFT_APP_NAME = "LUFT"

let LUFT_DETAILS_UPDATED = "Details Updated Successfully"

let LUFT_BLUETOOTH_APPLY_ALL = "Caution: Changes will not be applied to devices connected via Bluetooth. Please, update these devices individually."

let LUFT_BLUETOOTH_RESET = "Your device is reset. Please remove from BlueTooth. Goto->Settings>Bluetooth>Select device(i)>Forget this Device"



