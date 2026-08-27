//
//  AppDelegate.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import FBSDKLoginKit
import FBSDKShareKit
import FacebookCore
import FacebookLogin
import FacebookShare
//import Fabric
import TwitterKit
import Crashlytics
import LinkedinSwift
import BRYXBanner
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var allowRotation: Bool = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DispatchQueue.main.async {
            FIRApp.configure()
        }
        
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return true
        }
        gai.tracker(withTrackingId: "UA-110186272-2")
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true
        
        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        //gai.logger.logLevel = .verbose;
        
        //Fabric.with([Crashlytics.self])
        TWTRTwitter.sharedInstance().start(withConsumerKey:HulaConstants.twitterKey, consumerSecret:HulaConstants.twitterSecret)
    
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // facebook log
        AppEventsLogger.activate(application)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if allowRotation == true {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if LinkedinSwiftHelper.shouldHandle(url) {
            if #available(iOS 9.0, *) {
                return LinkedinSwiftHelper.application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            }
        }
        
        let ttrsession = TWTRTwitter.sharedInstance().application(app, open: url, options: options);
        if ttrsession {
            return true
        }
        
        
        if #available(iOS 9.0, *) {
            let sourceApplication = AppDelegate.facebookSourceApplication(from: options)
            let isHandled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: options[.annotation])
            return isHandled
        }
        
        // manual hack to check twitter validation
        //if url.pathComponents
        
        return false
    }

    /// Soft-read Facebook deep-link sourceApplication — missing keys must not force-cast crash.
    class func facebookSourceApplication(from options: [UIApplicationOpenURLOptionsKey : Any]) -> String? {
        return options[.sourceApplication] as? String
    }
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                
                
                guard granted else { return }
                self.getNotificationSettings()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                DispatchQueue.main.async {
                    guard settings.authorizationStatus == .authorized else { return }
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = AppDelegate.deviceTokenHex(deviceToken)
        print("Device Token: \(token)")
        HulaUser.sharedInstance.deviceId = token
        HulaUser.sharedInstance.updateServerData()
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //print(userInfo)
        
        
        if let text = AppDelegate.pushAlertText(from: userInfo) {
            let banner = Banner(title: NSLocalizedString("Notification", comment: ""), subtitle: text, backgroundColor: HulaConstants.appMainColor)
            banner.dismissesOnTap = true
            banner.didTapBlock = {
                // Presenting swappView directly skipped the login gate in
                // openSwapView and could surface stale in-memory trades after logout.
                if let portraitNav = self.portraitNavigationController(from: self.window?.rootViewController) {
                    portraitNav.openSwapView()
                }
            }
            banner.show(duration: 5.0)
            HLDataManager.sharedInstance.loadUserNotifications()
        } else {
            print("error")
        }
    }

    /// Hex-encode APNS device tokens. Empty Data must still produce a stable empty string.
    class func deviceTokenHex(_ deviceToken: Data) -> String {
        return deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }.joined()
    }

    /// Soft-read the banner subtitle from a remote-notification payload.
    /// String alerts and APNS dictionary alerts (`body` / `title` / `subtitle`) are accepted.
    /// Missing `aps`, empty text, and loc-key-only dictionaries skip the banner.
    class func pushAlertText(from userInfo: [AnyHashable : Any]) -> String? {
        let aps: NSDictionary?
        if let dict = userInfo["aps"] as? NSDictionary {
            aps = dict
        } else if let dict = userInfo["aps"] as? [String: Any] {
            aps = dict as NSDictionary
        } else {
            aps = nil
        }
        guard let aps = aps else {
            return nil
        }
        return nonEmptyAlertText(aps.object(forKey: "alert"))
    }

    /// APNS `alert` is either a string or `{title, body, subtitle}`. Prefer body for the banner.
    class func nonEmptyAlertText(_ alert: Any?) -> String? {
        if let text = alert as? String, text.characters.count > 0 {
            return text
        }
        let dict: NSDictionary?
        if let ns = alert as? NSDictionary {
            dict = ns
        } else if let swift = alert as? [String: Any] {
            dict = swift as NSDictionary
        } else {
            dict = nil
        }
        guard let dict = dict else {
            return nil
        }
        for key in ["body", "title", "subtitle"] {
            if let text = dict.object(forKey: key) as? String, text.characters.count > 0 {
                return text
            }
        }
        return nil
    }

    /// Walk the presented/tab/nav hierarchy to find the portrait shell that owns openSwapView.
    func portraitNavigationController(from root: UIViewController?) -> HulaPortraitNavigationController? {
        if let portraitNav = root as? HulaPortraitNavigationController {
            return portraitNav
        }
        if let nav = root as? UINavigationController {
            if let portraitNav = nav as? HulaPortraitNavigationController {
                return portraitNav
            }
            for child in nav.viewControllers {
                if let found = portraitNavigationController(from: child) {
                    return found
                }
            }
        }
        if let tab = root as? UITabBarController {
            if let found = portraitNavigationController(from: tab.selectedViewController) {
                return found
            }
            for child in tab.viewControllers ?? [] {
                if let found = portraitNavigationController(from: child) {
                    return found
                }
            }
        }
        for child in root?.childViewControllers ?? [] {
            if let found = portraitNavigationController(from: child) {
                return found
            }
        }
        return nil
    }
}

