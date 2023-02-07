//
//  MenuViewController.swift
//  luft
//
//  Created by iMac Augusta on 10/14/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit

protocol LTSideMenuDelegate:class {
    func selectedMenuID(sideMenuType:SideMenuType)
}

class MenuViewController: UIViewController {

    @IBOutlet weak var btnClosMenu: UIButton!
    @IBOutlet weak var tblMenu: UITableView!
    var menuDelegate:LTSideMenuDelegate?
    var isWifiState:Int? = 0
    var isSelectedDevice:RealmDeviceList? = nil
    var selectedMenu:SideMenuType = .SideMenuNone
    
    var arrSectionTilte: [String] = ["Rename","Notifications","Check for Firmware Update","Remove Device","Connect to Wi-Fi","Temperature Offset","Share Data","FAQ", "Contact Support"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblMenu.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        self.btnClosMenu.addTarget(self, action:#selector(self.btnTapClose(_sender:)), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tblMenu?.delegate = self
        self.tblMenu?.dataSource = self
        self.tblMenu.register(UINib(nibName: cellIdentity.settingCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.settingCellIdentifier)
        self.loadMenudata()
        self.tabBarController?.tabBar.isHidden = true
    }
    func loadMenudata() {
        if self.isSelectedDevice?.wifi_status == true {
            self.arrSectionTilte.removeAll()
            self.arrSectionTilte = ["Rename","Notifications","Check for Firmware Update","Remove Device","Remove from Wi-Fi","Temperature Offset","Share Data","FAQ", "Contact Support"]
          //  self.arrSectionTilte = ["Rename","Notifications","Check for Firmware Update","Remove Device","Connect to Wi-Fi","Remove from Wi-Fi","Temperature Offset","Share Data","FAQ", "Contact Support"]
        }
        self.tblMenu?.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        //UIApplication.shared.statusBarView?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
    }
    
}

extension MenuViewController {
    
    @objc func btnTapClose(_sender:UIButton) {
        self.selectedMenu = .SideMenuNone
        self.menuDelegate?.selectedMenuID(sideMenuType: self.selectedMenu)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension MenuViewController:UITableViewDelegate,UITableViewDataSource {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSectionTilte.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellValue = tableView.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier) as! LTSettingListTableViewCell
        cellValue.lblTitleCell.text = self.arrSectionTilte[indexPath.row]
        cellValue.lblSubTitleCell.text = ""
        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleView.isHidden = true
        cellValue.lblTitleCell.textAlignment = .left
        cellValue.lblSubTitleCell.textAlignment = .right
        cellValue.imgViewDisclosureCell.image = nil
        cellValue.selectionStyle = .none
        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellHeaderTitleColor
        cellValue.lblCellBorder.alpha = 0.4
        return cellValue
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? LTSettingListTableViewCell {
            
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuRename.rawValue.lowercased(){
                self.selectedMenu = .SideMenuRename
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuNotification.rawValue.lowercased(){
                self.selectedMenu = .SideMenuNotification
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuFrimware.rawValue.lowercased(){
                self.selectedMenu = .SideMenuFrimware
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuRemoveDevice.rawValue.lowercased(){
                self.selectedMenu = .SideMenuRemoveDevice
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuConnectToWifi.rawValue.lowercased(){
                self.selectedMenu = .SideMenuConnectToWifi
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuRemoveToWifi.rawValue.lowercased(){
                self.selectedMenu = .SideMenuRemoveToWifi
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuShareData.rawValue.lowercased(){
                self.selectedMenu = .SideMenuShareData
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuTempOffset.rawValue.lowercased(){
                self.selectedMenu = .SideMenuTempOffset
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuFAQ.rawValue.lowercased(){
                self.selectedMenu = .SideMenuFAQ
            }
            if cell.lblTitleCell.text?.lowercased() == SideMenuType.SideMenuContactSupport.rawValue.lowercased(){
                self.selectedMenu = .SideMenuContactSupport
            }
            self.menuDelegate?.selectedMenuID(sideMenuType: self.selectedMenu)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}



