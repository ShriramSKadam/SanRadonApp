//
//  Session.swift
//  
//
//  Created by CogInfo-Nandakumar on 23/11/17.
//  Copyright © 2017 CogInfo-Nandakumar. All rights reserved.
//

import UIKit

public class Session: NSObject {
    var userDefaults :UserDefaults
    
    class var sharedInstance: Session {
        struct Static {
            static let instance = Session()
        }
        return Static.instance
    }
    
    override init() {
        self.userDefaults = UserDefaults()
    }
    
    func removeAllInstance()  {
            let defaults = userDefaults
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                print(key)
                if key == "deviceID" || key == "saltKey" || key == "isAppFirst"{
                    
                }else {
                    defaults.removeObject(forKey: key)
                }
            }
    }
    
    func saveValue() {
        self.userDefaults.synchronize()
    }
    
    
//    func setAccessToken (_ value: String) {
//        
//        self.userDefaults.set(value, forKey: "AccessToken")
//        self.saveValue()
//    }
//    
//    func getAccessToken ()-> String {
//        let value: String? = self.userDefaults.object(forKey: "AccessToken") as? String
//        return value ?? ""
//    }
    
   
}


