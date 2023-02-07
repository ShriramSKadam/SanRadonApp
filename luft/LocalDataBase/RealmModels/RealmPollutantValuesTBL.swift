//
//  RealmPollutantValuesTBL.swift
//  luft
//
//  Created by iMac Augusta on 10/22/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class RealmPollutantValuesTBL: Object {
    
    @objc dynamic var auto_id = 0
    @objc dynamic var device_SerialID : String = ""
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
    @objc dynamic var timeStamp: Int = 0
    @objc dynamic var isWifi = false
    
    override class func primaryKey() -> String? {
        return "auto_id"
    }
}

