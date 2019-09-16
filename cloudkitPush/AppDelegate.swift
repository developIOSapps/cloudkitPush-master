//
//  AppDelegate.swift
//  cloudkitPush
//
//  Created by Soulchild on 27/09/2018.
//  Copyright © 2018 fluffy. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        

        UNUserNotificationCenter.current().delegate = self.window?.rootViewController as! ViewController
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { authorized, error in
            if authorized {
                DispatchQueue.main.async(execute: { application.registerForRemoteNotifications() })
            }
        }
        
        // When the app launch after user tap on notification (originally was not running / not in background)
        if(launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil){
            print("* * * * *  In the if UIApplicationLaunchOptionsKey")
        }
        
        return true
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        deleteSubscriptions()
        
    }

    
    fileprivate func registerNotificationNotification() {
        //      let subscription = CKQuerySubscription(recordType: "Notifications", predicate: NSPredicate(format: "title = 'st01'"), options: .firesOnRecordCreation)
        let subscription = CKQuerySubscription(recordType: "Notifications", predicate: NSPredicate(format: "TRUEPREDICATE"), options: [.firesOnRecordCreation, .firesOnRecordDeletion] )
        
        let notificationInfoWithAlert: CKNotificationInfo = {
            let notificationInfoWithAlert = CKNotificationInfo()
            notificationInfoWithAlert.titleLocalizationKey = "%1$@"
            notificationInfoWithAlert.titleLocalizationArgs = ["title"]
            notificationInfoWithAlert.alertLocalizationKey = "%1$@"
            notificationInfoWithAlert.alertLocalizationArgs = ["content"]
            notificationInfoWithAlert.shouldBadge = true
            notificationInfoWithAlert.soundName = "default"
            return notificationInfoWithAlert
        }()
        
        let notificationInfoSilent: CKNotificationInfo = {
            let notificationInfoSilent = CKNotificationInfo()
            notificationInfoSilent.shouldSendContentAvailable = true
            return notificationInfoSilent
        }()
        
        
        subscription.notificationInfo = notificationInfoSilent
        
        
        //     CKContainer.default().publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
        
        CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
            if error == nil
            { print(" Subscription saved successfully") }
            else
            { print("error saving subscription", error?.localizedDescription) }
        }
        )
    }
    fileprivate func registerLoginNotification() {
        
        let subscription = CKQuerySubscription(recordType: "Logins", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)
        
        let notificationInfoWithAlert = CKNotificationInfo()
        
        // this will use the 'title' field in the Record type 'notifications' as the title of the push notification
//        info.titleLocalizationKey = "%1$@"
//        info.titleLocalizationArgs = ["student"]
        
        // if you want to use multiple field combined for the title of push notification
        // info.titleLocalizationKey = "%1$@ %2$@" // if want to add more, the format will be "%3$@" and so on
        // info.titleLocalizationArgs = ["title", "subtitle"]
        
        // this will use the 'content' field in the Record type 'notifications' as the content of the push notification
        notificationInfoWithAlert.alertLocalizationKey = "%1$@"
        notificationInfoWithAlert.alertLocalizationArgs = ["student"]
        
        // use system default notification sound
        notificationInfoWithAlert.soundName = "default"
        notificationInfoWithAlert.shouldSendMutableContent = true
        
        let inf = CKNotificationInfo()
        inf.shouldSendMutableContent = true
        inf.shouldSendContentAvailable = true
        subscription.notificationInfo = inf
        
        
        CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                print(" Subscription saved successfully")
            } else {
                print("error saving subscription", error?.localizedDescription)
            }
        })
    }
    
    func deleteSubscriptions() {
        
        let db = CKContainer(identifier: "iCloud.com.dia.cloudKitExample.open").publicCloudDatabase
        
        DispatchQueue.global().sync {
            db.fetchAllSubscriptions { [unowned self] subscriptions, error in
                if error == nil {
                    if let subscriptions = subscriptions {
                        for subscription in subscriptions {
                            db.delete(withSubscriptionID: subscription.subscriptionID) { str, error in
                                if error != nil {
                                    // do your error handling here!
                                    print(error!.localizedDescription)
                                    fatalError("error deleting subscriptions")
                                } else {
                                    print("deleted subscription")
                                }
                            }
                        }
                        
                        self.registerNotificationNotification()
                        self.registerLoginNotification()
                        
                    }
                } else {
                    // do your error handling here!
                    print(error!.localizedDescription)
                }

        }
         }
    }
    
}


extension AppDelegate: UNUserNotificationCenterDelegate{
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        
//        let application = UIApplication.shared
//        
//        if(application.applicationState == .active){
//            print("app received notification while in foreground")
//        }
//        
//        // show the notification alert (banner), and with sound
//        completionHandler([.alert, .sound])
//    }
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let application = UIApplication.shared
//        
//        if(application.applicationState == .active){
//            print("user tapped the notification bar when the app is in foreground")
//        }
//        
//        if(application.applicationState == .inactive)
//        {
//            print("user tapped the notification bar when the app is in background")
//        }
//        
//        // tell the app that we have finished processing the user’s action / response
//        completionHandler()
//    }
//    
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
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("* * * * * didReceiveRemoteNotification - We received a remote notification")
        
        if let ckDict = userInfo["ck"] as? [AnyHashable : Any] {
            if let qryDict = ckDict["qry"] as? [AnyHashable : Any] {
                for (key, value) in qryDict {
                    print(key as! NSString)
                    if let item = value as? NSNumber {
                        print(item)
                    }
                    if let item = value as? NSString {
                        print(item)
                    }
                }
                //            if let alert = ["alert"] as? NSDictionary {
                //                if let message = alert["message"] as? NSString {
                //                    //Do stuff
                //                }
                //            } else if let alert = aps["alert"] as? NSString {
                //                //Do stuff
                //            }
            }
        }
        
        dump(userInfo)
        
        
        guard let _ = CKNotification(fromRemoteNotificationDictionary: userInfo) as? CKDatabaseNotification else { return }
        
        completionHandler(.newData)
        
        
        
//        appData.checkUpdates(finishClosure: { (result) in
//            let mainQueue = OperationQueue.main
//            mainQueue.addOperation({
//                completionHandler(result)
//            })
//        })
//

    }
    

}

