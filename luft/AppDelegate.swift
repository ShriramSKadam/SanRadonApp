//
//  AppDelegate.swift
//  luft
//
//  Created by iMac Augusta on 9/19/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FacebookCore
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import Crashlytics
import Fabric
import UserNotifications
import Siren

var currentDeviceToken = String()
var currentDeviceId =  String()

//let GOOGLE_CLIENT_ID = "93718205220-k6clurqfth2jr9ll9lna8jnck5ie99o2.apps.googleusercontent.com"

let GOOGLE_CLIENT_ID = "33913506360-01cep8ajpoh2g78q415c66msv1oi3oco.apps.googleusercontent.com"


protocol SocketDelegate {
    func connectionSuccessfull(sucess : Bool)
}

var textLog = TextLog.sharedInstance

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.crashlyticsandIntialSetup()
        textLog.write("App Launched")
        // for setup initial APNS settings
        callSirenForVersionCheck()
        self.setupNotification(application: application)
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        //AppSession.shared.setLiveState(state:2)
        if #available(iOS 13.0, *) {
         window?.overrideUserInterfaceStyle = .light
        }
        return true
    }
    
    func getDeviceUUID() -> String? {
        let keychain = Keychain()
        var deviceId = keychain["deviceId"] // Get string
        if deviceId == nil {
            deviceId = UUID().uuidString
            keychain["deviceId"] = deviceId
        }
        return deviceId
    }
    
    func crashlyticsandIntialSetup()  {
        if AppSession.shared.getUserSelectedTheme() == 2{
            AppSession.shared.setTheme(themeType: Theme.theme2.rawValue)
        }else {
            AppSession.shared.setTheme(themeType: Theme.theme1.rawValue)
        }
        
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        currentDeviceId = self.getDeviceUUID() ?? ""
        currentDeviceToken = ""
        GIDSignIn.sharedInstance().clientID = GOOGLE_CLIENT_ID
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        Fabric.sharedSDK().debug = true
        Crashlytics.sharedInstance().setUserEmail("gauri.shankar@augustahitech.com")
      
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if BackgroundBLEManager.shared.isBleBackGroundSyncDevice == true {
            Helper.shared.removeBleutoothConnection()
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadDashboardNoti"), object: nil, userInfo: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "luft")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - APNS Settings

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func setupNotification(application:UIApplication) {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
        
        self.registerForRemoteNotification()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func registerForRemoteNotification() {
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound,.badge,.alert]) { (granted, error) in
                guard error == nil else {
                    print("Notification registration error - \(error?.localizedDescription ?? "Unknown error in register notification.")")
                    Helper().showSnackBarAlert(message: error?.localizedDescription ?? "Unknown error when register notification.", type: .Failure)
                    return
                }
                if granted {
                    //Do stuff here..
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
                else {
                    
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound,.badge,.alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // 1. Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
        Helper.shared.showSnackBarAlertLong(message: error.localizedDescription, type: .Failure)
    }
    
    // 2. Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        currentDeviceToken = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(currentDeviceToken)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        print("didReceiveRemoteNotification")
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
//        let state = UIApplication.shared.applicationState
//        guard state == .active else {
//            completionHandler(.alert)
//            return
//        }
        completionHandler(.alert)
    }
}


public extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
          
}

extension AppDelegate {
    func callSirenForVersionCheck() {
        let siren = Siren.shared
        siren.presentationManager =  PresentationManager (appName: "lüft")
//        siren.presentationManager =  PresentationManager (appName: "lüft", alertTitle: "there is an update", alertMessage: "please update", updateButtonTitle: "update da", nextTimeButtonTitle: "cancel")
        siren.rulesManager = RulesManager(globalRules: .annoying,
        showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)

        siren.wail { results in
            switch results {
            case .success(let updateResults):
                print("AlertAction ", updateResults.alertAction)
                print("Localization ", updateResults.localization)
                print("Model ", updateResults.model)
                print("UpdateType ", updateResults.updateType)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
