
//  HttpMacro.swift
//  Created by CogInfo-Nandakumar on 08/11/17.
//  Copyright © 2017 CogInfo-Nandakumar. All rights reserved.
//

import Foundation
import UIKit

typealias kSuccessBlock = (_ success : Bool, _ message : String) ->()
typealias kErrorBlock = (_ errorMesssage: String) -> ()



typealias kModelSuccessBlock = (_ success : Bool, _ message : String, _ responseObject:AnyObject) ->()
typealias kModelErrorBlock = (_ errorMesssage: String) -> ()

let MAX_TITLE_CHAR = 300
let MAX_FIRST_NAME_CHAR = 70
let MIN_TITLE_CHAR = 10
let MAX_VIDEO_CHAR = 100
let MAX_YEAR_CHAR = 4
let MAX_LABEL_NAME = 20
let MIN_LABEL_NAME = 8
let MIN_WINE_MAKER = 5
let MAX_WINE_MAKER = 10
let MIN_COMMENTS_COUNT = 1
let MAX_COMMENTS_COUNT = 500



//GoogleAPi Key
let GOOGLE_API_KEY = "AIzaSyBYBnCTmsA0l1OQ2z5PvhHeD9mleYbPrG0"

//TwitterAPi Key
let TWITTER_CONSUMER_API_KEY = "a0Jbgu43KqWcHfNPSg3tf5sJn"
let TWITTER_CONSUMER_SECRET_API_KEY = "oSP8UTeXrrFDvRc8v2nfYT9gBArG4kDBT9jCZLE8zFqenqClxS"

/// Signup/signin
let API_SIGNUP_EMAIL = "accounts/TasterUserRegister"

let API_LOGIN_FB = "accounts/socialsignin"
let API_SIGNUP_FB = "accounts/SocialRegister"

//Login
let API_LOGIN_EMAIL = "/api/Admin/Login"

//Setting
let API_USER_ME = "/api/AppUser/Me"
let API_SETTING_HOME_BULIDING_TYPE = "/api/Device/HomebuildingType"
let API_SETTING_HOME_MITIGATION_TYPE = "/api/Device/HomeMitigationSystemType"
let API_SETTING_SAVE_DEVICE_DATA = "/api/Device/UpdateDeviceSettingDetails"



// App Constant
let MAX_EMAIL_CHARACTER_COUNT_LEFT = 64
let MAX_EMAIL_CHARACTER_COUNT_RIGHT = 255
let MAX_ADDRESS = 30
let MIN_PASSWORD = 8
let MAX_PASSWORD = 30
let MIN_USERNAME = 4
let MAX_USERNAME = 19
let MAX_ZIPCODE = 5
let MAX_NUMBER = 10
let MAX_FIRSTNAME = 20
let MAX_LASTNAME = 20
let MAX_DESCRIPTION = 1000
let MAX_EMAIL_COUNT = 100
let MAX_EVENT_COUNT = 50

let CONTENT_VALID_EMAIL = "Invalid Email"
let CONTENT_PLEASE_WAIT_LOADING = "Please Wait Loading . . ."
let PROFILE_PHOTO_TITLE = "Take photo or choose photo"
let TAKE_PHOTO = "Take photo"
let CHOOSE_LIBRARY = "Choose from Library"
let TITLE_CANCEL = "Cancel"
let NETWORK_CONNECTION = "Please check your network connection"

let EXISTSPROFESSONALUSER = "10015"
