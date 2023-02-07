//
//  LTViewController.swift
//  luft
//
//  Created by Augusta on 09/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData

class LTViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        if  AppSession.shared.getUserSelectedTheme() == 2{
            AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
        }else {
            AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
        }
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        //UIApplication.shared.statusBarView?.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        self.setLatestStatusBar()
        self.view.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.currentTheme().statusBarTextColor
    }
    
    func readBuildingTypeData(idBuildType:Int) -> String  {
        
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_BUILDING_TYPE)
        let predicate = NSPredicate(format: "id = %@", String(format: "%d", idBuildType))
        fetch.predicate = predicate
        do {
            let result = try context.fetch(fetch)
            for data in result as! [NSManagedObject] {
                return data.value(forKey: "name") as! String
            }
        } catch {
            print("Failed")
        }
        return ""
    }
    
    func readMitigationTypeData(idBuildType:Int) -> String  {
        
        let context = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_MITIGATION_TYPE)
        let predicate = NSPredicate(format: "id = %@", String(format: "%d", idBuildType))
        fetch.predicate = predicate
        do {
            let result = try context.fetch(fetch)
            for data in result as! [NSManagedObject] {
                return data.value(forKey: "name") as! String
            }
        } catch {
            print("Failed")
        }
        return ""
    }
    
}
