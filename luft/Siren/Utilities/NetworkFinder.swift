//
//  NetworkFinder.swift
//  Luft
//
//  Created by Shriram Subash on 17/10/22.
//  Copyright © 2022 iMac. All rights reserved.
//
import UIKit
import Foundation
import CoreBluetooth
import CoreLocation
import SystemConfiguration.CaptiveNetwork
import SystemConfiguration
import CoreTelephony


enum NetworkFinder{
    case twoG
    case threeG
    case fourG
    case fiveG
    case wifi
    case unknown
    case notReachable
}

class NetworkDeviceFinder: NSObject {


class func getConnectionType() -> NetworkFinder {
    guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
        return NetworkFinder.notReachable
    }
    
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability, &flags)
    
    let isReachable = flags.contains(.reachable)
    let isWWAN = flags.contains(.isWWAN)
    
    if isReachable {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrierType = networkInfo.serviceCurrentRadioAccessTechnology
        
        guard let carrierTypeName = carrierType?.first?.value else {
            return NetworkFinder.unknown
        }
        if isWWAN {
            
            switch carrierTypeName {
            case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                print("Reachable Via 2G")
                return NetworkFinder.twoG
                
            case CTRadioAccessTechnologyWCDMA,
                CTRadioAccessTechnologyHSDPA,
                CTRadioAccessTechnologyHSUPA,
                CTRadioAccessTechnologyCDMAEVDORev0,
                CTRadioAccessTechnologyCDMAEVDORevA,
                CTRadioAccessTechnologyCDMAEVDORevB,
            CTRadioAccessTechnologyeHRPD:
                print("Reachable Via 3G")
                return NetworkFinder.threeG
            case CTRadioAccessTechnologyLTE:
                print("Reachable Via 4G")
                return NetworkFinder.fourG
            default:
                print("Reachable Via 5G")
                return NetworkFinder.fiveG
            }
        } else {
            print("Reachable Via WIFI")
            if #available(iOS 14.1, *) {
                switch carrierTypeName {
                case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                    print("Reachable Via 2G")
                    return NetworkFinder.twoG
                    
                case CTRadioAccessTechnologyWCDMA,
                    CTRadioAccessTechnologyHSDPA,
                    CTRadioAccessTechnologyHSUPA,
                    CTRadioAccessTechnologyCDMAEVDORev0,
                    CTRadioAccessTechnologyCDMAEVDORevA,
                    CTRadioAccessTechnologyCDMAEVDORevB,
                CTRadioAccessTechnologyeHRPD:
                    print("Reachable Via 3G")
                    return NetworkFinder.threeG
                case CTRadioAccessTechnologyLTE:
                    print("Reachable Via 4G")
                    return NetworkFinder.fourG
                    
                case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
                    print("Reachable Via 5G")
                    return NetworkFinder.fiveG
                    
                default:
                    return NetworkFinder.wifi
                    
                }
            } else {
                // Fallback on earlier versions
                switch carrierTypeName {
                case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                    print("Reachable Via 2G")
                    return NetworkFinder.twoG
                    
                case CTRadioAccessTechnologyWCDMA,
                    CTRadioAccessTechnologyHSDPA,
                    CTRadioAccessTechnologyHSUPA,
                    CTRadioAccessTechnologyCDMAEVDORev0,
                    CTRadioAccessTechnologyCDMAEVDORevA,
                    CTRadioAccessTechnologyCDMAEVDORevB,
                CTRadioAccessTechnologyeHRPD:
                    print("Reachable Via 3G")
                    return NetworkFinder.threeG
                case CTRadioAccessTechnologyLTE:
                    print("Reachable Via 4G")
                    return NetworkFinder.fourG
                default:
                    return NetworkFinder.wifi
                }
            }
        }
    } else {
        return NetworkFinder.notReachable
    }
}

}
