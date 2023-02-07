//
//  RealmDBModels.swift
//  luft
//
//  Created by APPLE on 21/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class RealmDBModels: NSObject {

}


class ColorSettings: Object {
    @objc dynamic  var Device_ID: Int = 0
    @objc dynamic  var Color: String = ""
    @objc dynamic  var sync: Int = 0
    @objc dynamic  var Enabled: String = ""
    @objc dynamic  var endTime: Int = 0
    @objc dynamic  var startTime: Int = 0
    @objc dynamic  var Tag: String = ""
}

class DeviceDetailsJson: Object {
    
    @objc dynamic  var Device_ID: Int = 0
    @objc dynamic  var wifistatus: Int = 0
    @objc dynamic  var Name: String = ""
    @objc dynamic  var Professionalemail: String = ""
    @objc dynamic  var IsShared: Int = 0
    @objc dynamic  var User_ID: String = ""
    @objc dynamic  var SerialNumber: String = ""
    
}

class DeviceSettings: Object{
    
    @objc dynamic  var HAV: String = ""
    @objc dynamic  var Device_ID: Int = 0
    @objc dynamic  var sync: Int = 0
    @objc dynamic  var shouldNotify: Int = 0
    @objc dynamic  var HWV: String = ""
    @objc dynamic  var LAV: String = ""
    @objc dynamic  var Pollutant: String = ""
    @objc dynamic  var LWV: String = ""
    
}

class PollutantUnits: Object{
    
    @objc dynamic var Temperature: String?
    @objc dynamic var Radon: String?
    @objc dynamic var AirPressure: String?
    @objc dynamic var UserID: String?
    
}

class PollutantValues: Object{
    
    @objc dynamic var QuickSync: Int = 0
    @objc dynamic var Device_ID: Int = 0
    @objc dynamic var LogIndex: Int = 0
    @objc dynamic var Temperature: Float = 0
    @objc dynamic var CO2: Float = 0
    @objc dynamic var Radon: Float = 0
    @objc dynamic var AirPressure: Float = 0
    @objc dynamic var VOC: Float = 0
    @objc dynamic var date: Date = Date(timeIntervalSince1970: 1)
    @objc dynamic var Humidity: Float = 0
    @objc dynamic var onlyDate: String = ""
    @objc dynamic var WeekValue: String = ""
    @objc dynamic var dummyValue: Int = 0

}

class UserDetailsJson: Object{
    
    @objc dynamic var Email: String = ""
    @objc dynamic var FirstName: String = ""
    @objc dynamic var LastName: String = ""
    @objc dynamic var Dob: String = ""
    @objc dynamic var Gender: String = ""
    @objc dynamic var Mobile: String = ""
    
}
