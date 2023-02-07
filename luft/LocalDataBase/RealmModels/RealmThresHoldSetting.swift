//
//  RealmThresHoldSetting.swift
//  luft
//
//  Created by iMac Augusta on 10/18/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class RealmThresHoldSetting: Object {
    
    @objc dynamic var auto_id = 0
    @objc dynamic var device_id = 0
    @objc dynamic var pollutant = ""
    @objc dynamic var low_waring_value = ""
    @objc dynamic var high_waring_value = ""
    @objc dynamic var low_alert_value = ""
    @objc dynamic var high_alert_value = ""
    @objc dynamic var temp_offset = ""
    @objc dynamic var should_notify = Bool()
    @objc dynamic var sync = Bool()
    
    override class func primaryKey() -> String? {
        return "auto_id"
    }
}
