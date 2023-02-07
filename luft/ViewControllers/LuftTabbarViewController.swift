//
//  LuftViewController.swift
//  luft
//
//  Created by iMac Augusta on 9/23/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

class LuftTabbarViewController: UITabBarController,UITabBarControllerDelegate  {

    var strTabbarSelectedPeripheral: String = "LUFT"
    var deviceIDSelectedPrevious:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        self.tabBar.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        
        let tabHome = self.tabBar.items![0]
        tabHome.image = ThemeManager.currentTheme().luftDashBoardIconImage.withRenderingMode(.alwaysOriginal) // deselect image
        
        let tabFoll = self.tabBar.items![1]
        tabFoll.image = ThemeManager.currentTheme().luftDashBoardChartIconImage.withRenderingMode(.alwaysOriginal)
        
        let tabMsg = self.tabBar.items![2]
        tabMsg.image = ThemeManager.currentTheme().luftDashBoardSettingIconImage.withRenderingMode(.alwaysOriginal)
       // self.tabBar.isTranslucent = false
        self.tabBar.clipsToBounds = true
        self.tabBar.layer.addBorder(edge: .top, color: ThemeManager.currentTheme().ltCellHeaderTabbarBorderColor, thickness: 1.0)
    }
    
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item")
        print(self.strTabbarSelectedPeripheral)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let navViewController = (viewController as! UINavigationController).topViewController!
        if (navViewController.isKind(of: SettingViewController.self) == true) {
            let vc = navViewController as! SettingViewController
            vc.luftSettingTabbar = 100
        }
        if (navViewController.isKind(of: ChartViewController.self) == true) {
            let vc = navViewController as! ChartViewController
            if Reachability.isConnectedToNetwork() == true {
                vc.showAct()
                vc.isFromLoad = false
            }
        }
        
        if (navViewController.isKind(of: LuftDeviceViewController.self) == true) {
            let vc = navViewController as! LuftDeviceViewController
            if Reachability.isConnectedToNetwork() == true {
                //Not required for initial loading since no devices-Gauri-02/07/2022
                //vc.showAct()
                vc.isFromLoad = false
            }
        }
        print("calling")
        return true
    }
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let navViewController = (viewController as! UINavigationController).topViewController!
        if (navViewController.isKind(of: ChartViewController.self) == true) {
            if self.deviceIDSelectedPrevious != 0{
                let vc = navViewController as! ChartViewController
                vc.luftChartDeviceIDPrevious = self.deviceIDSelectedPrevious
                if Reachability.isConnectedToNetwork() == false {
                    vc.getDeviceList(isAPICall: false)
                }else {
                     vc.callMyDeviceAPI()
                }
            }else {
                self.deviceIDSelectedPrevious = -100
            }
        }
        
        if (navViewController.isKind(of: LuftDeviceViewController.self) == true) {
            if self.deviceIDSelectedPrevious != 0{
                let vc = navViewController as! LuftDeviceViewController
                vc.luftDashBoardDeviceIDPrevious = self.deviceIDSelectedPrevious
                if Reachability.isConnectedToNetwork() == false {
                    vc.getDeviceList(isAPICall: false)
                }else {
                    vc.callMyDeviceAPI()
                }
            }else {
                self.deviceIDSelectedPrevious = -100
            }
        }
        print("calling bottom")
    }
}
