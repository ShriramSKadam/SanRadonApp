//
//  RealmColorSetting.swift
//  luft
//
//  Created by iMac Augusta on 10/18/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class RealmColorSetting: Object {
    
    @objc dynamic var auto_id = 0
    @objc dynamic var device_id = 0
    @objc dynamic var color_type = ""
    @objc dynamic var color_code = ""
    @objc dynamic var color_code_disable = Bool()
    @objc dynamic var night_light_start_time = 0
    @objc dynamic var night_light_end_time = 0
    @objc dynamic var night_light_color_on_off = Bool()
    @objc dynamic var color_led_brightness = ""
    
    
    @objc dynamic var sync = Bool()
    
    
    override class func primaryKey() -> String? {
        return "auto_id"
    }
}


