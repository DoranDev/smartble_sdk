////
////  AppDelegate.swift
////  blesdk3
////
////  Created by Best Mafen on 2019/9/5.
////  Copyright © 2019 szabh. All rights reserved.
////
//
//import UIKit
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    var window: UIWindow?
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        BleConnector.shared.launch()
//        BleConnector.shared.addBleHandleDelegate(String(obj: self), self)
//       // ABHBackgroundMonitoring.share.startListening()
//        return true
//    }
//
//    func applicationWillResignActive(_ application: UIApplication) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//    }
//
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    }
//
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
////        ABHBackgroundMonitoring.share.stopListening()
//    }
//
//    func applicationWillTerminate(_ application: UIApplication) {
//        BleConnector.shared.removeBleHandleDelegate(String(obj: self))
//    }
//
//}
//
//extension AppDelegate: BleHandleDelegate {
//
//    func onSessionStateChange(_ status: Bool) {
//        if status {
//            _ = BleConnector.shared.sendObject(BleKey.TIME_ZONE, BleKeyFlag.UPDATE, BleTimeZone())
//            _ = BleConnector.shared.sendObject(BleKey.TIME, BleKeyFlag.UPDATE, BleTime.local())
//            _ = BleConnector.shared.sendData(BleKey.POWER, BleKeyFlag.READ)
//            _ = BleConnector.shared.sendData(BleKey.FIRMWARE_VERSION, BleKeyFlag.READ)
//        }
//    }
//}
//
