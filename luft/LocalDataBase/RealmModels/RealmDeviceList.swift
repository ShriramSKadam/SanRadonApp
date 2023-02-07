//
//  RealmDeviceList.swift
//  luft
//
//  Created by iMac Augusta on 10/18/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class RealmDeviceList: Object {
    
    @objc dynamic var auto_id = 0
    @objc dynamic var device_id = 0
    @objc dynamic var device_token = ""
    @objc dynamic var name = ""
    @objc dynamic var serial_id = ""
    @objc dynamic var user_id = 0
    @objc dynamic var shared = Bool()
    @objc dynamic var wifi_status = Bool()
    @objc dynamic var shared_user_email = ""
    @objc dynamic var time_zone = ""
    @objc dynamic var firmware_version = ""
    @objc dynamic var maxLogIndex = ""
    @objc dynamic var timeDiffrence = ""
    @objc dynamic var deviceLat = ""
    @objc dynamic var deviceLong = ""
    
    @objc dynamic var pressure_altitude_correction_status = Bool()
    @objc dynamic var pressure_elevation = ""
    @objc dynamic var pressure_elevation_deviation_mbr = ""
    @objc dynamic var pressure_elevation_deviation_ihg = ""
    
    @objc dynamic var isBluetoothSync = Bool()
    
    override class func primaryKey() -> String? {
        return "auto_id"
    }
}

