//
//  FliterViewController.swift
//  Luft
//
//  Created by iMac Augusta on 11/12/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData
import Realm
import RealmSwift

protocol LTFliterDelegate:class {
    func selectedFliter(fliterMenuType:Int)
}

class FliterViewController: UIViewController {
    
    @IBOutlet weak var btnClosMenu: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!

    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var viewSubSortby: UIView!
    @IBOutlet weak var viewSubSortOrder: UIView!
    @IBOutlet weak var viewSubButton: UIView!
    @IBOutlet weak var tblViewFilter: UITableView!
    @IBOutlet weak var viewPicker: UIView!
    
    
    @IBOutlet weak var btnSortByDeviceNameUpdateBy: UIButton!
    @IBOutlet weak var btnSortByAscendingDescending: UIButton!
    @IBOutlet weak var btnSortSave: UIButton!
    
    var fliterDelegate:LTFliterDelegate? = nil
    var arraySortBy = [String]()
    var arraySortOrder = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnClosMenu.addTarget(self, action:#selector(self.btnTapClose(_sender:)), for: .touchUpInside)
        self.btnCancel.addTarget(self, action:#selector(self.btnTapClose(_sender:)), for: .touchUpInside)
        self.btnSortSave.addTarget(self, action:#selector(self.btnSortSaveTapped(_sender:)), for: .touchUpInside)
        self.btnSortByDeviceNameUpdateBy.addTarget(self, action:#selector(self.btnSortByDeviceNameUpdateByTapped(_sender:)), for: .touchUpInside)
        self.btnSortByAscendingDescending.addTarget(self, action:#selector(self.btnSortByAscendingDescendingTapped(_sender:)), for: .touchUpInside)
        
        self.arraySortBy = ["Device Name","Last Updated"]
        self.arraySortOrder = ["Ascending","Descending"]
        self.tblViewFilter?.delegate = self
        self.tblViewFilter?.dataSource = self
        self.tblViewFilter.register(UINib(nibName: cellIdentity.settingCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.settingCellIdentifier)
        self.tblViewFilter.register(UINib(nibName: cellIdentity.settingHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentity.settingHeaderCellIdentifier)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadTheme()
    }
    func loadTheme() {
        self.viewBack.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.viewPicker.backgroundColor = ThemeManager.currentTheme().settingViewBackgroundColor
        self.viewSubSortby.backgroundColor = ThemeManager.currentTheme().filterSubViewBGColor
        self.viewSubSortOrder.backgroundColor = ThemeManager.currentTheme().filterSubViewBGColor
        self.viewBack.layer.cornerRadius = 10.0
        self.viewBack.clipsToBounds = true
        self.tabBarController?.tabBar.isHidden = true
        self.viewPicker.isHidden = true
        self.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func loadData()  {
        
        let sortFilterType: Int = AppSession.shared.getUserSortFilterType()
        switch sortFilterType {
        case SortFilterTypeEnum.SortDeviceNameAscending.rawValue:
            self.btnSortByDeviceNameUpdateBy.setTitle("Device Name", for: .normal)
            self.btnSortByAscendingDescending.setTitle("Ascending", for: .normal)
        case SortFilterTypeEnum.SortDeviceNameDescending.rawValue:
            self.btnSortByDeviceNameUpdateBy.setTitle("Device Name", for: .normal)
            self.btnSortByAscendingDescending.setTitle("Descending", for: .normal)
        case SortFilterTypeEnum.SortUpdateByNameAscending.rawValue:
            self.btnSortByDeviceNameUpdateBy.setTitle("Last Updated", for: .normal)
            self.btnSortByAscendingDescending.setTitle("Ascending", for: .normal)
        case SortFilterTypeEnum.SortUpdateByNameDescending.rawValue:
            self.btnSortByDeviceNameUpdateBy.setTitle("Last Updated", for: .normal)
            self.btnSortByAscendingDescending.setTitle("Descending", for: .normal)
        default:
            print("")
        }
    }
}

extension FliterViewController {
    
    @objc func btnTapClose(_sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func btnSortSaveTapped(_sender:UIButton) {
        
        if  self.btnSortByDeviceNameUpdateBy.titleLabel?.text == "Device Name" && self.btnSortByAscendingDescending.titleLabel?.text == "Ascending" {
            AppSession.shared.setUserSortFilterType(sortfilterType: 1)
        }
        if  self.btnSortByDeviceNameUpdateBy.titleLabel?.text == "Device Name" &&   self.btnSortByAscendingDescending.titleLabel?.text == "Descending" {
            AppSession.shared.setUserSortFilterType(sortfilterType: 2)
        }
        
        if  self.btnSortByDeviceNameUpdateBy.titleLabel?.text == "Last Updated" && self.btnSortByAscendingDescending.titleLabel?.text == "Ascending" {
            AppSession.shared.setUserSortFilterType(sortfilterType: 3)
        }
        if  self.btnSortByDeviceNameUpdateBy.titleLabel?.text == "Last Updated" &&   self.btnSortByAscendingDescending.titleLabel?.text == "Descending" {
            AppSession.shared.setUserSortFilterType(sortfilterType: 4)
        }
        print(AppSession.shared.getUserSortFilterType())
        self.fliterDelegate?.selectedFliter(fliterMenuType: 0)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func btnSortByDeviceNameUpdateByTapped(_sender:UIButton) {
        self.viewPicker.isHidden = false
        self.tblViewFilter.tag = 100
        self.tblViewFilter.reloadData()
    }
    
    @objc func btnSortByAscendingDescendingTapped(_sender:UIButton) {
        self.viewPicker.isHidden = false
        self.tblViewFilter.tag = 101
        self.tblViewFilter.reloadData()
    }
}

// MARK: - Table View Data's
extension FliterViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentity.settingHeaderCellIdentifier) as! LTSettingHeaderViewTableViewCell
        switch section {
        case 0:
            if self.tblViewFilter.tag == 100 {
                cell.lblHeaderTilte.text = "Sort By"
            }else {
                cell.lblHeaderTilte.text = "Sort Order"
            }
            cell.cellHeaderBackView.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
        default:
            cell.lblHeaderTilte.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:LTSettingListTableViewCell = self.tblViewFilter.dequeueReusableCell(withIdentifier: cellIdentity.settingCellIdentifier, for: indexPath) as! LTSettingListTableViewCell
        return self.generalCellSetting(cellValue: cell, index: indexPath)
    }
    
    func generalCellSetting(cellValue:LTSettingListTableViewCell,index:IndexPath) -> LTSettingListTableViewCell {
        
        if self.tblViewFilter.tag == 100 {
             cellValue.lblTitleCell.text = self.arraySortBy[index.row]
        }else {
            cellValue.lblTitleCell.text = self.arraySortOrder[index.row]
        }
        cellValue.lblTitleCell.textColor = ThemeManager.currentTheme().ltCellTitleColor
        cellValue.lblSubTitleCell.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        cellValue.lblTitleView.isHidden = false
        cellValue.lblSubTitleView.isHidden = true
        cellValue.lblTitleCell.textAlignment = .left
        cellValue.lblSubTitleCell.textAlignment = .right
        cellValue.imgViewDisclosureCell.image = nil
        cellValue.selectionStyle = .none
        cellValue.cellBackView.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
        cellValue.lblTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblSubTitleView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.cellImageView.backgroundColor = ThemeManager.currentTheme().clearColor
        cellValue.lblCellBorder.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        return cellValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tblViewFilter.tag == 100 {
            self.btnSortByDeviceNameUpdateBy.setTitle(self.arraySortBy[indexPath.row], for: .normal)
        }else {
            self.btnSortByAscendingDescending.setTitle(self.arraySortOrder[indexPath.row], for: .normal)
        }
        self.viewPicker.isHidden = true
    }
}


